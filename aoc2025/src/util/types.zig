const std = @import("std");

pub fn is_type(comptime value: anytype) bool {
    return @TypeOf(value) == type;
}
test "types is_type" {
    // Basic types
    try std.testing.expect(is_type(u8));
    try std.testing.expect(is_type(usize));
    try std.testing.expect(is_type(f32));
    try std.testing.expect(is_type(bool));
    try std.testing.expect(is_type(void));
    try std.testing.expect(is_type(noreturn));
    try std.testing.expect(is_type(anyerror));

    // Complex types
    try std.testing.expect(is_type(struct { foo: usize }));
    try std.testing.expect(is_type(enum { a, b }));
    try std.testing.expect(is_type(union { a: u8, b: bool }));
    try std.testing.expect(is_type(error{Oops}));
    try std.testing.expect(is_type([5]u8));
    try std.testing.expect(is_type([]const u8));
    try std.testing.expect(is_type(*u8));
    try std.testing.expect(is_type(?u8));

    // Values that are not types
    try std.testing.expect(!is_type("foo"));
    try std.testing.expect(!is_type(5));
    try std.testing.expect(!is_type(5.5));
    try std.testing.expect(!is_type(true));
    try std.testing.expect(!is_type({})); // void value
    try std.testing.expect(!is_type(error.Oops));
    try std.testing.expect(!is_type(@as(?u8, null)));
}

pub fn is_function(comptime value: anytype) bool {
    comptime if (is_type(value)) @compileError("is_function does not accept types as inputs\n");
    const info = @typeInfo(@TypeOf(value));
    return switch (info) {
        .@"fn" => true,
        .pointer => info.pointer.size == .one and @typeInfo(info.pointer.child) == .@"fn",
        else => false,
    };
}
/// only used for testing
fn dummy() void {}
test "types is_function" {
    const f = struct {
        pub fn call() void {}
    }.call;

    const Foo = struct {
        fn call() void {}
    };

    // Functions
    try std.testing.expect(is_function(dummy));
    try std.testing.expect(is_function(&dummy));
    try std.testing.expect(is_function(f));
    try std.testing.expect(is_function(&f));
    try std.testing.expect(is_function(Foo.call));
    try std.testing.expect(is_function(&Foo.call));

    // Function Pointers
    const ptr: *const fn () void = &dummy;
    try std.testing.expect(is_function(ptr));

    // Not functions
    try std.testing.expect(!is_function("foo"));
    try std.testing.expect(!is_function(5));
    try std.testing.expect(!is_function(true));
    try std.testing.expect(!is_function(null));
    try std.testing.expect(!is_function({}));
    const not_a_func: u32 = 42;
    try std.testing.expect(!is_function(&not_a_func));
}

pub fn is_number(comptime value: anytype) bool {
    comptime if (is_type(value)) @compileError("is_number does not accept types as inputs\n");
    return switch (@typeInfo(@TypeOf(value))) {
        .int, .float, .comptime_int, .comptime_float => true,
        else => false,
    };
}
test "types is_number" {
    // Comptime numbers
    try std.testing.expect(is_number('c'));
    try std.testing.expect(is_number(5));
    try std.testing.expect(is_number(0));
    try std.testing.expect(is_number(-5));
    try std.testing.expect(is_number(5.5));
    try std.testing.expect(is_number(-5.5));

    // Typed numbers
    const u: u32 = 10;
    const i: i32 = -10;
    const f: f32 = 3.14;
    const tiny: u1 = 1;
    const huge: i128 = 1000000;
    try std.testing.expect(is_number(u));
    try std.testing.expect(is_number(i));
    try std.testing.expect(is_number(f));
    try std.testing.expect(is_number(tiny));
    try std.testing.expect(is_number(huge));

    // Not numbers
    try std.testing.expect(!is_number("c"));
    try std.testing.expect(!is_number("5"));
    try std.testing.expect(!is_number(true));
    try std.testing.expect(!is_number(false));
    try std.testing.expect(!is_number(null));
    try std.testing.expect(!is_number({}));
    try std.testing.expect(!is_number([_]u8{}));
}

