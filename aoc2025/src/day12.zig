const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("libaoc");
const Stack = aoc.Stack;
const Solution = aoc.Solution;

const input = @embedFile("data/day12.txt");

const Case = struct {
    scaled_area: u32,
    shape_count_sum: u32,
    const Self = @This();

    fn from_string(slice: []const u8) @This() {
        var tokens = std.mem.tokenizeScalar(u8, slice[7..], ' ');
        var count_sum: u32 = 0;
        while (tokens.next()) |token| {
            count_sum += ((token[0] - '0') * 10) + (token[1] - '0');
        }
        const width: u32 = ((slice[0] - '0') * 10) + (slice[1] - '0');
        const height: u32 = ((slice[3] - '0') * 10) + (slice[4] - '0');
        return .{
            .scaled_area = (width / 3) * (height / 3),
            .shape_count_sum = count_sum,
        };
    }
};

const CASES_START_INDEX: usize = std.mem.indexOfScalar(u8, input, 'x').? - 2;
const CASES: Stack(Case, 1000) = blk: {
    const slice = input[CASES_START_INDEX..];
    var cases: Stack(Case, 1000) = .empty;
    var lines = aoc.slice.lines(slice);
    while (lines.next()) |line| {
        cases.push(.from_string(line));
    }
    break :blk cases;
};
const SHAPE_AREAS: Stack(u32, 6) = blk: {
    var areas: Stack(u32, 6) = .empty;
    var blocks = std.mem.tokenizeSequence(u8, input[0 .. CASES_START_INDEX - 2], "\n\n");
    while (blocks.next()) |block| {
        var count: u32 = 0;
        for (block[3..]) |ch| if (ch == '#') {
            count += 1;
        };
        areas.push(count);
    }
    break :blk areas;
};

fn part1(_: Allocator) !usize {
    var result: usize = 0;
    for (CASES.to_slice()) |case| {
        if (case.scaled_area >= case.shape_count_sum) {
            result += 1;
        }
    }

    return result;
}

fn part2(_: Allocator) !usize {
    return 42;
}

const expected_part1: usize = 463;
const expected_part2: usize = 42;

pub const solution: Solution = .{
    .day = .@"12",
    .p1 = .{ .f = part1, .expected = 463 },
    .p2 = .{ .f = part2, .expected = expected_part2 },
};

test "day12 part1" {
    _ = try aoc.validate(testing.allocator, part1, 463, .@"12", .one);
}

test "day12 part2" {
    _ = try aoc.validate(testing.allocator, part2, expected_part2, .@"12", .two);
}

test "day12 solution" {
    _ = try solution.solve(testing.allocator);
}
