const std = @import("std");

/// Checks `haystack` for `needle`.
/// Returns `true` if found, otherwise `false`;
pub fn contains(comptime T: type, haystack: []T, needle: T) bool {
    for (haystack) |element| {
        if (needle == element) {
            return true;
        }
    }

    return false;
}

pub fn split_once(comptime T: type, s: []const T, delim: T) struct { []const T, []const T } {
    var it = std.mem.splitScalar(T, s, delim);

    return .{
        it.next().?,
        it.next() orelse &[0]T{},
    };
}

/// Returns an iterator over the lines in a slice
pub fn lines(comptime T: type, s: []const T) std.mem.SplitIterator(T, .scalar) {
    const trimmed = std.mem.trim(T, s, &.{'\n'});
    return std.mem.splitScalar(T, trimmed, '\n');
}

const t = std.testing;

test "slice includes" {
    var h1 = [_]u8{ 'a', 'b', 'c' };
    try t.expect(contains(u8, &h1, 'b'));

    var h2 = [_]usize{ 1, 2, 3, 4, 5 };
    try t.expect(contains(usize, &h2, 1));
    try t.expect(contains(usize, &h2, 2));
    try t.expect(contains(usize, &h2, 3));
    try t.expect(contains(usize, &h2, 4));
    try t.expect(contains(usize, &h2, 5));
    try t.expect(!contains(usize, &h2, 6));
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
            0 => try t.expectEqualSlices(u8, "foo", line),
            1 => try t.expectEqualSlices(u8, "bar", line),
            2 => try t.expectEqualSlices(u8, "baz", line),
            else => unreachable,
        }
    }
}
