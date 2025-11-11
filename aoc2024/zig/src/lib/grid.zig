const std = @import("std");
const Allocator = std.mem.Allocator;
const Point = @import("point.zig");

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

            const s = std.mem.trimEnd(u8, str, "\n");
            var lines = std.mem.splitScalar(u8, s, '\n');

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
        pub inline fn inside(self: Self, pos: Point) bool {
            return pos.x < self.width and pos.y < self.height;
        }

        /// Returns some value at `(x, y)` or `null` if it doesn't exist
        pub inline fn get_opt(self: *const Self, pos: Point) ?T {
            return if (self.inside(pos)) self.inner[self.idx(pos)] else null;
        }

        /// Returns the value at `(x, y)` without checking grid bounds
        pub inline fn get_by_coord(self: *const Self, x: usize, y: usize) T {
            return self.inner[y * self.width + x];
        }

        /// Returns the value at `(x, y)` without checking grid bounds
        pub inline fn get(self: *const Self, pos: Point) T {
            return self.inner[self.idx(pos)];
        }

        /// Returns a pointer to some value at `(x, y)` or `null` if it doesn't exist
        pub inline fn get_opt_mut(self: *Self, pos: Point) ?*T {
            return if (self.inside(pos)) &self.inner[self.idx(pos)] else null;
        }

        /// Returns a pointer to the value at `pos`.
        /// Assumes `pos` is within grid bounds.
        pub inline fn get_mut(self: *Self, pos: Point) *T {
            return &self.inner[self.idx(pos)];
        }

        /// Sets the value at `pos`. Assumes `pos` is within grid bounds.
        pub inline fn set(self: *Self, pos: Point, value: T) void {
            self.inner[self.idx(pos)] = value;
        }

        /// Calculates the index into the one-dimensional
        /// data slice when given a (x, y) coordinate pair.
        pub inline fn idx(self: Self, pos: Point) usize {
            return pos.y * self.width + pos.x;
        }

        /// Convert an index into a coordinate
        pub inline fn coord(self: Self, i: usize) Point {
            return .init(i % self.width, i / self.width);
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
            const w_minus_1 = self.width - 1;

            const fmt = switch (T) {
                u8 => "{c} ",
                comptime_int => "{d} ",
                else => "{any} ",
            };

            for (self.inner, 0..) |item, i| {
                std.debug.print(fmt, .{item});

                if (i % self.width == w_minus_1) {
                    std.debug.print("\n", .{});
                }
            }

            std.debug.print("\n", .{});
        }

        pub fn print_with_context(self: *const Self, ctx: []const u8) void {
            std.debug.print("{s}\n", .{ctx});
            self.print();
        }

        pub fn print_with_details(self: *const Self) void {
            std.debug.print("width: {d}\n", .{self.width});
            std.debug.print("height: {d}\n", .{self.height});
            std.debug.print("inner: {any}\n", .{self.inner});

            self.print();
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

        /// Creates a new, transposed version of the grid.
        /// The width and height are swapped.
        pub fn transpose(self: Self) !Self {
            var transposed_grid = try Self.new(self.gpa, self.height, self.width);

            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    transposed_grid.set(.{ .x = y, .y = x }, self.get_by_coord(x, y));
                }
            }

            return transposed_grid;
        }

        /// Applies a skew to the grid, where each row `y` is shifted `y`
        /// positions to the right, padded with the given value.
        /// This aligns the top-left to bottom-right diagonals into columns.
        /// The new grid will have a width of `self.width + self.height - 1`.
        pub fn skew(self: Self, pad: T) !Self {
            const new_width = self.width + self.height - 1;
            var skew_grid = try Self.make(self.gpa, pad, new_width, self.height);

            for (0..self.height) |y| {
                const src_start = y * self.width;
                const src_end = src_start + self.width;
                const src = self.inner[src_start..src_end];

                const dest_start = (y * skew_grid.width) + y;
                const dest_end = dest_start + self.width;
                const dest = skew_grid.inner[dest_start..dest_end];

                @memcpy(dest, src);
            }

            return skew_grid;
        }

        /// Reverses the rows of the grid
        pub fn reverse_rows(self: *Self) void {
            for (0..self.height) |y| {
                const start = y * self.width;
                const end = start + self.width;
                std.mem.reverse(T, self.inner[start..end]);
            }
        }

        /// Adds padding to the start of each row in the grid.
        pub fn pad_left(self: *Self, n: comptime_int, pad: T) !void {
            if (n == 0) return;

            const new_width = self.width + n;
            const new_inner = try self.gpa.alloc(T, new_width * self.height);

            for (0..self.height) |y| {
                const new_start = y * new_width;
                const old_start = y * self.width;

                for (new_inner[new_start .. new_start + n]) |*item| {
                    item.* = pad;
                }

                @memcpy(
                    new_inner[new_start + n .. new_start + new_width],
                    self.inner[old_start .. old_start + self.width],
                );
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.width = new_width;
        }

        /// Adds padding to the end of each row in the grid.
        pub fn pad_right(self: *Self, n: comptime_int, pad: T) !void {
            if (n == 0) return;

            const old_width = self.width;
            const new_width = old_width + n;
            const new_inner = try self.gpa.alloc(T, new_width * self.height);

            for (0..self.height) |y| {
                const new_start = y * new_width;
                const old_start = y * old_width;

                const dest = new_inner[new_start .. new_start + old_width];
                const source = self.inner[old_start .. old_start + old_width];
                @memcpy(dest, source);

                for (new_inner[new_start + old_width .. new_start + new_width]) |*item| {
                    item.* = pad;
                }
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.width = new_width;
        }

        /// Adds padding rows to the top of the grid.
        pub fn pad_up(self: *Self, n: usize, pad: T) !void {
            if (n == 0) return;
            const size = self.width * (self.height + n);
            const new_inner = try self.gpa.alloc(T, size);

            for (new_inner[0 .. n * self.width]) |*item| {
                item.* = pad;
            }

            const dest = new_inner[n * self.width ..];
            const src = self.inner[0..];
            @memcpy(dest, src);

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.height = self.height + n;
        }

        /// Adds padding rows to the bottom of the grid.
        pub fn pad_down(self: *Self, n: usize, pad: T) !void {
            if (n == 0) return;

            const old_size = self.width * self.height;
            const size = self.width * (self.height + n);
            const new_inner = try self.gpa.alloc(T, size);

            for (new_inner[old_size..]) |*item| {
                item.* = pad;
            }

            const dest = new_inner[0..old_size];
            const src = self.inner[0..];
            @memcpy(dest, src);

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.height = self.height + n;
        }

        /// Adds padding to the left *and* right sides of the grid.
        pub fn pad_horizontal(self: *Self, n: usize, pad: T) !void {
            if (n == 0) return;

            const old_width = self.width;
            const new_width = old_width + n * 2;
            const new_inner = try self.gpa.alloc(T, new_width * self.height);

            for (0..self.height) |y| {
                const new_start = y * new_width + n;
                const old_start = y * old_width;

                const dest = new_inner[new_start .. new_start + old_width];
                const source = self.inner[old_start .. old_start + old_width];
                @memcpy(dest, source);

                for (new_inner[new_start - n .. new_start]) |*item| {
                    item.* = pad;
                }

                for (new_inner[new_start + old_width .. new_start + new_width - n]) |*item| {
                    item.* = pad;
                }
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.width = new_width;
        }

        /// Adds padding to the top *and* bottom of the grid.
        pub fn pad_vertical(self: *Self, n: usize, pad: T) !void {
            if (n == 0) return;

            const new_start = n * self.width;
            const old_size = self.width * self.height;
            const size = self.width * (self.height + n + n);
            const new_inner = try self.gpa.alloc(T, size);

            // Copy the original into the middle
            const dest = new_inner[new_start .. new_start + old_size];
            const src = self.inner[0..];
            @memcpy(dest, src);

            // Set the top to the pad value
            for (new_inner[old_size + (n * self.width) ..]) |*item| {
                item.* = pad;
            }

            // Set the bottom to the pad value
            for (new_inner[0 .. n * self.width]) |*item| {
                item.* = pad;
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.height = self.height + n + n;
        }

        /// Adds padding to all sides of the grid.
        pub fn pad_sides(self: *Self, n: usize, pad: T) !void {
            if (n == 0) return;

            const old_width = self.width;
            const old_height = self.height;
            const new_width = old_width + n * 2;
            const new_height = old_height + n * 2;
            const new_inner = try self.gpa.alloc(T, new_width * new_height);

            // top pad
            const top_pad_size = n * new_width;
            for (new_inner[0..top_pad_size]) |*item| {
                item.* = pad;
            }

            for (0..old_height) |y| {
                const new_row_start = (y + n) * new_width;
                const old_row_start = y * old_width;

                // left pad
                for (new_inner[new_row_start .. new_row_start + n]) |*item| {
                    item.* = pad;
                }

                // middle
                const dest = new_inner[new_row_start + n .. new_row_start + n + old_width];
                const source = self.inner[old_row_start .. old_row_start + old_width];
                @memcpy(dest, source);

                // right pad
                for (new_inner[new_row_start + n + old_width .. new_row_start + new_width]) |*item| {
                    item.* = pad;
                }
            }

            // bottom pad
            const bottom_pad_start = (old_height + n) * new_width;
            for (new_inner[bottom_pad_start..]) |*item| {
                item.* = pad;
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.width = new_width;
            self.height = new_height;
        }

        /// Removes padding from the top and bottom of the grid.
        /// Panics in debug mode if `n * 2` is greater than or equal to the grid height.
        pub fn strip_vertical(self: *Self, n: usize) !void {
            if (n == 0) return;
            std.debug.assert(n * 2 < self.height);

            const new_height = self.height - n * 2;
            const new_size = self.width * new_height;
            const new_inner = try self.gpa.alloc(T, new_size);

            const copy_start = n * self.width;
            const source = self.inner[copy_start .. copy_start + new_size];
            @memcpy(new_inner, source);

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.height = new_height;
        }

        /// Removes padding from the left and right sides of the grid.
        /// Panics in debug mode if `n * 2` is greater than or equal to the grid width.
        pub fn strip_horizontal(self: *Self, n: usize) !void {
            if (n == 0) return;
            std.debug.assert(n * 2 < self.width);

            const old_width = self.width;
            const new_width = self.width - n * 2;
            const new_inner = try self.gpa.alloc(T, new_width * self.height);

            for (0..self.height) |y| {
                const new_row_start = y * new_width;
                const old_row_start = y * old_width;

                const source = self.inner[old_row_start + n .. old_row_start + n + new_width];
                const dest = new_inner[new_row_start .. new_row_start + new_width];
                @memcpy(dest, source);
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.width = new_width;
        }

        /// Removes padding from all four sides of the grid.
        pub fn strip_sides(self: *Self, n: usize) !void {
            try self.strip_horizontal(n);
            try self.strip_vertical(n);
        }

        /// Removes n rows from the top of the grid.
        pub fn strip_up(self: *Self, n: usize) !void {
            if (n == 0) return;
            std.debug.assert(n < self.height);

            const new_height = self.height - n;
            const new_size = self.width * new_height;
            const new_inner = try self.gpa.alloc(T, new_size);

            const copy_start = n * self.width;
            const source = self.inner[copy_start..];
            @memcpy(new_inner, source);

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.height = new_height;
        }

        /// Removes n rows from the bottom of the grid.
        pub fn strip_down(self: *Self, n: usize) !void {
            if (n == 0) return;
            std.debug.assert(n < self.height);

            const new_height = self.height - n;
            const new_size = self.width * new_height;
            const new_inner = try self.gpa.alloc(T, new_size);

            const source = self.inner[0..new_size];
            @memcpy(new_inner, source);

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.height = new_height;
        }

        /// Removes n columns from the left of the grid.
        pub fn strip_left(self: *Self, n: usize) !void {
            if (n == 0) return;
            std.debug.assert(n < self.width);

            const old_width = self.width;
            const new_width = self.width - n;
            const new_inner = try self.gpa.alloc(T, new_width * self.height);

            for (0..self.height) |y| {
                const new_row_start = y * new_width;
                const old_row_start = y * old_width;

                const source = self.inner[old_row_start + n .. old_row_start + old_width];
                const dest = new_inner[new_row_start .. new_row_start + new_width];
                @memcpy(dest, source);
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.width = new_width;
        }

        /// Removes n columns from the right of the grid.
        pub fn strip_right(self: *Self, n: usize) !void {
            if (n == 0) return;
            std.debug.assert(n < self.width);

            const old_width = self.width;
            const new_width = self.width - n;
            const new_inner = try self.gpa.alloc(T, new_width * self.height);

            for (0..self.height) |y| {
                const new_row_start = y * new_width;
                const old_row_start = y * old_width;

                const source = self.inner[old_row_start .. old_row_start + new_width];
                const dest = new_inner[new_row_start .. new_row_start + new_width];
                @memcpy(dest, source);
            }

            self.gpa.free(self.inner);
            self.inner = new_inner;
            self.width = new_width;
        }
    };
}

const t = std.testing;

fn sum(p: Point, _: u16) u16 {
    return @intCast(p.x + p.y);
}

test "grid reverse_rows" {
    const s =
        \\123
        \\456
        \\789
    ;
    var g = try Grid(u8).from_string(t.allocator, s);
    var copy = try g.clone();

    defer g.deinit();
    defer copy.deinit();

    g.reverse_rows();

    const expected = .{
        '3', '2', '1',
        '6', '5', '4',
        '9', '8', '7',
    };

    try t.expectEqualSlices(u8, &expected, g.inner);

    g.reverse_rows();
    try t.expectEqualSlices(u8, copy.inner, g.inner);
}

test "grid skew and transpose for diagonal extraction" {
    const s =
        \\123
        \\456
        \\789
    ;
    var g = try Grid(u8).from_string(t.allocator, s);
    defer g.deinit();

    var skewed = try g.skew('.');
    defer skewed.deinit();

    var diag_grid = try skewed.transpose();
    defer diag_grid.deinit();

    // Original Grid (3x3):
    // 123
    // 456
    // 789
    //
    // Skewed Grid (5x3):
    // 123..
    // .456.
    // ..789
    //
    // Transposed Skewed Grid (3x5):
    // 1..
    // 24.
    // 357
    // .68
    // ..9
    const row0 = diag_grid.inner[0 * diag_grid.width .. (0 * diag_grid.width) + diag_grid.width];
    try t.expectEqualSlices(u8, "1..", row0);

    const row1 = diag_grid.inner[1 * diag_grid.width .. (1 * diag_grid.width) + diag_grid.width];
    try t.expectEqualSlices(u8, "24.", row1);

    const row2 = diag_grid.inner[2 * diag_grid.width .. (2 * diag_grid.width) + diag_grid.width];
    try t.expectEqualSlices(u8, "357", row2);
}

test "grid transpose" {
    const s =
        \\123
        \\456
    ;
    var g = try Grid(u8).from_string(t.allocator, s);
    defer g.deinit();

    var transposed = try g.transpose();
    defer transposed.deinit();

    const expected_inner = .{ '1', '4', '2', '5', '3', '6' };
    try t.expectEqualSlices(u8, &expected_inner, transposed.inner);
    try t.expectEqual(2, transposed.width);
    try t.expectEqual(3, transposed.height);

    // Test round trip
    var round_trip = try transposed.transpose();
    defer round_trip.deinit();
    try t.expectEqualSlices(u8, g.inner, round_trip.inner);
    try t.expectEqual(g.width, round_trip.width);
    try t.expectEqual(g.height, round_trip.height);
}

test "grid skew" {
    const s =
        \\ABC
        \\DEF
        \\GHI
    ;
    var g = try Grid(u8).from_string(t.allocator, s);
    defer g.deinit();

    var skewed = try g.skew('.');
    defer skewed.deinit();

    const new_width = g.width + g.height - 1;
    try t.expectEqual(5, new_width);
    try t.expectEqual(new_width, skewed.width);
    try t.expectEqual(g.height, skewed.height);

    const expected_inner = .{
        'A', 'B', 'C', '.', '.',
        '.', 'D', 'E', 'F', '.',
        '.', '.', 'G', 'H', 'I',
    };

    try t.expectEqualSlices(u8, &expected_inner, skewed.inner);
}

test "grid pad_sides strip_sides" {
    const s =
        \\AB
        \\CD
    ;

    var g = try Grid(u8).from_string(t.allocator, s);
    var copy = try g.clone();
    defer g.deinit();
    defer copy.deinit();

    try g.pad_sides(1, '.');

    const expected = .{
        '.', '.', '.', '.',
        '.', 'A', 'B', '.',
        '.', 'C', 'D', '.',
        '.', '.', '.', '.',
    };
    try t.expectEqualSlices(u8, &expected, g.inner);
    try t.expectEqual(4, g.width);
    try t.expectEqual(4, g.height);

    try g.pad_sides(0, 0);
    try t.expectEqualSlices(u8, &expected, g.inner);
    try t.expectEqual(4, g.width);
    try t.expectEqual(4, g.height);

    try g.strip_sides(1);
    try t.expectEqual(2, g.width);
    try t.expectEqual(2, g.height);
    try t.expectEqualSlices(u8, copy.inner, g.inner);
}

test "grid pad_vertical strip_vertical" {
    const s =
        \\ABC
        \\DEF
        \\GHI
    ;

    var g = try Grid(u8).from_string(t.allocator, s);
    var copy = try g.clone();
    defer g.deinit();
    defer copy.deinit();

    try g.pad_vertical(1, '!');

    const expected = .{
        '!', '!', '!',
        'A', 'B', 'C',
        'D', 'E', 'F',
        'G', 'H', 'I',
        '!', '!', '!',
    };
    try t.expectEqualSlices(u8, &expected, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(5, g.height);

    try g.pad_vertical(0, 0);
    try t.expectEqualSlices(u8, &expected, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(5, g.height);

    try g.strip_vertical(1);
    try t.expectEqual(3, g.width);
    try t.expectEqual(3, g.height);
    try t.expectEqualSlices(u8, copy.inner, g.inner);
}

test "grid pad_horizontal strip_horizontal" {
    var g = try Grid(u16).make_with(t.allocator, 3, 3, sum);
    var copy = try g.clone();
    defer g.deinit();
    defer copy.deinit();

    try g.pad_horizontal(1, 0);

    const expected = .{
        0, 0, 1, 2, 0,
        0, 1, 2, 3, 0,
        0, 2, 3, 4, 0,
    };
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(5, g.width);
    try t.expectEqual(3, g.height);

    try g.pad_horizontal(0, 0);
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(5, g.width);
    try t.expectEqual(3, g.height);

    try g.strip_horizontal(1);
    try t.expectEqual(3, g.width);
    try t.expectEqual(3, g.height);
    try t.expectEqualSlices(u16, copy.inner, g.inner);
}

test "grid pad_down strip_down" {
    var g = try Grid(u16).make_with(t.allocator, 3, 3, sum);
    var copy = try g.clone();

    defer g.deinit();
    defer copy.deinit();

    try g.pad_down(1, 5);

    const expected = .{
        0, 1, 2,
        1, 2, 3,
        2, 3, 4,
        5, 5, 5,
    };
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(4, g.height); // 3 original + 1 bottom

    try g.pad_down(0, 0);
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(4, g.height);

    try g.strip_down(1);
    try t.expectEqual(3, g.width);
    try t.expectEqual(3, g.height);
    try t.expectEqualSlices(u16, copy.inner, g.inner);
}

test "grid pad_up strip_up" {
    var g = try Grid(u16).make_with(t.allocator, 3, 3, sum);
    var copy = try g.clone();
    defer g.deinit();
    defer copy.deinit();

    try g.pad_up(2, 5);
    const expected = .{
        5, 5, 5,
        5, 5, 5,
        0, 1, 2,
        1, 2, 3,
        2, 3, 4,
    };
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(5, g.height);

    try g.pad_up(0, 0);
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(5, g.height);

    try g.strip_up(2);
    try t.expectEqualSlices(u16, copy.inner, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(3, g.height);
}

test "grid pad_left strip_left" {
    var g = try Grid(u16).make_with(t.allocator, 3, 3, sum);
    var copy = try g.clone();
    defer g.deinit();
    defer copy.deinit();

    try g.pad_left(1, 5);
    const expected = .{
        5, 0, 1, 2,
        5, 1, 2, 3,
        5, 2, 3, 4,
    };
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(4, g.width);
    try t.expectEqual(3, g.height);

    try g.pad_left(0, 0);
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(4, g.width);
    try t.expectEqual(3, g.height);

    try g.strip_left(1);
    try t.expectEqualSlices(u16, copy.inner, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(3, g.height);
}

test "grid pad_right strip_right" {
    var g = try Grid(u16).make_with(t.allocator, 3, 3, sum);
    var copy = try g.clone();
    defer g.deinit();
    defer copy.deinit();

    try g.pad_right(1, 5);

    const expected = .{
        0, 1, 2, 5,
        1, 2, 3, 5,
        2, 3, 4, 5,
    };
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(4, g.width);
    try t.expectEqual(3, g.height);

    try g.pad_right(0, 0);
    try t.expectEqualSlices(u16, &expected, g.inner);
    try t.expectEqual(4, g.width);
    try t.expectEqual(3, g.height);

    try g.strip_right(1);
    try t.expectEqualSlices(u16, copy.inner, g.inner);
    try t.expectEqual(3, g.width);
    try t.expectEqual(3, g.height);
}

test "grid new" {
    var grid = try Grid(u16).make_with(t.allocator, 5, 5, sum);
    defer grid.deinit();

    try t.expectEqual(25, grid.inner.len);
    try t.expectEqual(5, grid.width);
    try t.expectEqual(5, grid.height);
    try t.expectEqual(25, grid.width * grid.height);

    const val = grid.get_opt(.{ .x = 4, .y = 4 });
    try t.expect(val != null);
    try t.expectEqual(8, val.?);
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
    try t.expectEqual(25, grid.inner.len);
    try t.expectEqual(420, grid.inner[0]); // Check first
    try t.expectEqual(420, grid.inner[12]); // Check middle
    try t.expectEqual(420, grid.inner[24]); // Check last
    try t.expectEqual(420, grid.get(.{ .x = 2, .y = 2 })); // Use get
}

test "grid idx" {
    const dummy_grid = Grid(u8){
        .inner = &[_]u8{}, // Doesn't matter for idx
        .gpa = undefined, // Not needed
        .width = 7,
        .height = 3,
    };

    try t.expectEqual(0, dummy_grid.idx(Point.init(0, 0))); // Top-left
    try t.expectEqual(6, dummy_grid.idx(Point.init(6, 0))); // Top-right
    try t.expectEqual(7, dummy_grid.idx(Point.init(0, 1))); // Start of second row
    try t.expectEqual(10, dummy_grid.idx(Point.init(3, 1))); // Middle
    try t.expectEqual(14, dummy_grid.idx(Point.init(0, 2))); // Bottom-left
    try t.expectEqual(20, dummy_grid.idx(Point.init(6, 2))); // Bottom-right
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
