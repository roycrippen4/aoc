const std = @import("std");
const Allocator = std.mem.Allocator;
const Point = @import("point.zig").Point;

/// Errors associated with the `grid` module
pub const Error = error{ OutOfMemory, InvalidArgument };

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Entry = std.meta.Tuple(.{ usize, usize, T });

        /// Contents of the grid. This field is intended to be accessed
        /// directly.
        ///
        /// Pointers to elements in this slice are invalidated by various
        /// functions of this Grid in accordance with the respective
        /// documentation. In all cases, "invalidated" means that the memory
        /// has been passed to this allocator's resize or free function.
        inner: []T,

        /// How many T values this list can hold without allocating
        /// additional memory.
        gpa: Allocator,

        /// Width of the grid
        width: usize,
        /// Height of the grid
        height: usize,

        /// Initialize the grid
        pub fn init(gpa: Allocator, width: usize, height: usize) Error!Self {
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
        pub fn init_with_default(gpa: Allocator, default: T, width: usize, height: usize) Error!Self {
            const self = try init(gpa, width, height);

            for (self.inner) |*item| {
                item.* = default;
            }

            return self;
        }

        /// Creates a grid from a string.
        /// Lines must be separated by `\n` and have a consistent width;
        pub fn from_string(gpa: Allocator, str: []const u8) !Self {
            var lines = std.mem.splitScalar(u8, str, '\n');
            const first = lines.next() orelse return Error.InvalidArgument;
            const width = first.len;

            if (width == 0) return Error.InvalidArgument;

            var height: usize = 1;
            while (lines.next() != null) {
                height += 1;
            }

            var self = try Self.init(gpa, width, height);
            errdefer self.deinit();

            lines.reset();
            for (0..height) |y| {
                const line = lines.next().?;
                if (line.len != width) {
                    return Error.InvalidArgument;
                }

                for (line, 0..) |c, x| {
                    self.set(.{ .x = x, .y = y }, @as(T, @intCast(c)));
                }
            }
        }

        /// Creates a new `Grid` by rotating the provided grid 90° clockwise
        pub fn rotate_clockwise(_: Self, gpa: Allocator) Self {
            const g = try Self.init(gpa);
            return g;
        }

        /// Free memory. Important: pointers derived from `self.items` become invalid.
        pub fn deinit(self: *Self) void {
            if (@sizeOf(T) > 0) {
                self.gpa.free(self.inner);
            }

            self.* = undefined;
        }

        // ==========================================================
        // ===================== Immutable API ======================
        // ==========================================================

        /// Determine if the grid contains the given position
        pub fn inside(self: Self, pos: Point) bool {
            return pos.x < self.width and pos.y < self.height;
        }

        /// Returns some value at `(x, y)` or `null` if it doesn't exist
        pub fn get_opt(self: *const Self, pos: Point) ?T {
            return if (self.get_opt_mut(pos)) |ptr| ptr.* else return null;
        }

        /// Returns the value at `(x, y)` without checking grid bounds
        pub fn get(self: *const Self, pos: Point) T {
            return self.inner[self.idx(pos)];
        }

        /// Calculates the index into the one-dimensional
        /// data slice when given a (x, y) coordinate pair.
        pub fn idx(self: Self, pos: Point) usize {
            return pos.y * self.width + pos.x;
        }

        /// Returns the values of the 4 cardinal neighbors around a point.
        /// Null if a neighbor is out of bounds.
        pub fn nbor4(self: *const Self, p: Point) [4]?T {
            return .{
                self.get_opt(p.north()),
                self.get_opt(p.east()),
                self.get_opt(p.south()),
                self.get_opt(p.west()),
            };
        }

        /// Returns the values of the 8 surrounding neighbors around a point.
        /// Null if a neighbor is out of bounds.
        pub fn nbor8(self: *const Self, p: Point) [4]?T {
            return .{
                self.get_opt(p.north()),
                self.get_opt(p.northeast()),
                self.get_opt(p.east()),
                self.get_opt(p.southeast()),
                self.get_opt(p.south()),
                self.get_opt(p.southwest()),
                self.get_opt(p.west()),
                self.get_opt(p.northwest()),
            };
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
                for (0..self.wdith) |x| {
                    const p = Point.init(x, y);
                    if (predicate(p, self.get(p))) {
                        return p;
                    }
                }
            }
            return null;
        }

        // ==========================================================
        // ===================== Mutable API ========================
        // ==========================================================

        /// Returns a pointer to the value at `pos`. Assumes `pos` is within grid bounds.
        fn get_mut(self: *const Self, pos: Point) *T {
            return &self.inner[self.idx(pos)];
        }

        /// Returns a pointer to some value at `(x, y)` or `null` if it doesn't exist
        pub fn get_opt_mut(self: *const Self, pos: Point) ?*T {
            return if (self.inside(pos)) &self.inner[self.idx(pos)] else null;
        }

        /// Sets the value at `pos`. Assumes `pos` is within grid bounds.
        pub fn set(self: *Self, pos: Point, value: T) void {
            self.inner[self.idx(pos)] = value;
        }

        // /// Returns a new grid after applying `f` to all elements of the original.
        // /// Does not mutate original grid.
        // fn map(self: Self, f: fn (Point, T) T) Error!Self {
        //     const copy = try Self.init(self.gpa, self.width, self.height);
        //     errdefer copy.deinit();
        //
        //     for (0..copy.height) |y| {
        //         for (0..copy.width) |x| {
        //             const pos = Point.init(x, y);
        //             const i = self.idx(pos);
        //             copy.inner[i] = f(pos, self.inner[i]);
        //         }
        //     }
        //
        //     return copy;
        // }

        /// Applies the function `f` to each coordinate `p` in the `grid`, replacing the original value
        pub fn map_coords_mut(self: *Self, f: fn (Point, T) T) void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    const pos = Point.init(x, y);
                    const i = self.idx(pos);
                    self.inner[i] = f(pos, self.inner[i]);
                }
            }
        }

        // /// Applies the function `f` to each entry in the `Grid`, producing a new `Grid`
        // pub fn map(self: Self, comptime U: type, f: fn (Entry) U) Grid(U) {
        // }

        /// Best-effort pretty printing of the grid to stdout
        fn print(self: *Self) void {
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

            const size = self.width * self.height;
            if (size > 0 and size % self.width != 0) {
                std.debug.print("\n", .{});
            }
        }
    };
}

