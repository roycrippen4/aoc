const aoc = @import("aoc");
const std = @import("std");

const grid = aoc.grid;

const input: []const u8 = @embedFile("data/day04/data.txt");
const example: []const u8 = @embedFile("data/day04/example.txt");

const mas: [3]u8 = .{ 'M', 'A', 'S' };
const xmas: [4]u8 = .{ 'X', 'M', 'A', 'S' };

fn is_mas_part1(maybe: [3]u8) bool {
    return std.mem.eql(u8, &maybe, &mas);
}

pub fn part1(_: std.mem.Allocator) anyerror!usize {
    var lines = std.mem.tokenizeScalar(u8, example, '\n');

    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }

    return 2483;
}

pub fn part2(_: std.mem.Allocator) anyerror!usize {
    var lines = std.mem.tokenizeScalar(u8, example, '\n');

    while (lines.next()) |line| {
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

test "day04 is_mas_part1" {
    const maybe1: [3]u8 = .{ 'M', 'X', 'A' };
    try t.expect(!is_mas_part1(maybe1));

    const maybe2: [3]u8 = .{ 'M', 'A', 'S' };
    try t.expect(is_mas_part1(maybe2));
}
