use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day08,
        p1: Runner {
            expected: 244,
            f: part1::solve,
        },
        p2: Runner {
            expected: 912,
            f: part2::solve,
        },
    }
}
