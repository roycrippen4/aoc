const lib = @import("aoc");
const std = @import("std");
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;
const t = std.testing;

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
        total += lib.absDiff(left.items[idx], right.items[idx]);
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

test "part2" {
    _ = try lib.validate(part1, 1506483, lib.Day.one, lib.Part.one, t.allocator);
}

test "day01 part2" {
    _ = try lib.validate(part2, 23126924, lib.Day.one, lib.Part.two, t.allocator);
}

test "day01 parseTuple" {
    const line = "3   4";
    const l, const r = try parseTuple(line);
    try t.expectEqual(l, 3);
    try t.expectEqual(r, 4);
}

test "day01 updateOrInsert" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var map = HashMap(usize, usize).init(allocator);

    const no_entry = map.get(5);
    try t.expectEqual(null, no_entry);
    try updateOrInsert(&map, 5);
    try t.expectEqual(map.get(5), 1);
    try updateOrInsert(&map, 5);
    try updateOrInsert(&map, 5);
    try t.expectEqual(map.get(5), 3);
}
