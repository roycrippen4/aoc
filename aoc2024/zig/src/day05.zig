const std = @import("std");

const aoc = @import("aoc");

const Allocator = std.mem.Allocator;
const ArrayUsize = std.ArrayList(usize);
const ArrayArrayUsize = std.ArrayList(ArrayUsize);
const RulesMap = std.AutoHashMap(usize, ArrayUsize);

const input = @embedFile("data/day05/data.txt");
const example = @embedFile("data/day05/example.txt");

fn parse_rules(gpa: Allocator, s: []const u8) !RulesMap {
    const trimmed = std.mem.trim(u8, s, "\n");
    var lines = std.mem.tokenizeScalar(u8, trimmed, '\n');
    var map = RulesMap.init(gpa);

    while (lines.next()) |line| {
        // "43|58" -> l = 43, r = 58
        const l_str, const r_str = aoc.Slice.split_once(u8, line, '|');

        const key = try std.fmt.parseInt(usize, l_str, 10);
        const value = try std.fmt.parseInt(usize, r_str, 10);
        const entry = try map.getOrPut(key);

        if (entry.found_existing) {
            try entry.value_ptr.*.append(gpa, value);
        } else {
            var arraylist = try ArrayUsize.initCapacity(gpa, 24);
            try arraylist.append(gpa, value);
            entry.value_ptr.* = arraylist;
        }
    }

    return map;
}

fn parse_update_sequence(gpa: Allocator, line: []const u8) !ArrayUsize {
    var update_sequence = try ArrayUsize.initCapacity(gpa, 24);

    var it = std.mem.splitScalar(u8, line, ',');
    while (it.next()) |update_str| {
        const update = try std.fmt.parseInt(usize, update_str, 10);
        try update_sequence.append(gpa, update);
    }

    return update_sequence;
}

fn parse_updates(gpa: Allocator, s: []const u8) !ArrayArrayUsize {
    var updates = try ArrayArrayUsize.initCapacity(gpa, 256);

    const trimmed = std.mem.trim(u8, s, "\n");
    var lines = std.mem.tokenizeScalar(u8, trimmed, '\n');

    while (lines.next()) |line| {
        const update_sequence = try parse_update_sequence(gpa, line);
        try updates.append(gpa, update_sequence);
    }

    return updates;
}

fn parse(gpa: Allocator, s: []const u8) !struct { RulesMap, ArrayArrayUsize } {
    var parts = std.mem.splitSequence(u8, s, "\n\n");
    const rules_string = parts.next().?;
    const updates_string = parts.next().?;

    return .{
        try parse_rules(gpa, rules_string),
        try parse_updates(gpa, updates_string),
    };
}

fn cleanup(gpa: Allocator, rules: *RulesMap, updates: *ArrayArrayUsize) !void {
    var rules_it = rules.iterator();
    while (rules_it.next()) |entry| {
        entry.value_ptr.deinit(gpa);
    }
    rules.deinit();

    for (updates.items) |*item| {
        item.deinit(gpa);
    }
    updates.deinit(gpa);
}

pub fn evaluate(sequence: []usize, rules: *const RulesMap) usize {
    std.debug.assert(sequence.len % 2 != 0);

    for (0..sequence.len - 1) |i| {
        const update = sequence[i];
        const next_update = sequence[i + 1];
        const rule = rules.get(update) orelse return 0;

        if (!aoc.Slice.includes(usize, rule.items, next_update)) {
            return 0;
        }
    }

    const idx = (sequence.len - 1) / 2;
    return sequence[idx];
}

pub fn part1(gpa: std.mem.Allocator) anyerror!usize {
    var rules, var updates = try parse(gpa, example);
    defer cleanup(gpa, &rules, &updates) catch std.debug.print("ERROR CLEANING UP MEMORY", .{});

    var total: usize = 0;
    std.debug.print("{d}\n", .{total});

    for (updates.items) |sequence| {
        total += evaluate(sequence.items, &rules);
    }

    return total;
}

pub fn part2(_: std.mem.Allocator) anyerror!usize {
    var linesIter = std.mem.tokenizeScalar(u8, example, '\n');

    while (linesIter.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }

    return 42;
}

const t = std.testing;

test "day05 part1" {
    _ = try aoc.validate(part1, 42, aoc.Day.five, aoc.Part.one, t.allocator);
}

test "day05 part2" {
    _ = try aoc.validate(part2, 42, aoc.Day.five, aoc.Part.two, t.allocator);
}

test "day05 parse_rules" {
    const rules_string =
        "47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53\n61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13";
    const gpa = t.allocator;

    var map = try parse_rules(gpa, rules_string);
    defer {
        var map_iterator = map.iterator();
        while (map_iterator.next()) |entry| {
            entry.value_ptr.deinit(gpa);
        }
        map.deinit();
    }

    // from rust (known working)
    // a 29: [ 13 ],
    // b 61: [ 13, 53, 29 ],
    // c 47: [ 53, 13, 61, 29 ],
    // d 53: [ 29, 13 ],
    // e 97: [ 13, 61, 47, 29, 53, 75 ],
    // f 75: [ 29, 53, 47, 61, 13 ],

    // keys
    const a_k = 29;
    const b_k = 61;
    const c_k = 47;
    const d_k = 53;
    const e_k = 97;
    const f_k = 75;

    // expected values
    var a_v: [1]usize = .{13};
    var b_v: [3]usize = .{ 13, 53, 29 };
    var c_v: [4]usize = .{ 53, 13, 61, 29 };
    var d_v: [2]usize = .{ 29, 13 };
    var e_v: [6]usize = .{ 13, 61, 47, 29, 53, 75 };
    var f_v: [5]usize = .{ 29, 53, 47, 61, 13 };

    try t.expectEqualSlices(usize, map.get(a_k).?.items, a_v[0..]);
    try t.expectEqualSlices(usize, map.get(b_k).?.items, b_v[0..]);
    try t.expectEqualSlices(usize, map.get(c_k).?.items, c_v[0..]);
    try t.expectEqualSlices(usize, map.get(d_k).?.items, d_v[0..]);
    try t.expectEqualSlices(usize, map.get(e_k).?.items, e_v[0..]);
    try t.expectEqualSlices(usize, map.get(f_k).?.items, f_v[0..]);
}

// updates =
// [
//     [ 75, 47, 61, 53, 29 ],
//     [ 97, 61, 53, 29, 13 ],
//     [ 75, 29, 13 ],
//     [ 75, 97, 47, 61, 53 ],
//     [ 61, 13, 29 ],
//     [ 97, 13, 75, 29, 47 ],
// ]
