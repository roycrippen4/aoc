const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

pub fn Stack(comptime T: type, comptime N: usize) type {
    return struct {
        /// Number of items currently used by the stack
        len: usize = 0,

        /// Underlying data inside the stack
        items: [N]T = undefined,

        /// Total capacity for this stack
        capacity: usize = N,

        const Self = @This();

        /// Access an item in the stack
        /// Returns null if the index is out of bounds
        pub fn idx(self: Self, i: usize) ?T {
            if (i >= self.len) return null;
            return self.items[i];
        }

        /// Push an item onto the slice.
        /// Does not grow the slice.
        /// If the stacks's length and capacity are equal this function will return an error
        pub fn push(self: *Self, item: T) !void {
            if (self.len == self.capacity) return error.NoCapacity;
            self.items[self.len] = item;
            self.len += 1;
        }

        /// Pop an item off the stack.
        /// Returns an error if this function is called on an empty stack
        pub fn pop(self: *Self) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            const value = self.items[self.len];
            self.items[self.len] = undefined;
            return value;
        }

        /// Returns a copy the contents of the stack's backing array.
        /// The caller owns the returned memory and is expected to free it.
        pub fn copy(self: Self, gpa: Allocator) ![]T {
            const buf = try gpa.alloc(T, self.capacity);
            @memcpy(buf, &self.items);
            return buf;
        }

        /// Returns the value at the top of the stack without removing it.
        /// Returns an error if the stack is empty.
        pub fn peek(self: Self) !T {
            if (self.len == 0) return error.StackEmpty;
            return self.items[self.len - 1];
        }

        pub fn is_empty(self: Self) bool {
            return self.len == 0;
        }
    };
}

test "stack push and pop" {
    var stack = Stack(u32, 5){};
    try testing.expectEqual(@as(usize, 0), stack.len);
    try testing.expect(stack.is_empty());

    try stack.push(10);
    try testing.expectEqual(@as(usize, 1), stack.len);
    try testing.expect(!stack.is_empty());

    try stack.push(20);
    try testing.expectEqual(@as(usize, 2), stack.len);

    const item1 = stack.pop().?;
    try testing.expectEqual(@as(u32, 20), item1);
    try testing.expectEqual(@as(usize, 1), stack.len);

    const item2 = stack.pop().?;
    try testing.expectEqual(@as(u32, 10), item2);
    try testing.expectEqual(@as(usize, 0), stack.len);
    try testing.expect(stack.is_empty());
}

test "stack push to capacity" {
    var stack = Stack(i8, 3){};

    try stack.push(1);
    try stack.push(2);
    try stack.push(3);

    try testing.expectEqual(@as(usize, 3), stack.len);
    try testing.expectEqual(stack.len, stack.capacity);

    const result = stack.push(4);
    try testing.expectError(error.NoCapacity, result);
    try testing.expectEqual(@as(usize, 3), stack.len);
}

test "stack pop from empty" {
    var stack = Stack(bool, 5){};
    const result = stack.pop();
    try testing.expectEqual(null, result);
    try testing.expectEqual(@as(usize, 0), stack.len);
}

test "stack peek" {
    var stack = Stack(u16, 4){};

    try stack.push(100);
    try stack.push(200);

    const top_value = try stack.peek();
    try testing.expectEqual(@as(u16, 200), top_value);
    try testing.expectEqual(@as(usize, 2), stack.len);

    _ = stack.pop();

    const next_top_value = try stack.peek();
    try testing.expectEqual(@as(u16, 100), next_top_value);
    try testing.expectEqual(@as(usize, 1), stack.len);
}

test "stack peek on empty stack" {
    const stack = Stack(f32, 3){};
    const result = stack.peek();
    try testing.expectError(error.StackEmpty, result);
}

test "stack idx access" {
    var stack = Stack(u8, 10){};
    try stack.push(5);
    try stack.push(10);
    try stack.push(15);

    try testing.expectEqual(@as(u8, 5), stack.idx(0).?);
    try testing.expectEqual(@as(u8, 10), stack.idx(1).?);
    try testing.expectEqual(@as(u8, 15), stack.idx(2).?);
    try testing.expectEqual(null, stack.idx(3));
    try testing.expectEqual(null, stack.idx(9));
}

test "stack copy" {
    const gpa = testing.allocator;

    var stack = Stack(usize, 4){};
    try stack.push(11);
    try stack.push(22);

    const copied_slice = try stack.copy(gpa);
    defer gpa.free(copied_slice);

    try testing.expectEqualSlices(usize, &.{ 11, 22, undefined, undefined }, copied_slice);

    _ = stack.pop();
    try stack.push(33);

    try testing.expectEqualSlices(usize, &.{ 11, 33 }, stack.items[0..stack.len]);
    try testing.expectEqualSlices(usize, &.{ 11, 22, undefined, undefined }, copied_slice);
}
