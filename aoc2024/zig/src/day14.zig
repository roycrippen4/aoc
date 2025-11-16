const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const split_once = aoc.slice.split_once;

const input = @embedFile("data/day14/data.txt");

const N_BOTS: usize = 75;
const N_STEPS: usize = 100;

const WIDTH_ISIZE: isize = 101;
const WIDTH: usize = 101;
const HALF_WIDTH: usize = 101 / 2;

const HEIGHT_ISIZE: isize = 103;
const HEIGHT: usize = 103;
const HALF_HEIGHT: usize = 103 / 2;

const Bot = struct { isize, isize, isize, isize };
const Bots = []Bot;

const Offset = struct { isize, isize, isize };
const Offsets = [HEIGHT]Offset;

fn parse_bots(buf: []Bot) Bots {
    var lines = aoc.slice.lines(input);
    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        const trimmed = mem.trimStart(u8, line, "p=");
        const pos_str, const vel_str = split_once(u8, trimmed, ' ');
        const x_str, const y_str = split_once(u8, pos_str, ',');
        const vx_str, const vy_str = split_once(u8, mem.trimStart(u8, vel_str, "v="), ',');
        const x = fmt.parseInt(isize, x_str, 10) catch unreachable;
        const y = fmt.parseInt(isize, y_str, 10) catch unreachable;
        const vx = fmt.parseInt(isize, vx_str, 10) catch unreachable;
        const vy = fmt.parseInt(isize, vy_str, 10) catch unreachable;

        buf[i] = .{ x, y, vx, vy };
    }

    return buf[0..i];
}

/// Determines which quadrant of the grid the bot is currently inside
///
/// ```
///  up left │ up right
/// ─────────┼──────────
/// down left│down right
/// ```
fn find_quadrant(bot: Bot) Bot {
    const x: usize = @intCast(bot.@"0");
    const y: usize = @intCast(bot.@"1");

    return if (x == HALF_WIDTH or y == HALF_HEIGHT)
        .{ 0, 0, 0, 0 }
    else if (x < HALF_WIDTH and y < HALF_HEIGHT)
        .{ 1, 0, 0, 0 }
    else if (x >= HALF_WIDTH and y < HALF_HEIGHT)
        .{ 0, 1, 0, 0 }
    else if (x < HALF_WIDTH and y >= HALF_HEIGHT)
        .{ 0, 0, 1, 0 }
    else
        .{ 0, 0, 0, 1 };
}

inline fn simulate(bot: Bot) Bot {
    const x, const y, const vx, const vy = bot;
    return .{
        @mod(x + vx * N_STEPS, WIDTH_ISIZE),
        @mod(y + vy * N_STEPS, HEIGHT_ISIZE),
        vx,
        vy,
    };
}

inline fn update_acc(acc: *Bot, b: Bot) void {
    acc.@"0" += b.@"0";
    acc.@"1" += b.@"1";
    acc.@"2" += b.@"2";
    acc.@"3" += b.@"3";
}

inline fn multiply_quadrant_counts(acc: Bot) usize {
    const tl_i, const tr_i, const bl_i, const br_i = acc;

    const tl: usize = @intCast(tl_i);
    const tr: usize = @intCast(tr_i);
    const bl: usize = @intCast(bl_i);
    const br: usize = @intCast(br_i);

    return tl * tr * bl * br;
}

pub fn part1(_: std.mem.Allocator) !usize {
    var acc: Bot = .{ 0, 0, 0, 0 };

    var buf: [WIDTH * HEIGHT]Bot = undefined;
    const bots = parse_bots(&buf);

    for (bots) |bot| {
        const new_bot = simulate(bot); // get the final position of the bot
        const quad = find_quadrant(new_bot); // find the quadrant the moved bot is inside
        update_acc(&acc, quad);
    }

    return multiply_quadrant_counts(acc);
}

inline fn compute_variance(ns: []isize) isize {
    const len: isize = @intCast(ns.len);

    var sum: isize = 0;
    for (ns) |n| sum += n;
    const mean = @divFloor(sum, len);

    var x: isize = 0;
    for (ns) |n| x += std.math.pow(isize, (n - mean), 2);

    return @divFloor(x, len);
}

fn get_averages(bots: Bots) Offsets {
    var offsets: Offsets = .{.{ 0, 0, 0 }} ** HEIGHT;

    for (0..HEIGHT_ISIZE) |s| {
        const s_isize: isize = @intCast(s);
        var vert_pos = [_]isize{0} ** N_BOTS;
        var hori_pos = [_]isize{0} ** N_BOTS;

        for (bots, 0..) |bot, i| {
            const x, const y, const vx, const vy = bot;

            vert_pos[i] = @mod((x + vx * s_isize), WIDTH_ISIZE);
            hori_pos[i] = @mod((y + vy * s_isize), HEIGHT_ISIZE);
        }

        const vert_variance = compute_variance(&vert_pos);
        const hori_variance = compute_variance(&hori_pos);

        offsets[s] = .{ s_isize, vert_variance, hori_variance };
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

pub fn part2(_: std.mem.Allocator) !usize {
    var buf: [WIDTH * HEIGHT]Bot = undefined;
    const bots = parse_bots(&buf)[0..N_BOTS];

    const averages = get_averages(bots);
    const vert_offset, const hori_offset = get_offsets(averages);

    for (0..HEIGHT) |i| {
        const i_isize: isize = @intCast(i);
        const value_isize = i_isize * WIDTH_ISIZE + vert_offset.@"0";

        if (@mod(value_isize - hori_offset.@"0", HEIGHT_ISIZE) == 0) {
            const value: usize = @intCast(value_isize);
            return value;
        }
    }

    unreachable;
}

test "day13 part1" {
    _ = try aoc.validate(part1, 230900224, .@"13", .one, testing.allocator);
}

test "day13 part2" {
    _ = try aoc.validate(part2, 6532, .@"13", .two, testing.allocator);
}
