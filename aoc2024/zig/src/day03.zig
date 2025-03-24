const std = @import("std");
const lib = @import("lib");

const input = @embedFile("data/day03/data.txt");
const example = @embedFile("data/day03/example.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) std.testing.expect(false) catch @panic("LEAK DETECTED");
    }

    _ = try lib.validate(part1, 42, lib.Day.three, lib.Part.one, allocator);
    _ = try lib.validate(part2, 42, lib.Day.three, lib.Part.two, allocator);
}

pub fn part1(allocator: std.mem.Allocator) anyerror!usize {
    const lines = lib.lines(example, allocator);
    for (lines) |line| {
        std.debug.print("{s}\n", .{line});
    }
    return 42;
}

pub fn part2(allocator: std.mem.Allocator) anyerror!usize {
    const lines = lib.lines(example, allocator);
    for (lines) |line| {
        std.debug.print("{s}\n", .{line});
    }
    return 42;
}

test "part1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part1(allocator);

    std.debug.print("\n\nAnswer: {d}\n\n", .{answer});
}

test "part2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part2(allocator);

    std.debug.print("\n\nAnswer: {d}\n\n", .{answer});
}
