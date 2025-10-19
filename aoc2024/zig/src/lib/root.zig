const day = @import("day.zig");
const direction = @import("direction.zig");
const grid = @import("grid.zig");
const part = @import("part.zig");
const point = @import("point.zig");
const time = @import("time.zig");

pub const Math = @import("math.zig");
pub const Slice = @import("slice.zig");

pub const Day = day.Day;
pub const Direction = direction.Direction;
pub const Grid = grid.Grid;
pub const Part = part.Part;
pub const Point = point.Point;
pub const Time = time.Time;

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
    const time_str = try Time.colorTime(elapsed, allocator);
    defer allocator.free(time_str);
    std.debug.print("{s} {s} solved in {s}\n", .{ day_str, part_str, time_str });
    return elapsed;
}

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
