const builtin = @import("builtin");
const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("libaoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day07.txt");

const WIDTH: usize = aoc.slice.line_len(input);
const SPLITTER_CHAR: u8 = '^';
const START_IDX: usize = std.mem.indexOfScalar(u8, input, 'S').?;

var paths: [WIDTH]usize = blk: {
    var p: [WIDTH]usize = @splat(0);
    p[START_IDX] = 1;
    break :blk p;
};

fn part1(_: Allocator) !usize {
    var result: usize = 0;

    var lines = aoc.slice.lines(input);
    while (lines.next()) |line| for (0..line.len) |i| {
        if (line[i] != SPLITTER_CHAR) continue;
        if (paths[i] > 0) result += 1;

        paths[i - 1] += paths[i];
        paths[i + 1] += paths[i];
        paths[i] = 0;
    };
    return result;
}

fn part2(_: Allocator) !usize {
    var result: usize = 0;
    for (paths) |v| result += v;
    return result;
}

pub const solution: Solution = .{
    .day = .@"07",
    .p1 = .{ .f = part1, .expected = 1609 },
    .p2 = .{ .f = part2, .expected = 12472142047197 },
};

test "day07 solution" {
    _ = try solution.solve(testing.allocator);
}
