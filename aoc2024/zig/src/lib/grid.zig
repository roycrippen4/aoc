const std = @import("std");
const Allocator = std.mem.Allocator;

/// (x, y) coordinate pairs for the grid
pub const Position = struct { x: usize, y: usize };

/// Errors associated with the `grid` module
pub const Error = error{ OutOfMemory, InvalidArgument };

/// Eight cardinal directions
pub const Direction = enum {
    north,
    east,
    west,
    south,
    northeast,
    northwest,
    southeast,
    southwest,
};

fn move(direction: Direction, pos: Position) Position {
    return switch (direction) {
        .north => .{ .x = pos.x, .y = pos.y -% 1 },
        .south => .{ .x = pos.x, .y = pos.y + 1 },
        .west => .{ .x = pos.x -% 1, .y = pos.y },
        .east => .{ .x = pos.x + 1, .y = pos.y },
        .northwest => .{ .x = pos.x -% 1, .y = pos.y -% 1 },
        .northeast => .{ .x = pos.x + 1, .y = pos.y -% 1 },
        .southwest => .{ .x = pos.x -% 1, .y = pos.y + 1 },
        .southeast => .{ .x = pos.x + 1, .y = pos.y + 1 },
    };
}

test "grid move function" {
    const start_pos: Position = .{ .x = 5, .y = 5 };
    try t.expectEqual(Position{ .x = 5, .y = 4 }, move(.north, start_pos));
    try t.expectEqual(Position{ .x = 5, .y = 6 }, move(.south, start_pos));
    try t.expectEqual(Position{ .x = 4, .y = 5 }, move(.west, start_pos));
    try t.expectEqual(Position{ .x = 6, .y = 5 }, move(.east, start_pos));
    try t.expectEqual(Position{ .x = 4, .y = 4 }, move(.northwest, start_pos));
    try t.expectEqual(Position{ .x = 6, .y = 4 }, move(.northeast, start_pos));
    try t.expectEqual(Position{ .x = 4, .y = 6 }, move(.southwest, start_pos));
    try t.expectEqual(Position{ .x = 6, .y = 6 }, move(.southeast, start_pos));

    // Test edge case near 0
    const zero_pos: Position = .{ .x = 0, .y = 0 };
    try t.expectEqual(Position{ .x = 0, .y = std.math.maxInt(usize) }, move(.north, zero_pos)); // Wraps with -|
    try t.expectEqual(Position{ .x = std.math.maxInt(usize), .y = 0 }, move(.west, zero_pos)); // Wraps with -|
}

