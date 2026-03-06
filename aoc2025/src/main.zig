const std = @import("std");

const aoc = @import("libaoc");
const Solution = aoc.Solution;

pub const solutions: []const Solution = &.{
    @import("day01.zig").solution,
    @import("day02.zig").solution,
    @import("day03.zig").solution,
    @import("day04.zig").solution,
    @import("day05.zig").solution,
    @import("day06.zig").solution,
    @import("day07.zig").solution,
    @import("day08.zig").solution,
    @import("day09.zig").solution,
    @import("day10.zig").solution,
    @import("day11.zig").solution,
    @import("day12.zig").solution,
};

const help: []const u8 =
    \\Usage: aoc [DAY] [PART]
    \\Runner for Advent of Code solutions
    \\
    \\Examples:
    \\  aoc                Runs all solutions in order
    \\  aoc day 11         Runs both parts of day 11 
    \\  aoc day 9 part 1   Runs part one of day 9
    \\
;

fn solve_all(allocator: std.mem.Allocator) !u64 {
    var total_time: u64 = 0;
    inline for (solutions) |solution| {
        total_time += try solution.solve(allocator);
    }
}

const Args = struct {
    day_index: ?usize,
    part: ?aoc.Part,
    const Self = @This();

    const init: Self = .{
        .day_index = null,
        .part = null,
    };

    fn parse(args: []const []const u8) Self {
        var self: Self = .init;

        if (args.len == 1) return self;
        if (args.len == 2 or args.len == 4) invalid_arg_count();

        if (args.len == 3) {
            if (!std.mem.eql(u8, args[1], "day")) invalid_arg(args[1]);
            if (args[2].len > 2) invalid_arg(args[2]);

            const day = args[2];
            if (day.len == 2) {
                const index = (std.fmt.parseInt(usize, day, 10) catch day_parse_failure(day)) - 1;
                if (index > 11) day_parse_failure(day);
                self.day_index = index;
            } else {
                if (day[0] < '1' or day[0] > '9') day_parse_failure(day);
                self.day_index = (day[0] - '0') - 1;
            }
        }
        std.debug.assert(self.day_index != null);
        return self;
    }
};

pub fn main() !void {
    var area_state = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer area_state.deinit();
    const arena = area_state.allocator();

    var total_time: u64 = 0;
    var buf: [64]u8 = undefined;

    const args: Args = .parse(try std.process.argsAlloc(arena));
    if (args.day_index) |index| {
        total_time += try solutions[index].solve(arena);
    } else {
        inline for (solutions) |solution| {
            total_time += try solution.solve(arena);
        }
    }

    const time = try aoc.time.color(total_time, &buf);
    std.debug.print("\nTotal time: {s}\n", .{time});
}

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.print(fmt, args);
    std.process.exit(1);
}

fn invalid_arg_count() noreturn {
    fatal("Invalid argument count.\n\nSee help for details:\n{s}", .{help});
}

fn invalid_arg(arg: []const u8) noreturn {
    fatal("Invalid argument \"{s}\".\n\nSee help for details:\n{s}", .{ arg, help });
}

fn day_parse_failure(arg: []const u8) noreturn {
    fatal(
        "Failed to parse \"{s}\" as a valid day argument." ++
            \\
            \\Valid forms are `01` or `1`
            \\Day value must be between 1 and 12.
            \\
            \\Examples to run day 5:
            \\aoc day 5
            \\aoc day 05
            \\
            \\
        ,
        .{arg},
    );
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
