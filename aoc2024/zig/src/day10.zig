const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Grid = aoc.Grid;
const Point = aoc.Point;

const Entry = struct { x: usize, y: usize, v: usize };
const Terrain = Grid(usize);
const Visited = Grid(bool);

const input = @embedFile("data/day10/data.txt");
const example = @embedFile("data/day10/example.txt");

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

fn neighbors(point: Entry, grid: Terrain, visited: *Visited) [4]?Entry {
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
    for (neighbors(start, grid, visited)) |nbor_opt| {
        const nbor = nbor_opt orelse continue;
        sum += score_path_loop(nbor, grid, visited);
    }

    return sum;
}

fn score_path(gpa: Allocator, start: Entry, grid: Terrain) usize {
    var visited = Visited.make(gpa, false, grid.width, grid.height) catch unreachable;
    defer visited.deinit();

    return score_path_loop(start, grid, &visited);
}

pub fn part1(gpa: Allocator) !usize {
    var grid = try Grid(usize).from_string_generic(gpa, aoc.slice.trim(input), aoc.char.as_usize);
    defer grid.deinit();

    const starts = find_starting_points(grid);

    var result: usize = 0;
    for (starts) |p| {
        result += score_path(gpa, p, grid);
    }

    return result;
}

pub fn part2(_: Allocator) !usize {
    return 42;
}

test "day10 part1" {
    _ = try aoc.validate(part1, 517, .@"10", .one, testing.allocator);
}

test "day10 part2" {
    _ = try aoc.validate(part2, 42, .@"10", aoc.Part.two, testing.allocator);
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

test "day10 neighbors" {
    var g: Terrain = try .from_string_generic(testing.allocator,
        \\013
        \\101
        \\790
    , aoc.char.as_usize);
    defer g.deinit();

    var visited: Visited = try .make(testing.allocator, false, g.width, g.height);
    defer visited.deinit();

    const p: Entry = .{ .x = 1, .y = 1, .v = 0 };
    const nbors = neighbors(p, g, &visited);
    try testing.expectEqualDeep(Entry{ .x = 2, .y = 1, .v = 1 }, nbors[0]);
    try testing.expectEqualDeep(Entry{ .x = 0, .y = 1, .v = 1 }, nbors[1]);
    try testing.expectEqualDeep(Entry{ .x = 1, .y = 0, .v = 1 }, nbors[2]);
    try testing.expect(nbors[3] == null);
}
