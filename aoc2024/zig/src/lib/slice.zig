const std = @import("std");

/// Checks `haystack` for `needle`.
/// Returns `true` if found, otherwise `false`;
pub fn includes(comptime T: type, haystack: []T, needle: T) bool {
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

const t = std.testing;

test "Slice includes" {
    var h1 = [_]u8{ 'a', 'b', 'c' };
    try t.expect(includes(u8, &h1, 'b'));

    var h2 = [_]usize{ 1, 2, 3, 4, 5 };
    try t.expect(includes(usize, &h2, 1));
    try t.expect(includes(usize, &h2, 2));
    try t.expect(includes(usize, &h2, 3));
    try t.expect(includes(usize, &h2, 4));
    try t.expect(includes(usize, &h2, 5));
    try t.expect(!includes(usize, &h2, 6));
}
