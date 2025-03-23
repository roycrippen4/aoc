const std = @import("std");
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

const util = @import("util.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) std.testing.expect(false) catch @panic("LEAK DETECTED");
    }
    _ = try util.validate(part1, 1506483, util.Day.one, util.Part.one, allocator);
    _ = try util.validate(part2, 23126924, util.Day.one, util.Part.two, allocator);
}

const input = @embedFile("data/day01/data.txt");

fn parseTuple(line: []const u8) anyerror!struct { usize, usize } {
    var it = std.mem.splitSequence(u8, line, "   ");
    const l = try std.fmt.parseInt(usize, it.next().?, 10);
    const r = try std.fmt.parseInt(usize, it.next().?, 10);

    return .{ l, r };
}

pub fn part1(allocator: std.mem.Allocator) anyerror!usize {
    var left = ArrayList(usize).init(allocator);
    var right = ArrayList(usize).init(allocator);
    defer _ = left.deinit();
    defer _ = right.deinit();

    var flines = std.mem.tokenizeAny(u8, input, "\n");
    while (flines.next()) |line| {
        const l, const r = try parseTuple(line);
        try left.append(l);
        try right.append(r);
    }

    std.mem.sort(usize, left.items, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right.items, {}, comptime std.sort.asc(usize));

    var total: usize = 0;

    for (0..left.items.len) |idx| {
        total += util.absDiff(left.items[idx], right.items[idx]);
    }

    return total;
}

inline fn updateOrInsert(map: *HashMap(usize, usize), key: usize) anyerror!void {
    if (map.get(key)) |value| {
        try map.put(key, value + 1);
    } else {
        try map.put(key, 1);
    }
}

pub fn part2(allocator: std.mem.Allocator) anyerror!usize {
    var left = HashMap(usize, usize).init(allocator);
    var right = HashMap(usize, usize).init(allocator);
    defer _ = left.deinit();
    defer _ = right.deinit();

    var flines = std.mem.tokenizeAny(u8, input, "\n");
    while (flines.next()) |line| {
        const l, const r = try parseTuple(line);
        try updateOrInsert(&left, l);
        try updateOrInsert(&right, r);
    }

    var total: usize = 0;

    var it = left.iterator();
    while (it.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;

        if (right.get(key)) |freq| {
            total += (key * value * freq);
        }
    }

    return total;
}

test "part1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part1(allocator);

    std.debug.print("\n\n Answer: {d}\n\n", .{answer});
}

test "part2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part2(allocator);

    std.debug.print("\n\n Answer: {d}\n\n", .{answer});
}

test "parseTuple" {
    const line = "3   4";
    const l, const r = try parseTuple(line);
    try std.testing.expectEqual(l, 3);
    try std.testing.expectEqual(r, 4);
}

test "test ptr key" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var map = HashMap(usize, usize).init(allocator);
    const key: usize = 5;
    const ptr = &key;

    try map.put(key, 0);
    try std.testing.expectEqual(map.get(key), 0);
    try std.testing.expectEqual(map.get(ptr.*), 0);
}

test "updateOrInsert" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var map = HashMap(usize, usize).init(allocator);

    const no_entry = map.get(5);
    try std.testing.expectEqual(null, no_entry);
    try updateOrInsert(&map, 5);
    try std.testing.expectEqual(map.get(5), 1);
    try updateOrInsert(&map, 5);
    try updateOrInsert(&map, 5);
    try std.testing.expectEqual(map.get(5), 3);
}
