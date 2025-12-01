const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day01/data.txt");
const example = @embedFile("data/day01/example.txt");

fn part1(_: Allocator) !usize {
    return 42;
}

fn part2(_: Allocator) !usize {
    return 42;
}

pub fn solution() Solution {
    return .{
        .day = .@"01",
        .p1 = .{ .f = part1, .expected = 42 },
        .p2 = .{ .f = part2, .expected = 42 },
    };
}

test "day01 part1" {
    _ = try aoc.validate(part1, 42, .@"01", .one, testing.allocator);
}

test "day01 part2" {
    _ = try aoc.validate(part2, 42, .@"01", .two, testing.allocator);
}

test "day01 solution" {
    _ = try solution().solve(testing.allocator);
}
