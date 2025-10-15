const std = @import("std");

pub const Direction = enum {
    north,
    northwest,
    west,
    southwest,
    south,
    southeast,
    east,
    northeast,

    /// Converts the direction into a string
    pub fn to_string(self: Direction) []const u8 {
        return switch (self) {
            .north => "north",
            .south => "south",
            .east => "east",
            .west => "west",
            .northeast => "northeast",
            .northwest => "northwest",
            .southeast => "southeast",
            .southwest => "southwest",
        };
    }

    /// Debug print the direction with a trailing newline
    pub fn display(self: Direction) !void {
        std.debug.print("{s}\n", .{self.to_string()});
    }
};

test "direction to_string" {
    try std.testing.expectEqualStrings("north", Direction.north.to_string());
    try std.testing.expectEqualStrings("south", Direction.south.to_string());
    try std.testing.expectEqualStrings("east", Direction.east.to_string());
    try std.testing.expectEqualStrings("west", Direction.west.to_string());
    try std.testing.expectEqualStrings("northeast", Direction.northeast.to_string());
    try std.testing.expectEqualStrings("northwest", Direction.northwest.to_string());
    try std.testing.expectEqualStrings("southeast", Direction.southeast.to_string());
    try std.testing.expectEqualStrings("southwest", Direction.southwest.to_string());
}
