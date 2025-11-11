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
const day09 = @import("day09.zig");
const day10 = @import("day10.zig");

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

    total_time += try aoc.validate(day01.part1, 1506483, .@"01", .one, gpa);
    total_time += try aoc.validate(day01.part2, 23126924, .@"01", .two, gpa);

    total_time += try aoc.validate(day02.part1, 202, .@"02", .one, gpa);
    total_time += try aoc.validate(day02.part2, 271, .@"02", .two, gpa);

    total_time += try aoc.validate(day03.part1, 173731097, .@"03", .one, gpa);
    total_time += try aoc.validate(day03.part2, 93729253, .@"03", .two, gpa);

    total_time += try aoc.validate(day04.part1, 2483, .@"04", .one, gpa);
    total_time += try aoc.validate(day04.part2, 1925, .@"04", .two, gpa);

    total_time += try aoc.validate(day05.part1, 7198, .@"05", .one, gpa);
    total_time += try aoc.validate(day05.part2, 4230, .@"05", .two, gpa);

    total_time += try aoc.validate(day06.part1, 4559, .@"06", .one, gpa);
    total_time += try aoc.validate(day06.part2, 1604, .@"06", .two, gpa);

    total_time += try aoc.validate(day07.part1, 303766880536, .@"07", .one, gpa);
    total_time += try aoc.validate(day07.part2, 337041851384440, .@"07", .two, gpa);

    total_time += try aoc.validate(day08.part1, 244, .@"08", .one, gpa);
    total_time += try aoc.validate(day08.part2, 912, .@"08", .two, gpa);

    total_time += try aoc.validate(day09.part1, 6448989155953, .@"09", .one, gpa);
    total_time += try aoc.validate(day09.part2, 6476642796832, .@"09", .two, gpa);

    total_time += try aoc.validate(day10.part1, 517, .@"10", .one, gpa);
    total_time += try aoc.validate(day10.part2, 42, .@"10", .two, gpa);

    var buf: [64]u8 = undefined;
    const time = try aoc.time.color(total_time, &buf);
    std.debug.print("\nTotal time: {s}\n", .{time});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
