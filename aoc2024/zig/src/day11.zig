const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");

const Map = std.AutoHashMap(usize, usize);
const SmStack = aoc.Stack(usize, 160);
const LgStack = aoc.Stack(usize, 5000);

const USIZE_MAX: usize = std.math.maxInt(usize);

fn parse() [8]usize {
    const input_raw = @embedFile("data/day11/data.txt");
    const input = aoc.slice.trim(input_raw);
    var it = std.mem.splitScalar(u8, input, ' ');

    var result: [8]usize = undefined;
    var i: usize = 0;

    while (it.next()) |s| : (i += 1) {
        result[i] = std.fmt.parseInt(usize, s, 10) catch unreachable;
    }

    return result;
}

fn print_map(map: Map) void {
    var it = map.iterator();
    std.debug.print("Map{{\n", .{});

    while (it.next()) |entry| {
        std.debug.print("    {d}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("}}\n", .{});
}

fn index_of(indices: *Map, todo: *SmStack, n: usize) usize {
    const size = indices.count();
    const entry = indices.getOrPutAssumeCapacity(n);

    if (!entry.found_existing) {
        todo.push(n);
        entry.value_ptr.* = size;
    }

    return entry.value_ptr.*;
}

fn count_stones(gpa: Allocator, blinks: usize) !usize {
    var stones: aoc.Stack(struct { usize, usize }, 5000) = .{};

    var indices: Map = .init(gpa);
    defer indices.deinit();
    try indices.ensureTotalCapacity(5000);

    var todo: SmStack = .{};
    var numbers: SmStack = .{};
    var current: std.ArrayList(usize) = try .initCapacity(gpa, 5000);
    defer current.deinit(gpa);

    for (parse()) |number| {
        if (indices.get(number)) |index| {
            current.items[index] += 1;
        } else {
            indices.putAssumeCapacity(number, indices.count());
            todo.push(number);
            try current.append(gpa, 1);
        }
    }

    var next: std.ArrayList(usize) = try .initCapacity(gpa, indices.count());
    defer next.deinit(gpa);
    @memset(next.items, 0);

    for (0..blinks) |_| {
        std.mem.swap(SmStack, &numbers, &todo);

        var it = numbers.iterator();
        while (it.next()) |number| {
            stones.push(transform(number, &indices, &todo));
        }
        numbers.clear();

        try next.resize(gpa, indices.count());
        @memset(next.items, 0);

        for (0..stones.len) |i| {
            const first, const second = stones.items[i];
            const amount = current.items[i];

            next.items[first] += amount;
            if (second != USIZE_MAX) {
                next.items[second] += amount;
            }
        }

        std.mem.swap(std.ArrayList(usize), &current, &next);
    }

    var result: usize = 0;
    for (current.items) |item| result += item;

    return result;
}

fn transform(number: usize, indices: *Map, todo: *SmStack) struct { usize, usize } {
    if (number == 0) {
        return .{
            index_of(indices, todo, 1),
            USIZE_MAX,
        };
    }

    const digits = std.math.log10_int(number) + 1;
    if (digits % 2 == 0) {
        const power = std.math.pow(usize, 10, (digits / 2));
        return .{
            index_of(indices, todo, number / power),
            index_of(indices, todo, number % power),
        };
    }

    return .{
        index_of(indices, todo, number * 2024),
        USIZE_MAX,
    };
}

pub fn part1(gpa: Allocator) !usize {
    return count_stones(gpa, 25);
}

pub fn part2(gpa: Allocator) !usize {
    return count_stones(gpa, 75);
}

test "day11 part1" {
    _ = try aoc.validate(part1, 220999, .@"11", .one, testing.allocator);
}

test "day11 part2" {
    _ = try aoc.validate(part2, 261936432123724, .@"11", .two, testing.allocator);
}
