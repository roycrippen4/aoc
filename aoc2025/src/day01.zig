const std = @import("std");
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day01/data.txt");

inline fn parse_value(line: []const u8) !isize {
    const sign: isize = if (line[0] == 'L') @as(isize, -1) else 1;
    return try parseInt(isize, line[1..], 10) * sign;
}

fn part1(_: Allocator) !usize {
    var it = aoc.slice.lines(input);
    var dial: isize = 50;
    var count: usize = 0;

    while (it.next()) |line| {
        const value = try parse_value(line);
        dial = @mod(dial + value, 100);
        if (dial == 0) count += 1;
    }

    return count;
}

fn part2(_: Allocator) !usize {
    var it = aoc.slice.lines(input);

    var dial: isize = 50;
    var count: isize = 0;

    while (it.next()) |line| {
        const value = try parseInt(isize, line[1..], 10);

        if (line[0] == 'R') {
            count += @divFloor(dial + value, 100);
            dial = @mod(dial + value, 100);
        } else {
            count += @divFloor(value, 100);
            if (dial != 0 and @mod(value, 100) >= dial) count += 1;
            dial = @mod(dial - value, 100);
        }
    }

    return @intCast(count);
}

pub const solution: Solution = .{
    .day = .@"01",
    .p1 = .{ .f = part1, .expected = 1097 },
    .p2 = .{ .f = part2, .expected = 7101 },
};

test "day01 part1" {
    _ = try aoc.validate(part1, 1097, .@"01", .one, testing.allocator);
}

test "day01 part2" {
    _ = try aoc.validate(part2, 7101, .@"01", .two, testing.allocator);
}

test "day01 solution" {
    _ = try solution.solve(testing.allocator);
}
