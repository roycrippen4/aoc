const aoc = @import("aoc");
const std = @import("std");

const Grid = aoc.Grid;
const Point = aoc.Point;

const input: []const u8 = @embedFile("data/day04/data.txt");

fn northwest(g: Grid(u8), a: u32, x: usize, y: usize) u32 {
    const b = @as(u32, g.buf[(y - 1) * g.width + (x - 1)]);
    const c = @as(u32, g.buf[(y - 2) * g.width + (x - 2)]);
    const d = @as(u32, g.buf[(y - 3) * g.width + (x - 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

fn northeast(g: Grid(u8), a: u32, x: usize, y: usize) u32 {
    const b = @as(u32, g.buf[(y - 1) * g.width + (x + 1)]);
    const c = @as(u32, g.buf[(y - 2) * g.width + (x + 2)]);
    const d = @as(u32, g.buf[(y - 3) * g.width + (x + 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

fn southwest(g: Grid(u8), a: u32, x: usize, y: usize) u32 {
    const b = @as(u32, g.buf[(y + 1) * g.width + (x - 1)]);
    const c = @as(u32, g.buf[(y + 2) * g.width + (x - 2)]);
    const d = @as(u32, g.buf[(y + 3) * g.width + (x - 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

fn southeast(g: Grid(u8), a: u32, x: usize, y: usize) u32 {
    const b = @as(u32, g.buf[(y + 1) * g.width + (x + 1)]);
    const c = @as(u32, g.buf[(y + 2) * g.width + (x + 2)]);
    const d = @as(u32, g.buf[(y + 3) * g.width + (x + 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

pub fn part1(gpa: std.mem.Allocator) anyerror!usize {
    var g = try Grid(u8).from_string(gpa, input);
    try g.pad_sides(4, '.');

    var rot = try g.clone();
    rot.transpose_clockwise();

    defer rot.deinit();
    defer g.deinit();

    const XMAS = std.mem.readInt(u32, "XMAS", .little);
    const SAMX = std.mem.readInt(u32, "SAMX", .little);

    var count: usize = 0;
    for (3..g.height - 3) |y| {
        for (3..g.width - 3) |x| {
            const start = y * g.width + (x - 3) - 1;
            const end = y * g.width + x;

            const row = g.buf[start..end];
            const col = rot.buf[start..end];

            const row_word = std.mem.readInt(u32, row[0..4], .little);
            const col_word = std.mem.readInt(u32, col[0..4], .little);

            if (row_word == XMAS or row_word == SAMX) {
                count += 1;
            }
            if (col_word == XMAS or col_word == SAMX) {
                count += 1;
            }

            const a = @as(u32, g.buf[y * g.width + x]);

            if (northwest(g, a, x, y) == XMAS) {
                count += 1;
            }

            if (northeast(g, a, x, y) == XMAS) {
                count += 1;
            }

            if (southwest(g, a, x, y) == XMAS) {
                count += 1;
            }

            if (southeast(g, a, x, y) == XMAS) {
                count += 1;
            }
        }
    }

    return count;
}

pub fn part2(gpa: std.mem.Allocator) anyerror!usize {
    var g = try Grid(u8).from_string(gpa, input);
    try g.pad_sides(4, '.');
    defer g.deinit();

    var count: usize = 0;

    for (4..g.height - 4) |y| {
        for (4..g.width - 4) |x| {
            const cross1 = .{
                g.buf[(y - 1) * g.width + (x - 1)],
                g.buf[y * g.width + x],
                g.buf[(y + 1) * g.width + (x + 1)],
            };

            const cross2 = .{
                g.buf[(y - 1) * g.width + (x + 1)],
                g.buf[y * g.width + x],
                g.buf[(y + 1) * g.width + (x - 1)],
            };

            const cross1_ok = std.mem.eql(u8, &cross1, "MAS") or std.mem.eql(u8, &cross1, "SAM");
            const cross2_ok = std.mem.eql(u8, &cross2, "MAS") or std.mem.eql(u8, &cross2, "SAM");

            if (!cross1_ok or !cross2_ok) continue;
            count += 1;
        }
    }

    return count;
}

const t = std.testing;

test "day04 part1" {
    _ = try part1(t.allocator);
    // _ = try lib.validate(part1, 42, lib.Day.four, lib.Part.one, t.allocator);
}

test "day04 part2" {
    _ = try part2(t.allocator);
    // _ = try lib.validate(part2, 42, lib.Day.four, lib.Part.two, t.allocator);
}
