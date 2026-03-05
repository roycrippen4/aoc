const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const math = std.math;
const Allocator = mem.Allocator;
const testing = std.testing;

const aoc = @import("libaoc");
const Stack = aoc.Stack;
const Solution = aoc.Solution;

const input = @embedFile("data/day10.txt");

const Machine = struct {
    buttons: Stack(u16, 13),
    joltages: Stack(i16, 10),
    lights: u16,

    const Self = @This();

    pub fn from_string(string: []const u8) Self {
        const lights_end = mem.indexOfScalar(u8, string, ']').?;
        const joltage_start = mem.indexOfScalar(u8, string, '{').?;

        const lights = blk: {
            var lights: u16 = 0;
            for (string[1..lights_end], 0..) |ch, i| if (ch == '#') {
                const mask = @as(u16, 1) << @intCast(i);
                lights |= mask;
            };

            break :blk lights;
        };

        const joltages = blk: {
            var joltages: Stack(i16, 10) = .empty;
            var it = mem.tokenizeScalar(u8, string[joltage_start + 1 .. string.len - 1], ',');
            while (it.next()) |joltage_slice| {
                const joltage = fmt.parseInt(i16, joltage_slice, 10) catch unreachable;
                joltages.push(joltage);
            }

            break :blk joltages;
        };

        const buttons = blk: {
            var buttons: Stack(u16, 13) = .empty;
            var it = mem.tokenizeScalar(u8, string[lights_end + 2 .. joltage_start - 1], ' ');
            while (it.next()) |button_string| {
                const button = inner: {
                    const s = button_string[1 .. button_string.len - 1];
                    var i: usize = 0;
                    var button: u16 = 0;

                    // `i += 2` to skip commas
                    while (i < s.len) : (i += 2) {
                        const mask = @as(u16, 1) << @intCast((s[i] - '0'));
                        button |= mask;
                    }

                    break :inner button;
                };

                buttons.push(button);
            }
            break :blk buttons;
        };

        return .{
            .lights = lights,
            .buttons = buttons,
            .joltages = joltages,
        };
    }

    pub fn configure_buttons(self: Self) usize {
        const combinations = math.pow(usize, 2, self.buttons.len);
        var min_pressed: usize = math.maxInt(usize);
        var current_lights: u16 = 0;

        for (1..combinations) |i| {
            current_lights ^= self.buttons.items[@ctz(i)];
            if (current_lights == self.lights) {
                const combo = i ^ (i >> 1);
                min_pressed = @min(min_pressed, @popCount(combo));
            }
        }

        return min_pressed;
    }

    pub fn into_equations(self: Self) [MAX_JOLTAGES][MAX_BUTTONS]i32 {
        const buttons = self.buttons;
        const joltages = self.joltages;
        const width = buttons.len;
        const height = joltages.len;

        var equations: [MAX_JOLTAGES][MAX_BUTTONS]i32 = .{.{0} ** MAX_BUTTONS} ** MAX_JOLTAGES;

        for (0..height) |row| {
            equations[row][width] = joltages.items[row];
        }

        for (0..width) |col| {
            var limit: i32 = math.maxInt(i32);
            var it = biterator(u16, buttons.items[col]);
            while (it.next()) |row| {
                equations[row][col] = 1;
                limit = @min(limit, joltages.items[row]);
            }
            equations[height][col] = limit;
        }

        return equations;
    }

    pub fn configure_joltages(self: Self) usize {
        const subspace: Subspace = .from_machine(self);
        const particular_solution = subspace.solution();

        if (subspace.nullity == 0) {
            return @intCast(@divTrunc(particular_solution, subspace.lcm));
        } else {
            const remaining = (@as(u32, 1) << @intCast(subspace.bases.len)) - 1;
            const possible_value = recurse(subspace, subspace.rhs, remaining, particular_solution).?;
            return @intCast(possible_value);
        }
    }
};

const LINE_COUNT = aoc.slice.line_count(input);
const MACHINES: [LINE_COUNT]Machine = blk: {
    var machine_index: usize = 0;
    var machines: [LINE_COUNT]Machine = undefined;

    var lines = aoc.slice.lines(input);
    while (lines.next()) |line| : (machine_index += 1) {
        machines[machine_index] = .from_string(line);
    }

    break :blk machines;
};

fn part1(_: Allocator) !usize {
    var result: usize = 0;
    for (MACHINES) |machine| {
        result += machine.configure_buttons();
    }
    return result;
}

