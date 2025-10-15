const std = @import("std");
const Direction = @import("direction.zig").Direction;

pub const Point = struct {
    x: usize,
    y: usize,

    /// Create a new point
    pub fn init(x: usize, y: usize) Point {
        return Point{ .x = x, .y = y };
    }

    /// Divide two points
    pub fn div(self: Point, other: Point) Point {
        const x = self.x / other.x;
        const y = self.y / other.y;
        return Point.init(x, y);
    }

    /// Multiply two points
    pub fn mul(self: Point, other: Point) Point {
        const x = self.x * other.x;
        const y = self.y * other.y;
        return Point.init(x, y);
    }

    /// Sum two points
    pub fn add(self: Point, other: Point) Point {
        const x = self.x + other.x;
        const y = self.y + other.y;
        return Point.init(x, y);
    }

    /// Subtract two points
    pub fn sub(self: Point, other: Point) Point {
        const x = self.x - other.x;
        const y = self.y - other.y;
        return Point.init(x, y);
    }

    pub fn unit_step(self: Point, d: Direction) Point {
        const x = self.x;
        const y = self.y;

        return switch (d) {
            .north => Point.init(x, y - 1),
            .south => Point.init(x, y + 1),
            .west => Point.init(x - 1, y),
            .east => Point.init(x + 1, y),
            .northeast => Point.init(x + 1, y - 1),
            .northwest => Point.init(x - 1, y - 1),
            .southeast => Point.init(x + 1, y + 1),
            .southwest => Point.init(x - 1, y + 1),
        };
    }

    /// Returns a new point shifted one unit north
    pub fn north(self: Point) Point {
        return self.unit_step(Direction.north);
    }

    /// Returns a new point shifted one unit south
    pub fn south(self: Point) Point {
        return self.unit_step(Direction.south);
    }

    /// Returns a new point shifted one unit east
    pub fn east(self: Point) Point {
        return self.unit_step(Direction.east);
    }

    /// Returns a new point shifted one unit west
    pub fn west(self: Point) Point {
        return self.unit_step(Direction.west);
    }

    /// Returns a new point shifted one unit south-east
    pub fn southeast(self: Point) Point {
        return self.unit_step(Direction.southeast);
    }

    /// Returns a new point shifted one unit south-west
    pub fn southwest(self: Point) Point {
        return self.unit_step(Direction.southwest);
    }

    /// Returns a new point shifted one unit north-east
    pub fn northeast(self: Point) Point {
        return self.unit_step(Direction.northeast);
    }

    /// Returns a new point shifted one unit north-west
    pub fn northwest(self: Point) Point {
        return self.unit_step(Direction.northwest);
    }

    fn unit_step_mut(self: *Point, d: Direction) void {
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
    pub fn north_mut(self: *Point) void {
        return self.unit_step_mut(Direction.north);
    }

    /// Mutates this point to move one unit south
    pub fn south_mut(self: *Point) void {
        return self.unit_step_mut(Direction.south);
    }

    /// Mutates this point to move one unit east
    pub fn east_mut(self: *Point) void {
        return self.unit_step_mut(Direction.east);
    }

    /// Mutates this point to move one unit west
    pub fn west_mut(self: *Point) void {
        return self.unit_step_mut(Direction.west);
    }

    /// Mutates this point to move one unit south-east
    pub fn southeast_mut(self: *Point) void {
        return self.unit_step_mut(Direction.southeast);
    }

    /// Mutates this point to move one unit south-west
    pub fn southwest_mut(self: *Point) void {
        return self.unit_step_mut(Direction.southwest);
    }

    /// Mutates this point to move one unit north-east
    pub fn northeast_mut(self: *Point) void {
        return self.unit_step_mut(Direction.northeast);
    }

    /// Mutates this point to move one unit north-west
    pub fn northwest_mut(self: *Point) void {
        return self.unit_step_mut(Direction.northwest);
    }

    /// Get the coordinates of all orthoganal neighbors from a given point `p`.
    ///
    /// Order of the Array starts at `Direction.north`, rotates clockwise, and ends with
    /// `Direction.west`.
    pub fn nbor4(self: Point) [4]Point {
        return .{ self.north(), self.east(), self.south(), self.west() };
    }

    /// Get the coordinates of the eight surrounding neighbors (cardinal and intercardinal directions)
    /// from a given point `p`, often referred to as the [8-wind compass rose](https://en.wikipedia.org/wiki/Points_of_the_compass#8-wind_compass_rose).
    ///
    /// The order of the array starts at `Direction::North` and rotates clockwise.
    pub fn nbor8(self: Point) [8]Point {
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

    /// Convert this point into a string
    pub fn to_string(self: Point) ![]const u8 {
        var buf: [1024]u8 = undefined;
        return try std.fmt.bufPrint(&buf, "({}, {})", .{ self.x, self.y });
    }
};

test "point arithmetic" {
    const p1 = Point.init(10, 20);
    const p2 = Point.init(2, 5);

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
    const p = Point.init(5, 5);

    // Test cardinal directions
    try std.testing.expectEqual(Point.init(5, 4), p.north());
    try std.testing.expectEqual(Point.init(5, 6), p.south());
    try std.testing.expectEqual(Point.init(6, 5), p.east());
    try std.testing.expectEqual(Point.init(4, 5), p.west());

    // Test diagonal directions
    try std.testing.expectEqual(Point.init(6, 4), p.northeast());
    try std.testing.expectEqual(Point.init(4, 4), p.northwest());
    try std.testing.expectEqual(Point.init(6, 6), p.southeast());
    try std.testing.expectEqual(Point.init(4, 6), p.southwest());

    // Ensure the original point was not mutated
    try std.testing.expectEqual(p.x, 5);
    try std.testing.expectEqual(p.y, 5);
}

test "point mutable movement" {
    var p = Point.init(10, 10);

    p.north_mut();
    try std.testing.expectEqual(Point.init(10, 9), p);

    p.east_mut();
    try std.testing.expectEqual(Point.init(11, 9), p);

    p.south_mut();
    try std.testing.expectEqual(Point.init(11, 10), p);

    p.west_mut();
    try std.testing.expectEqual(Point.init(10, 10), p);
}

test "point neighbor generation" {
    const p = Point.init(3, 3);

    // Test nbor4
    const n4 = p.nbor4();
    try std.testing.expectEqualSlices(Point, &.{
        Point.init(3, 2), // North
        Point.init(4, 3), // East
        Point.init(3, 4), // South
        Point.init(2, 3), // West
    }, &n4);

    // Test nbor8
    const n8 = p.nbor8();
    try std.testing.expectEqualSlices(Point, &.{
        Point.init(3, 2), // North
        Point.init(4, 2), // Northeast
        Point.init(4, 3), // East
        Point.init(4, 4), // Southeast
        Point.init(3, 4), // South
        Point.init(2, 4), // Southwest
        Point.init(2, 3), // West
        Point.init(2, 2), // Northwest
    }, &n8);
}

test "point to_string" {
    const p = Point.init(123, 456);
    const s = try p.to_string();
    try std.testing.expectEqualStrings("(123, 456)", s);
}
