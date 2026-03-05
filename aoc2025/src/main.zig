const std = @import("std");
const builtin = @import("builtin");

const aoc = @import("libaoc");

pub fn main() !void {
    var area_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer area_state.deinit();
    const arena = area_state.allocator();

    var total_time: u64 = 0;

    total_time += try @import("day01.zig").solution.solve(arena);
    total_time += try @import("day02.zig").solution.solve(arena);
    total_time += try @import("day03.zig").solution.solve(arena);
    total_time += try @import("day04.zig").solution.solve(arena);
    total_time += try @import("day05.zig").solution.solve(arena);
    total_time += try @import("day06.zig").solution.solve(arena);
    total_time += try @import("day07.zig").solution.solve(arena);
    total_time += try @import("day08.zig").solution.solve(arena);
    total_time += try @import("day09.zig").solution.solve(arena);
    total_time += try @import("day10.zig").solution.solve(arena);
    total_time += try @import("day11.zig").solution.solve(arena);
    total_time += try @import("day12.zig").solution.solve(arena);

    var buf: [64]u8 = undefined;
    const time = try aoc.time.color(total_time, &buf);
    std.debug.print("\nTotal time: {s}\n", .{time});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
