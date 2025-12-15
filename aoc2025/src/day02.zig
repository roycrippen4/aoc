const std = @import("std");
const log10_int = std.math.log10_int;
const pow = std.math.pow;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const split_once = aoc.slice.split_once;
const Solution = aoc.Solution;

const input = aoc.slice.trim(@embedFile("data/day02/data.txt"));
const example = aoc.slice.trim(@embedFile("data/day02/example.txt"));

inline fn quantize_hi(hi: []const u8) usize {
    return switch (hi.len) {
        3 => 9,
        5 => 99,
        7 => 999,
        9 => 9999,
        else => unreachable,
    };
}

inline fn quantize_lo(lo: []const u8) usize {
    return switch (lo.len) {
        1 => 1,
        3 => 10,
        5 => 100,
        7 => 1000,
        9 => 10000,
        else => unreachable,
    };
}

inline fn into_id(n: usize) usize {
    const d = log10_int(n) + 1;
    const pow10 = pow(usize, 10, d);
    return n * pow10 + n;
}

fn sum_invalid_ids(range_str: []const u8) !usize {
    const lo_str, const hi_str = split_once(u8, range_str, '-');

    const lo_original = try parseInt(usize, lo_str, 10);
    const hi_original = try parseInt(usize, hi_str, 10);

    const lo_has_even_digits = lo_str.len % 2 == 0;
    const hi_has_even_digits = hi_str.len % 2 == 0;

    const eql_len = lo_str.len == hi_str.len;

    if (!lo_has_even_digits and !hi_has_even_digits and eql_len) {
        return 0;
    }

    const hi = switch (hi_has_even_digits) {
        true => blk: {
            const hi = try parseInt(usize, hi_str[0 .. hi_str.len / 2], 10);
            break :blk if (into_id(hi) > hi_original) hi - 1 else hi;
        },
        false => quantize_hi(hi_str),
    };

    var lo = switch (lo_has_even_digits) {
        true => blk: {
            const lo = try parseInt(usize, lo_str[0 .. lo_str.len / 2], 10);
            const lo_id = into_id(lo);
            if (lo_id > hi_original) return 0;

            break :blk if (lo_id < lo_original) lo + 1 else lo;
        },
        false => quantize_lo(lo_str),
    };

    var sum: usize = 0;
    while (lo <= hi) : (lo += 1) sum += into_id(lo);
    return sum;
}

fn part1(_: Allocator) !usize {
    var sum: usize = 0;

    var it = std.mem.splitScalar(u8, input, ',');
    while (it.next()) |range| {
        sum += try sum_invalid_ids(range);
    }

    return sum;
}

fn repeat(n_str: []const u8, len: usize) !usize {
    const n = try parseInt(usize, n_str, 10);
    const num = pow(usize, 10, len) - 1;
    const den = pow(usize, 10, n_str.len) - 1;
    return n * (num / den);
}

fn sum_invalid_ids2(range_str: []const u8) !usize {
    var s: aoc.Stack(usize, 1000) = .{};
    var sum: usize = 0;

    const lo_str, const hi_str = split_once(u8, range_str, '-');

    const lo_original = try parseInt(usize, lo_str, 10);
    const hi_original = try parseInt(usize, hi_str, 10);

    var i: usize = 1;
    while (i <= lo_str.len / 2) : (i += 1) {
        if (lo_str.len % i != 0) continue;

        const r = try repeat(lo_str[0..i], lo_str.len);

        if (r > lo_original and r < hi_original and !s.contains(r)) {
            sum += r;
            s.push(r);
        }
    }
    i = 1;

    while (i <= hi_str.len / 2) : (i += 1) {
        if (hi_str.len % i != 0) continue;

        const r = try repeat(hi_str[0..i], hi_str.len);

        if (r > lo_original and r < hi_original and !s.contains(r)) {
            sum += r;
            s.push(r);
        }
    }

    var clen = lo_str.len;
    while (clen <= hi_str.len) : (clen += 1) {
        const eff_lo = if (clen == lo_str.len) lo_original else pow(usize, 10, clen - 1);
        const eff_hi = if (clen == hi_str.len) hi_original else pow(usize, 10, clen) - 1;

        var d: usize = 1;
        while (d <= clen / 2) : (d += 1) {
            if (clen % d != 0) continue;

            const num = pow(usize, 10, clen) - 1;
            const den = pow(usize, 10, d) - 1;
            const mult = num / den;

            const gen_min = (eff_lo + mult - 1) / mult;
            const gen_max = eff_hi / mult;

            var g = gen_min;
            while (g <= gen_max) : (g += 1) {
                const id = g * mult;
                if (!s.contains(id)) {
                    sum += id;
                    s.push(id);
                }
            }
        }
    }

    return sum;
}

