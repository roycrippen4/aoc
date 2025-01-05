use std::collections::HashSet;

use rayon::prelude::*;

use crate::util::StringMethods;

type PathSet = HashSet<(usize, usize)>;
type Obs = Option<(usize, usize)>;
type Pos = (usize, usize, Dir);

fn into_padded_string(str: &&str) -> String {
    let mut s = str.to_string();
    s.pad(1, 'O');
    s
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
enum Dir {
    Up = 0,
    Right = 1,
    Down = 2,
    Left = 3,
    Off = 4,
}

fn get_grid(example: bool) -> Grid {
    let input = match example {
        true => include_str!("data/example.txt"),
        false => include_str!("data/data.txt"),
    };
    Grid::new(input.lines().collect())
}

static MOVES: [(isize, isize, Dir); 4] = [
    (0, -1, Dir::Right),
    (1, 0, Dir::Down),
    (0, 1, Dir::Left),
    (-1, 0, Dir::Up),
];

fn next(state: Pos, grid: &[char], obs: Obs, width: usize) -> Pos {
    let (x, y, d) = state;
    if d == Dir::Off {
        return (x, y, Dir::Off);
    }

    let (dx, dy, next_direction) = MOVES[d as usize];
    let new_x = (x as isize + dx) as usize;
    let new_y = (y as isize + dy) as usize;
    let c = grid_char(grid, new_x, new_y, width);

    if c == 'O' {
        return (x, y, Dir::Off);
    }

    if obs == Some((new_x, new_y)) || c == '#' {
        (x, y, next_direction)
    } else {
        (new_x, new_y, d)
    }
}

fn get_path(grid: &[char], start_state: Pos, width: usize) -> PathSet {
    let mut visited = HashSet::new();
    let (mut x, mut y, mut direction) = start_state;

    while direction != Dir::Off {
        visited.insert((x, y));
        let (nx, ny, nd) = next((x, y, direction), grid, None, width);
        x = nx;
        y = ny;
        direction = nd;
    }
    visited.remove(&(start_state.0, start_state.1));
    visited
}

fn is_loop(start_state: Pos, grid: &[char], obs: Obs, width: usize) -> bool {
    let mut tort = start_state;
    let mut hare = start_state;

    loop {
        tort = next(tort, grid, obs, width);
        hare = next(hare, grid, obs, width);
        hare = next(hare, grid, obs, width);
        if tort.2 == Dir::Off || hare.2 == Dir::Off {
            return false;
        }

        if tort == hare {
            return true;
        }
    }
}

#[inline]
fn idx(x: usize, y: usize, width: usize) -> usize {
    y * width + x
}

fn grid_char(grid: &[char], x: usize, y: usize, width: usize) -> char {
    grid[idx(x, y, width)]
}

fn find_guard(grid: &[char], width: usize, height: usize) -> Pos {
    for y in 0..height {
        for x in 0..width {
            if grid[idx(x, y, width)] == '^' {
                return (x, y, Dir::Up);
            }
        }
    }
    panic!("No guard found in grid") // we should always find a guard
}

#[derive(Clone, Debug, PartialEq)]
struct Grid {
    grid: Vec<char>,
    initial_x: usize,
    initial_y: usize,
    width: usize,
    direction: Dir,
}

impl Grid {
    pub fn new(data: Vec<&str>) -> Self {
        let mut data: Vec<_> = data.iter().map(into_padded_string).collect();
        data.insert(0, "O".repeat(data[0].len()));
        data.insert(data.len(), "O".repeat(data[0].len()));

        let height = data.len();
        let width = data[0].len();
        let mut grid = Vec::with_capacity(width * height);

        for row in &data {
            grid.extend(row.chars());
        }

        let (x, y, direction) = find_guard(&grid, width, height);
        Self {
            grid,
            width,
            initial_x: x,
            initial_y: y,
            direction,
        }
    }

    pub fn evaluate(&self) -> usize {
        get_path(
            &self.grid,
            (self.initial_x, self.initial_y, self.direction),
            self.width,
        )
        .into_par_iter()
        .filter(|&(ox, oy)| {
            is_loop(
                (self.initial_x, self.initial_y, self.direction),
                &self.grid,
                Some((ox, oy)),
                self.width,
            )
        })
        .count()
    }
}

#[allow(unused)]
fn example() -> usize {
    get_grid(true).evaluate()
}

pub fn solve() -> usize {
    get_grid(false).evaluate()
}

#[cfg(test)]
mod test {
    use crate::util::{self, validate};

    use super::{example, solve};

    #[test]
    fn test_solve() {
        validate(solve, 1604, util::Day::Day06, util::Kind::Part2);
    }

    #[test]
    fn test_example() {
        let result = example();
        assert_eq!(6, result);
    }
}
