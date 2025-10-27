const std = @import("std");
const Direction = @import("direction.zig").Intercardinal;

const Self = @This();

x: usize,
y: usize,

/// Create a new point
pub fn init(x: usize, y: usize) Self {
    return Self{ .x = x, .y = y };
}

/// Returns a point `{ .x = 0, .y = 0 }`
pub fn origin() Self {
    return .{ .x = 0, .y = 0 };
}

/// Divide two points
pub fn div(self: Self, other: Self) Self {
    const x = self.x / other.x;
    const y = self.y / other.y;
    return Self.init(x, y);
}

/// Multiply two points
pub fn mul(self: Self, other: Self) Self {
    const x = self.x *% other.x;
    const y = self.y *% other.y;
    return Self.init(x, y);
}

/// Sum two points
pub fn add(self: Self, other: Self) Self {
    const x = self.x +% other.x;
    const y = self.y +% other.y;
    return Self.init(x, y);
}

/// Subtract two points
pub fn sub(self: Self, other: Self) Self {
    const x = self.x -% other.x;
    const y = self.y -% other.y;
    return Self.init(x, y);
}

pub fn eql(self: Self, other: Self) bool {
    return self.x == other.x and self.y == other.y;
}

pub fn unit_step(self: Self, d: Direction) Self {
    const x = self.x;
    const y = self.y;

    return switch (d) {
        .north => Self.init(x, y -% 1),
        .south => Self.init(x, y +% 1),
        .west => Self.init(x -% 1, y),
        .east => Self.init(x +% 1, y),
        .northeast => Self.init(x +% 1, y -% 1),
        .northwest => Self.init(x -% 1, y -% 1),
        .southeast => Self.init(x +% 1, y +% 1),
        .southwest => Self.init(x -% 1, y +% 1),
    };
}

pub fn unit_step_opt(self: Self, d: Direction) ?Self {
    const x = self.x;
    const y = self.y;
    const usize_max = std.math.maxInt(usize);

    const bad_n = y == 0;
    const bad_s = y == usize_max;
    const bad_w = x == 0;
    const bad_e = x == usize_max;

    // zig fmt: off
        return switch (d) {
            .north     => return if (bad_n         ) null else Self.init(x, y - 1    ),
            .south     => return if (bad_s         ) null else Self.init(x, y + 1    ),
            .west      => return if (bad_w         ) null else Self.init(x - 1, y    ),
            .east      => return if (bad_e         ) null else Self.init(x + 1, y    ),
            .northeast => return if (bad_e or bad_n) null else Self.init(x + 1, y - 1),
            .northwest => return if (bad_w or bad_n) null else Self.init(x - 1, y - 1),
            .southeast => return if (bad_e or bad_s) null else Self.init(x + 1, y + 1),
            .southwest => return if (bad_w or bad_s) null else Self.init(x - 1, y + 1),
        };
        // zig fmt: on
}

/// Returns a new point shifted one unit north
pub fn north(self: Self) Self {
    return self.unit_step(Direction.north);
}

/// Returns a new point shifted one unit south
pub fn south(self: Self) Self {
    return self.unit_step(Direction.south);
}

/// Returns a new point shifted one unit east
pub fn east(self: Self) Self {
    return self.unit_step(Direction.east);
}

/// Returns a new point shifted one unit west
pub fn west(self: Self) Self {
    return self.unit_step(Direction.west);
}

/// Returns a new point shifted one unit south-east
pub fn southeast(self: Self) Self {
    return self.unit_step(Direction.southeast);
}

/// Returns a new point shifted one unit south-west
pub fn southwest(self: Self) Self {
    return self.unit_step(Direction.southwest);
}

/// Returns a new point shifted one unit north-east
pub fn northeast(self: Self) Self {
    return self.unit_step(Direction.northeast);
}

/// Returns a new point shifted one unit north-west
pub fn northwest(self: Self) Self {
    return self.unit_step(Direction.northwest);
}

/// Optionally returns a new point shifted one unit north
pub fn north_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.north);
}

/// Optionally returns a new point shifted one unit south
pub fn south_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.south);
}

/// Optionally returns a new point shifted one unit east
pub fn east_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.east);
}

/// Optionally returns a new point shifted one unit west
pub fn west_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.west);
}