const MAX_BUTTONS: usize = 14;
const MAX_JOLTAGES: usize = 11;

const Basis = struct {
    limit: i32,
    cost: i32,
    vs: [MAX_JOLTAGES]i32,
};

const Subspace = struct {
    rank: usize,
    nullity: usize,
    lcm: i32,
    rhs: [MAX_JOLTAGES]i32,
    bases: Stack(Basis, 4),
    const Self = @This();

    pub fn from_machine(machine: Machine) Self {
        const width = machine.buttons.len;
        const height = machine.joltages.len;
        var equations = machine.into_equations();
        var rank: usize = 0;
        var last = width;

        while (rank < height and rank < last) {
            const found = find_swap_index(rank, height, equations) orelse {
                last -= 1;
                for (0..height + 1) |index| {
                    mem.swap(i32, &equations[index][rank], &equations[index][last]);
                }
                continue;
            };
            mem.swap([MAX_BUTTONS]i32, &equations[rank], &equations[found]);

            var pivot: i32 = equations[rank][rank];
            if (pivot < 0) {
                pivot *= -1;
                for (rank..width + 1) |index| {
                    equations[rank][index] *= -1;
                }
            }

            for (0..height) |row| {
                const coefficient = equations[row][rank];
                if (row != rank and coefficient != 0) {
                    const abs_coefficient: i32 = @intCast(@abs(coefficient));
                    const lcm = least_common_multiple(abs_coefficient, pivot);
                    const x = @divFloor(lcm, abs_coefficient);
                    const sign = math.sign(coefficient);
                    const y = @divFloor(lcm, pivot * sign);

                    for (0..equations[row].len) |col| {
                        const value = x * equations[row][col] - y * equations[rank][col];
                        equations[row][col] = value;
                    }
                }
            }
            rank += 1;
        }

        var lcm: i32 = 1;
        for (0..rank) |pivot| {
            lcm = least_common_multiple(lcm, equations[pivot][pivot]);
        }

        var pivot: usize = 0;
        for (0..rank) |i| {
            const q = @divFloor(lcm, equations[i][pivot]);
            for (rank..width + 1) |j| {
                equations[i][j] *= q;
            }
            pivot += 1;
        }

        const nullity = width - rank;
        const rhs = blk: {
            var rhs: [MAX_JOLTAGES]i32 = undefined;
            for (0..MAX_JOLTAGES) |index| {
                rhs[index] = equations[index][width];
            }
            break :blk rhs;
        };

        var bases: Stack(Basis, 4) = .empty;
        for (0..nullity) |col| {
            const limit = equations[height][col + rank];
            const vs = blk: {
                var vs: [MAX_JOLTAGES]i32 = undefined;
                for (0..MAX_JOLTAGES) |index| {
                    vs[index] = equations[index][rank + col];
                }
                break :blk vs;
            };
            const cost = blk: {
                var sum: i32 = 0;
                for (0..rank) |index| sum += vs[index];
                break :blk lcm - sum;
            };
            bases.push(.{
                .limit = limit,
                .cost = cost,
                .vs = vs,
            });
        }

        return .{
            .rank = rank,
            .nullity = nullity,
            .lcm = lcm,
            .rhs = rhs,
            .bases = bases,
        };
    }

    pub fn solution(self: Self) i32 {
        var sum: i32 = 0;
        for (self.rhs[0..self.rank]) |value| sum += value;
        return sum;
    }
};

fn Biterator(comptime T: type) type {
    const info = @typeInfo(T);
    if (info != .int and info != .float)
        @compileError("Biterator only works on numeric types");

    return struct {
        t: T,
        _t: T,

        pub fn next(self: *@This()) ?usize {
            const one: T = @intCast(1);
            if (self.t == 0) {
                return null;
            } else {
                const tz = @ctz(self.t);
                self.t = self.t ^ (one << @intCast(tz));
                return tz;
            }
        }

        pub fn reset(self: *@This()) void {
            self.t = self._t;
        }
    };
}
pub fn biterator(comptime T: type, n: T) Biterator(T) {
    return .{
        .t = n,
        ._t = n,
    };
}

inline fn least_common_multiple(a_in: i32, b_in: i32) i32 {
    const gcd = blk: {
        var a = a_in;
        var b = b_in;

        while (b != 0) {
            const temp = @rem(a, b);
            a = b;
            b = temp;
        }

        break :blk a;
    };

    return a_in * @divTrunc(b_in, gcd);
}

