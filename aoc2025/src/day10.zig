const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const math = std.math;
const Allocator = mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Stack = aoc.Stack;
const Solution = aoc.Solution;
const BitSet = std.bit_set.StaticBitSet;

const use_example = false;
const input = if (use_example) example else @embedFile("data/day10.txt");

const example =
    \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
;

fn parse_lights(string: []const u8) u10 {
    var lights: BitSet(10) = .initEmpty();

    for (string, 0..) |ch, i| if (ch == '#') {
        lights.set(9 - i);
    };

    return lights.mask;
}
test "day10 parse_lights" {
    {
        const result = parse_lights("##.###.##.");
        try testing.expectEqual(0b1101110110, result);
    }
    {
        const result = parse_lights(".##.");
        try testing.expectEqual(0b0110000000, result);
    }
    {
        const result = parse_lights("...#.");
        try testing.expectEqual(0b0001000000, result);
    }
}

fn parse_button(string: []const u8) u10 {
    var i: usize = 0;
    var button: BitSet(10) = .initEmpty();

    while (i < string.len) : (i += 2) {
        button.set(9 - (string[i] - '0'));
    }

    return button.mask;
}
test "day10 parse_button" {
    {
        const result = parse_button("0,1,4");
        try testing.expectEqual(0b1100100000, result);
    }
    {
        const result = parse_button("4");
        try testing.expectEqual(0b0000100000, result);
    }
    {
        const result = parse_button("1,4");
        try testing.expectEqual(0b0100100000, result);
    }
    {
        const result = parse_button("0,1,2,3,4,5,6,7,8,9");
        try testing.expectEqual(0b1111111111, result);
    }
}

fn parse_buttons(string: []const u8) Stack(u10, 13) {
    var buttons: Stack(u10, 13) = .{};
    var buttons_iterator = mem.tokenizeScalar(u8, string, ' ');

    while (buttons_iterator.next()) |button_string| {
        const button = parse_button(button_string[1 .. button_string.len - 1]);
        buttons.push(button);
    }

    return buttons;
}
test "day10 parse_buttons" {
    const buttons = parse_buttons("(3) (1,3) (2) (2,3) (0,2) (0,1)");
    const expected: Stack(u10, 13) = .{
        .items = .{
            0b0001000000,
            0b0101000000,
            0b0010000000,
            0b0011000000,
            0b1010000000,
            0b1100000000,
        } ++ .{undefined} ** 7,
        .len = 6,
        .capacity = 13,
    };
    try testing.expectEqualDeep(expected, buttons);
}

fn parse_joltages(string: []const u8) Stack(u32, 10) {
    var joltages: Stack(u32, 10) = .{};
    var it = mem.tokenizeScalar(u8, string, ',');

    while (it.next()) |joltage_slice| {
        const joltage = fmt.parseInt(u32, joltage_slice, 10) catch unreachable;
        joltages.push(joltage);
    }

    return joltages;
}
test "day10 parse_joltages" {
    const joltages = parse_joltages("7,5,12,7,2");
    const expected: Stack(u32, 10) = .{
        .items = .{ 7, 5, 12, 7, 2 } ++ .{undefined} ** 5,
        .len = 5,
        .capacity = 10,
    };
    try testing.expectEqualDeep(expected, joltages);
}

const Machine = struct {
    const Buttons = Stack(u10, 13);
    const Joltages = Stack(u32, 10);

    lights: u10,
    buttons: Buttons,
    joltages: Joltages,

    const Self = @This();

    pub fn min_presses(self: Self) usize {
        const combinations: usize = math.pow(usize, 2, self.buttons.len);
        var min_pressed: usize = math.maxInt(usize);
        var current_lights: u10 = 0;

        for (1..combinations) |i| {
            current_lights ^= self.buttons.items[@ctz(i)];
            if (current_lights == self.lights) {
                const combo = i ^ (i >> 1);
                min_pressed = @min(min_pressed, @popCount(combo));
            }
        }

        return min_pressed;
    }
    test "day10 Machine.min_presses" {
        {
            const machine: Machine = .from_string("[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}");
            const result = machine.min_presses();
            try testing.expectEqual(2, result);
        }
        {
            const machine: Machine = .from_string("[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}");
            const result = machine.min_presses();
            try testing.expectEqual(3, result);
        }
    }

    pub fn from_string(string: []const u8) Self {
        const lights_end = mem.indexOfScalar(u8, string, ']').?;
        const joltage_start = mem.indexOfScalar(u8, string, '{').?;

        const lights_string = string[1..lights_end];
        const buttons_string = string[lights_end + 2 .. joltage_start - 1];
        const joltages_string = string[joltage_start + 1 .. string.len - 1];

        return .{
            .lights = parse_lights(lights_string),
            .buttons = parse_buttons(buttons_string),
            .joltages = parse_joltages(joltages_string),
        };
    }

    pub fn format(self: Self, writer: *std.io.Writer) std.io.Writer.Error!void {
        try writer.print(
            \\Machine{{
            \\    .lights = .{b:0>10},
            \\    .joltages = .{any},
            \\    .buttons = .{{
            \\
        , .{
            self.lights,
            self.joltages.to_slice(),
        });

        for (self.buttons.to_slice()) |button| {
            try writer.print("        {b:0>10},\n", .{button});
        }

        try writer.print(
            \\    }},
            \\}}
        , .{});
    }
};

const LINE_COUNT = aoc.slice.line_count(input);
const MACHINES: [LINE_COUNT]Machine = blk: {
    var machine_index: usize = 0;
    var machines: [LINE_COUNT]Machine = undefined;

    var lines = aoc.slice.lines(input);
    while (lines.next()) |line| : (machine_index += 1) {
        machines[machine_index] = .from_string(line);
    }

    break :blk machines;
};

fn part1(_: Allocator) !usize {
    var result: usize = 0;
    for (MACHINES) |machine| {
        result += machine.min_presses();
    }
    return result;
}

fn part2(_: Allocator) !usize {
    return 42;
}

pub const solution: Solution = .{
    .day = .@"10",
    .p1 = .{ .f = part1, .expected = 547 },
    .p2 = .{ .f = part2, .expected = 42 },
};

test "day10 part1" {
    _ = try aoc.validate(testing.allocator, part1, 547, .@"10", .one);
}

test "day10 part2" {
    _ = try aoc.validate(testing.allocator, part2, 42, .@"10", .two);
}

test "day10 solution" {
    _ = try solution.solve(testing.allocator);
}
