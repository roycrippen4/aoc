const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const mem = std.mem;
const fmt = std.fmt;
const parseInt = fmt.parseInt;

const aoc = @import("aoc");
const Solution = aoc.Solution;

fn n_contains(target: usize, sub: usize) struct { found: bool, target: usize } {
    var target_mut = target;
    var sub_mut = sub;
    var lt = target_mut % 10;
    var ls = sub_mut % 10;

    while (sub_mut > 0) {
        lt = target_mut % 10;
        ls = sub_mut % 10;
        target_mut /= 10;
        sub_mut /= 10;

        if (lt != ls) return .{
            .found = false,
            .target = target,
        };
    }

    return .{
        .found = true,
        .target = target_mut,
    };
}

fn is_target(ops: []usize, idx: usize, target: usize, is_part2: enum { yes, no }) bool {
    if (idx == 0) {
        return target == ops[0];
    }

    if (ops[idx] != 0 and
        target % ops[idx] == 0 and
        is_target(ops, idx - 1, target / ops[idx], is_part2))
    {
        return true;
    }

    if (is_part2 == .yes) {
        const result = n_contains(target, ops[idx]);
        if (result.found and is_target(ops, idx - 1, result.target, is_part2)) {
            return true;
        }
    }

    if (target >= ops[idx] and
        is_target(ops, idx - 1, target - ops[idx], is_part2))
    {
        return true;
    }

    return false;
}

const input = @embedFile("data/day07/data.txt");

fn part1(_: Allocator) !usize {
    var lines = aoc.slice.lines(input);
    var ops: [64]usize = undefined;
    var result: usize = 0;

    while (lines.next()) |line| {
        const target_str, const ops_str = aoc.slice.split_once(u8, line, ':');

        const target_trimmed = mem.trim(u8, target_str, "\n");
        const target = try parseInt(usize, target_trimmed, 10);

        var i: usize = 0;
        var ops_it = mem.splitScalar(u8, mem.trimStart(u8, ops_str, " "), ' ');

        while (ops_it.next()) |part| : (i += 1) {
            ops[i] = try parseInt(usize, part, 10);
        }

        if (is_target(ops[0..i], i - 1, target, .no)) {
            result += target;
        }
    }

    return result;
}

fn part2(_: Allocator) !usize {
    var lines = aoc.slice.lines(input);
    var ops: [64]usize = undefined;
    var result: usize = 0;

    while (lines.next()) |line| {
        const target_str, const ops_str = aoc.slice.split_once(u8, line, ':');
        const target_trimmed = mem.trim(u8, target_str, "\n");
        const target = try parseInt(usize, target_trimmed, 10);

        var i: usize = 0;
        var ops_it = mem.splitScalar(u8, mem.trimStart(u8, ops_str, " "), ' ');

        while (ops_it.next()) |part| : (i += 1) {
            ops[i] = try parseInt(usize, part, 10);
        }

        if (is_target(ops[0..i], i - 1, target, .yes)) {
            result += target;
        }
    }

    return result;
}

pub fn solution() Solution {
    return .{
        .day = .@"07",
        .p1 = .{ .f = part1, .expected = 303766880536 },
        .p2 = .{ .f = part2, .expected = 337041851384440 },
    };
}

test "day07 part1" {
    _ = try aoc.validate(part1, 303766880536, .@"07", .one, testing.allocator);
}

test "day07 part2" {
    _ = try aoc.validate(part2, 337041851384440, .@"07", .two, testing.allocator);
}

test "day07 solution" {
    _ = try solution().solve(testing.allocator);
}