fn find_swap_index(rank: usize, height: usize, equations: [MAX_JOLTAGES][MAX_BUTTONS]i32) ?usize {
    var index: ?usize = null;
    var min_abs: ?u32 = null;
    var row = rank;

    while (row < height) : (row += 1) {
        const v = equations[row][rank];
        if (v != 0) {
            const is_new_min = if (min_abs) |min| @abs(v) < min else true;
            if (is_new_min) {
                index = row;
                min_abs = @abs(v);
            }
        }
    }

    return index;
}

const Bounds = struct {
    min_index: usize,
    lower: i32,
    upper: i32,
    const Self = @This();

    pub fn find(subspace: Subspace, remaining: u32, rhs_in: [MAX_JOLTAGES]i32) ?Self {
        var rhs = rhs_in;
        var it = biterator(u32, remaining);
        while (it.next()) |bit_index| {
            const free = subspace.bases.items[bit_index];
            for (0..subspace.rank) |index| {
                const v = free.vs[index];
                if (v < 0) {
                    rhs[index] -= v * free.limit;
                }
            }
        }

        var bounds: ?Self = null;
        var min_size: i32 = math.maxInt(i32);

        it.reset();
        while (it.next()) |min_index| {
            const free = subspace.bases.items[min_index];
            var lower: i32 = 0;
            var upper: i32 = free.limit;

            for (0..subspace.rank) |index| {
                const t = rhs[index];
                const v = free.vs[index];

                if (v > 0) {
                    upper = @min(upper, @divTrunc(t, v));
                } else if (v < 0) {
                    lower = @max(@divTrunc((t + v * free.limit) + v + 1, v), lower);
                }
            }

            const size = upper - lower + 1;
            if (size > 0 and size < min_size) {
                min_size = size;
                bounds = .{
                    .min_index = min_index,
                    .lower = lower,
                    .upper = upper,
                };
            }
        }

        return bounds;
    }
};

fn recurse(subspace: Subspace, rhs_in: [MAX_JOLTAGES]i32, remaining_in: u32, presses: i32) ?i32 {
    var rhs = rhs_in;
    const bounds = Bounds.find(subspace, remaining_in, rhs_in) orelse return null;
    const remaining = remaining_in ^ (@as(u32, 1) << @intCast(bounds.min_index));
    const basis = subspace.bases.items[bounds.min_index];

    if (remaining != 0) {
        for (0..subspace.rank) |index| {
            rhs[index] -= (bounds.lower - 1) * basis.vs[index];
        }

        var minimum_opt: ?i32 = null;
        var n: i32 = bounds.lower;

        while (n <= bounds.upper) : (n += 1) {
            for (0..subspace.rank) |index| {
                rhs[index] -= basis.vs[index];
            }

            if (recurse(subspace, rhs, remaining, presses + @as(i32, @intCast(n)) * basis.cost)) |new_minimum| {
                minimum_opt = @min(minimum_opt orelse new_minimum, new_minimum);
            }
        }

        return minimum_opt;
    }

    if (basis.cost >= 0) {
        var n: i32 = bounds.lower;
        while (n <= bounds.upper) : (n += 1) {
            if (check(@intCast(n), subspace, rhs, basis, presses)) |minimum| {
                return minimum;
            }
        }

        return null;
    }

    var n = bounds.upper;
    while (n >= bounds.lower) : (n -= 1) {
        if (check(n, subspace, rhs, basis, presses)) |minimum| {
            return minimum;
        }
    }

    return null;
}
fn check(n: i32, subspace: Subspace, rhs: [MAX_JOLTAGES]i32, basis: Basis, presses: i32) ?i32 {
    for (0..subspace.rank) |index| {
        const r = rhs[index];
        const v = basis.vs[index];

        if (@rem(r - n * v, subspace.lcm) != 0) {
            return null;
        }
    }

    return @divTrunc(presses + n * basis.cost, subspace.lcm);
}

fn part2(_: Allocator) !usize {
    var result: usize = 0;
    for (MACHINES) |machine| {
        result += machine.configure_joltages();
    }
    return result;
}

pub const solution: Solution = .{
    .day = .@"10",
    .p1 = .{ .f = part1, .expected = 547 },
    .p2 = .{ .f = part2, .expected = 21111 },
};

test "day10 part1" {
    _ = try aoc.validate(testing.allocator, part1, 547, .@"10", .one);
}

test "day10 part2" {
    _ = try aoc.validate(testing.allocator, part2, 21111, .@"10", .two);
}

test "day10 solution" {
    _ = try solution.solve(testing.allocator);
}
