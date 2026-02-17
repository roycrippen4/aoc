use std::fmt::Debug;

use crate::util::dijkstra::Walkable;
use crate::util::{Grid, Point};
use crate::{Day, Runner, Solution};

mod part1;
mod part2;

#[derive(Debug, Copy, Clone, PartialEq, PartialOrd)]
enum Kind {
    Wall,
    Empty,
}

impl Walkable<Kind> for Kind {
    type Cost = usize;

    fn zero() -> Self::Cost {
        0
    }

    fn add(cost_a: Self::Cost, cost_b: Self::Cost) -> Self::Cost {
        cost_a + cost_b
    }

    fn cmp(cost_a: &Self::Cost, cost_b: &Self::Cost) -> std::cmp::Ordering {
        cost_a.cmp(cost_b)
    }

    fn passable(t: Kind) -> bool {
        t == Kind::Empty
    }

    fn cost_of(_: Kind) -> Self::Cost {
        1
    }
}

fn get_points() -> Vec<Point> {
    crate::data!()
        .lines()
        .map(|line| {
            let (x, y) = line.split_once(',').unwrap();
            let x: isize = x.parse().unwrap();
            let y: isize = y.parse().unwrap();
            Point::new(x, y)
        })
        .collect()
}

fn make_grid() -> Grid<Kind> {
    const SIZE: usize = 71;
    let mut grid = Grid::make(SIZE, SIZE, Kind::Empty);
    get_points()
        .into_iter()
        .take(1024)
        .for_each(|p| grid[p] = Kind::Wall);

    grid
}

const START: Point = Point::new(0, 0);
const END: Point = Point::new(70, 70);

pub const SOLUTION: Solution = Solution {
    day: Day::Day18,
    p1: Runner {
        expected: 506,
        f: part1::solve,
    },
    p2: Runner {
        expected: 372,
        f: part2::solve,
    },
};
