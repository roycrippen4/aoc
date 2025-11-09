const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Point = aoc.Point;

const Stack = aoc.Stack(Point, 10);
const Stacks = [62]Stack;
const Seen = [size * size]bool;

const size = 50;
const input = @embedFile("data/day08/data.txt");

inline fn get_index(c: u8) ?usize {
    return switch (c) {
        'a'...'z' => c - 97,
        'A'...'Z' => c - 39,
        '0'...'9' => c + 4,
        else => null,
    };
}

fn parse() Stacks {
    var stacks = [_]Stack{.{}} ** 62;
    var lines = std.mem.splitScalar(u8, input, '\n');

    var y: usize = 0;
    while (lines.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| {
            const index = get_index(c) orelse continue;
            stacks[index].push(.init(x, y)) catch unreachable;
        }
    }

    return stacks;
}

inline fn rotate_point(count: *usize, seen: *Seen, p1: Point, p2: Point) void {
    const p = p1.unchecked_times(2).sub(p2) orelse return;
    if (p.inside(size, size)) {
        const idx = p.y * size + p.x;

        if (!seen[idx]) {
            seen[idx] = true;
            count.* += 1;
        }
    }
}

pub fn part1(_: std.mem.Allocator) !usize {
    var seen: Seen = [_]bool{false} ** (size * size);
    var count: usize = 0;

    for (parse()) |stack| {
        if (stack.is_empty()) continue;
        for (0..stack.len - 1) |i| for (i + 1..stack.len) |j| {
            rotate_point(&count, &seen, stack.items[i], stack.items[j]);
            rotate_point(&count, &seen, stack.items[j], stack.items[i]);
        };
    }

    return count;
}

pub fn part2(_: std.mem.Allocator) !usize {
    return 42;
}

test "day08 part1" {
    _ = try aoc.validate(part1, 244, aoc.Day.@"08", aoc.Part.one, testing.allocator);
}

test "day08 part2" {
    _ = try aoc.validate(part2, 42, aoc.Day.@"08", aoc.Part.two, testing.allocator);
}
