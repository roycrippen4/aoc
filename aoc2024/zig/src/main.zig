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

    var total_time: u64 = 0;

    total_time += try util.validate(day01.part1, 1506483, util.Day.one, util.Part.one, allocator);
    total_time += try util.validate(day01.part2, 23126924, util.Day.one, util.Part.two, allocator);
    total_time += try util.validate(day02.part1, 202, util.Day.two, util.Part.one, allocator);
    total_time += try util.validate(day02.part2, 271, util.Day.two, util.Part.two, allocator);

    const time = util.Time.colorTime(total_time, allocator) catch unreachable;
    std.debug.print("\nTotal time: {s}\n", .{time});
}
