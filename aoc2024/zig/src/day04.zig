const std = @import("std");
const mem = std.mem;
const eql = std.mem.eql;
const testing = std.testing;
const Allocator = mem.Allocator;

const aoc = @import("aoc");
const Grid = aoc.Grid(u8);
const Point = aoc.Point;
const Solution = aoc.Solution;

const input = @embedFile("data/day04/data.txt");

inline fn northwest(g: Grid, a: u32, x: usize, y: usize) u32 {
    const b: u32 = @intCast(g.buf[(y - 1) * g.width + (x - 1)]);
    const c: u32 = @intCast(g.buf[(y - 2) * g.width + (x - 2)]);
    const d: u32 = @intCast(g.buf[(y - 3) * g.width + (x - 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

inline fn northeast(g: Grid, a: u32, x: usize, y: usize) u32 {
    const b: u32 = @intCast(g.buf[(y - 1) * g.width + (x + 1)]);
    const c: u32 = @intCast(g.buf[(y - 2) * g.width + (x + 2)]);
    const d: u32 = @intCast(g.buf[(y - 3) * g.width + (x + 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

inline fn southwest(g: Grid, a: u32, x: usize, y: usize) u32 {
    const b: u32 = @intCast(g.buf[(y + 1) * g.width + (x - 1)]);
    const c: u32 = @intCast(g.buf[(y + 2) * g.width + (x - 2)]);
    const d: u32 = @intCast(g.buf[(y + 3) * g.width + (x - 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

inline fn southeast(g: Grid, a: u32, x: usize, y: usize) u32 {
    const b: u32 = @intCast(g.buf[(y + 1) * g.width + (x + 1)]);
    const c: u32 = @intCast(g.buf[(y + 2) * g.width + (x + 2)]);
    const d: u32 = @intCast(g.buf[(y + 3) * g.width + (x + 3)]);

    return a | (b << 8) | (c << 16) | (d << 24);
}

fn part1(gpa: Allocator) anyerror!usize {
    var g: Grid = try .from_string(gpa, input);
    try g.pad_sides(4, '.');

    var rot = try g.clone();
    rot.transpose_clockwise();

    defer rot.deinit();
    defer g.deinit();

    const XMAS = mem.readInt(u32, "XMAS", .little);
    const SAMX = mem.readInt(u32, "SAMX", .little);

    var count: usize = 0;
    for (3..g.height - 3) |y| for (3..g.width - 3) |x| {
        const start = y * g.width + (x - 3) - 1;
        const end = y * g.width + x;

        const row = g.buf[start..end];
        const col = rot.buf[start..end];

        const row_word = mem.readInt(u32, row[0..4], .little);
        const col_word = mem.readInt(u32, col[0..4], .little);

        if (row_word == XMAS or row_word == SAMX) count += 1;
        if (col_word == XMAS or col_word == SAMX) count += 1;

        const a: u32 = @intCast(g.buf[y * g.width + x]);

        if (northwest(g, a, x, y) == XMAS) count += 1;
        if (northeast(g, a, x, y) == XMAS) count += 1;
        if (southwest(g, a, x, y) == XMAS) count += 1;
        if (southeast(g, a, x, y) == XMAS) count += 1;
    };

    return count;
}

inline fn is_sam_or_mas(slice: []const u8) bool {
    return eql(u8, slice, "MAS") or eql(u8, slice, "SAM");
}

fn part2(gpa: Allocator) anyerror!usize {
    var g: Grid = try .from_string(gpa, input);
    try g.pad_sides(4, '.');
    defer g.deinit();

    var count: usize = 0;

    for (4..g.height - 4) |y| for (4..g.width - 4) |x| {
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

        if (is_sam_or_mas(&cross1) and is_sam_or_mas(&cross2)) count += 1;
    };

    return count;
}

pub fn solution() Solution {
    return .{
        .day = .@"04",
        .p1 = .{ .f = part1, .expected = 2483 },
        .p2 = .{ .f = part2, .expected = 1925 },
    };
}

test "day04 part1" {
    _ = try aoc.validate(part1, 2483, .@"04", .one, testing.allocator);
}

test "day04 part2" {
    _ = try aoc.validate(part2, 1925, .@"04", .two, testing.allocator);
}

test "day04 solution" {
    _ = try solution().solve(testing.allocator);
}
