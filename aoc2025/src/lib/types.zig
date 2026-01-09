const std = @import("std");
const testing = std.testing;

/// Determines if a type is a number.
pub fn is_number(comptime T: type) bool {
    const Type = std.builtin.Type;
    const info = @typeInfo(T);

    return info == Type.int or info == Type.float;
}

test "types is_number" {
    try testing.expect(is_number(usize));
    try testing.expect(is_number(u16));
    try testing.expect(is_number(isize));
    try testing.expect(is_number(i16));
    try testing.expect(is_number(f64));
    try testing.expect(is_number(f16));

    try testing.expect(!is_number([]const u8));
    try testing.expect(!is_number([]u8));
    try testing.expect(!is_number(*[]u8));
    try testing.expect(!is_number(*u8));
}
