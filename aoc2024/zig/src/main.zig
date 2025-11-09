const std = @import("std");
const builtin = @import("builtin");

const aoc = @import("aoc");

const day01 = @import("day01.zig");
const day02 = @import("day02.zig");
const day03 = @import("day03.zig");
const day04 = @import("day04.zig");
const day05 = @import("day05.zig");
const day06 = @import("day06.zig");
const day07 = @import("day07.zig");
const day08 = @import("day08.zig");

var debug_allocator: std.heap.DebugAllocator(.{}) = .init;

pub fn main() !void {
    const gpa, const is_debug = gpa: {
        break :gpa switch (builtin.mode) {
            .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
            .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
        };
    };
    defer if (is_debug) {
        _ = debug_allocator.deinit();
    };

    var total_time: u64 = 0;

    total_time += try aoc.validate(day01.part1, 1506483, aoc.Day.@"01", aoc.Part.one, gpa);
    total_time += try aoc.validate(day01.part2, 23126924, aoc.Day.@"01", aoc.Part.two, gpa);

    total_time += try aoc.validate(day02.part1, 202, aoc.Day.@"02", aoc.Part.one, gpa);
    total_time += try aoc.validate(day02.part2, 271, aoc.Day.@"02", aoc.Part.two, gpa);

    total_time += try aoc.validate(day03.part1, 173731097, aoc.Day.@"03", aoc.Part.one, gpa);
    total_time += try aoc.validate(day03.part2, 93729253, aoc.Day.@"03", aoc.Part.two, gpa);

    total_time += try aoc.validate(day04.part1, 2483, aoc.Day.@"04", aoc.Part.one, gpa);
    total_time += try aoc.validate(day04.part2, 1925, aoc.Day.@"04", aoc.Part.two, gpa);

    total_time += try aoc.validate(day05.part1, 7198, aoc.Day.@"05", aoc.Part.one, gpa);
    total_time += try aoc.validate(day05.part2, 4230, aoc.Day.@"05", aoc.Part.two, gpa);

    total_time += try aoc.validate(day06.part1, 4559, aoc.Day.@"06", aoc.Part.one, gpa);
    total_time += try aoc.validate(day06.part2, 1604, aoc.Day.@"06", aoc.Part.two, gpa);

    total_time += try aoc.validate(day07.part1, 303766880536, aoc.Day.@"07", aoc.Part.one, gpa);
    total_time += try aoc.validate(day07.part2, 337041851384440, aoc.Day.@"07", aoc.Part.two, gpa);

    total_time += try aoc.validate(day08.part1, 244, aoc.Day.@"08", aoc.Part.one, gpa);
    total_time += try aoc.validate(day08.part2, 42, aoc.Day.@"08", aoc.Part.two, gpa);

    var buf: [64]u8 = undefined;
    const time = try aoc.time.color(total_time, &buf);
    std.debug.print("\nTotal time: {s}\n", .{time});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
