const std = @import("std");
const Allocator = std.mem.Allocator;
const util = @import("util.zig");

const input = @embedFile("data/day02/data.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) std.testing.expect(false) catch @panic("LEAK DETECTED");
    }

    _ = try util.validate(part1, 202, util.Day.two, util.Part.one, allocator);
    _ = try util.validate(part2, 271, util.Day.two, util.Part.two, allocator);
}

inline fn pairIsSafe(x: i64, y: i64, desc: bool) bool {
    const diff = x - y;
    return diff != 0 and @abs(diff) <= 3 and (diff > 0) == desc;
}

fn isSafe(line: []const u8) bool {
    var it = std.mem.tokenizeScalar(u8, line, ' ');

    const ix = std.fmt.parseInt(i64, it.next().?, 10) catch unreachable;
    const iy = std.fmt.parseInt(i64, it.peek().?, 10) catch unreachable;
    const desc = ix - iy > 0;
    it.reset();

    while (it.next()) |x_str| {
        if (it.peek()) |y_str| {
            const x = std.fmt.parseInt(i64, x_str, 10) catch unreachable;
            const y = std.fmt.parseInt(i64, y_str, 10) catch unreachable;
            if (!pairIsSafe(x, y, desc)) return false;
        }
    }
    return true;
}

fn isSafe2(line: []const u8, buffer: []i64) bool {
    var it = std.mem.splitScalar(u8, line, ' ');
    var count: usize = 0;

    while (it.next()) |v_str| : (count += 1) {
        if (count >= buffer.len) break;
        buffer[count] = std.fmt.parseInt(i64, v_str, 10) catch unreachable;
    }

    const nums = buffer[0..count];
    if (check(nums)) return true;

    std.mem.reverse(i64, nums);
    return check(nums);
}

fn check(nums: []const i64) bool {
    const desc = nums[0] - nums[1] > 0;

    var skip = false;
    var i: usize = 0;

    while (i + 1 < nums.len) : (i += 1) {
        const x = nums[i];
        const y = nums[i + 1];

        if (pairIsSafe(x, y, desc)) continue;
        if (skip) return false;

        if (i + 2 < nums.len) {
            skip = true;
            if (!pairIsSafe(x, nums[i + 2], desc)) return false;
            i += 1;
        }
    }

    return true;
}

pub fn part1(_: Allocator) anyerror!usize {
    var answer: usize = 0;
    var linesIter = std.mem.tokenizeScalar(u8, input, '\n');

    while (linesIter.next()) |line| {
        if (isSafe(line)) answer += 1;
    }

    return answer;
}

pub fn part2(allocator: Allocator) anyerror!usize {
    var answer: usize = 0;
    var it = std.mem.tokenizeScalar(u8, input, '\n');

    const buf = allocator.alloc(i64, 20) catch unreachable;
    defer allocator.free(buf);

    while (it.next()) |line| {
        if (isSafe2(line, buf)) answer += 1;
    }

    return answer;
}

test "part1" {
    _ = try util.validate(part1, 202, util.Day.two, util.Part.one, std.testing.allocator);
}

test "part2" {
    _ = try util.validate(part2, 271, util.Day.two, util.Part.two, std.testing.allocator);
}

test "isSafe" {
    try std.testing.expect(isSafe("7 6 4 2 1"));
    try std.testing.expect(!isSafe("1 2 7 8 9"));
    try std.testing.expect(!isSafe("9 7 6 2 1"));
    try std.testing.expect(!isSafe("1 3 2 4 5"));
    try std.testing.expect(!isSafe("8 6 4 4 1"));
    try std.testing.expect(isSafe("1 3 6 7 9"));
}

test "check" {
    try std.testing.expect(check(&[_]i64{ 7, 6, 4, 2, 1 }, true));
    try std.testing.expect(!check(&[_]i64{ 1, 2, 7, 8, 9 }, false));
    try std.testing.expect(!check(&[_]i64{ 9, 7, 6, 2, 1 }, true));
    try std.testing.expect(check(&[_]i64{ 1, 3, 2, 4, 5 }, false));
    try std.testing.expect(check(&[_]i64{ 8, 6, 4, 4, 1 }, true));
    try std.testing.expect(check(&[_]i64{ 1, 3, 6, 7, 9 }, false));
}
