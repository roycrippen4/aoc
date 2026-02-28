const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("libaoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day04.txt");
const SIZE: usize = aoc.slice.line_count(input);

const Grid = aoc.Grid(u8);

fn part1(gpa: Allocator) !usize {
    var grid = try Grid.from_string(gpa, input);
    defer grid.deinit(gpa);

    var answer: usize = 0;

    for (0..grid.buf.len) |i| if (grid.buf[i] == '@') {
        const nbors = grid.index_to_point(i).nbor8_opt();

        var count: usize = 0;
        for (nbors) |nbor_opt| if (nbor_opt) |nbor| {
            if (grid.inside(nbor) and grid.get(nbor) == '@') {
                count += 1;
            }
        };

        if (count < 4) answer += 1;
    };

    return answer;
}

inline fn remove(grid: *Grid) usize {
    var removed: usize = 0;

    for (1..grid.buf.len - 1) |i| if (grid.buf[i] == '@') {
        const nbors = grid.index_to_point(i).nbor8();
        var count: usize = 0;

        for (nbors) |nbor| if (grid.get(nbor) == '@') {
            count += 1;
        };

        if (count < 4) {
            removed += 1;
            grid.buf[i] = '.';
        }
    };

    return removed;
}

fn part2(gpa: Allocator) !usize {
    var grid = try Grid.from_string(gpa, input);
    defer grid.deinit(gpa);
    try grid.pad_sides(gpa, 1, '.');

    var answer: usize = 0;
    while (true) {
        const result = remove(&grid);
        if (result == 0) break;
        answer += result;
    }

    return answer;
}

pub const solution: Solution = .{
    .day = .@"04",
    .p1 = .{ .f = part1, .expected = 1549 },
    .p2 = .{ .f = part2, .expected = 8887 },
};

test "day04 part1" {
    _ = try aoc.validate(testing.allocator, part1, 1549, .@"04", .one);
}

test "day04 part2" {
    _ = try aoc.validate(testing.allocator, part2, 8887, .@"04", .two);
}

test "day04 solution" {
    _ = try solution.solve(testing.allocator);
}