pub fn Grid(comptime T: type) type {
    return struct {
        const Self = @This();

        /// Contents of the grid. This field is intended to be accessed
        /// directly.
        ///
        /// Pointers to elements in this slice are invalidated by various
        /// functions of this Grid in accordance with the respective
        /// documentation. In all cases, "invalidated" means that the memory
        /// has been passed to this allocator's resize or free function.
        items: []T,

        /// How many T values this list can hold without allocating
        /// additional memory.
        allocator: Allocator,

        /// Width of the grid
        width: usize,
        /// Height of the grid
        height: usize,
        /// Size (width * height) of the grid
        size: usize,

        /// Initialize the grid
        fn init(allocator: Allocator, grid_width: usize, grid_height: usize) Error!Self {
            const size: usize = @intCast(grid_width * grid_height);
            if (grid_width == 0 or grid_height == 0) return Error.InvalidArgument;

            const buf = try allocator.alloc(T, size);
            errdefer allocator.free(buf);

            return Self{
                .items = buf,
                .allocator = allocator,
                .size = size,
                .width = grid_width,
                .height = grid_height,
            };
        }

        /// Initialize the grid with a default value
        fn init_with_default(allocator: Allocator, default: T, grid_width: usize, grid_height: usize) Error!Self {
            const self = try init(allocator, grid_width, grid_height);

            for (self.items) |*item| {
                item.* = default;
            }

            return self;
        }

        /// Determine if the grid contains the given position
        fn inside(self: Self, pos: Position) bool {
            return pos.x < self.width and pos.y < self.height;
        }

        /// Optionally returns some value at `(x, y)` or `null` if it doesn't exist
        fn get_opt_ptr(self: *Self, pos: Position) ?*T {
            return if (self.inside(pos))
                &self.items[self.idx(pos)]
            else
                null;
        }

        fn get_opt(self: *Self, pos: Position) ?T {
            return if (self.get_opt_ptr(pos)) |ptr|
                ptr.*
            else
                return null;
        }

        /// Returns the value at `(x, y)` without checking grid bounds
        fn get(self: *Self, pos: Position) T {
            return self.items[self.idx(pos)];
        }

        /// Returns a pointer to the value at `pos`. Assumes `pos` is within grid bounds.
        /// Behavior is undefined if `pos` is out of bounds (likely panic).
        fn get_ptr(self: *Self, pos: Position) *T {
            return &self.items[self.idx(pos)];
        }

        /// Sets the value at `pos`. Assumes `pos` is within grid bounds.
        /// Behavior is undefined if `pos` is out of bounds (likely panic).
        pub fn set(self: *Self, pos: Position, value: T) void {
            self.items[self.idx(pos)] = value;
        }

        /// Calculates the index into the one-dimensional
        /// data slice when given a (x, y) coordinate pair.
        ///
        /// Does not determine if the returned index is valid.
        fn idx(self: Self, pos: Position) usize {
            return pos.y * self.width + pos.x;
        }

        /// Free memory. Important: pointers derived from `self.items` become invalid.
        fn deinit(self: *Self) void {
            if (@sizeOf(T) > 0) {
                self.allocator.free(self.items);
            }

            self.* = undefined;
        }

        /// Returns a new grid after applying `f` to all elements of the original.
        /// Does not mutate original grid.
        fn map(self: Self, f: fn (Position, T) T) Error!Self {
            const copy = try Self.init(self.allocator, self.width, self.height);
            errdefer copy.deinit();

            for (0..copy.height) |y| {
                for (0..copy.width) |x| {
                    const pos: Position = .{ .x = x, .y = y };
                    const i = self.idx(pos);
                    copy.items[i] = f(pos, self.items[i]);
                }
            }

            return copy;
        }

        /// Mutates elements of the grid via `f`
        fn map_mut(self: *Self, f: fn (Position, T) T) void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    const pos: Position = .{ .x = x, .y = y };
                    const i = self.idx(pos);
                    self.items[i] = f(pos, self.items[i]);
                }
            }
        }

        /// Creates a copy of the grid, using the same allocator.
        fn clone(self: Self) Error!Self {
            const buf = try self.allocator.alloc(T, self.size);
            errdefer self.allocator.free(buf);

            @memcpy(buf, self.items);

            return Self{
                .items = buf,
                .allocator = self.allocator,
                .width = self.width,
                .height = self.height,
                .size = self.size,
            };
        }

        /// Creates a grid from a string. Splits on '\n'.
        fn fromString(allocator: Allocator, str: []const u8) Error!Self {
            const lines = std.mem.tokenizeScalar(str, '\n');
            if (lines.len == 0) return Error.InvalidArgument;

            // const height = lines.len;
        }

        /// Best-effort pretty printing of the grid to stdout
        fn print(self: *Self) void {
            const print_as_chars = T == u8;
            const w_minus_1 = self.width - 1;

            var buf: [256]u8 = undefined;
            for (self.items, 0..) |item, i| {
                const str = switch (print_as_chars) {
                    true => std.fmt.bufPrint(&buf, "{c} ", .{item}) catch unreachable,
                    false => std.fmt.bufPrint(&buf, "{d} ", .{item}) catch unreachable,
                };

                std.debug.print("{s}", .{str});
                if (i % self.width == w_minus_1) {
                    std.debug.print("\n", .{});
                }
            }

            if (self.size > 0 and self.size % self.width != 0) {
                std.debug.print("\n", .{});
            }
        }
    };
}

const t = std.testing;

fn sum(p: Position, _: u16) u16 {
    return @intCast(p.x + p.y);
}

test "grid Grid init" {
    var grid = try Grid(u16).init(t.allocator, 5, 5);
    defer grid.deinit();

    grid.map_mut(sum);

    try t.expectEqual(@as(usize, 25), grid.items.len);
    try t.expectEqual(@as(usize, 5), grid.width);
    try t.expectEqual(@as(usize, 5), grid.height);
    try t.expectEqual(@as(usize, 25), grid.size);

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
    try t.expectEqual(@as(usize, 25), grid.items.len);
    try t.expectEqual(@as(usize, 420), grid.items[0]); // Check first
    try t.expectEqual(@as(usize, 420), grid.items[12]); // Check middle
    try t.expectEqual(@as(usize, 420), grid.items[24]); // Check last
    try t.expectEqual(@as(usize, 420), grid.get(.{ .x = 2, .y = 2 })); // Use get
}

