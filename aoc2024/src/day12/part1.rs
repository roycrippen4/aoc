#![allow(unused)]

use core::fmt;

use itertools::Itertools;
use rayon::array::IntoIter;

use crate::{rgb, util::StringMethods};

struct Grid {
    data: Vec<char>,
    height: usize,
    width: usize,
}

/// (x, y, value)
type Point = (usize, usize, char);
/// x, y
type Coordinate = (usize, usize);

impl Grid {
    pub fn new(input: &str) -> Self {
        let data: Vec<Vec<char>> = input
            .trim()
            .split('\n')
            .map(|s| s.chars().collect())
            .collect();

        let height = data.len();
        let width = data[0].len();
        let data = data.into_iter().flatten().collect();

        Self {
            height,
            data,
            width,
        }
    }

    pub fn idx(&self, x: usize, y: usize) -> char {
        let idx = self.width * y + x;
        self.data[idx]
    }

    #[inline]
    pub fn neighbors(&self, point: Point) -> [Point; 8] {
        let (x, y, v) = point;
        [
            (x + 1, y, self.idx(x + 1, y)),         // right
            (x - 1, y, self.idx(x - 1, y)),         // left
            (x, y - 1, self.idx(x, y - 1)),         // up
            (x, y + 1, self.idx(x, y + 1)),         // down
            (x - 1, y - 1, self.idx(x - 1, y - 1)), // up-left
            (x + 1, y - 1, self.idx(x + 1, y - 1)), // up-right
            (x - 1, y + 1, self.idx(x - 1, y + 1)), // down-left
            (x + 1, y + 1, self.idx(x + 1, y + 1)), // down-right
        ]
    }
}

impl fmt::Display for Grid {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let mut s = String::new();

        (0..self.height).for_each(|y| {
            (0..self.width).for_each(|x| {
                s.push(self.idx(x, y));
            });
            s.push('\n');
        });

        write!(f, "{s}")
    }
}

fn show_neighbor_window(p: Point, grid: &Grid) {
    let (px, py, pv) = p;
    let mut values: Vec<Vec<_>> = grid
        .to_string()
        .split("\n")
        .map(|s| {
            s.split("")
                .filter(|s| !s.is_empty())
                .map(|s| s.to_string())
                .collect::<Vec<_>>()
        })
        .filter(|s| !s.is_empty())
        .collect();

    grid.neighbors(p).iter().for_each(|(x, y, v)| {
        values[*y][*x] = rgb!(v, 255, 0, 0);
    });
    values[py][px] = rgb!(pv, 255, 0, 0);

    (0..values.len()).for_each(|y| {
        let mut s = String::new();
        (0..values[0].len()).for_each(|x| {
            s.push_str(&values[y][x]);
        });
        println!("{s}");
    });
}

fn evaluate(data: &str) -> usize {
    let grid = Grid::new(data);
    (1..grid.height - 1).for_each(|y| {
        (1..grid.width - 1).for_each(|x| {
            println!();
            show_neighbor_window((x, y, grid.idx(x, y)), &grid);
        });
    });
    0
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day12, Part::Part1},
    };

    use super::{evaluate, solve, Grid};

    #[test]
    fn test_solve() {
        dbg!(solve());
    }

    #[test]
    fn test_evaluate() {
        let result = evaluate(SIMPLE);
        dbg!(result);
    }

    #[test]
    fn test_grid_display() {
        let grid = Grid::new(example!());
        println!("{grid}");
    }

    static SIMPLE: &str = r"AAAA
BBCD
BBCC
EEEC";
}
