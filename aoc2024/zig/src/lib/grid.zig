const std = @import("std");
const Allocator = std.mem.Allocator;
const Point = @import("point.zig").Point;

/// Errors associated with the `grid` module
pub const Error = error{ OutOfMemory, InvalidArgument };

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();

        inner: []T,

        gpa: Allocator,
        width: usize,
        height: usize,

        /// Initialize the grid
        pub fn new(gpa: Allocator, width: usize, height: usize) Error!Self {
            const size: usize = @intCast(width * height);
            if (width == 0 or height == 0) return Error.InvalidArgument;

            const buf = try gpa.alloc(T, size);
            errdefer gpa.free(buf);

            return Self{
                .inner = buf,
                .gpa = gpa,
                .width = width,
                .height = height,
            };
        }

        /// Initialize the grid with a default value
        pub fn make(gpa: Allocator, default: T, width: usize, height: usize) Error!Self {
            const self = try Self.new(gpa, width, height);

            for (self.inner) |*item| {
                item.* = default;
            }

            return self;
        }

        /// Create a new grid by applying the `f` to each point in the grid
        pub fn make_with(gpa: Allocator, width: usize, height: usize, f: fn (Point, T) T) !Self {
            var self = try Self.new(gpa, width, height);
            self.map_mut(f);

            return self;
        }

        pub fn from_string(gpa: Allocator, str: []const u8) !Grid(u8) {
            comptime {
                if (T != u8) {
                    @compileError("from_string is only available for Grid(u8)");
                }
            }

            var lines = std.mem.splitScalar(u8, str, '\n');
            const first = lines.next() orelse return Error.InvalidArgument;
            const width = first.len;

            if (width == 0) return Error.InvalidArgument;

            var height: usize = 1;
            while (lines.next() != null) {
                height += 1;
            }

            var self = try Grid(u8).new(gpa, width, height);
            errdefer self.deinit();

            lines.reset();
            var y: usize = 0;
            while (lines.next()) |line| {
                if (line.len != width) {
                    return Error.InvalidArgument;
                }

                for (line, 0..) |c, x| {
                    self.set(.{ .x = x, .y = y }, c);
                }

                y += 1;
            }

            return self;
        }

        pub fn from_string_generic(gpa: Allocator, str: []const u8, mapfn: fn (u8) T) !Grid(T) {
            var lines = std.mem.splitScalar(u8, str, '\n');
            const first = lines.next() orelse return Error.InvalidArgument;
            const width = first.len;

            if (width == 0) return Error.InvalidArgument;

            var height: usize = 1;
            while (lines.next() != null) {
                height += 1;
            }

            var self = try Grid(T).new(gpa, width, height);
            errdefer self.deinit();

            lines.reset();
            var y: usize = 0;
            while (lines.next()) |line| {
                if (line.len != width) {
                    return Error.InvalidArgument;
                }

                for (line, 0..) |c, x| {
                    self.set(.{ .x = x, .y = y }, mapfn(c));
                }

                y += 1;
            }

            return self;
        }

        /// Free memory. Important: pointers derived from `self.items` become invalid.
        pub fn deinit(self: *Self) void {
            if (@sizeOf(T) > 0) {
                self.gpa.free(self.inner);
            }

            self.* = undefined;
        }

        /// Determine if the grid contains the given position
        pub fn inside(self: Self, pos: Point) bool {
            return pos.x < self.width and pos.y < self.height;
        }

        /// Returns some value at `(x, y)` or `null` if it doesn't exist
        pub fn get_opt(self: *const Self, pos: Point) ?T {
            return if (self.inside(pos)) self.inner[self.idx(pos)] else null;
        }

        /// Returns the value at `(x, y)` without checking grid bounds
        pub fn get(self: *const Self, pos: Point) T {
            return self.inner[self.idx(pos)];
        }

        /// Returns a pointer to some value at `(x, y)` or `null` if it doesn't exist
        pub fn get_opt_mut(self: *Self, pos: Point) ?*T {
            return if (self.inside(pos)) &self.inner[self.idx(pos)] else null;
        }

        /// Returns a pointer to the value at `pos`.
        /// Assumes `pos` is within grid bounds.
        fn get_mut(self: *Self, pos: Point) *T {
            return &self.inner[self.idx(pos)];
        }

        /// Sets the value at `pos`. Assumes `pos` is within grid bounds.
        pub fn set(self: *Self, pos: Point, value: T) void {
            self.inner[self.idx(pos)] = value;
        }

        /// Calculates the index into the one-dimensional
        /// data slice when given a (x, y) coordinate pair.
        pub fn idx(self: Self, pos: Point) usize {
            return pos.y * self.width + pos.x;
        }

        /// Creates a copy of the grid, using the same allocator.
        pub fn clone(self: Self) Error!Self {
            const buf = try self.gpa.alloc(T, self.width * self.height);
            errdefer self.gpa.free(buf);
            @memcpy(buf, self.inner);
            return Self{
                .inner = buf,
                .gpa = self.gpa,
                .width = self.width,
                .height = self.height,
            };
        }

        /// Searches for the first element's position that satisfies the predicate
        pub fn find(self: *const Self, comptime predicate: fn (Point, T) bool) ?Point {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    const p = Point.init(x, y);
                    if (predicate(p, self.get(p))) {
                        return p;
                    }
                }
            }
            return null;
        }

        /// Best-effort pretty printing of the grid to stdout
        pub fn print(self: *const Self) void {
            const print_as_chars = T == u8;
            const w_minus_1 = self.width - 1;

            var buf: [256]u8 = undefined;
            for (self.inner, 0..) |item, i| {
                const str = switch (print_as_chars) {
                    true => std.fmt.bufPrint(&buf, "{c} ", .{item}) catch unreachable,
                    false => std.fmt.bufPrint(&buf, "{d} ", .{item}) catch unreachable,
                };

                std.debug.print("{s}", .{str});
                if (i % self.width == w_minus_1) {
                    std.debug.print("\n", .{});
                }
            }
        }

        /// Creates a new `Grid(U)` from a `Grid(T)` by applying
        /// the function `f(Entry(U))` to each element in the input `Grid`.
        pub fn map(self: *const Self, comptime U: type, f: fn (Point, T) U) !Grid(U) {
            var g = try Grid(U).new(self.gpa, self.width, self.height);

            for (0..g.height) |y| {
                for (0..g.width) |x| {
                    const p = Point.init(x, y);
                    const old_v = self.get(p);
                    const new_v = f(p, old_v);
                    g.set(p, new_v);
                }
            }

            return g;
        }

        /// Applies a function to each element of the grid, mutating it in place.
        pub fn map_mut(self: *Self, f: fn (Point, T) T) void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    const p = Point.init(x, y);
                    const i = self.idx(p);
                    self.inner[i] = f(p, self.inner[i]);
                }
            }
        }

        /// Rotates a square grid 90 degrees clockwise in-place.
        /// Asserts that the grid is square.
        pub fn transpose_clockwise(self: *Self) void {
            std.debug.assert(self.width == self.height);
            const N = self.width;
            if (N == 0) return;
            const n_minus_1 = N - 1;

            for (0..N / 2) |y| {
                for (y..n_minus_1 - y) |x| {
                    const idx1 = y * N + x;
                    const idx2 = x * N + (n_minus_1 - y);
                    const idx3 = (n_minus_1 - y) * N + (n_minus_1 - x);
                    const idx4 = (n_minus_1 - x) * N + y;

                    const temp = self.inner[idx1];
                    self.inner[idx1] = self.inner[idx4];
                    self.inner[idx4] = self.inner[idx3];
                    self.inner[idx3] = self.inner[idx2];
                    self.inner[idx2] = temp;
                }
            }
        }

        /// Rotates a square grid 90 degrees counter-clockwise in-place.
        /// Asserts that the grid is square.
        pub fn transpose_counter_clockwise(self: *Self) void {
            std.debug.assert(self.width == self.height);
            const N = self.width;
            if (N == 0) return;
            const n_minus_1 = N - 1;

            for (0..N / 2) |y| {
                for (y..n_minus_1 - y) |x| {
                    const idx1 = y * N + x;
                    const idx2 = x * N + (n_minus_1 - y);
                    const idx3 = (n_minus_1 - y) * N + (n_minus_1 - x);
                    const idx4 = (n_minus_1 - x) * N + y;

                    const temp = self.inner[idx1];
                    self.inner[idx1] = self.inner[idx2];
                    self.inner[idx2] = self.inner[idx3];
                    self.inner[idx3] = self.inner[idx4];
                    self.inner[idx4] = temp;
                }
            }
        }
    };
}

