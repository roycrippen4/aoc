use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day13,
        p1: Runner {
            expected: 29436,
            f: part1::solve,
        },
        p2: Runner {
            expected: 103729094227877,
            f: part2::solve,
        },
    }
}
