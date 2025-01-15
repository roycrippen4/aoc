#![allow(unused)]

use core::fmt;

use rayon::array::IntoIter;

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

    pub fn neighbors(&self, point: Point) -> [Option<Point>; 8] {
        let (x, y, v) = point;
        let mut neighbors = [None, None, None, None, None, None, None, None];

        // right
        if x < self.width - 1 {
            let p = (x + 1, y, self.idx(x + 1, y));
            neighbors[0] = Some(p);
        }
        // left
        if x != 0 {
            let p = (x - 1, y, self.idx(x - 1, y));
            neighbors[1] = Some(p)
        }
        // up
        if y != 0 {
            let p = (x, y - 1, self.idx(x, y - 1));
            neighbors[2] = Some(p)
        }
        // down
        if y < self.height - 1 {
            let p = (x, y + 1, self.idx(x, y + 1));
            neighbors[3] = Some(p)
        }
        // up-left
        if y != 0 && x != 0 {
            let p = (x - 1, y - 1, self.idx(x - 1, y - 1));
            neighbors[4] = Some(p)
        }
        // up-right
        if y != 0 && x < self.width - 1 {
            let p = (x + 1, y - 1, self.idx(x + 1, y - 1));
            neighbors[5] = Some(p)
        }
        // down-left
        if y < self.height - 1 && x != 0 {
            let p = (x - 1, y + 1, self.idx(x - 1, y + 1));
            neighbors[6] = Some(p)
        }
        // down-right
        if y < self.height - 1 && x < self.width - 1 {
            let p = (x + 1, y + 1, self.idx(x + 1, y + 1));
            neighbors[7] = Some(p)
        }

        neighbors
    }
}

pub struct GridPointsIter<'a> {
    grid: &'a Grid,
    x: usize,
    y: usize,
}

impl Iterator for GridPointsIter<'_> {
    type Item = (usize, usize, char);

    fn next(&mut self) -> Option<Self::Item> {
        if self.y >= self.grid.height {
            return None;
        }

        let value = self.grid.idx(self.x, self.y);
        let current = (self.x, self.y, value);

        self.x += 1;
        if self.x >= self.grid.width {
            self.x = 0;
            self.y += 1;
        }

        Some(current)
    }
}

impl<'a> IntoIterator for &'a Grid {
    type Item = (usize, usize, char);
    type IntoIter = GridPointsIter<'a>;

    fn into_iter(self) -> Self::IntoIter {
        GridPointsIter {
            grid: self,
            x: 0,
            y: 0,
        }
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

fn evaluate(data: &str) -> usize {
    let grid = Grid::new(data);
    (1..grid.height - 1).for_each(|y| {
        (1..grid.width - 1).for_each(|x| {
            let p = (x, y, grid.idx(x, y));
            println!("{:?} -> {:?}", p, grid.neighbors(p))
        });
    });
    // grid.into_iter()
    //     .for_each(|p| println!("{:?} -> {:?}", p, grid.neighbors(p)));
    println!("{grid}");
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
        let data = include_str!("data/example.txt");
        let result = evaluate(data);
        dbg!(result);
    }

    #[test]
    fn test_grid_display() {
        let grid = Grid::new(example!());
        println!("{grid}");
    }
}
