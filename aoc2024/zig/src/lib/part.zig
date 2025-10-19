const std = @import("std");

/// Enum representing the two parts commonly
/// found with advent of code problems.
pub const Part = enum {
    one,
    two,

    /// Converts the part into its character representation
    pub fn toString(self: Part) []const u8 {
        return switch (self) {
            .one => "Part 1",
            .two => "Part 2",
        };
    }
};

const t = std.testing;
test "util part.toString" {
    try t.expectEqualStrings("Part 1", Part.one.toString());
    try t.expectEqualStrings("Part 2", Part.two.toString());
}
