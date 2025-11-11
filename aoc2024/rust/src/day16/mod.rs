pub mod part1;
pub mod part2;

use std::ops::{Index, IndexMut};

use crate::util::Point;

pub(super) struct Grid {
    pub width: usize,
    pub height: usize,
    pub size: usize,
    pub data: Vec<char>,
}

impl Grid {
    pub fn new(input: &str) -> Self {
        let lines: Vec<_> = input.trim().lines().collect();
        let height = lines.len();
        let width = lines[0].len();
        let size = width * height;
        let data: Vec<char> = lines.into_iter().flat_map(str::chars).collect();

        Self {
            height,
            width,
            size,
            data,
        }
    }
}

impl Index<Point<usize>> for Grid {
    type Output = char;

    fn index(&self, p: Point<usize>) -> &Self::Output {
        let idx = (p.y * self.width) + p.x;
        &self.data[idx]
    }
}

impl IndexMut<Point<usize>> for Grid {
    fn index_mut(&mut self, p: Point<usize>) -> &mut Self::Output {
        let idx = (p.y * self.width) + p.x;
        &mut self.data[idx]
    }
}
