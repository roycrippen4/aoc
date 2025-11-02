const std = @import("std");
const Allocator = std.mem.Allocator;
const t = std.testing;
const mem = std.mem;
const fmt = std.fmt;
const parseInt = fmt.parseInt;

const aoc = @import("aoc");

const input = @embedFile("data/day07/data.txt");

fn eval_part1(root: usize, tgt: usize, idx: usize, vs: []usize) bool {
    if (vs.len == idx) return false;

    const l = root + vs[idx];
    const r = root * vs[idx];
    const is_tgt = l == tgt or r == tgt;
    const all_used = vs.len - 1 == idx;

    return if (is_tgt and all_used)
        true
    else
        eval_part1(r, tgt, idx + 1, vs) or eval_part1(l, tgt, idx + 1, vs);
}

pub fn part1(_: Allocator) !usize {
    var lines = aoc.slice.lines(u8, input);
    var parts_buf: [64]usize = undefined;
    var result: usize = 0;

    while (lines.next()) |line| {
        const target_str, const list_str = aoc.slice.split_once(u8, line, ':');

        const target_trimmed = mem.trim(u8, target_str, "\n");
        const target = try parseInt(usize, target_trimmed, 10);

        var i: usize = 0;
        var list_it = mem.splitScalar(u8, mem.trimStart(u8, list_str, " "), ' ');

        while (list_it.next()) |part| : (i += 1) {
            parts_buf[i] = try parseInt(usize, part, 10);
        }

        if (eval_part1(parts_buf[0], target, 1, parts_buf[0..i])) {
            result += target;
        }
    }

    return result;
}

pub fn concat_usize(a: usize, b: usize) usize {
    var mult: usize = 1;
    var temp: usize = b;

    while (temp > 0) {
        mult *= 10;
        temp /= 10;
    }

    return a * mult + b;
}

fn eval_part2(root: usize, tgt: usize, idx: usize, vs: []usize) bool {
    if (vs.len == idx) return false;

    const next = vs[idx];
    const plus = root + next;
    const concat = concat_usize(root, next);
    const mult = root * next;
    const is_tgt = plus == tgt or mult == tgt or concat == tgt;
    const all_used = vs.len - 1 == idx;

    if (is_tgt and all_used) return true;

    const next_idx = idx + 1;
    return eval_part2(plus, tgt, next_idx, vs) or
        eval_part2(concat, tgt, next_idx, vs) or
        eval_part2(mult, tgt, next_idx, vs);
}

pub fn part2(_: Allocator) !usize {
    var lines = aoc.slice.lines(u8, input);
    var parts_buf: [64]usize = undefined;
    var result: usize = 0;

    while (lines.next()) |line| {
        const target_str, const list_str = aoc.slice.split_once(u8, line, ':');

        const target_trimmed = mem.trim(u8, target_str, "\n");
        const target = try parseInt(usize, target_trimmed, 10);

        var i: usize = 0;
        var list_it = mem.splitScalar(u8, mem.trimStart(u8, list_str, " "), ' ');

        while (list_it.next()) |part| : (i += 1) {
            parts_buf[i] = try parseInt(usize, part, 10);
        }

        if (eval_part2(parts_buf[0], target, 1, parts_buf[0..i])) {
            result += target;
        }
    }

    return result;
}

test "day07 part1" {
    _ = try aoc.validate(part1, 303766880536, aoc.Day.@"07", aoc.Part.one, t.allocator);
}

test "day07 part2" {
    _ = try aoc.validate(part2, 337041851384440, aoc.Day.@"07", aoc.Part.two, t.allocator);
}

test "day07 eval_part1" {
    var v0 = [2]usize{ 10, 19 };
    try t.expect(eval_part1(v0[0], 190, 1, v0[0..]));

    var v1 = [3]usize{ 81, 40, 27 };
    try t.expect(eval_part1(v1[0], 3267, 1, v1[0..]));

    var v2 = [2]usize{ 17, 5 };
    try t.expect(!eval_part1(v2[0], 83, 1, v2[0..]));

    var v3 = [4]usize{ 6, 8, 6, 15 };
    try t.expect(!eval_part1(v3[0], 7290, 1, v3[0..]));

    var v4 = [3]usize{ 16, 10, 13 };
    try t.expect(!eval_part1(v4[0], 161011, 1, v4[0..]));

    var v5 = [3]usize{ 17, 8, 14 };
    try t.expect(!eval_part1(v5[0], 192, 1, v5[0..]));

    var v6 = [4]usize{ 9, 7, 18, 13 };
    try t.expect(!eval_part1(v6[0], 21037, 1, v6[0..]));

    var v7 = [4]usize{ 11, 6, 16, 20 };
    try t.expect(eval_part1(v7[0], 292, 1, v7[0..]));
}