const t = std.testing;

fn sum(p: Point, _: u16) u16 {
    return @intCast(p.x + p.y);
}

test "grid new" {
    var grid = try Grid(u16).make_with(t.allocator, 5, 5, sum);
    defer grid.deinit();

    try t.expectEqual(@as(usize, 25), grid.inner.len);
    try t.expectEqual(@as(usize, 5), grid.width);
    try t.expectEqual(@as(usize, 5), grid.height);
    try t.expectEqual(@as(usize, 25), grid.width * grid.height);

    const val = grid.get_opt(.{ .x = 4, .y = 4 });
    try t.expect(val != null);
    try t.expectEqual(@as(u16, 8), val.?); // 4 + 4 = 8
}

test "grid new argument errors" {
    try t.expectError(Error.InvalidArgument, Grid(u8).new(t.allocator, 0, 5));
    try t.expectError(Error.InvalidArgument, Grid(u8).new(t.allocator, 5, 0));
    try t.expectError(Error.InvalidArgument, Grid(u8).new(t.allocator, 0, 0));
    try t.expectError(Error.InvalidArgument, Grid(u8).make(t.allocator, 0, 0, 5));
    try t.expectError(Error.InvalidArgument, Grid(u8).make(t.allocator, 0, 5, 0));
}

test "grid make" {
    var grid = try Grid(usize).make(t.allocator, 420, 5, 5);
    defer grid.deinit();
    try t.expectEqual(@as(usize, 25), grid.inner.len);
    try t.expectEqual(@as(usize, 420), grid.inner[0]); // Check first
    try t.expectEqual(@as(usize, 420), grid.inner[12]); // Check middle
    try t.expectEqual(@as(usize, 420), grid.inner[24]); // Check last
    try t.expectEqual(@as(usize, 420), grid.get(.{ .x = 2, .y = 2 })); // Use get
}

