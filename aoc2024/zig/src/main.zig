const std = @import("std");
const day01 = @import("day01.zig");
const util = @import("util.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) unreachable;
    }

    _ = try util.validate(day01.part1, 1506483, util.Day.one, util.Part.one, allocator);
    _ = try util.validate(day01.part2, 23126924, util.Day.one, util.Part.two, allocator);
}
