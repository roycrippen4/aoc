const std = @import("std");
const Allocator = std.mem.Allocator;

/// (x, y) coordinate pairs for the grid
pub const Position = struct { x: usize, y: usize };

/// Errors associated with the `grid` module
pub const Error = error{ OutOfMemory, InvalidArgument };

// pub const GridError = error{InvalidArgument};

pub fn Grid(comptime T: type, grid_width: usize, grid_height: usize) type {
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
        fn init(allocator: Allocator) Error!Self {
            const size: usize = @intCast(grid_width * grid_height);
            if (size == 0) return Error.InvalidArgument;

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
        fn init_with_default(allocator: Allocator, default: T) Error!Self {
            const size: usize = @intCast(grid_width * grid_height);
            if (size == 0) return Error.InvalidArgument;

            const buf = try allocator.alloc(T, size);
            errdefer allocator.free(buf);

            for (buf) |*item| {
                item.* = default;
            }

            return Self{
                .items = buf,
                .allocator = allocator,
                .size = size,
                .width = grid_width,
                .height = grid_height,
            };
        }

        /// Optionally returns some value at `(x, y)` or `null` if it doesn't exist
        fn get_opt(self: *Self, x: usize, y: usize) ?T {
            if (x >= self.width or y >= self.height) return null;
            return self.items[self.idx(x, y)];
        }

        /// Uses the function `f` to derive the grid's values
        fn deriveValues(self: *Self, f: fn (Position) T) void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    self.items[self.idx(x, y)] = f(.{ .x = x, .y = y });
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

        /// Calculates the index into the one-dimensional
        /// data slice when given a (x, y) coordinate pair.
        ///
        /// Does not determine if the returned index is valid.
        fn idx(self: *Self, x: usize, y: usize) usize {
            return self.width * y + x;
        }

        /// Returns a slice of all the items plus the extra capacity, whose memory
        /// contents are `undefined`.
        fn allocatedSlice(self: Self) []T {
            return self.items.ptr[0..self.size];
        }

        /// Free memory. Important: pointers derived from `self.items` become invalid.
        fn deinit(self: Self) void {
            if (@sizeOf(T) > 0) {
                self.allocator.free(self.allocatedSlice());
            }
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

fn sum(p: Position) u8 {
    return @intCast(p.x + p.y);
}
test "grid Grid init" {
    var grid = try Grid(u8, 5, 5).init(t.allocator);
    defer grid.deinit();
    grid.deriveValues(sum);
    try t.expectEqual(@as(usize, 25), grid.items.len);
    try t.expectEqual(8, grid.get_opt(4, 4).?);
}

test "grid Grid" {
    var grid = try Grid(u8, 5, 5).init(t.allocator);
    defer grid.deinit();
    grid.deriveValues(sum);
    std.debug.print("{any}\n", .{grid.items});
}

test "grid init_with_default" {
    var grid = try Grid(usize, 5, 5).init_with_default(t.allocator, 420);
    defer grid.deinit();
    try t.expectEqual(@as(usize, 25), grid.items.len);
    try t.expectEqual(@as(usize, 420), grid.items[0]);
    try t.expectEqual(@as(usize, 420), grid.items[24]);
}

test "grid print" {
    std.debug.print("\n--- grid print u8 ---\n", .{});
    var grid = try Grid(u8, 5, 5).init_with_default(t.allocator, 'x');
    defer grid.deinit();
    grid.print();

    std.debug.print("\n--- grid print u64 ---\n", .{});
    var grid2 = try Grid(u64, 5, 5).init_with_default(t.allocator, 55);
    defer grid2.deinit();
    grid2.print();
    std.debug.print("\n---------------------\n", .{});
}

test "grid get_opt" {
    var grid = try Grid(u8, 3, 2).init(t.allocator);
    defer grid.deinit();
    grid.deriveValues(sum); // Values will be 0..4
    // grid.print(); // uncomment to visualize: 0 1 2 \n 1 2 3
    try t.expectEqual(@as(u8, 0), grid.get_opt(0, 0).?);
    try t.expectEqual(@as(u8, 2), grid.get_opt(2, 0).?);
    try t.expectEqual(@as(u8, 1), grid.get_opt(0, 1).?);
    try t.expectEqual(@as(u8, 3), grid.get_opt(2, 1).?);
    try t.expectEqual(null, grid.get_opt(3, 0)); // Out of bounds X
    try t.expectEqual(null, grid.get_opt(0, 2)); // Out of bounds Y
    try t.expectEqual(null, grid.get_opt(5, 5)); // Out of bounds X and Y
}

// Test for the new clone function
test "grid clone" {
    const width = 4;
    const height = 3;
    var original = try Grid(u8, width, height).init(t.allocator);
    defer original.deinit();

    // Populate original grid
    original.deriveValues(sum);

    // Clone it
    var cloned = try original.clone();
    // IMPORTANT: Defer deinit for the clone too!
    defer cloned.deinit();

    // --- Assertions ---
    // 1. Dimensions must match
    try t.expectEqual(original.width, cloned.width);
    try t.expectEqual(original.height, cloned.height);
    try t.expectEqual(original.size, cloned.size);

    // 3. Item slice lengths must match
    try t.expectEqual(original.items.len, cloned.items.len);
    try t.expectEqual(original.size, cloned.items.len);

    // 4. CRUCIAL: Pointers must be different (separate allocations)
    try t.expect(original.items.ptr != cloned.items.ptr);

    // 5. Contents must be identical
    try t.expect(std.mem.eql(u8, original.items, cloned.items));

    // 6. (Optional but good) Modify clone and check original is unchanged
    const change_idx = cloned.idx(1, 1);
    const original_value = cloned.items[change_idx];
    cloned.items[change_idx] = 99; // Modify clone

    try t.expectEqual(original_value, original.items[change_idx]); // Original should be unchanged
    try t.expectEqual(@as(u8, 99), cloned.items[change_idx]); // Clone should have the new value

    // 7. (Optional but good) Modify original and check clone is unchanged
    const change_idx_2 = original.idx(0, 0);
    const clone_value_2 = cloned.items[change_idx_2];
    original.items[change_idx_2] = 111; // Modify original

    try t.expectEqual(clone_value_2, cloned.items[change_idx_2]); // Clone should be unchanged
    try t.expectEqual(@as(u8, 111), original.items[change_idx_2]); // Original should have the new value

}
