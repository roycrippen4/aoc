const std = @import("std");
const aoc = @import("aoc");

const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;
const testing = std.testing;

const input = std.mem.trim(u8, @embedFile("data/day01/data.txt"), "\n");

fn parseTuple(line: []const u8) !struct { usize, usize } {
    var it = std.mem.splitSequence(u8, line, "   ");
    const l = try std.fmt.parseInt(usize, it.next().?, 10);
    const r = try std.fmt.parseInt(usize, it.next().?, 10);

    return .{ l, r };
}

pub fn part1(gpa: std.mem.Allocator) !usize {
    var left = try ArrayList(usize).initCapacity(gpa, 1024);
    var right = try ArrayList(usize).initCapacity(gpa, 1024);
    defer left.deinit(gpa);
    defer right.deinit(gpa);

    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        const l, const r = try parseTuple(line);
        try left.append(gpa, l);
        try right.append(gpa, r);
    }

    std.mem.sort(usize, left.items, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right.items, {}, comptime std.sort.asc(usize));

    var total: usize = 0;

    for (0..left.items.len) |idx| {
        total += aoc.math.abs_diff(left.items[idx], right.items[idx]);
    }

    return total;
}

inline fn updateOrInsert(map: *HashMap(usize, usize), key: usize) !void {
    if (map.get(key)) |value| {
        try map.put(key, value + 1);
    } else {
        try map.put(key, 1);
    }
}

pub fn part2(allocator: std.mem.Allocator) !usize {
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

test "day01 part1" {
    _ = try aoc.validate(part1, 1506483, aoc.Day.@"01", aoc.Part.one, testing.allocator);
}

test "day01 part2" {
    _ = try aoc.validate(part2, 23126924, aoc.Day.@"01", aoc.Part.two, testing.allocator);
}

test "day01 parseTuple" {
    const line = "3   4";
    const l, const r = try parseTuple(line);
    try testing.expectEqual(l, 3);
    try testing.expectEqual(r, 4);
}

test "day01 updateOrInsert" {
    var map = HashMap(usize, usize).init(testing.allocator);

    const no_entry = map.get(5);
    try testing.expectEqual(null, no_entry);
    try updateOrInsert(&map, 5);
    try testing.expectEqual(map.get(5), 1);
    try updateOrInsert(&map, 5);
    try updateOrInsert(&map, 5);
    try testing.expectEqual(map.get(5), 3);
}