test "grid idx function" {
    const W = 7;
    const H = 3;

    const dummy_grid = Grid(u8){
        .items = &[_]u8{}, // Doesn't matter for idx
        .allocator = undefined, // Not needed
        .width = W,
        .height = H,
        .size = W * H,
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
        .items = &[_]u8{},
        .allocator = undefined,
        .width = W,
        .height = H,
        .size = W * H,
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
    grid.map_mut(sum);

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

    const ptr1 = grid.get_ptr(.{ .x = 1, .y = 1 });
    try t.expectEqual(@as(u16, 2), ptr1.*);
    ptr1.* = 99;
    try t.expectEqual(@as(u16, 99), grid.get(.{ .x = 1, .y = 1 }));

    const ptr2 = grid.get_opt_ptr(.{ .x = 0, .y = 0 });
    try t.expect(ptr2 != null);
    try t.expectEqual(@as(u16, 0), ptr2.?.*);
    ptr2.?.* = 111;
    try t.expectEqual(@as(u16, 111), grid.get(.{ .x = 0, .y = 0 }));

    const ptr_null = grid.get_opt_ptr(.{ .x = W, .y = 0 }); // Out of bounds
    try t.expect(ptr_null == null);

    grid.set(.{ .x = 2, .y = 1 }, 222);
    try t.expectEqual(@as(u16, 222), grid.get(.{ .x = 2, .y = 1 }));
}

test "grid map (non-mutating)" {
    var grid = try Grid(u16).init_with_default(t.allocator, 10, 3, 2);
    defer grid.deinit();

    const add_pos = struct {
        fn func(pos: Position, val: u16) u16 {
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
    try t.expect(grid.items.ptr != mapped_grid.items.ptr); // Ensure distinct memory
}

test "grid map_mut" {
    var grid = try Grid(u16).init(t.allocator, 5, 5);
    defer grid.deinit();
    grid.map_mut(sum); // Test map_mut which uses idx internally
    try t.expectEqual(@as(usize, 25), grid.items.len);
    try t.expectEqual(@as(u16, 0), grid.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u16, 8), grid.get(.{ .x = 4, .y = 4 }));
    try t.expectEqual(@as(u16, 4), grid.get(.{ .x = 1, .y = 3 }));
}

test "grid print" {
    std.debug.print("\n--- grid print u8 ---\n", .{});
    // Use smaller grid for concise output
    var grid_u8 = try Grid(u8).init_with_default(t.allocator, 'x', 3, 2);
    defer grid_u8.deinit();
    grid_u8.set(.{ .x = 1, .y = 0 }, 'A');
    grid_u8.set(.{ .x = 0, .y = 1 }, 'B');
    grid_u8.print();

    std.debug.print("\n--- grid print u64 ---\n", .{});
    var grid_u64 = try Grid(u64).init_with_default(t.allocator, 55, 2, 3);
    defer grid_u64.deinit();
    grid_u64.set(.{ .x = 0, .y = 1 }, 111);
    grid_u64.set(.{ .x = 1, .y = 2 }, 999);
    grid_u64.print();
    std.debug.print("\n---------------------\n", .{});
}

test "grid clone" {
    const width = 4;
    const height = 3;
    var original = try Grid(u16).init(t.allocator, width, height);
    defer original.deinit();
    original.map_mut(sum); // Fill with initial values

    var cloned = try original.clone();
    defer cloned.deinit();

    try t.expectEqual(original.width, cloned.width);
    try t.expectEqual(original.height, cloned.height);
    try t.expectEqual(original.size, cloned.size);
    try t.expectEqual(original.items.len, cloned.items.len);
    try t.expect(original.items.ptr != cloned.items.ptr);
    try t.expect(std.mem.eql(u16, original.items, cloned.items));

    const change_pos_1 = Position{ .x = 1, .y = 1 };
    const original_value_1 = original.get(change_pos_1);
    cloned.set(change_pos_1, 99);
    try t.expectEqual(original_value_1, original.get(change_pos_1));
    try t.expectEqual(@as(u16, 99), cloned.get(change_pos_1));

    // Modify original, check clone unchanged
    const change_pos_2 = Position{ .x = 0, .y = 0 };
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
    try t.expectEqual(@as(usize, 5), grid1x5.size);
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
    try t.expectEqual(@as(usize, 5), grid5x1.size);
    grid5x1.set(.{ .x = 3, .y = 0 }, 88);
    try t.expectEqual(@as(u8, 2), grid5x1.get(.{ .x = 0, .y = 0 }));
    try t.expectEqual(@as(u8, 88), grid5x1.get(.{ .x = 3, .y = 0 }));
    try t.expectEqual(@as(u8, 2), grid5x1.get(.{ .x = 4, .y = 0 }));
    try t.expectEqual(null, grid5x1.get_opt(.{ .x = 5, .y = 0 })); // Out of bounds x
    try t.expectEqual(null, grid5x1.get_opt(.{ .x = 0, .y = 1 })); // Out of bounds y
}
