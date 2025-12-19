const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const use_example = false;

const input = if (use_example)
    @embedFile("data/day06/example.txt")
else
    @embedFile("data/day06/data.txt");

fn count_cols(comptime s: []const u8) usize {
    @setEvalBranchQuota(80000);
    var lines = aoc.slice.lines(s);
    const first_row = lines.next().?;
    var it = std.mem.tokenizeScalar(u8, first_row, ' ');
    var cols: usize = 0;
    while (it.next()) |_| : (cols += 1) {}
    return cols;
}

fn count_rows(comptime s: []const u8) usize {
    @setEvalBranchQuota(80000);
    var it = aoc.slice.lines(s);
    var rows: usize = 0;
    while (it.next()) |_| : (rows += 1) {}
    return rows;
}

const COLS: usize = count_cols(input); // needed for comptime creation of matrix
const ROWS: usize = count_rows(input); // needed for comptime creation of matrix
const Row = aoc.Stack(usize, COLS);
const Numbers = aoc.Stack(Row, ROWS); // last row is the results row, not the operators!

// creates the matrix at comptime
fn collect_digits(comptime s: []const u8) Numbers {
    @setEvalBranchQuota(400000);

    var nums: Numbers = .{};

    var lines_it = aoc.slice.lines(s);
    while (lines_it.next()) |line| {
        if (lines_it.index orelse break == ROWS - 1) break;

        var row: Row = .{};
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        while (it.next()) |digit_str| {
            const digit = std.fmt.parseInt(usize, digit_str, 10) catch unreachable;
            row.push(digit);
        }
        nums.push(row);
    }

    return nums;
}

const Op = enum {
    plus,
    times,

    pub fn from_str(comptime s: []const u8) @This() {
        return if (std.mem.eql(u8, "+", s))
            .plus
        else if (std.mem.eql(u8, "*", s))
            .times
        else
            unreachable;
    }
    test "day06 Op.from_str" {
        try testing.expectEqual(.plus, Op.from_str("+"));
        try testing.expectEqual(.times, Op.from_str("*"));
    }

    pub fn apply(self: @This(), a: usize, b: usize) usize {
        return switch (self) {
            .plus => a + b,
            .times => if (a == 0) 1 * b else if (b == 0) a * 1 else a * b,
        };
    }
    test "day06 Op.apply" {
        try testing.expectEqual(489, Op.plus.apply(69, 420));
    }

    pub fn to_string(self: @This()) []const u8 {
        return switch (self) {
            .plus => "+",
            .times => "*",
        };
    }
};

fn collect_ops(comptime s: []const u8) [COLS]Op {
    @setEvalBranchQuota(80000);
    var ops: [COLS]Op = undefined;

    var lines = aoc.slice.lines(s);
    var i: usize = 0;
    while (i != ROWS - 1) : (i += 1) _ = lines.next();

    i = 0;
    var it = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    while (it.next()) |op_str| : (i += 1) {
        const op: Op = .from_str(op_str);
        ops[i] = op;
    }

    return ops;
}

const NUMBERS: Numbers = collect_digits(input); // making this `var` is kind of naughty
const OPS: [COLS]Op = collect_ops(input);

fn part1(_: Allocator) !usize {
    var results: Row = .{
        .capacity = COLS,
        .len = COLS,
        .items = .{0} ** COLS,
    };

    for (0..COLS) |j| for (0..ROWS - 1) |i| {
        const op = OPS[j];
        const item = NUMBERS.items[i].items[j];
        const prev_result = results.items[j];
        const new_result = op.apply(prev_result, item);

        results.items[j] = new_result;
    };

    var answer: usize = 0;
    for (results.to_slice()) |n| {
        answer += n;
    }

    return answer;
}

fn part2(_: Allocator) !usize {
    return 42;
}

pub fn solution() Solution {
    return .{
        .day = .@"06",
        .p1 = .{ .f = part1, .expected = 6343365546996 },
        .p2 = .{ .f = part2, .expected = 42 },
    };
}

test "day06 part1" {
    _ = try aoc.validate(part1, 6343365546996, .@"06", .one, testing.allocator);
}

test "day06 part2" {
    _ = try aoc.validate(part2, 42, .@"06", .two, testing.allocator);
}

test "day06 solution" {
    _ = try solution().solve(testing.allocator);
}
