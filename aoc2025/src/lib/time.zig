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
    _start: ?std.time.Instant = null,
    label: ?[]const u8 = null,

    const Self = @This();

    pub fn start(self: Self) Self {
        return .{
            ._start = std.time.Instant.now() catch unreachable,
            .label = self.label,
        };
    }

    pub fn with_label(self: Self, label: []const u8) Self {
        return .{
            ._start = self._start,
            .label = label,
        };
    }

    pub fn stop(self: *const Self) void {
        var buf: [64]u8 = undefined;

        const now = std.time.Instant.now() catch unreachable;
        const elapsed = now.since(self._start.?);
        const timestr = color(elapsed, &buf) catch unreachable;

        if (self.label) |label| {
            std.debug.print("[{s}]: Time taken: {s}\n", .{ label, timestr });
        } else {
            std.debug.print("Time taken: {s}\n", .{timestr});
        }
    }
}{
    ._start = null,
    .label = null,
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
