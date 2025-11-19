const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const mem = std.mem;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input: []const u8 = @embedFile("data/day03/data.txt");

inline fn parse(s: []const u8) u64 {
    const comma_idx = mem.indexOfScalar(u8, s, ',') orelse return 0;
    const x_slice = s[4..comma_idx];
    const y_slice = s[comma_idx + 1 .. s.len - 1];
    const x = std.fmt.parseInt(u64, x_slice, 10) catch unreachable;
    const y = std.fmt.parseInt(u64, y_slice, 10) catch unreachable;
    return x * y;
}

inline fn is_mul(s: []const u8) bool {
    return mem.startsWith(u8, s, "mul(");
}

inline fn get_paren_idx(s: []const u8) usize {
    return mem.indexOfScalar(u8, s, ')') orelse @panic("failed to find a `)`");
}

inline fn is_do(s: []const u8) bool {
    return mem.startsWith(u8, s, "do()");
}

inline fn is_dont(s: []const u8) bool {
    return mem.startsWith(u8, s, "don't()");
}

fn part1(_: Allocator) !usize {
    var i: u64 = 0;
    var sum: u64 = 0;

    while (i < input.len) : (i += 1) {
        if (!is_mul(input[i..])) continue;

        const j = get_paren_idx(input[i..]);
        if (j >= 12) continue;

        sum += parse(input[i .. i + j + 1]);
        i += j;
    }

    return sum;
}

fn part2(_: Allocator) !usize {
    var i: u64 = 0;
    var enable = true;
    var sum: u64 = 0;

    while (i < input.len) : (i += 1) {
        if (is_do(input[i..])) {
            enable = true;
            i += 3;
            continue;
        }

        if (is_dont(input[i..])) {
            enable = false;
            i += 6;
            continue;
        }

        if (!enable or !is_mul(input[i..])) continue;

        const j = get_paren_idx(input[i..]);
        if (j >= 12) continue;

        sum += parse(input[i .. i + j + 1]);
        i += j;
    }

    return sum;
}

pub fn solution() Solution {
    return .{
        .day = .@"03",
        .p1 = .{ .f = part1, .expected = 173731097 },
        .p2 = .{ .f = part2, .expected = 93729253 },
    };
}

test "day03 part1" {
    _ = try aoc.validate(part1, 173731097, .@"03", .one, testing.allocator);
}

test "day03 part2" {
    _ = try aoc.validate(part2, 93729253, .@"03", .two, testing.allocator);
}

test "day03 solution" {
    _ = try solution().solve(testing.allocator);
}

test "day03 parse" {
    const result = parse("mul(2,4)");
    try std.testing.expectEqual(8, result);
}