fn part2(_: Allocator) !usize {
    var sum: usize = 0;

    var it = std.mem.splitScalar(u8, input, ',');
    while (it.next()) |range| {
        sum += try sum_invalid_ids2(range);
    }

    return sum;
}

pub fn solution() Solution {
    return .{
        .day = .@"02",
        .p1 = .{ .f = part1, .expected = 18893502033 },
        .p2 = .{ .f = part2, .expected = 26202168557 },
    };
}

test "day02 part 1 example" {
    var sum: usize = 0;

    var it = std.mem.splitScalar(u8, example, ',');
    while (it.next()) |range| {
        sum += try sum_invalid_ids(range);
    }

    try testing.expectEqual(1227775554, sum);
}

test "day02 part 2 example" {
    var sum: usize = 0;

    var it = std.mem.splitScalar(u8, example, ',');
    while (it.next()) |range| {
        sum += try sum_invalid_ids2(range);
    }

    try testing.expectEqual(4174379265, sum);
}

test "day02 part1" {
    _ = try aoc.validate(part1, 18893502033, .@"02", .one, testing.allocator);
}

test "day02 part2" {
    _ = try aoc.validate(part2, 26202168557, .@"02", .two, testing.allocator);
}

test "day02 solution" {
    _ = try solution().solve(testing.allocator);
}

test "day02 into_id" {
    try testing.expectEqual(1010, into_id(10));
    try testing.expectEqual(11, into_id(1));
    try testing.expectEqual(9999, into_id(99));
    try testing.expectEqual(123123, into_id(123));
}

test "day02 sum_invalid_ids" {
    try testing.expectEqual(33, try sum_invalid_ids("11-22"));
    try testing.expectEqual(99, try sum_invalid_ids("95-115"));
    try testing.expectEqual(1010, try sum_invalid_ids("998-1012"));
    try testing.expectEqual(1188511885, try sum_invalid_ids("1188511880-1188511890"));
    try testing.expectEqual(222222, try sum_invalid_ids("222220-222224"));
    try testing.expectEqual(0, try sum_invalid_ids("1698522-1698528"));
    try testing.expectEqual(446446, try sum_invalid_ids("446443-446449"));
    try testing.expectEqual(38593859, try sum_invalid_ids("38593856-38593862"));
    try testing.expectEqual(0, try sum_invalid_ids("565653-565659"));
    try testing.expectEqual(0, try sum_invalid_ids("824824821-824824827"));
    try testing.expectEqual(0, try sum_invalid_ids("2121212118-2121212124"));
}

test "day02 sum_invalid_ids2" {
    try testing.expectEqual(11 + 22, try sum_invalid_ids2("11-22"));
    try testing.expectEqual(99 + 111, try sum_invalid_ids2("95-115"));
    try testing.expectEqual(999 + 1010, try sum_invalid_ids2("998-1012"));
    try testing.expectEqual(1188511885, try sum_invalid_ids2("1188511880-1188511890"));
    try testing.expectEqual(222222, try sum_invalid_ids2("222220-222224"));
    try testing.expectEqual(0, try sum_invalid_ids2("1698522-1698528"));
    try testing.expectEqual(446446, try sum_invalid_ids2("446443-446449"));
    try testing.expectEqual(38593859, try sum_invalid_ids2("38593856-38593862"));
    try testing.expectEqual(565656, try sum_invalid_ids2("565653-565659"));
    try testing.expectEqual(824824824, try sum_invalid_ids2("824824821-824824827"));
    try testing.expectEqual(2121212121, try sum_invalid_ids2("2121212118-2121212124"));
}
