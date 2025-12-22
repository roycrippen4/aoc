const std = @import("std");
const builtin = @import("builtin");

const aoc = @import("aoc");

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

    total_time += try @import("day01.zig").solution().solve(gpa);
    total_time += try @import("day02.zig").solution().solve(gpa);
    total_time += try @import("day03.zig").solution().solve(gpa);
    total_time += try @import("day04.zig").solution().solve(gpa);
    total_time += try @import("day05.zig").solution().solve(gpa);
    total_time += try @import("day06.zig").solution().solve(gpa);

    var buf: [64]u8 = undefined;
    const time = try aoc.time.color(total_time, &buf);
    std.debug.print("\nTotal time: {s}\n", .{time});
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
