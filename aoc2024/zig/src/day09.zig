const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day09/data.txt");

const Block = union(enum) {
    empty: usize,
    file: struct {
        size: usize,
        id: usize,
    },

    fn from(i: usize, n: usize) Block {
        return if (i % 2 == 0)
            .{
                .file = .{
                    .size = n,
                    .id = i / 2,
                },
            }
        else
            .{ .empty = n };
    }
};

var buf: [256 * 256]Block = undefined;
fn parse(comptime s: []const u8) []Block {
    var ptr: usize = 0;

    for (aoc.slice.trim(s), 0..) |c, i|
        if (aoc.char.to_digit(usize, c)) |n| {
            buf[ptr] = .from(i, n);
            ptr += 1;
        };

    return buf[0..ptr];
}

fn part1(_: Allocator) !usize {
    const blocks = parse(input);
    var result: usize = 0;
    var back_i = blocks.len - 1;
    var position: usize = 0;
    var fill_id: usize = 0;
    var remaining: usize = 0;

    switch (blocks[back_i]) {
        .file => |f| {
            fill_id = f.id;
            remaining = f.size;
        },
        else => {},
    }

    for (blocks, 0..) |block, i| {
        if (i >= back_i) break;

        switch (block) {
            .file => |f| {
                result += f.id * (position * 2 + f.size - 1) * f.size / 2;
                position += f.size;
            },
            .empty => |size| {
                var hole = size;

                while (hole > 0) {
                    const min = @min(hole, remaining);
                    hole -= min;
                    remaining -= min;
                    result += fill_id * (position * 2 + min - 1) * min / 2;
                    position += min;

                    if (remaining != 0) continue;

                    back_i -= 2;
                    if (back_i <= i) break;

                    switch (blocks[back_i]) {
                        .file => |f| {
                            fill_id = f.id;
                            remaining = f.size;
                        },
                        else => {},
                    }
                }
            },
        }
    }

    for (0..remaining) |_| {
        result += position * fill_id;
        position += 1;
    }

    return result;
}

const File = struct {
    id: usize,
    size: usize,
    offset: usize,
};

const Space = struct {
    size: usize,
    offset: usize,
};

fn part2(_: Allocator) !usize {
    const blocks = parse(input);
    var offset: usize = 0;
    var files: aoc.Stack(File, 10_000) = .{};
    var spaces: aoc.Stack(Space, 10_000) = .{};

    for (blocks) |block| {
        switch (block) {
            .file => |f| {
                files.push(File{ .id = f.id, .size = f.size, .offset = offset });
                offset += f.size;
            },
            .empty => |size| {
                spaces.push(Space{ .size = size, .offset = offset });
                offset += size;
            },
        }
    }

    var result: usize = 0;
    var cache = [_]usize{0} ** 10;
    var file_ptr = files.len;
    while (file_ptr > 0) : (file_ptr -= 1) {
        const file = files.items[file_ptr - 1];
        var found = false;

        if (cache[file.size] < file.id) {
            for (cache[file.size]..file.id) |i| {
                if (spaces.items[i].size < file.size) continue;

                const off = spaces.items[i].offset;
                result += file.id * (off * 2 + file.size - 1) * file.size / 2;
                spaces.items[i].size -= file.size;
                spaces.items[i].offset += file.size;
                cache[file.size] = i;
                found = true;
                break;
            }
        }

        if (!found) {
            result += file.id * (file.offset * 2 + file.size - 1) * file.size / 2;
            cache[file.size] = std.math.maxInt(usize);
        }
    }

    return result;
}

pub fn solution() Solution {
    return .{
        .day = .@"09",
        .p1 = .{ .f = part1, .expected = 6448989155953 },
        .p2 = .{ .f = part2, .expected = 6476642796832 },
    };
}

test "day09 part1" {
    _ = try aoc.validate(part1, 6448989155953, .@"09", .one, testing.allocator);
}

test "day09 part2" {
    _ = try aoc.validate(part2, 6476642796832, .@"09", .two, testing.allocator);
}

test "day09 solution" {
    _ = try solution().solve(testing.allocator);
}
