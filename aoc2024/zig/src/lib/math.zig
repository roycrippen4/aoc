const std = @import("std");

/// Calculates the absolute difference between two usize values
pub fn abs_diff(x: usize, y: usize) usize {
    const safe_x: i64 = @intCast(x);
    const safe_y: i64 = @intCast(y);
    return @abs(safe_x - safe_y);
}

const t = std.testing;

test "util absDiff" {
    const x: usize = 3;
    const y: usize = 1;
    const expected: usize = 2;
    try t.expectEqual(expected, abs_diff(x, y));
}
