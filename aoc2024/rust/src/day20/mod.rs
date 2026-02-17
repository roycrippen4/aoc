use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub const SOLUTION: Solution = Solution {
    day: Day::Day20,
    p1: Runner {
        expected: 42,
        f: part1::solve,
    },
    p2: Runner {
        expected: 42,
        f: part2::solve,
    },
};
