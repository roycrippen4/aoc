const aoc = @import("aoc");
const std = @import("std");

const Point = aoc.Point;
const Direction = enum {
    north,
    east,
    south,
    west,
    off,
    const Self = @This();

    pub fn turn(self: Self) Self {
        return switch (self) {
            .north => .east,
            .east => .south,
            .south => .west,
            .west => .north,
            .off => unreachable,
        };
    }
};

const State = struct { pos: Point, direction: Direction };

const Allocator = std.mem.Allocator;
const Grid = std.AutoHashMap(usize, u8);
const JumpMap = std.AutoHashMap(usize, State);
const UsizeSet = aoc.set.ArraySetManaged(usize);

/// Convert a point to a unique numeric key
inline fn point_to_key(p: Point, width: usize) usize {
    return (p.y + 1) * width + (p.x + 1);
}

/// Convert a numeric key to a point
inline fn key_to_point(key: usize, width: usize) Point {
    return .{
        .x = (key % width) - 1,
        .y = @divFloor(key, width) - 1,
    };
}

/// Convert a state (position and direction) into a key
inline fn state_to_key(state: State, width: usize) usize {
    return point_to_key(state.pos, width) * 4 + @intFromEnum(state.direction);
}

fn parse(gpa: Allocator, comptime s: []const u8) !struct { Grid, usize, Point } {
    var lines = aoc.slice.lines(u8, s);

    const size = lines.peek().?.len;

    var grid: Grid = .init(gpa);
    try grid.ensureTotalCapacity(20000);

    var start: ?Point = null;
    var y: usize = 0;

    while (lines.next()) |line| : (y += 1) {
        for (line, 0..) |ch, x| {
            const p: Point = .init(x, y);
            const key = point_to_key(p, size + 2);
            grid.putAssumeCapacityNoClobber(key, ch);

            if (ch == '^') {
                start = p;
            }
        }
    }

    return .{
        grid,
        size,
        start orelse @panic("Should have found start"),
    };
}

fn find_path(gpa: Allocator, grid: Grid, start: Point, size: usize) !UsizeSet {
    const v_width = size + 2;
    var path: UsizeSet = .init(gpa);
    try path.ensureTotalCapacity(7000);

    var position = start;
    var direction: Direction = .north;

    while (grid.contains(point_to_key(position, v_width))) {
        _ = path.addAssumeCapacity(point_to_key(position, v_width));

        const next = switch (direction) {
            .north => position.north_opt(),
            .south => position.south_opt(),
            .east => position.east_opt(),
            .west => position.west_opt(),
            .off => unreachable,
        } orelse return path;

        const key = point_to_key(next, v_width);
        const value = grid.get(key);
        if (value == '#') {
            direction = direction.turn();
        } else {
            position = next;
        }
    }

    return path;
}

const input = @embedFile("data/day06/data.txt");

pub fn part1(gpa: std.mem.Allocator) anyerror!usize {
    var grid, const size, const start = try parse(gpa, input);
    var path = try find_path(gpa, grid, start, size);

    defer {
        grid.deinit();
        path.deinit();
    }

    return path.cardinality();
}