const t = std.testing;

fn sum(p: Point, _: u16) u16 {
    return @intCast(p.x + p.y);
}

test "grid Grid init" {
    var grid = try Grid(u16).init(t.allocator, 5, 5);
    defer grid.deinit();

    grid.map_coords_mut(sum);

    try t.expectEqual(@as(usize, 25), grid.inner.len);
    try t.expectEqual(@as(usize, 5), grid.width);
    try t.expectEqual(@as(usize, 5), grid.height);
    try t.expectEqual(@as(usize, 25), grid.width * grid.height);

    const val = grid.get_opt(.{ .x = 4, .y = 4 });
    try t.expect(val != null);
    try t.expectEqual(@as(u16, 8), val.?); // 4 + 4 = 8
}

test "grid init argument errors" {
    try t.expectError(Error.InvalidArgument, Grid(u8).init(t.allocator, 0, 5));
    try t.expectError(Error.InvalidArgument, Grid(u8).init(t.allocator, 5, 0));
    try t.expectError(Error.InvalidArgument, Grid(u8).init(t.allocator, 0, 0));
    try t.expectError(Error.InvalidArgument, Grid(u8).init_with_default(t.allocator, 0, 0, 5));
    try t.expectError(Error.InvalidArgument, Grid(u8).init_with_default(t.allocator, 0, 5, 0));
}

test "grid init_with_default" {
    var grid = try Grid(usize).init_with_default(t.allocator, 420, 5, 5);
    defer grid.deinit();
    try t.expectEqual(@as(usize, 25), grid.inner.len);
    try t.expectEqual(@as(usize, 420), grid.inner[0]); // Check first
    try t.expectEqual(@as(usize, 420), grid.inner[12]); // Check middle
    try t.expectEqual(@as(usize, 420), grid.inner[24]); // Check last
    try t.expectEqual(@as(usize, 420), grid.get(.{ .x = 2, .y = 2 })); // Use get
}

test "grid idx function" {
    const W = 7;
    const H = 3;

    const dummy_grid = Grid(u8){
        .inner = &[_]u8{}, // Doesn't matter for idx
        .gpa = undefined, // Not needed
        .width = W,
        .height = H,
    };

    try t.expectEqual(@as(usize, 0), dummy_grid.idx(.{ .x = 0, .y = 0 })); // Top-left
    try t.expectEqual(@as(usize, 6), dummy_grid.idx(.{ .x = 6, .y = 0 })); // Top-right
    try t.expectEqual(@as(usize, 7), dummy_grid.idx(.{ .x = 0, .y = 1 })); // Start of second row
    try t.expectEqual(@as(usize, 10), dummy_grid.idx(.{ .x = 3, .y = 1 })); // Middle
    try t.expectEqual(@as(usize, 14), dummy_grid.idx(.{ .x = 0, .y = 2 })); // Bottom-left
    try t.expectEqual(@as(usize, 20), dummy_grid.idx(.{ .x = 6, .y = 2 })); // Bottom-right
}

