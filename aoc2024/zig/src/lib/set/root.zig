pub const Set = HashSetManaged;

/// HashSetUnmanaged is a conveniently exported "unmanaged" version of a hash-based Set.
/// This Hash-based is optmized for lookups.
pub const HashSetUnmanaged = @import("hash_set/unmanaged.zig").HashSetUnmanaged;

/// HashSetManaged is a conveniently exported "managed" version of a hash_based Set.
pub const HashSetManaged = @import("hash_set/managed.zig").HashSetManaged;

/// ArraySetUnmanaged is a conveniently exported "unmanaged" version of an array-based Set.
/// This is a bit more specialized and optimized for heavy iteration.
pub const ArraySetUnmanaged = @import("array_hash_set/unmanaged.zig").ArraySetUnmanaged;

/// ArraySetManaged is a conveniently exported "managed" version of an array-based Set.
pub const ArraySetManaged = @import("array_hash_set/managed.zig").ArraySetManaged;

test "tests" {
    _ = @import("hash_set/unmanaged.zig");
    _ = @import("hash_set/managed.zig");
    _ = @import("array_hash_set/unmanaged.zig");
    _ = @import("array_hash_set/managed.zig");
}
