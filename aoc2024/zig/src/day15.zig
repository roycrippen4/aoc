const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");

const DIM: usize = 51;
const GRID_END: usize = DIM * (DIM - 1);

const input_raw = aoc.slice.trim(@embedFile("data/day15/data.txt"));

var input: [input_raw.len]u8 = undefined;
const moves = input[GRID_END + 1 ..];

const Direction = enum(i32) {
    north = -(@as(i32, DIM)),
    south = @intCast(DIM),
    west = -1,
    east = 1,
    null = 0,
};

pub fn part1(_: std.mem.Allocator) !usize {
    @memcpy(&input, input_raw); // we need a mutable copy of the input
    var grid: []u8 = input[0..GRID_END];

    var bot: i32 = blk: {
        for (grid, 0..) |c, i| if (c == '@') break :blk @intCast(i);
        unreachable;
    };

    var move_lut = [_]Direction{.null} ** 127;
    move_lut[@intCast('<')] = .west;
    move_lut[@intCast('>')] = .east;
    move_lut[@intCast('^')] = .north;
    move_lut[@intCast('v')] = .south;

    for (moves) |move| if (move != '\n') {
        const dir = @intFromEnum(move_lut[@intCast(move)]);
        var i = bot + dir;

        outer: while (true) switch (grid[@intCast(i)]) {
            '.' => while (true) {
                grid[@intCast(i)] = grid[@intCast(i - dir)];
                if (grid[@intCast(i)] == '@') {
                    grid[@intCast(i - dir)] = '.';
                    bot = i;
                    break :outer;
                }
                i -= dir;
            },
            'O' => i += dir,
            '#' => break,
            else => unreachable,
        };
    };

    var result: usize = 0;

    for (grid, 0..) |t, i| if (t == 'O') {
        const y_score = 100 * (i / DIM);
        const x_score = i % DIM;
        result += y_score + x_score;
    };

    return result;
}

const HEIGHT: usize = 50;
const WIDTH: usize = HEIGHT * 2;
const WIDTH_I32: i32 = @intCast(WIDTH);
const BOT: u8 = '@';
const BOX: u8 = 'O';
const WALL: u8 = '#';
const EMPT: u8 = '.';
const BOXL: u8 = '[';
const BOXR: u8 = ']';
const SIZE: usize = HEIGHT * WIDTH;

var GRID_BUF: [SIZE]u8 = .{0} ** SIZE;

fn parse() struct { []u8, i32 } {
    var gi: usize = 0;
    var i: usize = 0;
    var bot: i32 = 0;

    const max = (HEIGHT + 1) * HEIGHT;
    while (i != max) : (i += 1) switch (input[i]) {
        EMPT => {
            GRID_BUF[gi] = EMPT;
            GRID_BUF[gi + 1] = EMPT;
            gi += 2;
        },
        BOX => {
            GRID_BUF[gi] = BOXL;
            GRID_BUF[gi + 1] = BOXR;
            gi += 2;
        },
        WALL => {
            GRID_BUF[gi] = WALL;
            GRID_BUF[gi + 1] = WALL;
            gi += 2;
        },
        BOT => {
            bot = @intCast(gi);
            GRID_BUF[gi] = BOT;
            GRID_BUF[gi + 1] = EMPT;
            gi += 2;
        },
        else => {},
    };

    return .{ GRID_BUF[0..], bot };
}

// Horizontal moves are handled same as part 1
fn move_horizontal(g: *[]u8, bot: *i32, i: i32, dir: i32) void {
    var idx: i32 = i;
    outer: while (true) switch (g.*[@intCast(idx)]) {
        EMPT => while (true) {
            g.*[@intCast(idx)] = g.*[@intCast(idx - dir)];

            if (g.*[@intCast(idx)] == BOT) {
                g.*[@intCast(idx - dir)] = EMPT;
                bot.* = i;
                break :outer;
            }

            idx -= dir;
        },
        BOXL, BOXR => idx += 2 * dir,
        WALL => return,
        else => |unknown| {
            std.debug.print("{c}\n", .{unknown});
            @panic("FUCK");
        },
    };
}

/// Recursive call that returns true if a move can be made.
fn can_move(g: *[]u8, swp: *[32]i32, len: *usize, left: i32, d: i32) bool {
    const l = left + d;

    if (aoc.slice.contains(i32, swp[0..len.*], l)) {
        return true;
    }

    const left_item = g.*[@intCast(l)];
    const right_item = g.*[@intCast(l + 1)];

    const move_possible = if (left_item == EMPT and right_item == EMPT)
        true
    else if (left_item == WALL or right_item == WALL)
        false
    else if (left_item == BOXL)
        can_move(g, swp, len, l, d)
    else if (left_item == EMPT and right_item == BOXL)
        can_move(g, swp, len, l + 1, d)
    else if (left_item == BOXR and right_item == EMPT)
        can_move(g, swp, len, l - 1, d)
    else if (left_item == BOXR and right_item == BOXL)
        can_move(g, swp, len, l - 1, d) and can_move(g, swp, len, l + 1, d)
    else
        @panic("move possible fell through");

    if (move_possible) {
        swp.*[len.*] = l;
        len.* += 1;
        return true;
    }

    return false;
}

fn move_boxes(grid: *[]u8, left: i32, i: i32, dir: i32) bool {
    var swp = [_]i32{0} ** 32;
    var s_len: usize = 0;

    if (!can_move(grid, &swp, &s_len, left, dir)) {
        return false;
    }

    for (swp[0..s_len]) |s| {
        std.mem.swap(u8, &grid.*[@intCast(s)], &grid.*[@intCast(s - dir)]);
        std.mem.swap(u8, &grid.*[@intCast(s + 1)], &grid.*[@intCast(s + 1 - dir)]);
    }

    std.mem.swap(u8, &grid.*[@intCast(i)], &grid.*[@intCast(i - dir)]);

    return true;
}

fn move_vertical(grid: *[]u8, bot: *i32, i: i32, dir: i32) void {
    const did_move = blk: switch (grid.*[@intCast(i)]) {
        EMPT => {
            std.mem.swap(u8, &grid.*[@intCast(i)], &grid.*[@intCast(bot.*)]);
            break :blk true;
        },
        WALL => false,
        BOXL => move_boxes(grid, i, i, dir),
        BOXR => move_boxes(grid, i - 1, i, dir),
        else => unreachable,
    };

    if (did_move) {
        bot.* = i;
    }
}

pub fn part2(_: std.mem.Allocator) !usize {
    @memcpy(&input, input_raw); // we need a mutable copy of the input
    var grid, var bot = parse();

    var move_lut = [_]i32{0} ** 0x7F;
    move_lut[@intCast('<')] = -1;
    move_lut[@intCast('>')] = 1;
    move_lut[@intCast('^')] = -WIDTH_I32;
    move_lut[@intCast('v')] = WIDTH_I32;

    for (moves) |move| if (move != '\n') {
        const dir: i32 = move_lut[@intCast(move)];
        const i: i32 = bot + dir;

        switch (dir) {
            1, -1 => move_horizontal(&grid, &bot, i, dir),
            else => move_vertical(&grid, &bot, i, dir),
        }
    };

    var result: usize = 0;
    for (grid, 0..) |t, i| if (t == BOXL) {
        const y_score = 100 * (i / WIDTH);
        const x_score = i % WIDTH;
        result += y_score + x_score;
    };

    return result;
}

test "day15 part1" {
    _ = try aoc.validate(part1, 1526673, .@"15", .one, testing.allocator);
}

test "day15 part2" {
    _ = try aoc.validate(part2, 1535509, .@"15", .two, testing.allocator);
}
