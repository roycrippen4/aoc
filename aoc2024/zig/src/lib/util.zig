const std = @import("std");

/// Enum representing the two parts commonly
/// found with advent of code problems.
pub const Part = enum {
    one,
    two,

    /// Converts the part into its character representation
    pub fn toString(self: Part) []const u8 {
        return switch (self) {
            .one => "Part 1",
            .two => "Part 2",
        };
    }
};

/// An enum representing days for Advent of Code problems (1-25).
/// Each variant corresponds to a day number in the challenge.
pub const Day = enum {
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    ten,
    eleven,
    twelve,
    thirteen,
    fourteen,
    fifteen,
    sixteen,
    seventeen,
    eighteen,
    nineteen,
    twenty,
    twenty_one,
    twenty_two,
    twenty_three,
    twenty_four,
    twenty_five,

    /// Converts the Day enum variant to a formatted string.
    /// Returns a string in the format "Day XX" where XX is a zero-padded two-digit number.
    /// Example: Day.two becomes "Day 02", Day.twenty_five becomes "Day 25"
    pub fn toString(self: Day) []const u8 {
        return switch (self) {
            .one => "Day 01",
            .two => "Day 02",
            .three => "Day 03",
            .four => "Day 04",
            .five => "Day 05",
            .six => "Day 06",
            .seven => "Day 07",
            .eight => "Day 08",
            .nine => "Day 09",
            .ten => "Day 10",
            .eleven => "Day 11",
            .twelve => "Day 12",
            .thirteen => "Day 13",
            .fourteen => "Day 14",
            .fifteen => "Day 15",
            .sixteen => "Day 16",
            .seventeen => "Day 17",
            .eighteen => "Day 18",
            .nineteen => "Day 19",
            .twenty => "Day 20",
            .twenty_one => "Day 21",
            .twenty_two => "Day 22",
            .twenty_three => "Day 23",
            .twenty_four => "Day 24",
            .twenty_five => "Day 25",
        };
    }
};

pub const Time = enum {
    Sec,
    MilSlow,
    MilMed,
    MilFast,
    Micro,

    fn convertToSeconds(ns: u64) f64 {
        const ns_f: f64 = @floatFromInt(ns);
        const ns_per_s_f: f64 = @floatFromInt(std.time.ns_per_s);
        return ns_f / ns_per_s_f;
    }

    fn convertToMil(ns: u64) f64 {
        const ns_f: f64 = @floatFromInt(ns);
        const ns_per_ms_f: f64 = @floatFromInt(std.time.ns_per_ms);
        return ns_f / ns_per_ms_f;
    }

    fn convertToMicro(ns: u64) f64 {
        const ns_f: f64 = @floatFromInt(ns);
        const ns_per_us_f: f64 = @floatFromInt(std.time.ns_per_us);
        return ns_f / ns_per_us_f;
    }

    fn getRange(ns: u64) Time {
        const time = convertToSeconds(ns);
        if (time > 1.0) {
            return Time.Sec;
        }
        if (time > 0.1) {
            return Time.MilSlow;
        }
        if (time > 0.01) {
            return Time.MilMed;
        }
        if (time > 0.001) {
            return Time.MilFast;
        }
        return Time.Micro;
    }

    pub fn colorTime(ns: u64, allocator: std.mem.Allocator) anyerror![]u8 {
        return switch (getRange(ns)) {
            .Sec => {
                const secs = convertToSeconds(ns);
                const string = try std.fmt.allocPrint(allocator, "{d:.3}s", .{secs});
                defer allocator.free(string);
                return try rgb(255, 0, 0, string, allocator);
            },
            .MilSlow => {
                const mils = convertToMil(ns);
                const string = try std.fmt.allocPrint(allocator, "{d:.3}ms", .{mils});
                defer allocator.free(string);
                return try rgb(255, 82, 0, string, allocator);
            },
            .MilMed => {
                const mils = convertToMil(ns);
                const string = try std.fmt.allocPrint(allocator, "{d:.3}ms", .{mils});
                defer allocator.free(string);
                return try rgb(255, 165, 0, string, allocator);
            },
            .MilFast => {
                const mils = convertToMil(ns);
                const string = try std.fmt.allocPrint(allocator, "{d:.3}ms", .{mils});
                defer allocator.free(string);
                return try rgb(127, 210, 0, string, allocator);
            },
            .Micro => {
                const micros = convertToMicro(ns);
                const string = try std.fmt.allocPrint(allocator, "{d:.3}µs", .{micros});
                defer allocator.free(string);
                return try rgb(0, 255, 0, string, allocator);
            },
        };
    }
};

fn rgb(r: u8, g: u8, b: u8, s: []const u8, allocator: std.mem.Allocator) anyerror![]u8 {
    return try std.fmt.allocPrint(
        allocator,
        "\x1b[38;2;{d};{d};{d}m{s}\x1b[0m",
        .{ r, g, b, s },
    );
}

pub fn validate(f: fn (std.mem.Allocator) anyerror!u64, expected: u64, day: Day, part: Part, allocator: std.mem.Allocator) anyerror!u64 {
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
    const day_str = day.toString();
    const part_str = part.toString();
    const time_str = try Time.colorTime(elapsed, allocator);
    defer allocator.free(time_str);
    std.debug.print("{s} {s} solved in {s}\n", .{ day_str, part_str, time_str });
    return elapsed;
}

pub fn absDiff(x: usize, y: usize) usize {
    const safe_x: i64 = @intCast(x);
    const safe_y: i64 = @intCast(y);
    return @abs(safe_x - safe_y);
}

const t = std.testing;
test "util part.toString" {
    try t.expectEqualStrings("Part 1", Part.one.toString());
    try t.expectEqualStrings("Part 2", Part.two.toString());
}

test "util absDiff" {
    const x: usize = 3;
    const y: usize = 1;
    const expected: usize = 2;
    try t.expectEqual(expected, absDiff(x, y));
}
