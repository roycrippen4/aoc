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

inline fn rotate_point(p1: Point, p2: Point) ?Point {
    const p = p2.unchecked_times(2).sub(p1) orelse return null;
    return if (!p.inside(size, size))
        null
    else
        p;
}

pub fn part1(_: std.mem.Allocator) !usize {
    var seen: Seen = [_]bool{false} ** (size * size);
    var count: usize = 0;

    for (parse()) |stack| {
        if (stack.is_empty()) continue;
        for (0..stack.len - 1) |i| for (i + 1..stack.len) |j| {
            if (rotate_point(stack.items[i], stack.items[j])) |p| {
                const idx = p.y * size + p.x;
                if (!seen[idx]) {
                    seen[idx] = true;
                    count += 1;
                }
            }

            if (rotate_point(stack.items[j], stack.items[i])) |p| {
                const idx = p.y * size + p.x;
                if (!seen[idx]) {
                    seen[idx] = true;
                    count += 1;
                }
            }
        };
    }

    return count;
}

pub fn part2(_: std.mem.Allocator) !usize {
    var seen: Seen = [_]bool{false} ** (size * size);
    var count: usize = 0;

    for (parse()) |stack| {
        if (stack.is_empty()) continue;
        for (0..stack.len - 1) |i| for (i + 1..stack.len) |j| {
            var a = stack.items[i];
            var b = stack.items[j];

            const a_idx = a.y * size + a.x;
            if (!seen[a_idx]) {
                seen[a_idx] = true;
                count += 1;
            }
            const b_idx = b.y * size + b.x;
            if (!seen[b_idx]) {
                seen[b_idx] = true;
                count += 1;
            }

            while (rotate_point(a, b)) |next| {
                const idx = next.y * size + next.x;
                if (!seen[idx]) {
                    seen[idx] = true;
                    count += 1;
                }
                a = b;
                b = next;
            }

            a = stack.items[j];
            b = stack.items[i];

            while (rotate_point(a, b)) |next| {
                const idx = next.y * size + next.x;
                if (!seen[idx]) {
                    seen[idx] = true;
                    count += 1;
                }
                a = b;
                b = next;
            }
        };
    }

    return count;
}

test "day08 part1" {
    _ = try aoc.validate(part1, 244, aoc.Day.@"08", aoc.Part.one, testing.allocator);
}

test "day08 part2" {
    _ = try aoc.validate(part2, 912, aoc.Day.@"08", aoc.Part.two, testing.allocator);
}
