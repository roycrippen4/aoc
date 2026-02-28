//! Array helper functions
const std = @import("std");
const testing = std.testing;

const types = @import("types.zig");

/// Stateless array generation
/// ```zig
/// const f = struct {
///     pub fn anon(index: usize) u8 {
///         return index + '0';
///     }
/// };
/// array[index] = f(index: usize) T
/// ```
/// for `(0..N)`
pub fn from_fn(
    comptime T: type,
    comptime len: usize,
    comptime f: anytype, // beware of footgun
) [len]T {
    std.debug.assert(types.is_function(f));
    var arr: [len]T = undefined;
    for (0..len) |i| arr[i] = f(i);
    return arr;
}

pub fn from_fn_mut(
    comptime T: type,
    comptime len: usize,
    context: anytype,
) [len]T {
    const has_call_method = std.meta.hasMethod(@TypeOf(context), "call");
    if (!has_call_method) {
        @compileError("Parameter `context` in `Array.from_fn_mut` must have a public method named `call`");
    }

    var array: [len]T = undefined;
    for (0..len) |i| array[i] = context.call(i);
    return array;
}

test "array from_fn_mut" {
    var environment: usize = 0;
    const Ctx = struct {
        counter: *usize,

        pub fn call(self: *@This(), _: usize) usize {
            self.counter.* += 1;
            return self.counter.* * self.counter.*;
        }
    };
    var ctx: Ctx = .{ .counter = &environment };

    const result = from_fn_mut(usize, 5, &ctx);
    std.debug.print("{any}\n", .{result});
    std.debug.print("environment = {d}\n", .{environment});
    try std.testing.expect(std.meta.hasFn(Ctx, "call"));
    // std.debug.print("{}\n", .{std.meta.hasFn(Ctx, "call")});
}
