use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub const SOLUTION: Solution = Solution {
    day: Day::Day04,
    p1: Runner {
        expected: 2483,
        f: part1::solve,
    },
    p2: Runner {
        expected: 1925,
        f: part2::solve,
    },
};
