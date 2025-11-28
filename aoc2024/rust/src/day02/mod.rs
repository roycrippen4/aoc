use crate::{Day, Runner, Solution};

fn into_isize_vec(line: &str) -> Vec<isize> {
    line.split_whitespace()
        .map(|s| s.parse().expect("Cannot parse to usize"))
        .collect()
}

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day02,
        p1: Runner {
            expected: 202,
            f: part1::solve,
        },
        p2: Runner {
            expected: 271,
            f: part2::solve,
        },
    }
}