test "grid inside function" {
    const W = 5;
    const H = 4;
    const dummy_grid = Grid(u8){
        .inner = &[_]u8{},
        .gpa = undefined,
        .width = W,
        .height = H,
    };

    // Inside
    try t.expect(dummy_grid.inside(.{ .x = 0, .y = 0 }));
    try t.expect(dummy_grid.inside(.{ .x = 4, .y = 3 }));
    try t.expect(dummy_grid.inside(.{ .x = 2, .y = 1 }));

    // Outside (edges)
    try t.expect(!dummy_grid.inside(.{ .x = 5, .y = 0 }));
    try t.expect(!dummy_grid.inside(.{ .x = 0, .y = 4 }));
    try t.expect(!dummy_grid.inside(.{ .x = 5, .y = 4 }));

    // Outside (beyond)
    try t.expect(!dummy_grid.inside(.{ .x = 10, .y = 2 }));
    try t.expect(!dummy_grid.inside(.{ .x = 2, .y = 10 }));
    try t.expect(!dummy_grid.inside(.{ .x = 10, .y = 10 }));
}

test "grid get, get_opt, get_ptr, get_opt_ptr, set" {
    const W = 3;
    const H = 2;
    var grid = try Grid(u16).init(t.allocator, W, H);
    defer grid.deinit();
    grid.map_coords_mut(sum);

    try t.expectEqual(@as(u16, 0), grid.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u16, 2), grid.get(.{ .x = 2, .y = 0 }));
    try t.expectEqual(@as(u16, 1), grid.get(.{ .x = 0, .y = 1 }));
    try t.expectEqual(@as(u16, 3), grid.get(.{ .x = 2, .y = 1 }));
    try t.expectEqual(@as(u16, 0), grid.get_opt(.{ .x = 0, .y = 0 }).?);
    try t.expectEqual(@as(u16, 2), grid.get_opt(.{ .x = 2, .y = 0 }).?);
    try t.expectEqual(@as(u16, 1), grid.get_opt(.{ .x = 0, .y = 1 }).?);
    try t.expectEqual(@as(u16, 3), grid.get_opt(.{ .x = 2, .y = 1 }).?);
    try t.expectEqual(null, grid.get_opt(.{ .x = 3, .y = 0 })); // Out of bounds X
    try t.expectEqual(null, grid.get_opt(.{ .x = 0, .y = 2 })); // Out of bounds Y
    try t.expectEqual(null, grid.get_opt(.{ .x = 3, .y = 2 })); // Out of bounds X and Y
    try t.expectEqual(null, grid.get_opt(.{ .x = 99, .y = 99 })); // Far out of bounds

    const ptr1 = grid.get_mut(.{ .x = 1, .y = 1 });
    try t.expectEqual(@as(u16, 2), ptr1.*);
    ptr1.* = 99;
    try t.expectEqual(@as(u16, 99), grid.get(.{ .x = 1, .y = 1 }));

    const ptr2 = grid.get_opt_mut(.{ .x = 0, .y = 0 });
    try t.expect(ptr2 != null);
    try t.expectEqual(@as(u16, 0), ptr2.?.*);
    ptr2.?.* = 111;
    try t.expectEqual(@as(u16, 111), grid.get(.{ .x = 0, .y = 0 }));

    const ptr_null = grid.get_opt_mut(.{ .x = W, .y = 0 }); // Out of bounds
    try t.expect(ptr_null == null);

    grid.set(.{ .x = 2, .y = 1 }, 222);
    try t.expectEqual(@as(u16, 222), grid.get(.{ .x = 2, .y = 1 }));
}

test "grid map (non-mutating)" {
    var grid = try Grid(u16).init_with_default(t.allocator, 10, 3, 2);
    defer grid.deinit();

    const add_pos = struct {
        fn func(pos: Point, val: u16) u16 {
            const x: u16 = @intCast(pos.x);
            const y: u16 = @intCast(pos.y);
            return val + x + y;
        }
    }.func;

    var mapped_grid = try grid.map(add_pos);
    defer mapped_grid.deinit();

    try t.expectEqual(@as(u16, 10), grid.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u16, 10), grid.get(.{ .x = 2, .y = 1 }));
    try t.expectEqual(@as(u16, 10), mapped_grid.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u16, 11), mapped_grid.get(.{ .x = 1, .y = 0 }));
    try t.expectEqual(@as(u16, 12), mapped_grid.get(.{ .x = 2, .y = 0 }));
    try t.expectEqual(@as(u16, 11), mapped_grid.get(.{ .x = 0, .y = 1 }));
    try t.expectEqual(@as(u16, 12), mapped_grid.get(.{ .x = 1, .y = 1 }));
    try t.expectEqual(@as(u16, 13), mapped_grid.get(.{ .x = 2, .y = 1 }));

    try t.expectEqual(grid.width, mapped_grid.width);
    try t.expectEqual(grid.height, mapped_grid.height);
    try t.expect(grid.inner.ptr != mapped_grid.inner.ptr); // Ensure distinct memory
}

