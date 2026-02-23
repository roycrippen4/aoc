const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const Allocator = mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Stack = aoc.Stack;
const Solution = aoc.Solution;
const BitSet = std.bit_set.IntegerBitSet(10);

const use_example = false;
const input = if (use_example)
    @embedFile("data/day10/example.txt")
else
    @embedFile("data/day10/data.txt");

fn parse_lights(string: []const u8) u10 {
    var lights: BitSet = .initEmpty();

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
    var button: BitSet = .initEmpty();

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
        for (self.buttons.to_slice()) |button| {
            if (button == self.lights) return 1;
        }

        for (0..self.buttons.len - 1) |i| {
            for (i..self.buttons.len) |j| {
                const b1 = self.buttons.items[i];
                const b2 = self.buttons.items[j];
                if (b1 ^ b2 == self.lights) return 2;
            }
        }

        for (0..self.buttons.len - 2) |i| {
            for (i..self.buttons.len - 1) |j| {
                for (j..self.buttons.len) |k| {
                    const b1 = self.buttons.items[i];
                    const b2 = self.buttons.items[j];
                    const b3 = self.buttons.items[k];
                    if (b1 ^ b2 ^ b3 == self.lights) return 3;
                }
            }
        }

        for (0..self.buttons.len - 3) |i| {
            for (i..self.buttons.len - 2) |j| {
                for (j..self.buttons.len - 1) |k| {
                    for (k..self.buttons.len) |l| {
                        const b1 = self.buttons.items[i];
                        const b2 = self.buttons.items[j];
                        const b3 = self.buttons.items[k];
                        const b4 = self.buttons.items[l];
                        if (b1 ^ b2 ^ b3 ^ b4 == self.lights) return 4;
                    }
                }
            }
        }

        for (0..self.buttons.len - 4) |i| {
            for (i..self.buttons.len - 3) |j| {
                for (j..self.buttons.len - 2) |k| {
                    for (k..self.buttons.len - 1) |l| {
                        for (l..self.buttons.len) |m| {
                            const b1 = self.buttons.items[i];
                            const b2 = self.buttons.items[j];
                            const b3 = self.buttons.items[k];
                            const b4 = self.buttons.items[l];
                            const b5 = self.buttons.items[m];
                            if (b1 ^ b2 ^ b3 ^ b4 ^ b5 == self.lights) return 5;
                        }
                    }
                }
            }
        }

        for (0..self.buttons.len - 5) |i| {
            for (i..self.buttons.len - 4) |j| {
                for (j..self.buttons.len - 3) |k| {
                    for (k..self.buttons.len - 2) |l| {
                        for (l..self.buttons.len - 1) |m| {
                            for (m..self.buttons.len) |n| {
                                const b1 = self.buttons.items[i];
                                const b2 = self.buttons.items[j];
                                const b3 = self.buttons.items[k];
                                const b4 = self.buttons.items[l];
                                const b5 = self.buttons.items[m];
                                const b6 = self.buttons.items[n];
                                if (b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ b6 == self.lights) return 6;
                            }
                        }
                    }
                }
            }
        }

        for (0..self.buttons.len - 6) |i| {
            for (i..self.buttons.len - 5) |j| {
                for (j..self.buttons.len - 4) |k| {
                    for (k..self.buttons.len - 3) |l| {
                        for (l..self.buttons.len - 2) |m| {
                            for (m..self.buttons.len - 1) |n| {
                                for (n..self.buttons.len) |o| {
                                    const b1 = self.buttons.items[i];
                                    const b2 = self.buttons.items[j];
                                    const b3 = self.buttons.items[k];
                                    const b4 = self.buttons.items[l];
                                    const b5 = self.buttons.items[m];
                                    const b6 = self.buttons.items[n];
                                    const b7 = self.buttons.items[o];
                                    if (b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ b6 ^ b7 == self.lights) return 7;
                                }
                            }
                        }
                    }
                }
            }
        }

        unreachable;
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
    std.debug.print("{d}\n", .{result});
    return 42;
}

fn part2(_: Allocator) !usize {
    return 42;
}

pub const solution: Solution = .{
    .day = .@"10",
    .p1 = .{ .f = part1, .expected = 42 },
    .p2 = .{ .f = part2, .expected = 42 },
};

test "day10 part1" {
    _ = try aoc.validate(testing.allocator, part1, 42, .@"10", .one);
}

test "day10 part2" {
    _ = try aoc.validate(testing.allocator, part2, 42, .@"10", .two);
}

test "day10 solution" {
    _ = try solution.solve(testing.allocator);
}
