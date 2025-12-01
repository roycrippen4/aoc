use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day01,
        p1: Runner {
            expected: 42,
            f: part1::solve,
        },
        p2: Runner {
            expected: 42,
            f: part2::solve,
        },
    }
}
