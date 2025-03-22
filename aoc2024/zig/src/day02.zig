const std = @import("std");
const util = @import("util.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) std.testing.expect(false) catch @panic("LEAK DETECTED");
    }

    _ = try util.validate(part1, 42, util.Day.two, util.Part.one, allocator);
    _ = try util.validate(part2, 42, util.Day.two, util.Part.two, allocator);
}

pub fn part1(allocator: std.mem.Allocator) anyerror!usize {
    _ = .{allocator}; // remove this
    return 42;
}

pub fn part2(allocator: std.mem.Allocator) anyerror!usize {
    _ = .{allocator}; // remove this
    return 42;
}

test "part1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part1(allocator);

    std.debug.print("\n\n Answer: {d}\n\n", .{answer});
}

test "part2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const answer = try part2(allocator);

    std.debug.print("\n\n Answer: {d}\n\n", .{answer});
}
