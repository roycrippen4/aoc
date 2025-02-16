const std = @import("std");
const ArrayList = std.ArrayList;

const Lists = struct { l: ArrayList(u32), r: ArrayList(u32) };

const ListsError = error{
    ParseFailure,
    AppendFailure,
};

pub fn main() !void {
    var t = try std.time.Timer.start();
    const input = @embedFile("./data/data.txt");
    const result = try day01Part1(input);
    if (1506483 != result) {
        std.debug.print("Failed to solve!", .{});
        return;
    }
    std.debug.print("Answer: {}\nSolved in {}\n", .{ result, std.fmt.fmtDuration(t.read()) });
}

fn absDiff(x: u32, y: u32) u64 {
    const safe_x: i64 = @intCast(x);
    const safe_y: i64 = @intCast(y);
    return @abs(safe_x - safe_y);
}

fn parseInput(input: []const u8, allocator: std.mem.Allocator) ListsError!Lists {
    var lists: Lists = .{
        .l = ArrayList(u32).init(allocator),
        .r = ArrayList(u32).init(allocator),
    };

    var flines = std.mem.tokenizeAny(u8, input, "\n");
    while (flines.next()) |line| {
        var it = std.mem.splitSequence(u8, line, "   ");

        const l = std.fmt.parseInt(u32, it.next().?, 10) catch return ListsError.ParseFailure;
        lists.l.append(l) catch return ListsError.AppendFailure;

        const r = std.fmt.parseInt(u32, it.next().?, 10) catch return ListsError.ParseFailure;
        lists.r.append(r) catch return ListsError.AppendFailure;
    }

    return lists;
}

fn day01Part1(input: []const u8) ListsError!u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var lists = try parseInput(input, gpa.allocator());
    defer _ = lists.l.deinit();
    defer _ = lists.r.deinit();
    std.mem.sort(u32, lists.l.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, lists.r.items, {}, comptime std.sort.asc(u32));

    var total: u64 = 0;

    for (0..lists.l.items.len) |idx| {
        total += absDiff(lists.l.items[idx], lists.r.items[idx]);
    }

    return total;
}

test "solve" {
    var t = try std.time.Timer.start();
    const input = @embedFile("./data/data.txt");
    const result = try part1(input);
    try std.testing.expectEqual(1506483, result);
    std.debug.print("Answer: {}\nSolved in {}\n", .{ result, std.fmt.fmtDuration(t.read()) });
}

test "example" {
    const input = @embedFile("./data/example.txt");
    const result = try part1(input);
    try std.testing.expectEqual(11, result);
}

test "test absDiff" {
    const x: u64 = 3;
    const y: u64 = 1;
    const expected: u64 = 2;
    try std.testing.expectEqual(expected, absDiff(x, y));
}

test "lists struct test" {
    const allocator = std.testing.allocator;

    var lists: Lists = .{
        .l = ArrayList(u32).init(allocator),
        .r = ArrayList(u32).init(allocator),
    };

    defer _ = lists.l.deinit();
    defer _ = lists.r.deinit();

    try lists.l.appendSlice(&[_]u32{ 1, 2, 3 });
    try lists.r.appendSlice(&[_]u32{ 4, 5, 6 });

    std.debug.assert(lists.l.items.len == lists.r.items.len);
}
