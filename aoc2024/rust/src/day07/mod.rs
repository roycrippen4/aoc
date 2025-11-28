use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day07,
        p1: Runner {
            expected: 303766880536,
            f: part1::solve,
        },
        p2: Runner {
            expected: 337041851384440,
            f: part2::solve,
        },
    }
}
