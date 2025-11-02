const aoc = @import("aoc");
const std = @import("std");

const input: []const u8 = @embedFile("data/day03/data.txt");

inline fn parse(s: []const u8) u64 {
    const comma_idx = std.mem.indexOfScalar(u8, s, ',') orelse return 0;
    const x_slice = s[4..comma_idx];
    const y_slice = s[comma_idx + 1 .. s.len - 1];
    const x = std.fmt.parseInt(u64, x_slice, 10) catch unreachable;
    const y = std.fmt.parseInt(u64, y_slice, 10) catch unreachable;
    return x * y;
}

inline fn isMul(s: []const u8) bool {
    return std.mem.startsWith(u8, s, "mul(");
}

inline fn getParenIdx(s: []const u8) usize {
    return std.mem.indexOfScalar(u8, s, ')') orelse @panic("failed to find a `)`");
}

inline fn isDo(s: []const u8) bool {
    return std.mem.startsWith(u8, s, "do()");
}

inline fn isDont(s: []const u8) bool {
    return std.mem.startsWith(u8, s, "don't()");
}

pub fn part1(_: std.mem.Allocator) anyerror!usize {
    var i: u64 = 0;
    var sum: u64 = 0;

    while (i < input.len) : (i += 1) {
        if (!isMul(input[i..])) continue;

        const j = getParenIdx(input[i..]);
        if (j >= 12) continue;

        sum += parse(input[i .. i + j + 1]);
        i += j;
    }

    return sum;
}

pub fn part2(_: std.mem.Allocator) anyerror!usize {
    var i: u64 = 0;
    var enable = true;
    var sum: u64 = 0;

    while (i < input.len) : (i += 1) {
        if (isDo(input[i..])) {
            enable = true;
            i += 3;
            continue;
        }

        if (isDont(input[i..])) {
            enable = false;
            i += 6;
            continue;
        }

        if (!enable or !isMul(input[i..])) continue;

        const j = getParenIdx(input[i..]);
        if (j >= 12) continue;

        sum += parse(input[i .. i + j + 1]);
        i += j;
    }

    return sum;
}

const t = std.testing;

test "day03 part1" {
    _ = try aoc.validate(part1, 173731097, aoc.Day.@"03", aoc.Part.one, t.allocator);
}

test "day03 part2" {
    _ = try aoc.validate(part2, 93729253, aoc.Day.@"03", aoc.Part.two, t.allocator);
}

test "day03 parse" {
    const result = parse("mul(2,4)");
    try std.testing.expectEqual(8, result);
}
