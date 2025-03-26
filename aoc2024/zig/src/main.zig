const std = @import("std");
const lib = @import("lib");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit = gpa.deinit();
        if (deinit == .leak) unreachable;
    }

    var total_time: u64 = 0;

    total_time += try lib.validate(day01.part1, 1506483, lib.Day.one, lib.Part.one, allocator);
    total_time += try lib.validate(day01.part2, 23126924, lib.Day.one, lib.Part.two, allocator);
    total_time += try lib.validate(day02.part1, 202, lib.Day.two, lib.Part.one, allocator);
    total_time += try lib.validate(day02.part2, 271, lib.Day.two, lib.Part.two, allocator);
    total_time += try lib.validate(day03.part1, 173731097, lib.Day.three, lib.Part.one, allocator);
    total_time += try lib.validate(day03.part2, 93729253, lib.Day.three, lib.Part.two, allocator);

    const time = lib.Time.colorTime(total_time, allocator) catch unreachable;
    defer allocator.free(time);
    std.debug.print("\nTotal time: {s}\n", .{time});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
