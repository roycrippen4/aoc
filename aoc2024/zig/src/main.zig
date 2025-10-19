const std = @import("std");
const aoc = @import("aoc");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) unreachable;
    }

    var total_time: u64 = 0;

    total_time += try aoc.validate(day01.part1, 1506483, aoc.Day.one, aoc.Part.one, allocator);
    total_time += try aoc.validate(day01.part2, 23126924, aoc.Day.one, aoc.Part.two, allocator);

    total_time += try aoc.validate(day02.part1, 202, aoc.Day.two, aoc.Part.one, allocator);
    total_time += try aoc.validate(day02.part2, 271, aoc.Day.two, aoc.Part.two, allocator);

    total_time += try aoc.validate(day03.part1, 173731097, aoc.Day.three, aoc.Part.one, allocator);
    total_time += try aoc.validate(day03.part2, 93729253, aoc.Day.three, aoc.Part.two, allocator);

    total_time += try aoc.validate(day04.part1, 2483, aoc.Day.four, aoc.Part.one, allocator);
    total_time += try aoc.validate(day04.part2, 1925, aoc.Day.four, aoc.Part.two, allocator);

    total_time += try aoc.validate(day05.part1, 7198, aoc.Day.five, aoc.Part.one, allocator);
    total_time += try aoc.validate(day05.part2, 4230, aoc.Day.five, aoc.Part.two, allocator);

    const time = aoc.Time.colorTime(total_time, allocator) catch unreachable;
    defer allocator.free(time);
    std.debug.print("\nTotal time: {s}\n", .{time});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
