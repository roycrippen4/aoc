const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");

const ArrayUsize = std.ArrayList(usize);
const ArrayArrayUsize = std.ArrayList(ArrayUsize);
const RulesMap = std.AutoHashMap(usize, aoc.Stack(usize, 24));

const input = @embedFile("data/day05/data.txt");

fn parse_rules(gpa: Allocator, s: []const u8) !RulesMap {
    const trimmed = std.mem.trim(u8, s, "\n");
    var lines = std.mem.tokenizeScalar(u8, trimmed, '\n');
    var map: RulesMap = .init(gpa);

    while (lines.next()) |line| {
        // "43|58" -> l = 43, r = 58
        const l_str, const r_str = aoc.slice.split_once(u8, line, '|');

        const key = try std.fmt.parseInt(usize, l_str, 10);
        const value = try std.fmt.parseInt(usize, r_str, 10);

        const entry = try map.getOrPut(key);
        if (entry.found_existing) {
            entry.value_ptr.*.push(value);
        } else {
            var stack: aoc.Stack(usize, 24) = .{};
            stack.push(value);
            entry.value_ptr.* = stack;
        }
    }

    return map;
}

fn parse_update_sequence(gpa: Allocator, line: []const u8) !ArrayUsize {
    var update_sequence: ArrayUsize = try .initCapacity(gpa, 24);

    var it = std.mem.splitScalar(u8, line, ',');
    while (it.next()) |update_str| {
        const update = try std.fmt.parseInt(usize, update_str, 10);
        try update_sequence.append(gpa, update);
    }

    return update_sequence;
}

fn parse_updates(gpa: Allocator, s: []const u8) !ArrayArrayUsize {
    var updates: ArrayArrayUsize = try .initCapacity(gpa, 256);

    var lines = aoc.slice.lines(s);

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

fn evaluate_part1(sequence: []usize, rules: *const RulesMap) usize {
    std.debug.assert(sequence.len % 2 != 0);

    for (0..sequence.len - 1) |i| {
        const update = sequence[i];
        const next_update = sequence[i + 1];
        const rule = rules.get(update) orelse return 0;

        if (!aoc.slice.contains(usize, &rule.items, next_update)) {
            return 0;
        }
    }

    const idx = (sequence.len - 1) / 2;
    return sequence[idx];
}

pub fn part1(gpa: Allocator) !usize {
    var rules, var updates = try parse(gpa, input);
    defer {
        rules.deinit();
        for (updates.items) |*item| item.deinit(gpa);
        updates.deinit(gpa);
    }

    var total: usize = 0;
    for (updates.items) |sequence| {
        total += evaluate_part1(sequence.items, &rules);
    }

    return total;
}

fn is_in_order(update: []usize, map: RulesMap) bool {
    for (0..update.len - 1) |i| {
        const current = update[i];
        const next = update[i + 1];

        const mapping = map.get(current) orelse return false;
        if (!aoc.slice.contains(usize, &mapping.items, next)) {
            return false;
        }
    }

    return true;
}

fn fix_order(update: *ArrayUsize, map: RulesMap) void {
    if (is_in_order(update.items, map)) return;

    for (0..update.items.len - 1) |i| {
        const mapping = map.get(update.items[i]) orelse {
            std.mem.swap(usize, &update.items[i], &update.items[i + 1]);
            continue;
        };

        if (!aoc.slice.contains(usize, &mapping.items, update.items[i + 1])) {
            std.mem.swap(usize, &update.items[i], &update.items[i + 1]);
            continue;
        }
    }

    fix_order(update, map);
}

pub fn part2(gpa: Allocator) !usize {
    var rules, var updates = try parse(gpa, input);
    defer {
        rules.deinit();
        for (updates.items) |*item| item.deinit(gpa);
        updates.deinit(gpa);
    }

    var total: usize = 0;

    for (updates.items) |*update| {
        if (is_in_order(update.items, rules)) continue;
        fix_order(update, rules);

        const idx = (update.items.len - 1) / 2;
        total += update.items[idx];
    }

    return total;
}

test "day05 part1" {
    _ = try aoc.validate(part1, 7198, .@"05", .one, testing.allocator);
}

test "day05 part2" {
    _ = try aoc.validate(part2, 4230, .@"05", .two, testing.allocator);
}
