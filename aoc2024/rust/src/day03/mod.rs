use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub const SOLUTION: Solution = Solution {
    day: Day::Day03,
    p1: Runner {
        expected: 173731097,
        f: part1::solve,
    },
    p2: Runner {
        expected: 93729253,
        f: part2::solve,
    },
};