pub fn is_float(comptime value: anytype) bool {
    comptime if (is_type(value)) @compileError("is_float does not accept types as inputs\n");
    return switch (@typeInfo(@TypeOf(value))) {
        .float, .comptime_float => true,
        else => false,
    };
}
test "types is_float" {
    // Comptime floats
    try std.testing.expect(is_float(5.5));
    try std.testing.expect(is_float(-3.14159));
    try std.testing.expect(is_float(0.0));

    // Typed floats
    const f_16: f16 = 1.0;
    const f_32: f32 = 1.0;
    const f_64: f64 = 1.0;
    const f_128: f128 = 1.0;
    try std.testing.expect(is_float(f_16));
    try std.testing.expect(is_float(f_32));
    try std.testing.expect(is_float(f_64));
    try std.testing.expect(is_float(f_128));

    // Not floats
    try std.testing.expect(!is_float(5)); // comptime_int
    try std.testing.expect(!is_float(-5));
    try std.testing.expect(!is_float(0));
    const u: u32 = 10;
    try std.testing.expect(!is_float(u));
    try std.testing.expect(!is_float("3.14"));
    try std.testing.expect(!is_float(true));
}

pub fn is_integer(comptime value: anytype) bool {
    comptime if (is_type(value)) @compileError("is_integer does not accept types as inputs\n");
    return switch (@typeInfo(@TypeOf(value))) {
        .int, .comptime_int => true,
        else => false,
    };
}
test "types is_integer" {
    // Comptime integers
    try std.testing.expect(is_integer('c'));
    try std.testing.expect(is_integer(5));
    try std.testing.expect(is_integer(0));
    try std.testing.expect(is_integer(-5));

    // Typed integers
    const char: u8 = 'c';
    const five: usize = 5;
    const negative_five: isize = -5;
    const tiny: u1 = 1;
    const huge: i128 = 1000000;

    try std.testing.expect(is_integer(char));
    try std.testing.expect(is_integer(five));
    try std.testing.expect(is_integer(negative_five));
    try std.testing.expect(is_integer(tiny));
    try std.testing.expect(is_integer(huge));

    // Not integers
    try std.testing.expect(!is_integer(5.5));
    const f: f32 = 5.0;
    try std.testing.expect(!is_integer(f));
    try std.testing.expect(!is_integer("c"));
    try std.testing.expect(!is_integer(true));
    try std.testing.expect(!is_integer(null));
}

pub fn is_unsigned_integer(comptime value: anytype) bool {
    comptime if (is_type(value)) @compileError("is_unsigned_integer does not accept types as inputs\n");
    const info = @typeInfo(@TypeOf(value));
    return switch (info) {
        .int => info.int.signedness == .unsigned,
        .comptime_int => std.math.sign(value) >= 0,
        else => false,
    };
}
test "types is_unsigned_integer" {
    // Comptime ints
    try std.testing.expect(is_unsigned_integer('c'));
    try std.testing.expect(is_unsigned_integer(5));
    try std.testing.expect(is_unsigned_integer(0));
    try std.testing.expect(!is_unsigned_integer(-5));

    // Typed unsigned ints
    const u_8: u8 = 10;
    const u_size: usize = 0;
    const tiny: u1 = 1;
    try std.testing.expect(is_unsigned_integer(u_8));
    try std.testing.expect(is_unsigned_integer(u_size));
    try std.testing.expect(is_unsigned_integer(tiny));

    // Typed signed ints (Should return false because their underlying type allows signs, even if value is positive)
    const i_8: i8 = 10;
    const i_size: isize = -1;
    const zero_signed: i32 = 0;
    try std.testing.expect(!is_unsigned_integer(i_8));
    try std.testing.expect(!is_unsigned_integer(i_size));
    try std.testing.expect(!is_unsigned_integer(zero_signed));

    // Not integers
    try std.testing.expect(!is_unsigned_integer("c"));
    try std.testing.expect(!is_unsigned_integer(5.5));
    try std.testing.expect(!is_unsigned_integer(true));
}
