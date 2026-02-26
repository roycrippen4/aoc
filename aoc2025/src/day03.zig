const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day03/data.txt");

fn find_max_joltage(line: []const u8) usize {
    var a: isize = -1;
    var b: isize = -1;

    for (0..line.len) |i| {
        const value = @as(isize, line[i] - '0');

        if (a < value and i != line.len - 1) {
            a = value;
            b = -1;
        } else if (b < value) {
            b = value;
        }
    }

    std.debug.assert(a != -1 and b != -1);

    return @intCast((a * 10) + b);
}

fn part1(_: Allocator) !usize {
    var sum: usize = 0;

    var it = aoc.slice.lines(input);
    while (it.next()) |line| {
        sum += find_max_joltage(line);
    }

    return sum;
}

fn array_to_number(s: [12]usize) usize {
    var result: usize = 0;
    var magnitude = std.math.pow(usize, 10, s.len - 1);

    for (0..s.len) |i| {
        result += (s[i] * magnitude);
        magnitude /= 10;
    }

    return result;
}

fn shift(s: *[12]usize, n: usize) void {
    for (0..s.len - 1) |i| if (s[i] < s[i + 1]) {
        s[i] = s[i + 1];
        s[i + 1] = 0;
    };

    if (s[s.len - 1] < n) {
        s[s.len - 1] = n;
    }
}

fn find_max_joltage2(line: []const u8) usize {
    var array: [12]usize = undefined;

    for (0..12) |i| array[i] = line[i] - '0';
    for (line[12..]) |c| shift(&array, c - '0');

    return array_to_number(array);
}

fn part2(_: Allocator) !usize {
    var sum: usize = 0;
    var it = aoc.slice.lines(input);

    while (it.next()) |line| {
        sum += find_max_joltage2(line);
    }

    return sum;
}

pub const solution: Solution = .{
    .day = .@"03",
    .p1 = .{ .f = part1, .expected = 17085 },
    .p2 = .{ .f = part2, .expected = 169408143086082 },
};

test "day03 part1" {
    _ = try aoc.validate(testing.allocator, part1, 17085, .@"03", .one);
}

test "day03 part2" {
    _ = try aoc.validate(testing.allocator, part2, 169408143086082, .@"03", .two);
}

test "day03 solution" {
    _ = try solution.solve(testing.allocator);
}

const example =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

test "day03 find_max_joltage" {
    try testing.expectEqual(98, find_max_joltage("987654321111111"));
    try testing.expectEqual(89, find_max_joltage("811111111111119"));
    try testing.expectEqual(78, find_max_joltage("234234234234278"));
    try testing.expectEqual(92, find_max_joltage("818181911112111"));
}

test "day03 part1 example" {
    var sum: usize = 0;

    var it = aoc.slice.lines(example);
    while (it.next()) |line| {
        sum += find_max_joltage(line);
    }

    try testing.expectEqual(357, sum);
}

test "day03 find_joltage2" {
    try testing.expectEqual(987654321111, find_max_joltage2("987654321111111"));
    try testing.expectEqual(811111111119, find_max_joltage2("811111111111119"));
    try testing.expectEqual(434234234278, find_max_joltage2("234234234234278"));
    try testing.expectEqual(888911112111, find_max_joltage2("818181911112111"));
}

test "day03 stack_to_number" {
    try testing.expectEqual(
        999999999999,
        array_to_number(.{ 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9 }),
    );
}

test "day03 example part 2" {
    var sum: usize = 0;

    var it = aoc.slice.lines(example);
    while (it.next()) |line| {
        sum += find_max_joltage2(line);
    }

    try testing.expectEqual(3121910778619, sum);
}
