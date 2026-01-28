const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day14/data.txt");

const N_BOTS: usize = 75;
const N_STEPS: usize = 100;
const WIDTH: usize = 101;
const HEIGHT: usize = 103;
const HALF_WIDTH: usize = 101 / 2;
const HALF_HEIGHT: usize = 103 / 2;

const Quadrant = enum {
    northwest,
    northeast,
    southwest,
    southeast,
    center,
};

const Bot = struct {
    x: isize,
    y: isize,
    vx: isize,
    vy: isize,
    const Self = @This();

    pub inline fn final_quadrant(self: Self) Quadrant {
        const x = @mod(self.x + self.vx * N_STEPS, WIDTH);
        const y = @mod(self.y + self.vy * N_STEPS, HEIGHT);

        return if (x == HALF_WIDTH or y == HALF_HEIGHT)
            .center
        else if (x < HALF_WIDTH and y < HALF_HEIGHT)
            .northwest
        else if (x >= HALF_WIDTH and y < HALF_HEIGHT)
            .northeast
        else if (x < HALF_WIDTH and y >= HALF_HEIGHT)
            .southeast
        else
            .southwest;
    }
};

const Bots = [aoc.slice.line_count(input)]Bot;
const Offset = struct { isize, isize, isize };
const Offsets = [HEIGHT]Offset;

const BOTS: Bots = blk: {
    @setEvalBranchQuota(175_000);
    var bots: Bots = undefined;
    var lines = aoc.slice.lines(input);
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        const trimmed = std.mem.trimStart(u8, line, "p=");
        const pos_str, const vel_str = aoc.slice.split_once(u8, trimmed, ' ');

        const x_str, const y_str = aoc.slice.split_once(u8, pos_str, ',');
        const x = std.fmt.parseInt(isize, x_str, 10) catch unreachable;
        const y = std.fmt.parseInt(isize, y_str, 10) catch unreachable;

        const trimmed_vel_str = std.mem.trimStart(u8, vel_str, "v=");
        const vx_str, const vy_str = aoc.slice.split_once(u8, trimmed_vel_str, ',');
        const vx = std.fmt.parseInt(isize, vx_str, 10) catch unreachable;
        const vy = std.fmt.parseInt(isize, vy_str, 10) catch unreachable;

        bots[i] = .{
            .x = x,
            .y = y,
            .vx = vx,
            .vy = vy,
        };
    }

    break :blk bots;
};

fn part1(_: std.mem.Allocator) !usize {
    var northwest_count: usize = 0;
    var northeast_count: usize = 0;
    var southwest_count: usize = 0;
    var southeast_count: usize = 0;

    for (BOTS) |bot| switch (bot.final_quadrant()) {
        .northwest => northwest_count += 1,
        .northeast => northeast_count += 1,
        .southwest => southwest_count += 1,
        .southeast => southeast_count += 1,
        .center => {},
    };

    return northwest_count * northeast_count * southwest_count * southeast_count;
}

inline fn compute_variance(ns: []isize) isize {
    const len: isize = @intCast(ns.len);

    var sum: isize = 0;
    for (ns) |n| sum += n;
    const mean = @divFloor(sum, len);

    var x: isize = 0;
    for (ns) |n| {
        x += std.math.pow(isize, (n - mean), 2);
    }

    return @divFloor(x, len);
}

fn get_averages() Offsets {
    var offsets: Offsets = .{.{ 0, 0, 0 }} ** HEIGHT;

    for (0..HEIGHT) |s| {
        const s_isize: isize = @intCast(s);
        var vert_pos = [_]isize{0} ** N_BOTS;
        var hori_pos = [_]isize{0} ** N_BOTS;

        for (BOTS[0..N_BOTS], 0..) |bot, i| {
            const dx = bot.x + bot.vx * s_isize;
            const dy = bot.y + bot.vy * s_isize;
            vert_pos[i] = @mod(dx, WIDTH);
            hori_pos[i] = @mod(dy, HEIGHT);
        }

        const vert_variance = compute_variance(&vert_pos);
        const hori_variance = compute_variance(&hori_pos);

        offsets[s] = .{
            s_isize,
            vert_variance,
            hori_variance,
        };
    }

    return offsets;
}

fn get_offsets(averages: Offsets) struct { Offset, Offset } {
    var min_x = averages[0];
    var min_y = averages[0];

    for (averages) |average| {
        if (min_x.@"1" > average.@"1") {
            min_x = average;
        }
        if (min_y.@"2" > average.@"2") {
            min_y = average;
        }
    }

    return .{ min_x, min_y };
}

fn part2(_: std.mem.Allocator) !usize {
    const averages = get_averages();
    const vert_offset, const hori_offset = get_offsets(averages);

    for (0..HEIGHT) |i| {
        const i_: isize = @intCast(i);
        const value = i_ * WIDTH + vert_offset.@"0";

        if (@mod(value - hori_offset.@"0", HEIGHT) == 0) {
            return @intCast(value);
        }
    }

    unreachable;
}

pub fn solution() Solution {
    return .{
        .day = .@"14",
        .p1 = .{ .f = part1, .expected = 230900224 },
        .p2 = .{ .f = part2, .expected = 6532 },
    };
}

test "day14 part1" {
    _ = try aoc.validate(part1, 230900224, .@"14", .one, testing.allocator);
}

test "day14 part2" {
    _ = try aoc.validate(part2, 6532, .@"14", .two, testing.allocator);
}

test "day14 solution" {
    _ = try solution().solve(testing.allocator);
}
