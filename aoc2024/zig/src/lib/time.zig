const std = @import("std");

pub const Unit = enum {
    sec,
    milli_slow,
    milli_med,
    milli_fast,
    micros,

    pub fn from_ns(ns: u64) Unit {
        const time = as_secs(ns);
        if (time > 1.0) return Unit.sec;
        if (time > 0.1) return Unit.milli_slow;
        if (time > 0.01) return Unit.milli_med;
        if (time > 0.001) return Unit.milli_fast;

        return Unit.micros;
    }
};

fn as_secs(ns: u64) f64 {
    const ns_f: f64 = @floatFromInt(ns);
    const ns_per_s_f: f64 = @floatFromInt(std.time.ns_per_s);
    return ns_f / ns_per_s_f;
}

fn as_millis(ns: u64) f64 {
    const ns_f: f64 = @floatFromInt(ns);
    const ns_per_ms_f: f64 = @floatFromInt(std.time.ns_per_ms);
    return ns_f / ns_per_ms_f;
}

fn as_micros(ns: u64) f64 {
    const ns_f: f64 = @floatFromInt(ns);
    const ns_per_us_f: f64 = @floatFromInt(std.time.ns_per_us);
    return ns_f / ns_per_us_f;
}

/// Convenience wrapper around `std.time.Instant`
pub const Stopwatch = struct {
    _start: std.time.Instant,
    const Self = @This();

    pub fn start() !Self {
        return .{
            ._start = try std.time.Instant.now(),
        };
    }

    pub fn stop(self: *const Self) !void {
        var buf: [64]u8 = undefined;

        const now = try std.time.Instant.now();
        const elapsed = now.since(self._start);
        const timestr = try color(elapsed, &buf);
        std.debug.print("Time taken: {s}\n", .{timestr});
    }
};

pub fn color(ns: u64, buf: []u8) ![]u8 {
    return switch (Unit.from_ns(ns)) {
        .sec => {
            return try std.fmt.bufPrint(
                buf,
                "\x1b[38;2;{d};{d};{d}m{d:.3}s\x1b[0m",
                .{ 255, 0, 0, as_secs(ns) },
            );
        },
        .milli_slow => {
            return try std.fmt.bufPrint(
                buf,
                "\x1b[38;2;{d};{d};{d}m{d:.3}ms\x1b[0m",
                .{ 255, 82, 0, as_millis(ns) },
            );
        },
        .milli_med => {
            return try std.fmt.bufPrint(
                buf,
                "\x1b[38;2;{d};{d};{d}m{d:.3}ms\x1b[0m",
                .{ 255, 165, 0, as_millis(ns) },
            );
        },
        .milli_fast => {
            return try std.fmt.bufPrint(
                buf,
                "\x1b[38;2;{d};{d};{d}m{d:.3}ms\x1b[0m",
                .{ 127, 210, 0, as_millis(ns) },
            );
        },
        .micros => {
            return try std.fmt.bufPrint(
                buf,
                "\x1b[38;2;{d};{d};{d}m{d:.3}µs\x1b[0m",
                .{ 0, 255, 0, as_micros(ns) },
            );
        },
    };
}

fn rgb(r: u8, g: u8, b: u8, s: []const u8, buf: []u8) ![]u8 {
    return try std.fmt.bufPrint(
        &buf,
        "\x1b[38;2;{d};{d};{d}m{s}\x1b[0m",
        .{ r, g, b, s },
    );
}

test "time measure" {
    const measure = try Stopwatch.start();
    std.Thread.sleep(std.time.ns_per_s);
    try measure.stop();
}
