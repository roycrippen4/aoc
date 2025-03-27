const lib = @import("lib");
const std = @import("std");

const input = @embedFile("data/day04/data.txt");
const example = @embedFile("data/day04/example.txt");

pub fn part1(_: std.mem.Allocator) anyerror!usize {
    var linesIter = std.mem.tokenizeScalar(u8, example, '\n');

    while (linesIter.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }

    return 42;
}

pub fn part2(_: std.mem.Allocator) anyerror!usize {
    var linesIter = std.mem.tokenizeScalar(u8, example, '\n');

    while (linesIter.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }

    return 42;
}

const t = std.testing;

test "day04 part1" {
    _ = try part1(t.allocator);
    // _ = try lib.validate(part1, 42, lib.Day.four, lib.Part.one, t.allocator);
}

test "day04 part2" {
    _ = try part2(t.allocator);
    // _ = try lib.validate(part2, 42, lib.Day.four, lib.Part.two, t.allocator);
}
