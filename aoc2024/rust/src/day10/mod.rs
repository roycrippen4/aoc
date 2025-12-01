use std::str::FromStr;

use crate::util::{Entry, Grid};
use crate::{Day, Runner, Solution};

fn find_starting_points(grid: &Grid<usize>) -> Vec<Entry<usize>> {
    (0..grid.height)
        .flat_map(|y| {
            (0..grid.width).filter_map(move |x| {
                let xi = x as isize;
                let yi = y as isize;
                (grid[(xi, yi)] == 0).then_some((xi, yi, 0))
            })
        })
        .collect()
}

fn make_grid(data: &str) -> crate::util::Grid<usize> {
    crate::util::Grid::from_str(data).unwrap().as_usize()
}

mod part1;
mod part2;

pub fn solution() -> Solution {
    Solution {
        day: Day::Day10,
        p1: Runner {
            expected: 517,
            f: part1::solve,
        },
        p2: Runner {
            expected: 1116,
            f: part2::solve,
        },
    }
}
