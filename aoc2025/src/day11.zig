const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("libaoc");
const Solution = aoc.Solution;
const Stack = aoc.Stack;

const input = @embedFile("data/day11.txt");

fn encode(key: []const u8) usize {
    std.debug.assert(key.len == 3);
    return @as(usize, key[0]) << 16 | @as(usize, key[1]) << 8 | @as(usize, key[2]);
}

const YOU: usize = encode("you");
const SVR: usize = encode("svr");
const FFT: usize = encode("fft");
const DAC: usize = encode("dac");
const OUT: usize = encode("out");

const Edges = struct {
    edges: Stack(usize, 19),
    paths: isize,
    const Self = @This();

    pub const init: Self = .{
        .edges = .{},
        .paths = -1,
    };

    // only using this because `edges.edges.push` looks weird
    fn push(self: *Self, edge: usize) void {
        self.edges.push(edge);
    }
};

const HashMap = std.AutoHashMap(usize, Edges);
fn build_map(allocator: Allocator) !HashMap {
    var map: HashMap = .init(allocator);
    var lines = aoc.slice.lines(input);
    while (lines.next()) |line| {
        var edges: Edges = .init;
        var tokens = std.mem.tokenizeScalar(u8, line[5..], ' ');
        while (tokens.next()) |token| {
            edges.push(encode(token));
        }
        const key = encode(line[0..3]);
        try map.put(key, edges);
    }

    try map.put(OUT, .init);

    return map;
}

fn reset_paths(map: *HashMap) void {
    var it = map.valueIterator();
    while (it.next()) |value| value.paths = -1;
}

fn count_paths(graph: *HashMap, current: usize, end: usize) isize {
    if (current == end) {
        return 1;
    }

    const node = graph.getPtr(current).?;
    if (node.paths != -1) {
        return node.paths;
    }

    var total_paths: isize = 0;
    for (node.edges.to_slice()) |edge| {
        total_paths += count_paths(graph, edge, end);
    }

    node.paths = total_paths;
    return total_paths;
}

fn part1(allocator: Allocator) !usize {
    var map = try build_map(allocator);
    defer map.deinit();
    return @intCast(count_paths(&map, YOU, OUT));
}

// discovered through experimentation that
// paths can only flow in the following ways:
// svr -> fft
// fft -> dac
// dac -> out
fn part2(allocator: Allocator) !usize {
    var map = try build_map(allocator);
    defer map.deinit();

    const svr_to_fft: usize = @intCast(count_paths(&map, SVR, FFT));
    reset_paths(&map);

    const fft_to_dac: usize = @intCast(count_paths(&map, FFT, DAC));
    reset_paths(&map);

    const dac_to_out: usize = @intCast(count_paths(&map, DAC, OUT));
    reset_paths(&map);

    return svr_to_fft * fft_to_dac * dac_to_out;
}

pub const solution: Solution = .{
    .day = .@"11",
    .p1 = .{ .f = part1, .expected = 428 },
    .p2 = .{ .f = part2, .expected = 331468292364745 },
};

test "day11 part1" {
    _ = try aoc.validate(testing.allocator, part1, 428, .@"11", .one);
}

test "day11 part2" {
    _ = try aoc.validate(testing.allocator, part2, 331468292364745, .@"11", .two);
}

test "day11 solution" {
    _ = try solution.solve(testing.allocator);
}
