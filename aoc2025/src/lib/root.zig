const std = @import("std");
const Allocator = std.mem.Allocator;

pub const char = @import("char.zig");
pub const direction = @import("direction.zig");
pub const math = @import("math.zig");
pub const slice = @import("slice.zig");
pub const time = @import("time.zig");

pub const Day = @import("day.zig").Day;
pub const Grid = @import("grid.zig").Grid;
pub const Part = @import("part.zig").Part;
pub const Point = @import("point.zig");
pub const Stack = @import("stack.zig").Stack;
pub const Deque = @import("deque.zig").Deque;

pub const Solver = struct {
    f: fn (Allocator) anyerror!usize,
    expected: usize,
};

pub const Solution = struct {
    p1: Solver,
    p2: Solver,
    day: Day,

    pub fn solve(self: @This(), allocator: Allocator) !u64 {
        const p1_time = try validate(self.p1.f, self.p1.expected, self.day, .one, allocator);
        const p2_time = try validate(self.p2.f, self.p2.expected, self.day, .two, allocator);
        return p1_time + p2_time;
    }
};

pub fn validate(
    f: fn (Allocator) anyerror!usize,
    expected: usize,
    d: Day,
    p: Part,
    allocator: Allocator,
) !u64 {
    const start = try std.time.Instant.now();
    const result = try f(allocator);
    const elapsed = (try std.time.Instant.now()).since(start);

    if (result != expected) {
        std.debug.print(
            \\===========================
            \\  Failed to solve!
            \\      Expected: {d}
            \\      Found   : {d}
            \\===========================
            \\
        , .{
            expected,
            result,
        });
        @panic("shit");
    }

    var buf: [64]u8 = undefined;
    const time_str = try time.color(elapsed, &buf);
    std.debug.print("{f} {f} solved in {s}\n", .{ d, p, time_str });
    return elapsed;
}

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