test "grid idx" {
    const dummy_grid = Grid(u8){
        .inner = &[_]u8{}, // Doesn't matter for idx
        .gpa = undefined, // Not needed
        .width = 7,
        .height = 3,
    };

    try t.expectEqual(@as(usize, 0), dummy_grid.idx(Point.init(0, 0))); // Top-left
    try t.expectEqual(@as(usize, 6), dummy_grid.idx(Point.init(6, 0))); // Top-right
    try t.expectEqual(@as(usize, 7), dummy_grid.idx(Point.init(0, 1))); // Start of second row
    try t.expectEqual(@as(usize, 10), dummy_grid.idx(Point.init(3, 1))); // Middle
    try t.expectEqual(@as(usize, 14), dummy_grid.idx(Point.init(0, 2))); // Bottom-left
    try t.expectEqual(@as(usize, 20), dummy_grid.idx(Point.init(6, 2))); // Bottom-right
}

test "grid inside function" {
    const dummy_grid = Grid(u8){
        .inner = &[_]u8{},
        .gpa = undefined,
        .width = 5,
        .height = 4,
    };

    // Inside
    try t.expect(dummy_grid.inside(Point.init(0, 0)));
    try t.expect(dummy_grid.inside(Point.init(4, 3)));
    try t.expect(dummy_grid.inside(Point.init(2, 1)));

    // Outside (edges)
    try t.expect(!dummy_grid.inside(Point.init(5, 0)));
    try t.expect(!dummy_grid.inside(Point.init(0, 4)));
    try t.expect(!dummy_grid.inside(Point.init(5, 4)));

    // Outside (beyond)
    try t.expect(!dummy_grid.inside(.{ .x = 10, .y = 2 }));
    try t.expect(!dummy_grid.inside(.{ .x = 2, .y = 10 }));
    try t.expect(!dummy_grid.inside(.{ .x = 10, .y = 10 }));
}

