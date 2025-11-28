use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day09,
        p1: Runner {
            expected: 6448989155953,
            f: part1::solve,
        },
        p2: Runner {
            expected: 6476642796832,
            f: part2::solve,
        },
    }
}
