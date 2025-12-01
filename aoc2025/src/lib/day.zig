const std = @import("std");
const Writer = std.io.Writer;

/// An enum representing days for Advent of Code problems (1-25).
/// Each variant corresponds to a day number in the challenge.
pub const Day = enum {
    @"01",
    @"02",
    @"03",
    @"04",
    @"05",
    @"06",
    @"07",
    @"08",
    @"09",
    @"10",
    @"11",
    @"12",
    @"13",
    @"14",
    @"15",
    @"16",
    @"17",
    @"18",
    @"19",
    @"20",
    @"21",
    @"22",
    @"23",
    @"24",
    @"25",

    pub inline fn format(self: Day, writer: *Writer) Writer.Error!void {
        try writer.print("Day {s}", .{@tagName(self)});
    }
};
