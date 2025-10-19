const std = @import("std");

/// Calculates the absolute difference between two usize values
pub fn abs_diff(x: usize, y: usize) usize {
    const safe_x: i64 = @intCast(x);
    const safe_y: i64 = @intCast(y);
    return @abs(safe_x - safe_y);
}

/// Checks `haystack` for `needle`.
/// Returns `true` if found, otherwise `false`;
pub fn slice_includes(comptime T: type, haystack: []T, needle: T) bool {
    for (haystack) |element| {
        if (needle == element) {
            return true;
        }
    }

    return false;
}

const t = std.testing;

test "util absDiff" {
    const x: usize = 3;
    const y: usize = 1;
    const expected: usize = 2;
    try t.expectEqual(expected, abs_diff(x, y));
}

test "Util slice_includes" {
    var h1 = [_]u8{ 'a', 'b', 'c' };
    try t.expect(slice_includes(u8, &h1, 'b'));

    var h2 = [_]usize{ 1, 2, 3, 4, 5 };
    try t.expect(slice_includes(usize, &h2, 1));
    try t.expect(slice_includes(usize, &h2, 2));
    try t.expect(slice_includes(usize, &h2, 3));
    try t.expect(slice_includes(usize, &h2, 4));
    try t.expect(slice_includes(usize, &h2, 5));
    try t.expect(!slice_includes(usize, &h2, 6));
}
