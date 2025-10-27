const day = @import("day.zig");
const grid = @import("grid.zig");
const part = @import("part.zig");

pub const Point = @import("point.zig");

pub const direction = @import("direction.zig");
pub const math = @import("math.zig");
pub const slice = @import("slice.zig");
pub const time = @import("time.zig");
pub const set = @import("set/root.zig");

pub const Day = day.Day;
pub const Grid = grid.Grid;
pub const Part = part.Part;

const std = @import("std");

pub fn validate(f: fn (std.mem.Allocator) anyerror!u64, expected: u64, d: Day, p: Part, allocator: std.mem.Allocator) anyerror!u64 {
    const start = try std.time.Instant.now();
    const result = try f(allocator);
    const finish = try std.time.Instant.now();

    if (result != expected) {
        const fmt_str =
            \\
            \\
            \\===========================
            \\  Failed to solve!
            \\      Expected: {d}
            \\      Found   : {d}
            \\===========================
            \\
            \\
        ;
        const msg = try std.fmt.allocPrint(allocator, fmt_str, .{ expected, result });
        @panic(msg);
    }

    const elapsed = finish.since(start);
    const day_str = d.toString();
    const part_str = p.toString();

    var buf: [64]u8 = undefined;
    const time_str = try time.color(elapsed, &buf);
    std.debug.print("{s} {s} solved in {s}\n", .{ day_str, part_str, time_str });
    return elapsed;
}

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