/// Optionally returns a new point shifted one unit south-east
pub fn southeast_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.southeast);
}

/// Optionally returns a new point shifted one unit south-west
pub fn southwest_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.southwest);
}

/// Optionally returns a new point shifted one unit north-east
pub fn northeast_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.northeast);
}

/// Optionally returns a new point shifted one unit north-west
pub fn northwest_opt(self: Self) ?Self {
    return self.unit_step_opt(Direction.northwest);
}

fn unit_step_mut(self: *Self, d: Direction) void {
    switch (d) {
        Direction.north => self.y = self.y - 1,
        Direction.south => self.y = self.y + 1,
        Direction.west => self.x = self.x - 1,
        Direction.east => self.x = self.x + 1,
        Direction.northeast => {
            self.x = self.x + 1;
            self.y = self.y - 1;
        },
        Direction.northwest => {
            self.x = self.x - 1;
            self.y = self.y - 1;
        },
        Direction.southeast => {
            self.x = self.x + 1;
            self.y = self.y + 1;
        },
        Direction.southwest => {
            self.x = self.x - 1;
            self.y = self.y + 1;
        },
    }
}

/// Mutates this point to move one unit north
pub fn north_mut(self: *Self) void {
    return self.unit_step_mut(Direction.north);
}

/// Mutates this point to move one unit south
pub fn south_mut(self: *Self) void {
    return self.unit_step_mut(Direction.south);
}

/// Mutates this point to move one unit east
pub fn east_mut(self: *Self) void {
    return self.unit_step_mut(Direction.east);
}

/// Mutates this point to move one unit west
pub fn west_mut(self: *Self) void {
    return self.unit_step_mut(Direction.west);
}

/// Mutates this point to move one unit south-east
pub fn southeast_mut(self: *Self) void {
    return self.unit_step_mut(Direction.southeast);
}

/// Mutates this point to move one unit south-west
pub fn southwest_mut(self: *Self) void {
    return self.unit_step_mut(Direction.southwest);
}

/// Mutates this point to move one unit north-east
pub fn northeast_mut(self: *Self) void {
    return self.unit_step_mut(Direction.northeast);
}

/// Mutates this point to move one unit north-west
pub fn northwest_mut(self: *Self) void {
    return self.unit_step_mut(Direction.northwest);
}

/// Get the coordinates of all orthoganal neighbors from a given point `p`.
///
/// Order of the Array starts at `Direction.north`, rotates clockwise, and ends with
/// `Direction.west`.
pub fn nbor4(self: Self) [4]Self {
    return .{
        self.north(),
        self.east(),
        self.south(),
        self.west(),
    };
}

/// Get the coordinates of all orthoganal neighbors from a given point `p`.
///
/// Order of the Array starts at `Direction.north`, rotates clockwise, and ends with
/// `Direction.west`.
pub fn nbor4_opt(self: Self) [4]?Self {
    return .{
        self.north_opt(),
        self.east_opt(),
        self.south_opt(),
        self.west_opt(),
    };
}

/// Get the coordinates of the eight surrounding neighbors (cardinal and intercardinal directions)
/// from a given point `p`, often referred to as the [8-wind compass rose](https://en.wikipedia.org/wiki/Selfs_of_the_compass#8-wind_compass_rose).
///
/// The order of the array starts at `Direction.north` and rotates clockwise.
pub fn nbor8(self: Self) [8]Self {
    return .{
        self.north(),
        self.northeast(),
        self.east(),
        self.southeast(),
        self.south(),
        self.southwest(),
        self.west(),
        self.northwest(),
    };
}

/// Get the coordinates of the eight surrounding neighbors (cardinal and intercardinal directions)
/// from a given point `p`, often referred to as the [8-wind compass rose](https://en.wikipedia.org/wiki/Selfs_of_the_compass#8-wind_compass_rose).
///
/// The order of the array starts at `Direction.north` and rotates clockwise.
/// If the point overflows or underflows it will be `null`
pub fn nbor8_opt(self: Self) [8]?Self {
    return .{
        self.north_opt(),
        self.northeast_opt(),
        self.east_opt(),
        self.southeast_opt(),
        self.south_opt(),
        self.southwest_opt(),
        self.west_opt(),
        self.northwest_opt(),
    };
}

