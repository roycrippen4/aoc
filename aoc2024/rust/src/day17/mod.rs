use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub const SOLUTION: Solution = Solution {
    day: Day::Day17,
    p1: Runner {
        expected: 657457310,
        f: part1::solve,
    },
    p2: Runner {
        expected: 105875099912602,
        f: part2::solve,
    },
};

const A: usize = 59590048;
const B: usize = 0;
const C: usize = 0;
const LEN: usize = 16;
const PROGRAM: [usize; 16] = [2, 4, 1, 5, 7, 5, 0, 3, 1, 6, 4, 3, 5, 5, 3, 0];

fn run(mut a: usize, mut b: usize, mut c: usize) -> Vec<usize> {
    let mut out: Vec<usize> = vec![];
    let mut pc = 0;

    while pc != LEN {
        let literal = PROGRAM[pc + 1];
        let combo = match literal {
            4 => a,
            5 => b,
            6 => c,
            n => n,
        };
        pc += 2;

        match PROGRAM[pc - 2] {
            0 => a >>= combo,
            1 => b ^= literal,
            2 => b = combo % 8,
            3 => pc = if a != 0 { literal } else { pc },
            4 => b ^= c,
            5 => out.push(combo % 8),
            6 => b = a >> combo,
            7 => c = a >> combo,

            _ => unreachable!(),
        }
    }

    out
}
