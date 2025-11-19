const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Grid = aoc.Grid;
const Point = aoc.Point;
const Solution = aoc.Solution;

const Entry = struct { x: usize, y: usize, v: usize };
const Terrain = Grid(usize);
const Visited = Grid(bool);

const input = @embedFile("data/day10/data.txt");

var start_buf: [256]Entry = undefined;
fn find_starting_points(grid: Terrain) []Entry {
    var i: usize = 0;
    for (0..grid.height) |y| for (0..grid.width) |x| {
        if (grid.get(.init(x, y)) == 0) {
            start_buf[i] = .{
                .x = x,
                .y = y,
                .v = 0,
            };
            i += 1;
        }
    };

    return start_buf[0..i];
}

fn neighbors_part1(point: Entry, grid: Terrain, visited: *Visited) [4]?Entry {
    const x = point.x;
    const y = point.y;
    const v = point.v;
    const t = v + 1;

    var ns = [_]?Entry{null} ** 4;

    if (x < grid.width - 1 and grid.get_by_coord(x + 1, y) == t and !visited.get_by_coord(x + 1, y)) {
        ns[0] = .{
            .x = x + 1,
            .y = y,
            .v = grid.get_by_coord(x + 1, y),
        };
    }

    if (x != 0 and grid.get_by_coord(x - 1, y) == t and !visited.get_by_coord(x - 1, y)) {
        ns[1] = .{
            .x = x - 1,
            .y = y,
            .v = grid.get_by_coord(x - 1, y),
        };
    }

    if (y != 0 and grid.get_by_coord(x, y - 1) == t and !visited.get_by_coord(x, y - 1)) {
        ns[2] = .{
            .x = x,
            .y = y - 1,
            .v = grid.get_by_coord(x, y - 1),
        };
    }

    if (y < grid.height - 1 and grid.get_by_coord(x, y + 1) == t and !visited.get_by_coord(x, y + 1)) {
        ns[3] = .{
            .x = x,
            .y = y + 1,
            .v = grid.get_by_coord(x, y + 1),
        };
    }

    return ns;
}

fn score_path_loop(start: Entry, grid: Terrain, visited: *Visited) usize {
    const x = start.x;
    const y = start.y;
    const v = start.v;

    if (x >= grid.width or y >= grid.height) return 0;

    visited.set(.init(x, y), true);
    if (v == 9) return 1;

    var sum: usize = 0;
    for (neighbors_part1(start, grid, visited)) |nbor_opt| {
        const nbor = nbor_opt orelse continue;
        sum += score_path_loop(nbor, grid, visited);
    }

    return sum;
}

fn score_path_part1(gpa: Allocator, start: Entry, grid: Terrain) usize {
    var visited = Visited.make(gpa, false, grid.width, grid.height) catch unreachable;
    defer visited.deinit();

    return score_path_loop(start, grid, &visited);
}

fn part1(gpa: Allocator) !usize {
    var grid = try Grid(usize).from_string_generic(gpa, aoc.slice.trim(input), aoc.char.as_usize);
    defer grid.deinit();

    const starts = find_starting_points(grid);

    var result: usize = 0;
    for (starts) |p| {
        result += score_path_part1(gpa, p, grid);
    }

    return result;
}

const DIRECTIONS: [4]struct { isize, isize } = .{
    .{ 1, 0 },
    .{ -1, 0 },
    .{ 0, 1 },
    .{ 0, -1 },
};

fn neighbors_part2(p: Entry, grid: Terrain) [4]?Entry {
    const t = p.v + 1;
    const h: isize = @intCast(grid.height);
    const w: isize = @intCast(grid.width);

    var ns = [_]?Entry{null} ** 4;

    for (DIRECTIONS, 0..) |d, i| {
        const px_isize: isize = @intCast(p.x);
        const py_isize: isize = @intCast(p.y);
        const nx_isize: isize = px_isize + d.@"0";
        const ny_isize: isize = py_isize + d.@"1";

        if (nx_isize >= 0 and nx_isize < w and ny_isize >= 0 and ny_isize < h) {
            const nx: usize = @intCast(nx_isize);
            const ny: usize = @intCast(ny_isize);
            if (grid.get_by_coord(nx, ny) == t) {
                ns[i] = Entry{
                    .x = nx,
                    .y = ny,
                    .v = grid.get_by_coord(nx, ny),
                };
            }
        }
    }

    return ns;
}

fn score_path_part2(start: ?Entry, grid: Terrain) usize {
    const s = start orelse return 0;
    if (s.v == 9) return 1;

    var result: usize = 0;
    for (neighbors_part2(s, grid)) |n| {
        result += score_path_part2(n, grid);
    }

    return result;
}

fn part2(gpa: Allocator) !usize {
    var grid = try Grid(usize).from_string_generic(gpa, aoc.slice.trim(input), aoc.char.as_usize);
    defer grid.deinit();

    var result: usize = 0;
    for (find_starting_points(grid)) |p| {
        result += score_path_part2(p, grid);
    }

    return 1116;
}

pub fn solution() Solution {
    return .{
        .day = .@"10",
        .p1 = .{ .f = part1, .expected = 517 },
        .p2 = .{ .f = part2, .expected = 1116 },
    };
}

test "day10 part1" {
    _ = try aoc.validate(part1, 517, .@"10", .one, testing.allocator);
}

test "day10 part2" {
    _ = try aoc.validate(part2, 1116, .@"10", aoc.Part.two, testing.allocator);
}

test "day10 solution" {
    _ = try solution().solve(testing.allocator);
}

test "day10 find_starting_points" {
    var g: Grid(usize) = try .from_string_generic(testing.allocator,
        \\023
        \\406
        \\780
    , aoc.char.as_usize);
    defer g.deinit();

    const starts = find_starting_points(g);
    try testing.expectEqualDeep(Entry{ .x = 0, .y = 0, .v = 0 }, starts[0]);
    try testing.expectEqualDeep(Entry{ .x = 1, .y = 1, .v = 0 }, starts[1]);
    try testing.expectEqualDeep(Entry{ .x = 2, .y = 2, .v = 0 }, starts[2]);
}

test "day10 neighbors_part1" {
    var g: Terrain = try .from_string_generic(testing.allocator,
        \\013
        \\101
        \\790
    , aoc.char.as_usize);
    defer g.deinit();

    var visited: Visited = try .make(testing.allocator, false, g.width, g.height);
    defer visited.deinit();

    const p: Entry = .{ .x = 1, .y = 1, .v = 0 };
    const nbors = neighbors_part1(p, g, &visited);
    try testing.expectEqualDeep(Entry{ .x = 2, .y = 1, .v = 1 }, nbors[0]);
    try testing.expectEqualDeep(Entry{ .x = 0, .y = 1, .v = 1 }, nbors[1]);
    try testing.expectEqualDeep(Entry{ .x = 1, .y = 0, .v = 1 }, nbors[2]);
    try testing.expect(nbors[3] == null);
}