/// Convert this point into a string
pub fn to_string(self: Self, buf: []u8) ![]const u8 {
    return try std.fmt.bufPrint(buf, "({d}, {d})", .{ self.x, self.y });
}

test "point arithmetic" {
    const p1 = Self.init(10, 20);
    const p2 = Self.init(2, 5);

    // Test addition
    const p_add = p1.add(p2);
    try std.testing.expectEqual(p_add.x, 12);
    try std.testing.expectEqual(p_add.y, 25);

    // Test subtraction
    const p_sub = p1.sub(p2);
    try std.testing.expectEqual(p_sub.x, 8);
    try std.testing.expectEqual(p_sub.y, 15);

    // Test multiplication
    const p_mul = p1.mul(p2);
    try std.testing.expectEqual(p_mul.x, 20);
    try std.testing.expectEqual(p_mul.y, 100);

    // Test division
    const p_div = p1.div(p2);
    try std.testing.expectEqual(p_div.x, 5);
    try std.testing.expectEqual(p_div.y, 4);
}

test "point immutable movement" {
    const p = Self.init(5, 5);

    // Test cardinal directions
    try std.testing.expectEqual(Self.init(5, 4), p.north());
    try std.testing.expectEqual(Self.init(5, 6), p.south());
    try std.testing.expectEqual(Self.init(6, 5), p.east());
    try std.testing.expectEqual(Self.init(4, 5), p.west());

    // Test diagonal directions
    try std.testing.expectEqual(Self.init(6, 4), p.northeast());
    try std.testing.expectEqual(Self.init(4, 4), p.northwest());
    try std.testing.expectEqual(Self.init(6, 6), p.southeast());
    try std.testing.expectEqual(Self.init(4, 6), p.southwest());

    // Ensure the original point was not mutated
    try std.testing.expectEqual(p.x, 5);
    try std.testing.expectEqual(p.y, 5);
}

test "point mutable movement" {
    var p = Self.init(10, 10);

    p.north_mut();
    try std.testing.expectEqual(Self.init(10, 9), p);

    p.east_mut();
    try std.testing.expectEqual(Self.init(11, 9), p);

    p.south_mut();
    try std.testing.expectEqual(Self.init(11, 10), p);

    p.west_mut();
    try std.testing.expectEqual(Self.init(10, 10), p);
}

test "point neighbor generation" {
    const p = Self.init(3, 3);

    // Test nbor4
    const n4 = p.nbor4();
    try std.testing.expectEqualSlices(Self, &.{
        Self.init(3, 2), // North
        Self.init(4, 3), // East
        Self.init(3, 4), // South
        Self.init(2, 3), // West
    }, &n4);

    // Test nbor8
    const n8 = p.nbor8();
    try std.testing.expectEqualSlices(Self, &.{
        Self.init(3, 2), // North
        Self.init(4, 2), // Northeast
        Self.init(4, 3), // East
        Self.init(4, 4), // Southeast
        Self.init(3, 4), // South
        Self.init(2, 4), // Southwest
        Self.init(2, 3), // West
        Self.init(2, 2), // Northwest
    }, &n8);
}

test "point nbor opt generation" {
    const p = Self.init(0, 0);
    const n4 = p.nbor4_opt();
    const expected_n4 = .{ null, Self.init(1, 0), Self.init(0, 1), null };
    try std.testing.expectEqualSlices(?Self, &expected_n4, &n4);

    const n8 = p.nbor8_opt();
    const expected_n8 = .{
        null,
        null,
        Self.init(1, 0),
        Self.init(1, 1),
        Self.init(0, 1),
        null,
        null,
        null,
    };
    try std.testing.expectEqualSlices(?Self, &expected_n8, &n8);
}

test "point to_string" {
    const p = Self.init(123, 456);
    var buf: [64]u8 = undefined;
    const s = try p.to_string(&buf);
    try std.testing.expectEqualStrings("(123, 456)", s);
}

test "point eql" {
    const p1 = Self.init(10, 12);
    const p2 = Self.init(0, 1);
    const p3 = Self.init(0, 1);

    try std.testing.expect(p2.eql(p3));
    try std.testing.expect(!p1.eql(p3));
}
