use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub const SOLUTION: Solution = Solution {
    day: Day::Day05,
    p1: Runner {
        expected: 7198,
        f: part1::solve,
    },
    p2: Runner {
        expected: 4230,
        f: part2::solve,
    },
};