fn find_jumps(gpa: Allocator, grid: Grid, size: usize) !JumpMap {
    var jump_map: JumpMap = .init(gpa);
    try jump_map.ensureTotalCapacity(100_000);

    const v_width = size + 2;
    const OFF_MAP: State = .{
        .pos = .origin(),
        .direction = .off,
    };

    for (0..size) |i| {
        var h_fwd = OFF_MAP;
        var h_bwd = OFF_MAP;

        for (0..size) |j| {
            const h_fwd_state: State = .{
                .pos = .init(j, i),
                .direction = .west,
            };
            const h_fwd_key = state_to_key(h_fwd_state, v_width);
            jump_map.putAssumeCapacityNoClobber(h_fwd_key, h_fwd);

            const h_fwd_grid_key = point_to_key(.init(j, i), v_width);
            if (grid.get(h_fwd_grid_key) == '#') {
                h_fwd = .{
                    .pos = .init(j + 1, i),
                    .direction = .north,
                };
            }

            const x_rev = size - 1 - j;
            const h_bwd_state: State = .{
                .pos = .{ .x = x_rev, .y = i },
                .direction = .east,
            };
            const h_bwd_key = state_to_key(h_bwd_state, v_width);
            jump_map.putAssumeCapacityNoClobber(h_bwd_key, h_bwd);

            const h_bwd_grid_key = point_to_key(.{ .x = x_rev, .y = i }, v_width);
            if (grid.get(h_bwd_grid_key) == '#') {
                h_bwd = .{
                    .pos = .{ .x = x_rev -% 1, .y = i },
                    .direction = .south,
                };
            }
        }

        var v_fwd = OFF_MAP;
        var v_bwd = OFF_MAP;
        for (0..size) |j| {
            const v_fwd_state: State = .{
                .pos = .{ .x = i, .y = j },
                .direction = .north,
            };

            const v_fwd_key = state_to_key(v_fwd_state, v_width);
            jump_map.putAssumeCapacityNoClobber(v_fwd_key, v_fwd);

            const v_fwd_grid_key = point_to_key(.{ .x = i, .y = j }, v_width);
            if (grid.get(v_fwd_grid_key) == '#') {
                v_fwd = .{
                    .pos = .{ .x = i, .y = j + 1 },
                    .direction = .east,
                };
            }

            const y_rev = size - 1 - j;
            const v_bwd_state: State = .{
                .pos = .{ .x = i, .y = y_rev },
                .direction = .south,
            };
            const v_bwd_key = state_to_key(v_bwd_state, v_width);
            jump_map.putAssumeCapacityNoClobber(v_bwd_key, v_bwd);

            const v_bwd_grid_key = point_to_key(.{ .x = i, .y = y_rev }, v_width);
            if (grid.get(v_bwd_grid_key) == '#') {
                v_bwd = .{ .pos = .{ .x = i, .y = y_rev -% 1 }, .direction = .west };
            }
        }
    }

    return jump_map;
}

fn find_cycles(gpa: Allocator, path: UsizeSet, grid: Grid, start: Point, jump_map: JumpMap, size: usize) !usize {
    const v_width = size + 2;

    var visited: UsizeSet = try .initCapacity(gpa, 512);
    defer visited.deinit();

    var count: usize = 0;
    var it = path.iterator();

    while (it.next()) |entry| {
        const path_key = entry.key_ptr.*;
        if (grid.get(path_key) != '.') continue;

        const obs = key_to_point(path_key, v_width);
        visited.clearRetainingCapacity();

        var pos = start;
        var dir: Direction = .north;
        while (true) {
            const key = state_to_key(.{ .pos = pos, .direction = dir }, v_width);

            if (!grid.contains(point_to_key(pos, v_width))) break;

            if (visited.contains(key)) {
                count += 1;
                break;
            }

            _ = try visited.add(key);

            if (pos.x != obs.x and pos.y != obs.y) {
                const jump = jump_map.get(key) orelse break;
                if (jump.direction == .off) break;
                pos = jump.pos;
                dir = jump.direction;
            } else {
                const next_pos = switch (dir) {
                    .north => pos.north_opt(),
                    .south => pos.south_opt(),
                    .east => pos.east_opt(),
                    .west => pos.west_opt(),
                    .off => unreachable,
                } orelse break;
                const next_key = point_to_key(next_pos, v_width);

                if (grid.get(next_key) == '#' or next_pos.eql(obs)) {
                    dir = dir.turn();
                } else {
                    pos = next_pos;
                }
            }
        }
    }

    return count;
}

pub fn part2(gpa: std.mem.Allocator) anyerror!usize {
    var grid, const size, const start = try parse(gpa, input);
    var path = try find_path(gpa, grid, start, size);
    var jump_map = try find_jumps(gpa, grid, size);
    const cycles = try find_cycles(gpa, path, grid, start, jump_map, size);

    defer {
        grid.deinit();
        path.deinit();
        jump_map.deinit();
    }

    return cycles;
}

const t = std.testing;

test "day06 part1" {
    _ = try aoc.validate(part1, 4559, aoc.Day.@"06", aoc.Part.one, t.allocator);
}

test "day06 part2" {
    _ = try aoc.validate(part2, 1604, aoc.Day.@"06", aoc.Part.two, t.allocator);
}

test "day06 key_to_pos and pos_to_key" {
    const width = 132;
    const point = key_to_point(16046, width);
    const key = point_to_key(Point.init(73, 120), width);

    const expected_key = 16046;
    const expected_point = Point.init(73, 120);

    try t.expectEqual(expected_key, key);
    try t.expect(expected_point.eql(point));

    const round_trip_point = key_to_point(point_to_key(expected_point, width), width);
    try t.expect(expected_point.eql(round_trip_point));
}

test "day06 state_to_key" {
    const result = state_to_key(.{ .pos = .init(54, 108), .direction = .south }, 132);
    try t.expectEqual(57774, result);
}
