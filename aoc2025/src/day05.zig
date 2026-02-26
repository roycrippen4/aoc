const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const Range = struct {
    lo: usize,
    hi: usize,

    const Self = @This();

    fn from_str(s: []const u8) Self {
        const start_str, const end_str = aoc.slice.split_once_scalar(u8, s, '-');
        const lo = std.fmt.parseInt(usize, start_str, 10) catch unreachable;
        const hi = std.fmt.parseInt(usize, end_str, 10) catch unreachable;

        return .{
            .lo = @min(lo, hi),
            .hi = @max(lo, hi),
        };
    }

    fn merge(self: Self, other: Self) ?Self {
        const lo = if (self.lo >= other.lo and self.lo <= other.hi)
            other.lo
        else if (other.lo >= self.lo and other.lo <= self.hi)
            self.lo
        else
            return null;

        const hi = @max(self.hi, other.hi);

        return .{
            .lo = lo,
            .hi = hi,
        };
    }

    fn includes(self: Self, n: usize) bool {
        return self.lo <= n and n <= self.hi;
    }

    inline fn count(self: Self) usize {
        return (self.hi - self.lo) + 1;
    }

    pub fn format(self: Self, writer: *std.io.Writer) std.io.Writer.Error!void {
        try writer.print("Range{{ lo. = {d}, .hi = {d} }}", .{ self.lo, self.hi });
    }
};

const input = @embedFile("data/day05.txt");
const split_result = aoc.slice.split_once_sequence(u8, input, "\n\n");

const ranges_str = split_result.@"0";
const range_count = aoc.slice.line_count(ranges_str);
const ranges: [range_count]Range = blk: {
    var ranges_: [range_count]Range = undefined;

    var it = aoc.slice.lines(ranges_str);
    var i: usize = 0;
    while (it.next()) |line| : (i += 1) {
        const range = Range.from_str(line);
        ranges_[i] = range;
    }

    break :blk ranges_;
};

const ids_str = split_result.@"1";
const id_count = aoc.slice.line_count(ids_str);
const ids: [id_count]usize = blk: {
    var ids_: [id_count]usize = undefined;

    var it = aoc.slice.lines(ids_str);
    var i: usize = 0;
    while (it.next()) |line| : (i += 1) {
        const id = std.fmt.parseInt(usize, line, 10) catch unreachable;
        ids_[i] = id;
    }

    break :blk ids_;
};

fn part1(_: Allocator) !usize {
    var result: usize = 0;
    var seen: [id_count]bool = .{false} ** id_count;

    for (0.., ids) |i, id| for (ranges) |range| {
        if (range.includes(id) and !seen[i]) {
            seen[i] = true;
            result += 1;
        }
    };

    return result;
}

const RangeStack = aoc.Stack(Range, range_count);

fn merge_ranges_inner(rs: []const Range) struct { RangeStack, bool } {
    var did_merge = false;
    var merged: RangeStack = .{};
    var skip_idxs: aoc.Stack(usize, range_count) = .{};

    for (0.., rs[0 .. rs.len - 1]) |i, r1| {
        for (i + 1.., rs[i + 1 ..]) |j, r2| {
            if (skip_idxs.contains(i)) break;

            if (r1.merge(r2)) |r3| {
                did_merge = true;
                merged.push(r3);
                skip_idxs.push(i);
                skip_idxs.push(j);
            }
        }
    }

    for (0.., rs) |i, r| {
        if (!skip_idxs.contains(i)) {
            merged.push(r);
        }
    }

    return .{ merged, did_merge };
}

fn merge_ranges(rs: []const Range) RangeStack {
    var m, var did_merge = merge_ranges_inner(rs);

    while (true) {
        m, did_merge = merge_ranges_inner(m.to_slice());
        if (!did_merge) break;
    }

    return m;
}

fn part2(_: Allocator) !usize {
    const merged = merge_ranges(&ranges);

    var result: usize = 0;
    var it = merged.iterator();
    while (it.next()) |range| {
        result += range.count();
    }

    return result;
}

pub const solution: Solution = .{
    .day = .@"05",
    .p1 = .{ .f = part1, .expected = 611 },
    .p2 = .{ .f = part2, .expected = 345995423801866 },
};

test "day05 part1" {
    _ = try aoc.validate(testing.allocator, part1, 611, .@"05", .one);
}

test "day05 part2" {
    _ = try aoc.validate(testing.allocator, part2, 345995423801866, .@"05", .two);
}

test "day05 solution" {
    _ = try solution.solve(testing.allocator);
}

test "day05 Range.includes" {
    const r = Range.from_str("1-3");
    try testing.expect(r.includes(1));
    try testing.expect(r.includes(2));
    try testing.expect(r.includes(3));

    try testing.expect(!r.includes(0));
    try testing.expect(!r.includes(4));
}
test "day05 Range.merge" {
    const r1: Range = .{ .lo = 3, .hi = 5 };
    const r2: Range = .{ .lo = 12, .hi = 18 };
    const r3: Range = .{ .lo = 16, .hi = 20 };

    try testing.expect(r1.merge(r2) == null);
    try testing.expect(r1.merge(r3) == null);
    try testing.expectEqualDeep(r2.merge(r3), r3.merge(r2));
    try testing.expectEqualDeep(
        Range{ .lo = 12, .hi = 20 },
        r2.merge(r3),
    );

    const r4: Range = .{ .lo = 16, .hi = 20 };
    const r5: Range = .{ .lo = 16, .hi = 20 };
    try testing.expectEqualDeep(r4.merge(r5), r5.merge(r4));
}
test "day05 Range.from_str" {
    try testing.expectEqualDeep(
        Range{ .lo = 2, .hi = 10 },
        Range.from_str("2-10"),
    );

    try testing.expectEqualDeep(
        Range{ .lo = 2, .hi = 10 },
        Range.from_str("10-2"),
    );
}
