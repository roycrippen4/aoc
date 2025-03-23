const std = @import("std");
const util = @import("util.zig");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) unreachable;
    }

    _ = try util.validate(day01.part1, 1506483, util.Day.one, util.Part.one, allocator);
    _ = try util.validate(day01.part2, 23126924, util.Day.one, util.Part.two, allocator);
    _ = try util.validate(day02.part1, 202, util.Day.two, util.Part.one, allocator);
}
