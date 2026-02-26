const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const aoc = @import("aoc");
const Solution = aoc.Solution;

const input = @embedFile("data/day08.txt");

const LEN: usize = 1000;

pub fn DisjointSet(comptime N: usize) type {
    return struct {
        const Self = @This();

        roots: [N]u16 = blk: {
            var arr: [N]u16 = undefined;
            for (0..N) |i| arr[i] = @intCast(i);
            break :blk arr;
        },
        ranks: [N]u16 = .{0} ** N,

        pub inline fn get_root(self: *Self, idx: usize) u16 {
            var curr: usize = idx;
            while (true) {
                const parent = self.roots[curr];
                const pp = self.roots[@intCast(parent)];
                if (parent == pp) {
                    return parent;
                }
                self.roots[curr] = pp;
                curr = parent;
            }
        }

        pub inline fn @"union"(self: *Self, idx0: usize, idx1: usize) bool {
            if (idx0 == idx1) {
                return false;
            }

            const root0 = self.get_root(idx0);
            const root1 = self.get_root(idx1);
            if (root0 == root1) {
                return false;
            }

            const r_idx0: usize = @intCast(root0);
            const r_idx1: usize = @intCast(root1);
            const rank0 = self.ranks[r_idx0];
            const rank1 = self.ranks[r_idx1];

            switch (std.math.order(rank0, rank1)) {
                .lt => self.roots[r_idx0] = root1,
                .eq => {
                    self.roots[r_idx1] = root0;
                    self.ranks[r_idx0] = rank1 + 1;
                },
                .gt => self.roots[r_idx1] = root0,
            }

            return true;
        }
    };
}

const Edge = struct {
    a_idx: usize,
    b_idx: usize,
    dist: i64,

    pub const default: @This() = .{
        .a_idx = std.math.maxInt(usize),
        .b_idx = std.math.maxInt(usize),
        .dist = std.math.maxInt(i64),
    };
};
const Coordinates = struct {
    xs: [LEN]i64,
    ys: [LEN]i64,
    zs: [LEN]i64,
};

const coords: Coordinates = blk: {
    var xs: [LEN]i64 = @splat(0);
    var ys: [LEN]i64 = @splat(0);
    var zs: [LEN]i64 = @splat(0);

    var line_number: usize = 0;
    var lines = aoc.slice.lines(input);
    while (lines.next()) |line| : (line_number += 1) {
        var it = std.mem.tokenizeScalar(u8, line, ',');
        xs[line_number] = std.fmt.parseInt(i64, it.next().?, 10) catch unreachable;
        ys[line_number] = std.fmt.parseInt(i64, it.next().?, 10) catch unreachable;
        zs[line_number] = std.fmt.parseInt(i64, it.next().?, 10) catch unreachable;
    }

    break :blk .{
        .xs = xs,
        .ys = ys,
        .zs = zs,
    };
};

fn make_edges(comptime N: usize, comptime SIMD_MAX: @Vector(8, i64)) [N]Edge {
    var edges: [N]Edge = @splat(.default);
    var edge_idx: usize = 0;

    for (0..LEN - 1) |i| {
        const xis: @Vector(8, i64) = @splat(coords.xs[i]);
        const yis: @Vector(8, i64) = @splat(coords.ys[i]);
        const zis: @Vector(8, i64) = @splat(coords.zs[i]);

        var j = i + 1;

        while (j + 8 <= LEN) {
            const xjs = coords.xs[j..][0..8].*;
            const yjs = coords.ys[j..][0..8].*;
            const zjs = coords.zs[j..][0..8].*;

            const dxs = xis - xjs;
            const dys = yis - yjs;
            const dzs = zis - zjs;

            const distances = (dxs * dxs) + (dys * dys) + (dzs * dzs);
            const mask = distances < SIMD_MAX;

            if (@reduce(.Or, mask)) for (0..8) |lane| if (mask[lane]) {
                edges[edge_idx] = .{
                    .a_idx = i,
                    .b_idx = j + lane,
                    .dist = distances[lane],
                };
                edge_idx += 1;
            };

            j += 8;
        }
    }

    const sort_by_dist = struct {
        fn sort_by_dist(_: void, lhs: Edge, rhs: Edge) bool {
            return lhs.dist < rhs.dist;
        }
    }.sort_by_dist;

    std.mem.sort(Edge, &edges, {}, sort_by_dist);
    return edges;
}

fn part1(_: Allocator) !usize {
    const simd_max: @Vector(8, i64) = @splat(64_500_000);
    const edges = make_edges(1100, simd_max);

    var dsu: DisjointSet(LEN) = .{};
    for (0..LEN) |i| {
        const edge = edges[i];
        _ = dsu.@"union"(edge.a_idx, edge.b_idx);
    }

    var counts: [LEN]usize = @splat(0);
    for (0..LEN) |i| {
        counts[dsu.get_root(i)] += 1;
    }
    std.mem.sort(usize, &counts, {}, std.sort.desc(usize));

    return counts[0] * counts[1] * counts[2];
}

fn part2(_: Allocator) !usize {
    const simd_max: @Vector(8, i64) = @splat(205_000_000);
    const edges = make_edges(6000, simd_max);

    var dsu: DisjointSet(LEN) = .{};
    var last_edge: Edge = .default;

    for (edges) |edge| if (dsu.@"union"(edge.a_idx, edge.b_idx)) {
        last_edge = edge;
    };

    return @intCast(coords.xs[last_edge.a_idx] * coords.xs[last_edge.b_idx]);
}

pub const solution: Solution = .{
    .day = .@"08",
    .p1 = .{ .f = part1, .expected = 352584 },
    .p2 = .{ .f = part2, .expected = 9617397716 },
};

test "day08 part1" {
    _ = try aoc.validate(testing.allocator, part1, 352584, .@"08", .one);
}

test "day08 part2" {
    _ = try aoc.validate(testing.allocator, part2, 9617397716, .@"08", .two);
}

test "day08 solution" {
    _ = try solution.solve(testing.allocator);
}
