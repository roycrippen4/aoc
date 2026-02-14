const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;
const Point = aoc.Point;

const abs_diff = aoc.math.abs_diff;
const input = aoc.slice.trim(@embedFile("data/day09/data.txt"));

const COUNT: usize = aoc.slice.line_count(input);
const COORDS: [COUNT]Point = blk: {
    var coords: [COUNT]Point = undefined;

    var i: usize = 0;
    var it = aoc.slice.lines(input);
    while (it.next()) |line| : (i += 1) {
        const x_str, const y_str = aoc.slice.split_once_scalar(u8, line, ',');
        const x = std.fmt.parseInt(usize, x_str, 10) catch unreachable;
        const y = std.fmt.parseInt(usize, y_str, 10) catch unreachable;
        coords[i] = .{ .x = x, .y = y };
    }

    break :blk coords;
};

fn part1(_: Allocator) !usize {
    var max_area: usize = 0;

    for (0..COORDS.len - 1) |i| for (i + 1..COORDS.len) |j| {
        const a = COORDS[i];
        const b = COORDS[j];
        const length = aoc.math.abs_diff(usize, a.x, b.x) + 1;
        const width = aoc.math.abs_diff(usize, a.y, b.y) + 1;

        max_area = @max(max_area, length * width);
    };

    return max_area;
}

fn scan_from(i: usize, kdir: isize) usize {
    const ip = COORDS[i];

    var limit: usize = 50;
    var max_x: usize = 0;
    var best_area: usize = 0;

    var j: isize = @intCast(i);
    var k: isize = if (kdir > 0) 0 else COORDS.len - 1;

    while (limit > 0) : (limit -= 1) {
        j -= kdir;
        const jp = COORDS[@intCast(j)];

        if (jp.x < max_x) continue;
        max_x = jp.x;

        while (true) : (k += kdir) {
            const kp = COORDS[@intCast(k)];
            const ky: isize = @intCast(kp.y);
            const jy: isize = @intCast(jp.y);
            if (ky * kdir >= jy * kdir) break;
        }

        if (COORDS[@intCast(k)].x < ip.x) break;

        const length = abs_diff(usize, ip.x, jp.x) + 1;
        const width = abs_diff(usize, ip.y, jp.y) + 1;
        const new_area = length * width;

        best_area = @max(best_area, new_area);
    }

    return best_area;
}

const START_INDEX: usize = blk: {
    var max_dx: usize = 0;
    var index: usize = 0;

    for (1..COORDS.len) |i| {
        const dx = abs_diff(usize, COORDS[i].x, COORDS[i - 1].x);
        if (dx > max_dx) {
            max_dx = dx;
            index = i;
        }
    }

    break :blk index;
};

fn part2(_: Allocator) !usize {
    const area1 = scan_from(START_INDEX, 1);
    const area2 = scan_from(START_INDEX + 1, -1);
    return @max(area1, area2);
}

pub const solution: Solution = .{
    .day = .@"09",
    .p1 = .{ .f = part1, .expected = 4777816465 },
    .p2 = .{ .f = part2, .expected = 1410501884 },
};

test "day09 part1" {
    _ = try aoc.validate(part1, 4777816465, .@"09", .one, testing.allocator);
}

test "day09 part2" {
    _ = try aoc.validate(part2, 1410501884, .@"09", .two, testing.allocator);
}

test "day09 solution" {
    _ = try solution.solve(testing.allocator);
}
