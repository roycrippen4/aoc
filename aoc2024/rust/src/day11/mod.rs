use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day11,
        p1: Runner {
            expected: 220999,
            f: part1::solve,
        },
        p2: Runner {
            expected: 261936432123724,
            f: part2::solve,
        },
    }
}
