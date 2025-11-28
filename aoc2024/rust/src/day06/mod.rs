use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day06,
        p1: Runner {
            expected: 4559,
            f: part1::solve,
        },
        p2: Runner {
            expected: 1604,
            f: part2::solve,
        },
    }
}
