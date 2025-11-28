use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day12,
        p1: Runner {
            expected: 1361494,
            f: part1::solve,
        },
        p2: Runner {
            expected: 830516,
            f: part2::solve,
        },
    }
}
