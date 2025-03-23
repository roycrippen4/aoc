const std = @import("std");
const util = @import("util.zig");

const input = @embedFile("data/day02/data.txt");
const example = @embedFile("data/day02/example.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) std.testing.expect(false) catch @panic("LEAK DETECTED");
    }

    _ = try util.validate(part1, 42, util.Day.two, util.Part.one, allocator);
    _ = try util.validate(part2, 42, util.Day.day, util.Part.two, allocator);
}

fn parseLevels(line: []const u8, allocator: std.mem.Allocator) []u64 {
    const str_levels = util.splitByte(line, ' ', allocator);
    defer allocator.free(str_levels);
    const levels = allocator.alloc(u64, str_levels.len) catch unreachable;

    for (0..str_levels.len, str_levels) |i, value| {
        levels[i] = std.fmt.parseInt(usize, value, 10) catch unreachable;
    }

    return levels;
}

fn pairIsSafe(x: u64, y: u64, direction: bool) bool {
    const ix: i64 = @intCast(x);
    const iy: i64 = @intCast(y);
    const diff = ix - iy;
    return diff != 0 and @abs(diff) <= 3 and (diff > 0) == direction;
}

fn isSafe(levels: []u64) bool {
    const x: i64 = @intCast(levels[0]);
    const y: i64 = @intCast(levels[1]);
    const direction = x - y > 0;

    for (0..levels.len - 1) |i| {
        if (i == levels.len - 1) {
            return true;
        }

        const safe = pairIsSafe(levels[i], levels[i + 1], direction);
        if (!safe) {
            return false;
        }
    }

    return true;
}

pub fn part1(allocator: std.mem.Allocator) anyerror!usize {
    const lines = util.lines(input, allocator);
    defer allocator.free(lines);

    var answer: usize = 0;

    for (lines) |line| {
        const levels = parseLevels(line, allocator);
        if (isSafe(levels)) {
            answer += 1;
        }
    }

    return answer;
}

pub fn part2(allocator: std.mem.Allocator) anyerror!usize {
    const lines = util.lines(example, allocator);
    for (lines) |line| {
        std.debug.print("{s}\n", .{line});
    }
    return 42;
}

test "part1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part1(allocator);

    std.debug.print("\n\nAnswer: {d}\n\n", .{answer});
}

test "part2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part2(allocator);

    std.debug.print("\n\nAnswer: {d}\n\n", .{answer});
}

test "isSafe" {
    var list = [_]u64{ 1, 3, 6, 7, 9 };
    try std.testing.expect(isSafe(&list));
}

test "pairIsSafe" {
    try std.testing.expect(pairIsSafe(1, 3, 1 - 3 > 0));
}

test "parseValues" {
    const allocator = std.testing.allocator;
    const s = "7 6 4 2 1";
    const values = parseLevels(s, allocator);
    defer allocator.free(values);
    const expected = [_]u64{ 7, 6, 4, 2, 1 };
    try std.testing.expect(std.mem.eql(u64, values, &expected));
}