test "grid map_mut" {
    var grid = try Grid(u16).init(t.allocator, 5, 5);
    defer grid.deinit();
    grid.map_coords_mut(sum); // Test map_mut which uses idx internally
    try t.expectEqual(@as(usize, 25), grid.inner.len);
    try t.expectEqual(@as(u16, 0), grid.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u16, 8), grid.get(.{ .x = 4, .y = 4 }));
    try t.expectEqual(@as(u16, 4), grid.get(.{ .x = 1, .y = 3 }));
}

test "grid clone" {
    const width = 4;
    const height = 3;
    var original = try Grid(u16).init(t.allocator, width, height);
    defer original.deinit();
    original.map_coords_mut(sum); // Fill with initial values

    var cloned = try original.clone();
    defer cloned.deinit();

    try t.expectEqual(original.width, cloned.width);
    try t.expectEqual(original.height, cloned.height);
    try t.expectEqual(original.height * original.width, cloned.height * cloned.width);
    try t.expectEqual(original.inner.len, cloned.inner.len);
    try t.expect(original.inner.ptr != cloned.inner.ptr);
    try t.expect(std.mem.eql(u16, original.inner, cloned.inner));

    const change_pos_1 = Point{ .x = 1, .y = 1 };
    const original_value_1 = original.get(change_pos_1);
    cloned.set(change_pos_1, 99);
    try t.expectEqual(original_value_1, original.get(change_pos_1));
    try t.expectEqual(@as(u16, 99), cloned.get(change_pos_1));

    // Modify original, check clone unchanged
    const change_pos_2 = Point{ .x = 0, .y = 0 };
    const cloned_value_2 = cloned.get(change_pos_2);
    original.set(change_pos_2, 111);
    try t.expectEqual(cloned_value_2, cloned.get(change_pos_2));
    try t.expectEqual(@as(u16, 111), original.get(change_pos_2));
}

test "grid edge cases 1xN and Nx1" {
    // 1x5 Grid
    var grid1x5 = try Grid(u8).init_with_default(t.allocator, 1, 1, 5);
    defer grid1x5.deinit();
    try t.expectEqual(@as(usize, 1), grid1x5.width);
    try t.expectEqual(@as(usize, 5), grid1x5.height);
    try t.expectEqual(@as(usize, 5), grid1x5.width * grid1x5.height);
    grid1x5.set(.{ .x = 0, .y = 2 }, 99);
    try t.expectEqual(@as(u8, 1), grid1x5.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u8, 99), grid1x5.get(.{ .x = 0, .y = 2 }));
    try t.expectEqual(@as(u8, 1), grid1x5.get(.{ .x = 0, .y = 4 }));
    try t.expectEqual(null, grid1x5.get_opt(.{ .x = 1, .y = 0 })); // Out of bounds x
    try t.expectEqual(null, grid1x5.get_opt(.{ .x = 0, .y = 5 })); // Out of bounds y

    // 5x1 Grid
    var grid5x1 = try Grid(u8).init_with_default(t.allocator, 2, 5, 1);
    defer grid5x1.deinit();
    try t.expectEqual(@as(usize, 5), grid5x1.width);
    try t.expectEqual(@as(usize, 1), grid5x1.height);
    try t.expectEqual(@as(usize, 5), grid5x1.width * grid5x1.height);
    grid5x1.set(.{ .x = 3, .y = 0 }, 88);
    try t.expectEqual(@as(u8, 2), grid5x1.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u8, 88), grid5x1.get(.{ .x = 3, .y = 0 }));
    try t.expectEqual(@as(u8, 2), grid5x1.get(.{ .x = 4, .y = 0 }));
    try t.expectEqual(null, grid5x1.get_opt(.{ .x = 5, .y = 0 })); // Out of bounds x
    try t.expectEqual(null, grid5x1.get_opt(.{ .x = 0, .y = 1 })); // Out of bounds y
}