test "grid get, get_opt, get_ptr, get_opt_ptr, set" {
    var grid = try Grid(u16).make_with(t.allocator, 3, 2, sum);
    defer grid.deinit();

    try t.expectEqual(@as(u16, 0), grid.get(Point.init(0, 0)));
    try t.expectEqual(@as(u16, 2), grid.get(Point.init(2, 0)));
    try t.expectEqual(@as(u16, 1), grid.get(Point.init(0, 1)));
    try t.expectEqual(@as(u16, 3), grid.get(Point.init(2, 1)));
    try t.expectEqual(@as(u16, 0), grid.get_opt(Point.init(0, 0)).?);
    try t.expectEqual(@as(u16, 2), grid.get_opt(Point.init(2, 0)).?);
    try t.expectEqual(@as(u16, 1), grid.get_opt(Point.init(0, 1)).?);
    try t.expectEqual(@as(u16, 3), grid.get_opt(Point.init(2, 1)).?);
    try t.expectEqual(null, grid.get_opt(Point.init(3, 0))); // Out of bounds X
    try t.expectEqual(null, grid.get_opt(Point.init(0, 2))); // Out of bounds Y
    try t.expectEqual(null, grid.get_opt(Point.init(3, 2))); // Out of bounds X and Y
    try t.expectEqual(null, grid.get_opt(.{ .x = 99, .y = 99 })); // Far out of bounds

    const ptr1 = grid.get_mut(Point.init(1, 1));
    try t.expectEqual(@as(u16, 2), ptr1.*);
    ptr1.* = 99;
    try t.expectEqual(@as(u16, 99), grid.get(Point.init(1, 1)));

    const ptr2 = grid.get_opt_mut(Point.init(0, 0));
    try t.expect(ptr2 != null);
    try t.expectEqual(@as(u16, 0), ptr2.?.*);
    ptr2.?.* = 111;
    try t.expectEqual(@as(u16, 111), grid.get(Point.init(0, 0)));

    const ptr_null = grid.get_opt_mut(Point.init(3, 0)); // Out of bounds
    try t.expect(ptr_null == null);

    grid.set(Point.init(2, 1), 222);
    try t.expectEqual(@as(u16, 222), grid.get(Point.init(2, 1)));
}

test "grid map (non-mutating)" {
    var grid = try Grid(u16).make(t.allocator, 10, 3, 2);
    defer grid.deinit();

    const add_pos = struct {
        fn func(pos: Point, val: u16) u16 {
            const x: u16 = @intCast(pos.x);
            const y: u16 = @intCast(pos.y);
            return val + x + y;
        }
    }.func;

    var mapped_grid = try grid.map(u16, add_pos);
    defer mapped_grid.deinit();

    try t.expectEqual(@as(u16, 10), grid.get(Point.init(0, 0)));
    try t.expectEqual(@as(u16, 10), grid.get(Point.init(2, 1)));
    try t.expectEqual(@as(u16, 10), mapped_grid.get(Point.init(0, 0)));
    try t.expectEqual(@as(u16, 11), mapped_grid.get(Point.init(1, 0)));
    try t.expectEqual(@as(u16, 12), mapped_grid.get(Point.init(2, 0)));
    try t.expectEqual(@as(u16, 11), mapped_grid.get(Point.init(0, 1)));
    try t.expectEqual(@as(u16, 12), mapped_grid.get(Point.init(1, 1)));
    try t.expectEqual(@as(u16, 13), mapped_grid.get(Point.init(2, 1)));

    try t.expectEqual(grid.width, mapped_grid.width);
    try t.expectEqual(grid.height, mapped_grid.height);
    try t.expect(grid.inner.ptr != mapped_grid.inner.ptr); // Ensure distinct memory
}

