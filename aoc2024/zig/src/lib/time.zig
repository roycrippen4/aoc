const std = @import("std");

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
