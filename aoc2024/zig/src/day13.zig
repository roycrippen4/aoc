const std = @import("std");
const fmt = std.fmt;
const testing = std.testing;
const mem = std.mem;
const Allocator = mem.Allocator;
const Writer = std.io.Writer;

const aoc = @import("aoc");
const Point = aoc.Point;

const input = @embedFile("data/day13/data.txt");
const example = @embedFile("data/day13/example.txt");

fn parse_prize(s: []const u8) Point {
    const stripped = mem.trimStart(u8, s, "Prize: X=");
    var it = mem.splitSequence(u8, stripped, ", Y=");
    return .init(
        fmt.parseInt(usize, it.next().?, 10) catch unreachable,
        fmt.parseInt(usize, it.next().?, 10) catch unreachable,
    );
}

const Button = struct {
    x: usize,
    y: usize,
    cost: usize,

    pub fn parse(s: []const u8) Button {
        const stripped = mem.trimStart(u8, s, "Button ");
        const cost: usize = if (stripped[0] == 'A') 3 else 1;

        var it = mem.splitSequence(u8, stripped[3..], ", ");
        const x = fmt.parseInt(usize, it.next().?[1..], 10) catch unreachable;
        const y = fmt.parseInt(usize, it.next().?[2..], 10) catch unreachable;

        return .{
            .cost = cost,
            .x = x,
            .y = y,
        };
    }
};

const Machine = struct {
    a: Button,
    b: Button,
    prize: Point,

    pub fn parse(s: []const u8) Machine {
        var it = aoc.slice.lines(s);
        return .{
            .a = .parse(it.next().?),
            .b = .parse(it.next().?),
            .prize = parse_prize(it.next().?),
        };
    }

    pub fn with_offset(self: Machine) Machine {
        return .{
            .a = self.a,
            .b = self.b,
            .prize = .{
                .x = self.prize.x + 10_000_000_000_000,
                .y = self.prize.y + 10_000_000_000_000,
            },
        };
    }

    pub fn cheapest(self: Machine) usize {
        const a = self.a;
        const b = self.b;
        const p = self.prize;
        const ax_isize: isize = @intCast(a.x);
        const ay_isize: isize = @intCast(a.y);
        const bx_isize: isize = @intCast(b.x);
        const by_isize: isize = @intCast(b.y);

        const determinant: isize = (ax_isize * by_isize) - (ay_isize * bx_isize);

        if (determinant != 0) {
            const pxby: f64 = @floatFromInt(p.x * b.y);
            const bxpy: f64 = @floatFromInt(b.x * p.y);
            const determinant_f64: f64 = @floatFromInt(determinant);
            const i = (pxby - bxpy) / determinant_f64;

            if (!is_positive_int(i)) return 0;

            const axpy: f64 = @floatFromInt(a.x * p.y);
            const pxay: f64 = @floatFromInt(p.x * a.y);
            const j = (axpy - pxay) / determinant_f64;

            if (!is_positive_int(j)) return 0;

            const i_usize: usize = @intFromFloat(i);
            const j_usize: usize = @intFromFloat(j);

            return (i_usize * a.cost) + (j_usize * b.cost);
        }

        return 0;
    }
};

fn is_positive_int(f: f64) bool {
    const int_part = @trunc(f);
    const fract = f - int_part;
    const int: isize = @intFromFloat(int_part);
    return fract == 0 and int > 0;
}

pub fn part1(_: mem.Allocator) !usize {
    var result: usize = 0;
    var it = mem.splitSequence(u8, mem.trimEnd(u8, input, "\n"), "\n\n");
    while (it.next()) |s| {
        result += Machine.parse(s).cheapest();
    }
    return result;
}

pub fn part2(_: std.mem.Allocator) !usize {
    var result: usize = 0;
    var it = mem.splitSequence(u8, mem.trimEnd(u8, input, "\n"), "\n\n");
    while (it.next()) |s| {
        result += Machine.parse(s).with_offset().cheapest();
    }
    return result;
}

test "day13 part1" {
    _ = try aoc.validate(part1, 29436, .@"13", .one, testing.allocator);
}

test "day13 part2" {
    _ = try aoc.validate(part2, 103_729_094_227_877, .@"13", .two, testing.allocator);
}

test "day13 is_positive_int" {
    try testing.expect(is_positive_int(5.0));
    try testing.expect(!is_positive_int(-5.0));
    try testing.expect(!is_positive_int(-5.123));
    try testing.expect(!is_positive_int(5.123));
}

test "day13 parse_prize" {
    const s = "Prize: X=8400, Y=5400";
    const expected: Point = .init(8400, 5400);
    try testing.expect(expected.eql(parse_prize(s)));
}

test "day13 Button.parse" {
    const expected_a: Button = .{ .cost = 3, .x = 94, .y = 34 };
    const expected_b: Button = .{ .cost = 1, .x = 22, .y = 67 };
    try testing.expectEqualDeep(expected_a, Button.parse("Button A: X+94, Y+34"));
    try testing.expectEqualDeep(expected_b, Button.parse("Button B: X+22, Y+67"));
}

test "day13 Machine.parse" {
    const machine_text =
        \\Button A: X+69, Y+23
        \\Button B: X+27, Y+71
        \\Prize: X=18641, Y=10279
    ;

    const expected: Machine = .{
        .a = .{ .x = 69, .y = 23, .cost = 3 },
        .b = .{ .x = 27, .y = 71, .cost = 1 },
        .prize = .{ .x = 18641, .y = 10279 },
    };
    try testing.expectEqualDeep(
        expected,
        Machine.parse(machine_text),
    );
}

test "day13 get_cheapest" {
    try testing.expectEqual(
        280,
        Machine.parse(
            \\Button A: X+94, Y+34
            \\Button B: X+22, Y+67
            \\Prize: X=8400, Y=5400
        ).cheapest(),
    );

    try testing.expectEqual(
        200,
        Machine.parse(
            \\Button A: X+17, Y+86
            \\Button B: X+84, Y+37
            \\Prize: X=7870, Y=6450
        ).cheapest(),
    );
}