test "grid map_mut" {
    var grid = try Grid(u16).new(t.allocator, 5, 5);
    defer grid.deinit();
    grid.map_mut(sum); // Test map_mut which uses idx internally
    try t.expectEqual(@as(usize, 25), grid.inner.len);
    try t.expectEqual(@as(u16, 0), grid.get(Point.init(0, 0)));
    try t.expectEqual(@as(u16, 8), grid.get(Point.init(4, 4)));
    try t.expectEqual(@as(u16, 4), grid.get(Point.init(1, 3)));
}

test "grid clone" {
    const width = 4;
    const height = 3;
    var original = try Grid(u16).new(t.allocator, width, height);
    defer original.deinit();
    original.map_mut(sum); // Fill with initial values

    var cloned = try original.clone();
    defer cloned.deinit();

    try t.expectEqual(original.width, cloned.width);
    try t.expectEqual(original.height, cloned.height);
    try t.expectEqual(original.height * original.width, cloned.height * cloned.width);
    try t.expectEqual(original.inner.len, cloned.inner.len);
    try t.expect(original.inner.ptr != cloned.inner.ptr);
    try t.expect(std.mem.eql(u16, original.inner, cloned.inner));

    const change_pos_1 = Point.init(1, 1);
    const original_value_1 = original.get(change_pos_1);
    cloned.set(change_pos_1, 99);
    try t.expectEqual(original_value_1, original.get(change_pos_1));
    try t.expectEqual(@as(u16, 99), cloned.get(change_pos_1));

    // Modify original, check clone unchanged
    const change_pos_2 = Point.init(0, 0);
    const cloned_value_2 = cloned.get(change_pos_2);
    original.set(change_pos_2, 111);
    try t.expectEqual(cloned_value_2, cloned.get(change_pos_2));
    try t.expectEqual(@as(u16, 111), original.get(change_pos_2));
}

test "grid edge cases 1xN and Nx1" {
    // 1x5 Grid
    var grid1x5 = try Grid(u8).make(t.allocator, 1, 1, 5);
    defer grid1x5.deinit();
    try t.expectEqual(@as(usize, 1), grid1x5.width);
    try t.expectEqual(@as(usize, 5), grid1x5.height);
    try t.expectEqual(@as(usize, 5), grid1x5.width * grid1x5.height);
    grid1x5.set(Point.init(0, 2), 99);
    try t.expectEqual(@as(u8, 1), grid1x5.get(Point.init(0, 0)));
    try t.expectEqual(@as(u8, 99), grid1x5.get(Point.init(0, 2)));
    try t.expectEqual(@as(u8, 1), grid1x5.get(Point.init(0, 4)));
    try t.expectEqual(null, grid1x5.get_opt(Point.init(1, 0))); // Out of bounds x
    try t.expectEqual(null, grid1x5.get_opt(Point.init(0, 5))); // Out of bounds y

    // 5x1 Grid
    var grid5x1 = try Grid(u8).make(t.allocator, 2, 5, 1);
    defer grid5x1.deinit();
    try t.expectEqual(@as(usize, 5), grid5x1.width);
    try t.expectEqual(@as(usize, 1), grid5x1.height);
    try t.expectEqual(@as(usize, 5), grid5x1.width * grid5x1.height);
    grid5x1.set(Point.init(3, 0), 88);
    try t.expectEqual(@as(u8, 2), grid5x1.get(Point.init(0, 0)));
    try t.expectEqual(@as(u8, 88), grid5x1.get(Point.init(3, 0)));
    try t.expectEqual(@as(u8, 2), grid5x1.get(Point.init(4, 0)));
    try t.expectEqual(null, grid5x1.get_opt(Point.init(5, 0))); // Out of bounds x
    try t.expectEqual(null, grid5x1.get_opt(Point.init(0, 1))); // Out of bounds y
}

