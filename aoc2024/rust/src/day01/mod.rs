use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day01,
        p1: Runner {
            expected: 1506483,
            f: part1::solve,
        },
        p2: Runner {
            expected: 23126924,
            f: part2::solve,
        },
    }
}
