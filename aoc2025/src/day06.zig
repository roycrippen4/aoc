const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day06/data.txt");

const COLS: usize = blk: {
    var lines = aoc.slice.lines(input);
    const first_row = lines.next().?;
    var it = std.mem.tokenizeScalar(u8, first_row, ' ');
    var cols: usize = 0;
    while (it.next()) |_| : (cols += 1) {}
    break :blk cols;
};

const ROWS: usize = blk: {
    var it = aoc.slice.lines(input);
    var rows: usize = 0;
    while (it.next()) |_| : (rows += 1) {}
    break :blk rows;
};

const Row = aoc.Stack(usize, COLS);
const Numbers = aoc.Stack(Row, ROWS);

const NUMBERS: Numbers = blk: {
    @setEvalBranchQuota(400000);
    var nums: Numbers = .{};

    var lines_it = aoc.slice.lines(input);
    while (lines_it.next()) |line| {
        if (lines_it.index orelse break == ROWS - 1) break;

        var row: Row = .{};
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        while (it.next()) |n_str| {
            const n = std.fmt.parseInt(usize, n_str, 10) catch unreachable;
            row.push(n);
        }
        nums.push(row);
    }

    break :blk nums;
};

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

const OPS_STR: []const u8 = blk: {
    var lines = aoc.slice.lines(input);
    var i: usize = 0;
    while (i != ROWS - 1) : (i += 1) _ = lines.next();
    break :blk lines.next().?;
};

const OPS: [COLS]Op = blk: {
    @setEvalBranchQuota(20000);
    var ops: [COLS]Op = undefined;

    var i: usize = 0;
    var it = std.mem.tokenizeScalar(u8, OPS_STR, ' ');
    while (it.next()) |op_str| : (i += 1) {
        const op: Op = .from_str(op_str);
        ops[i] = op;
    }

    break :blk ops;
};

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

const Blk = struct { index: usize, width: usize };
const LINE_LEN = aoc.slice.line_len(input) + 1;
const BLKS: aoc.Stack(Blk, COLS) = blk: {
    @setEvalBranchQuota(5000);
    var blk_widths: aoc.Stack(Blk, COLS) = .{};

    var start: usize = 0;
    for (1.., OPS_STR[1..]) |i, char| {
        switch (char) {
            '+', '*' => {
                blk_widths.push(.{
                    .index = start,
                    .width = i - start,
                });
                start = i;
            },
            ' ' => {},
            else => unreachable,
        }
    }

    blk_widths.push(.{
        .index = start,
        .width = OPS_STR.len - start,
    });

    break :blk blk_widths;
};

fn part2(_: Allocator) !usize {
    var answer: usize = 0;

    for (0..COLS) |blk_idx| {
        const blk = BLKS.items[blk_idx];
        const op = OPS[blk_idx];

        var col_idx = blk.index + blk.width;
        var total_cols = blk.width;
        var blk_result: usize = 0;

        while (total_cols > 0) {
            col_idx -= 1;
            total_cols -= 1;

            var num_buf: [ROWS - 1]u8 = undefined;
            for (0..ROWS - 1) |row_idx| {
                const i = col_idx + (row_idx * LINE_LEN);
                num_buf[row_idx] = input[i];
            }

            const n_str = std.mem.trim(u8, &num_buf, &.{ '\n', ' ' });
            if (n_str.len == 0) continue;
            const n = std.fmt.parseInt(usize, n_str, 10) catch continue;
            blk_result = op.apply(blk_result, n);
        }

        answer += blk_result;
    }

    return answer;
}

pub const solution: Solution = .{
    .day = .@"06",
    .p1 = .{ .f = part1, .expected = 6343365546996 },
    .p2 = .{ .f = part2, .expected = 11136895955912 },
};

test "day06 part1" {
    _ = try aoc.validate(testing.allocator, part1, 6343365546996, .@"06", .one);
}

test "day06 part2" {
    _ = try aoc.validate(testing.allocator, part2, 11136895955912, .@"06", .two);
}

test "day06 solution" {
    _ = try solution.solve(testing.allocator);
}
