const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day01/data.txt");

fn part1(_: Allocator) !usize {
    var it = aoc.slice.lines(input);
    var dial: isize = 50;
    var count: usize = 0;

    while (it.next()) |line| {
        const dir = line[0];
        const value = try std.fmt.parseInt(isize, line[1..], 10);

        dial = if (dir == 'L')
            @mod(@mod(dial - value, 100) + 100, 100)
        else
            @mod(@mod(dial + value, 100) + 100, 100);

        if (dial == 0) count += 1;
    }

    return count;
}

fn part2(_: Allocator) !usize {
    return 42;
}

pub fn solution() Solution {
    return .{
        .day = .@"01",
        .p1 = .{ .f = part1, .expected = 1097 },
        .p2 = .{ .f = part2, .expected = 42 },
    };
}

test "day01 part1" {
    _ = try aoc.validate(part1, 1097, .@"01", .one, testing.allocator);
}

test "day01 part2" {
    _ = try aoc.validate(part2, 42, .@"01", .two, testing.allocator);
}

test "day01 solution" {
    _ = try solution().solve(testing.allocator);
}
