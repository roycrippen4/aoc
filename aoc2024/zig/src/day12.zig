const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");

const input = @embedFile("data/day12/data.txt");
const size = aoc.slice.line_count(input);
const Grid = [size][size]u8;
const Visited = [size][size]bool;
const Deque = aoc.Deque(struct { usize, usize }).Static(32);

const grid: Grid = blk: {
    @setEvalBranchQuota(100_000);
    var buf: Grid = undefined;
    var y: usize = 0;
    var it = aoc.slice.lines(input);
    while (it.next()) |line| : (y += 1) {
        for (line, 0..) |c, x| buf[y][x] = c;
    }

    break :blk buf;
};

fn corner(x: usize, y: usize, v: u8) bool {
    return (y == 0 or grid[y - 1][x] != v) and (x == 0 or grid[y][x - 1] != v);
}

fn blood_fill1(x: usize, y: usize, v: u8, dq: *Deque, visited: *Visited) !usize {
    dq.reset();
    visited[y][x] = true;
    var peri: usize = 0;
    var area: usize = 0;

    try dq.push_back(.{ x, y });

    while (dq.pop_front()) |p| {
        area += 1;
        const nx, const ny = p;

        if (ny == 0 or grid[ny - 1][nx] != v) {
            peri += 1;
        } else if (!visited[ny - 1][nx]) {
            try dq.push_back(.{ nx, ny - 1 });
            visited[ny - 1][nx] = true;
        }

        if (nx == 0 or grid[ny][nx - 1] != v) {
            peri += 1;
        } else if (!visited[ny][nx - 1]) {
            try dq.push_back(.{ nx - 1, ny });
            visited[ny][nx - 1] = true;
        }

        if (ny + 1 == size or grid[ny + 1][nx] != v) {
            peri += 1;
        } else if (!visited[ny + 1][nx]) {
            try dq.push_back(.{ nx, ny + 1 });
            visited[ny + 1][nx] = true;
        }

        if (nx + 1 == size or grid[ny][nx + 1] != v) {
            peri += 1;
        } else if (!visited[ny][nx + 1]) {
            try dq.push_back(.{ nx + 1, ny });
            visited[ny][nx + 1] = true;
        }
    }

    return peri * area;
}

pub fn part1(_: Allocator) !usize {
    var visited: Visited = .{.{false} ** size} ** size;
    var result: usize = 0;
    var dq: Deque = .{};

    for (0..size) |y| for (0..size) |x| {
        if (visited[y][x]) continue;

        const v = grid[y][x];
        if (corner(x, y, v)) {
            result += try blood_fill1(x, y, v, &dq, &visited);
        }
    };
    return result;
}

fn corners(x: usize, y: usize, v: u8) u8 {
    const u = y == 0 or grid[y - 1][x] != v;
    const l = x == 0 or grid[y][x - 1] != v;
    const r = x == size - 1 or grid[y][x + 1] != v;
    const d = y == size - 1 or grid[y + 1][x] != v;

    const ur = y == 0 or x == size - 1 or grid[y - 1][x + 1] != v;
    const ul = y == 0 or x == 0 or grid[y - 1][x - 1] != v;
    const dr = y == size - 1 or x == size - 1 or grid[y + 1][x + 1] != v;
    const dl = y == size - 1 or x == 0 or grid[y + 1][x - 1] != v;

    return @as(u8, @intFromBool(u and l)) +
        @as(u8, @intFromBool(u and r)) +
        @as(u8, @intFromBool(d and l)) +
        @as(u8, @intFromBool(d and r)) +
        @as(u8, @intFromBool(!u and !l and ul)) +
        @as(u8, @intFromBool(!u and !r and ur)) +
        @as(u8, @intFromBool(!d and !l and dl)) +
        @as(u8, @intFromBool(!d and !r and dr));
}

fn blood_fill2(x: usize, y: usize, v: u8, visited: *Visited) !usize {
    visited[y][x] = true;
    var sides: usize = 0;
    var area: usize = 0;

    var dq: Deque = .{};
    try dq.push_back(.{ x, y });

    while (dq.pop_front()) |p| {
        const nx, const ny = p;
        area += 1;
        sides += corners(nx, ny, v);

        if (ny != 0 and grid[ny - 1][nx] == v and !visited[ny - 1][nx]) {
            try dq.push_back(.{ nx, ny - 1 });
            visited[ny - 1][nx] = true;
        }

        if (nx != 0 and grid[ny][nx - 1] == v and !visited[ny][nx - 1]) {
            try dq.push_back(.{ nx - 1, ny });
            visited[ny][nx - 1] = true;
        }

        if (ny + 1 != size and grid[ny + 1][nx] == v and !visited[ny + 1][nx]) {
            try dq.push_back(.{ nx, ny + 1 });
            visited[ny + 1][nx] = true;
        }

        if (nx + 1 != size and grid[ny][nx + 1] == v and !visited[ny][nx + 1]) {
            try dq.push_back(.{ nx + 1, ny });
            visited[ny][nx + 1] = true;
        }
    }

    return sides * area;
}

pub fn part2(_: Allocator) !usize {
    var visited: Visited = .{.{false} ** size} ** size;
    var result: usize = 0;

    for (0..size) |y| for (0..size) |x| {
        if (visited[y][x]) continue;

        const v = grid[y][x];
        if (corner(x, y, v)) {
            result += try blood_fill2(x, y, v, &visited);
        }
    };
    return result;
}

test "day12 part1" {
    _ = try aoc.validate(part1, 1361494, .@"12", .one, testing.allocator);
}

test "day12 part2" {
    _ = try aoc.validate(part2, 830516, .@"12", .two, testing.allocator);
}
