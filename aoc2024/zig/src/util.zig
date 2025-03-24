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

pub fn splitByte(string: []const u8, b: u8, allocator: std.mem.Allocator) [][]const u8 {
    const delim: [1]u8 = .{b};
    const count = std.mem.count(u8, string, &delim) + 1;

    var groups = allocator.alloc([]const u8, count) catch unreachable;

    var it = std.mem.tokenizeScalar(u8, string, b);
    for (0..count) |i| {
        groups[i] = it.next() orelse unreachable;
    }

    return groups;
}

pub fn lines(string: []const u8, allocator: std.mem.Allocator) [][]const u8 {
    const trimmed = std.mem.trim(u8, string, "\n");
    return splitByte(trimmed, '\n', allocator);
}

test "lines" {
    const allocator = std.testing.allocator;
    const string = "one\ntwo\nthree";
    const split = splitByte(string, '\n', allocator);
    defer allocator.free(split);

    try std.testing.expectEqual(3, split.len);
    try std.testing.expectEqualStrings("one", split[0]);
    try std.testing.expectEqualStrings("two", split[1]);
    try std.testing.expectEqualStrings("three", split[2]);
}

test "splitByte" {
    const allocator = std.testing.allocator;
    const string = "one|two|three";
    const split = splitByte(string, '|', allocator);
    defer allocator.free(split);

    try std.testing.expectEqual(3, split.len);
    try std.testing.expectEqualStrings("one", split[0]);
    try std.testing.expectEqualStrings("two", split[1]);
    try std.testing.expectEqualStrings("three", split[2]);
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

test "absDiff" {
    const x: usize = 3;
    const y: usize = 1;
    const expected: usize = 2;
    try std.testing.expectEqual(expected, absDiff(x, y));
}