test "grid find" {
    var grid = try Grid(u16).make_with(t.allocator, 4, 3, sum);
    defer grid.deinit();

    const is_five = struct {
        fn p(_: Point, val: u16) bool {
            return val == 5;
        }
    }.p;

    const found = grid.find(is_five);
    try t.expect(found != null);
    try t.expectEqual(@as(usize, 3), found.?.x);
    try t.expectEqual(@as(usize, 2), found.?.y);

    const is_ten = struct {
        fn p(_: Point, val: u16) bool {
            return val == 10;
        }
    }.p;

    const not_found = grid.find(is_ten);
    try t.expect(not_found == null);
}

test "grid from_string" {
    const s =
        \\123
        \\456
        \\789
    ;

    var g = try Grid(u8).from_string(t.allocator, s);
    defer g.deinit();

    try t.expectEqual(g.get(Point.init(1, 1)), '5');
    try t.expectEqual(g.get(Point.init(2, 2)), '9');
}

test "grid transpose clockwise" {
    var expected = try Grid(u8).from_string(t.allocator,
        \\741
        \\852
        \\963
    );
    var actual = try Grid(u8).from_string(t.allocator,
        \\123
        \\456
        \\789
    );

    defer expected.deinit();
    defer actual.deinit();

    actual.transpose_clockwise();

    try t.expectEqualSlices(u8, expected.inner, actual.inner);
}

test "grid transpose counter clockwise" {
    var expected = try Grid(u8).from_string(t.allocator,
        \\369
        \\258
        \\147
    );
    var actual = try Grid(u8).from_string(t.allocator,
        \\123
        \\456
        \\789
    );

    defer expected.deinit();
    defer actual.deinit();

    actual.transpose_counter_clockwise();
    try t.expectEqualSlices(u8, expected.inner, actual.inner);
}

test "grid transpose round trip" {
    var g = try Grid(u8).from_string(t.allocator,
        \\123
        \\456
        \\789
    );
    defer g.deinit();

    var clone = try g.clone();
    defer clone.deinit();

    // Rotate 360 should be the same as the original
    clone.transpose_clockwise();
    clone.transpose_clockwise();
    clone.transpose_clockwise();
    clone.transpose_clockwise();

    try t.expectEqualSlices(u8, g.inner, clone.inner);

    // Rotate 90 clockwise, then 90 counter-clockwise should be the same as the original
    clone.transpose_clockwise();
    clone.transpose_counter_clockwise();
    try t.expectEqualSlices(u8, g.inner, clone.inner);
}

test "grid is generic" {
    // simple example type
    const Item = enum {
        x,
        o,
        other,

        const Self = @This();

        pub fn from_char(c: u8) Self {
            return switch (c) {
                'x' => Self.x,
                'o' => Self.o,
                else => Self.other,
            };
        }

        pub fn to_char(self: Self) u8 {
            return switch (self) {
                Self.x => 'x',
                Self.o => 'o',
                Self.other => '?',
            };
        }
    };

    const x = Item.from_char('x');
    const o = Item.from_char('o');
    const other = Item.from_char('1');

    try t.expectEqual(x, Item.x);
    try t.expectEqual(o, Item.o);
    try t.expectEqual(other, Item.other);

    try t.expectEqual(x.to_char(), 'x');
    try t.expectEqual(o.to_char(), 'o');
    try t.expectEqual(other.to_char(), '?');

    const s =
        \\xox
        \\oxo
        \\123
    ;

    var g = try Grid(Item).from_string_generic(t.allocator, s, Item.from_char);
    defer g.deinit();

    try t.expectEqual(Item.x, g.inner[0]);
    try t.expectEqual(Item.o, g.inner[1]);
    try t.expectEqual(Item.other, g.inner[8]);
}
