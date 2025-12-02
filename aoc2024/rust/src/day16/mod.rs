use std::collections::VecDeque;

use crate::util::Point;
use crate::util::point::{DOWN, LEFT, RIGHT, UP};
use crate::{Day, Runner, Solution};

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day16,
        p1: Runner {
            expected: 133584,
            f: part1::solve,
        },
        p2: Runner {
            expected: 622,
            f: part2::solve,
        },
    }
}

#[inline(always)]
const fn index(p: Point) -> usize {
    (p.y as usize * DIM) + p.x as usize
}

macro_rules! find_point {
    ($str: expr, $ch: expr) => {{
        let bytes = INPUT.as_bytes();
        let mut x: isize = 0;
        let mut y: isize = 0;
        let mut i: usize = 0;

        while i < bytes.len() {
            let b = bytes[i];

            if b == b'\n' {
                x = 0;
                y += 1;
                i += 1;
                continue;
            }

            if b == $ch {
                break;
            }

            x += 1;
            i += 1
        }

        Point::new(x, y)
    }};
}

const INPUT: &str = crate::data!();
const DIM: usize = crate::line_count!(INPUT);
const AREA: usize = DIM * DIM;
const DIRECTIONS: [Point; 4] = [RIGHT, DOWN, LEFT, UP];

const START: Point = find_point!(INPUT, b'S');
const END: Point = find_point!(INPUT, b'E');

type State = (Point, usize, usize);
type BestPaths = [bool; AREA];
type Seen = [[usize; 4]; AREA];

fn dfs(
    first: &mut VecDeque<State>,
    second: &mut VecDeque<State>,
    lowest: &mut usize,
    seen: &mut Seen,
    grid: &[char],
) {
    match first.pop_front() {
        None => (),
        Some((_, _, cost)) if cost >= *lowest => dfs(first, second, lowest, seen, grid),
        Some((pos, _, cost)) if pos == END => {
            *lowest = cost;
            dfs(first, second, lowest, seen, grid);
        }
        Some((curr_pos, curr_dir, curr_cost)) => {
            let fwd = (curr_pos + DIRECTIONS[curr_dir], curr_dir, curr_cost + 1);
            let left = (curr_pos, (curr_dir + 3) % 4, curr_cost + 1000);
            let right = (curr_pos, (curr_dir + 1) % 4, curr_cost + 1000);

            for state @ (pos, dir, cost) in [fwd, left, right] {
                let idx = index(pos);
                if grid[idx] != '#' && cost < seen[idx][dir] {
                    seen[idx][dir] = cost;
                    match curr_dir == dir {
                        true => first.push_back(state),
                        false => second.push_back(state),
                    }
                }
            }

            dfs(first, second, lowest, seen, grid);
        }
    }
}
