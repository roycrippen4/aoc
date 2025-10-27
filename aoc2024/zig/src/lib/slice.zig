const std = @import("std");
const mem = std.mem;
const testing = std.testing;

/// Checks `haystack` for `needle`.
/// Returns `true` if found, otherwise `false`;
pub fn contains(comptime T: type, haystack: []const T, needle: anytype) bool {
    if (@TypeOf(needle) == T or @TypeOf(needle) == comptime_int) {
        return mem.indexOfScalar(T, haystack, needle) != null;
    } else {
        const needle_slice: []const T = needle;
        return mem.indexOf(T, haystack, needle_slice) != null;
    }
}

pub fn split_once(comptime T: type, s: []const T, delim: T) struct { []const T, []const T } {
    var it = mem.splitScalar(T, s, delim);

    return .{
        it.next().?,
        it.next() orelse &[0]T{},
    };
}

pub inline fn chunks_needed(comptime N: usize, len: usize) usize {
    comptime if (N == 0) @compileError("N must be > 0");
    return (len + N - 1) / N;
}

pub fn chunks(
    comptime T: type,
    comptime N: usize,
    s: []const T,
    out: [][]const T,
) ![]const []const T {
    comptime if (N == 0) @compileError("N must be > 0");

    const need = chunks_needed(N, s.len);
    if (out.len < need) {
        return error.BufferTooSmall;
    }

    var off: usize = 0;
    var wrote: usize = 0;
    while (off < s.len) : (off += N) {
        const end = @min(off + N, s.len);
        out[wrote] = s[off..end];
        wrote += 1;
    }
    return out[0..wrote];
}

test "slice chunks" {
    const s = "abcdefghijklmnop";
    const n_elements = 5;

    var buf: [chunks_needed(n_elements, s.len)][]const u8 = undefined;

    const result = try chunks(u8, n_elements, s, buf[0..]);

    for (result, 0..) |chunk, i| {
        std.debug.print("s[{d}]: {s}\n", .{ i, chunk });
    }
}

/// Returns an iterator over the lines in a slice
pub fn lines(comptime T: type, s: []const T) mem.SplitIterator(T, .scalar) {
    const trimmed = mem.trim(T, s, &.{'\n'});
    return mem.splitScalar(T, trimmed, '\n');
}

test "slice lines" {
    const s =
        \\
        \\foo
        \\bar
        \\baz
        \\
    ;
    var lines_it = lines(u8, s);
    var i: usize = 0;

    while (lines_it.next()) |line| : (i += 1) {
        switch (i) {
            0 => try testing.expectEqualSlices(u8, "foo", line),
            1 => try testing.expectEqualSlices(u8, "bar", line),
            2 => try testing.expectEqualSlices(u8, "baz", line),
            else => unreachable,
        }
    }
}

test "slice contains generic" {
    try testing.expect(contains(u8, "barbazquux", "baz"));
    try testing.expect(!contains(u8, "barbazquux", "yes"));
    try testing.expect(contains(u8, "abcdefg", "a"));
    try testing.expect(contains(u8, "abcdefg", "abcdefg"));
    try testing.expect(contains(u8, "foooooo", ""));

    var h1 = [_]u8{ 'a', 'b', 'c' };
    try testing.expect(contains(u8, &h1, 'b'));
    try testing.expect(!contains(u8, &h1, 'd'));

    var h2 = [_]usize{ 1, 2, 3, 4, 5 };
    try testing.expect(contains(usize, &h2, 1));
    try testing.expect(contains(usize, &h2, 5));
    try testing.expect(!contains(usize, &h2, 6));
}
