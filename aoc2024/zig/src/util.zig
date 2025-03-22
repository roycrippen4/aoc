const std = @import("std");
const time = std.time;
const fmt = std.fmt;

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

    /// Converts a u8 value to a corresponding Day enum variant.
    /// Takes a number from 1 to 25 and returns the matching Day.
    /// Panics with unreachable if given an invalid value (0 or > 25).
    pub fn fromU8(value: u8) Day {
        return switch (value) {
            1 => .one,
            2 => .two,
            3 => .three,
            4 => .four,
            5 => .five,
            6 => .six,
            7 => .seven,
            8 => .eight,
            9 => .nine,
            10 => .ten,
            11 => .eleven,
            12 => .twelve,
            13 => .thirteen,
            14 => .fourteen,
            15 => .fifteen,
            16 => .sixteen,
            17 => .seventeen,
            18 => .eighteen,
            19 => .nineteen,
            20 => .twenty,
            21 => .twenty_one,
            22 => .twenty_two,
            23 => .twenty_three,
            24 => .twenty_four,
            25 => .twenty_five,
            else => unreachable,
        };
    }
};

const Time = enum {
    Sec,
    MilSlow,
    MilMed,
    MilFast,
    Micro,

    fn convertToSeconds(ns: u64) f64 {
        const ns_f: f64 = @floatFromInt(ns);
        const ns_per_s_f: f64 = @floatFromInt(time.ns_per_s);
        return ns_f / ns_per_s_f;
    }

    fn convertToMil(ns: u64) f64 {
        const ns_f: f64 = @floatFromInt(ns);
        const ns_per_ms_f: f64 = @floatFromInt(time.ns_per_ms);
        return ns_f / ns_per_ms_f;
    }

    fn convertToMicro(ns: u64) f64 {
        const ns_f: f64 = @floatFromInt(ns);
        const ns_per_us_f: f64 = @floatFromInt(time.ns_per_us);
        return ns_f / ns_per_us_f;
    }

    fn getRange(ns: u64) Time {
        const t = convertToSeconds(ns);
        if (t > 1.0) {
            return Time.Sec;
        }
        if (t > 0.1) {
            return Time.MilSlow;
        }
        if (t > 0.01) {
            return Time.MilMed;
        }
        if (t > 0.001) {
            return Time.MilFast;
        }
        return Time.Micro;
    }

    fn colorTime(ns: u64, allocator: std.mem.Allocator) fmt.AllocPrintError![]u8 {
        return switch (getRange(ns)) {
            .Sec => {
                const secs = convertToSeconds(ns);
                const string = try fmt.allocPrint(allocator, "{d:.3}s", .{secs});
                defer allocator.free(string);
                return try rgb(255, 0, 0, string, allocator);
            },
            .MilSlow => {
                const mils = convertToMil(ns);
                const string = try fmt.allocPrint(allocator, "{d:.3}ms", .{mils});
                defer allocator.free(string);
                return try rgb(255, 82, 0, string, allocator);
            },
            .MilMed => {
                const mils = convertToMil(ns);
                const string = try fmt.allocPrint(allocator, "{d:.3}ms", .{mils});
                defer allocator.free(string);
                return try rgb(255, 165, 0, string, allocator);
            },
            .MilFast => {
                const mils = convertToMil(ns);
                const string = try fmt.allocPrint(allocator, "{d:.3}ms", .{mils});
                defer allocator.free(string);
                return try rgb(127, 210, 0, string, allocator);
            },
            .Micro => {
                const micros = convertToMicro(ns);
                const string = try fmt.allocPrint(allocator, "{d:.3}µs", .{micros});
                defer allocator.free(string);
                return try rgb(0, 255, 0, string, allocator);
            },
        };
    }
};

fn rgb(r: u8, g: u8, b: u8, s: []const u8, allocator: std.mem.Allocator) fmt.AllocPrintError![]u8 {
    return try fmt.allocPrint(
        allocator,
        "\x1b[38;2;{d};{d};{d}m{s}\x1b[0m",
        .{ r, g, b, s },
    );
}

const TimeError = error{
    AllocPrintError,
    Unsupported,
    OutOfMemory,
};

pub fn validate(f: fn () u64, expected: u64, day: Day, part: Part, allocator: std.mem.Allocator) TimeError!void {
    const now = try time.Instant.now();
    const result = f();
    const done = try time.Instant.now();

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
        const msg = try fmt.allocPrint(allocator, fmt_str, .{ expected, result });
        @panic(msg);
    }

    const day_str = day.toString();
    const part_str = part.toString();
    const time_str = try Time.colorTime(done.since(now), allocator);
    defer allocator.free(time_str);
    std.debug.print("{s} {s} solved in {s}\n", .{ day_str, part_str, time_str });
}

fn part1() u64 {
    const t = 500 * time.ns_per_us; // 500µs
    // const t = 5 * time.ns_per_ms; // 5ms
    // const t = 50 * time.ns_per_ms; // 50ms
    // const t = 500 * time.ns_per_ms; // 500ms
    // const t = 1.25 * time.ns_per_s; // 1.25s
    std.Thread.sleep(t);
    return 42;
}

test "validate" {
    try validate(part1, 42, Day.one, Part.one, std.testing.allocator);
}

test "rgb" {
    const allocator = std.testing.allocator;
    const red_text = try rgb(0, 255, 0, "hello", allocator);
    defer allocator.free(red_text);
    std.debug.print("{s}\n", .{red_text});
}

test "part.toString" {
    try std.testing.expectEqualStrings("Part 1", Part.one.toString());
    try std.testing.expectEqualStrings("Part 2", Part.two.toString());
}
