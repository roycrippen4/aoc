use std::collections::HashSet;

use rayon::prelude::*;

use crate::{data, util::StringMethods};

type PathSet = HashSet<(usize, usize)>;
type Obs = (usize, usize);
type Pos = (usize, usize, Dir);

fn find_guard(grid: &[u8], width: usize, height: usize) -> Pos {
    for y in 0..height {
        for x in 0..width {
            if grid[y * width + x] == 94 {
                return (x, y, Dir::Up);
            }
        }
    }
    unreachable!("No guard found in grid") // we should always find a guard
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
enum Dir {
    Up = 0,
    Right = 1,
    Down = 2,
    Left = 3,
    Off = 4,
}

const MOVES: [(isize, isize, Dir); 4] = [
    (0, -1, Dir::Right),
    (1, 0, Dir::Down),
    (0, 1, Dir::Left),
    (-1, 0, Dir::Up),
];

fn make_grid(data: Vec<&str>) -> (Vec<u8>, usize, Pos) {
    let mut data: Vec<_> = data.iter().map(|s| s.to_string().pad(1, 'O')).collect();
    data.insert(0, "O".repeat(data[0].len()));
    data.insert(data.len(), "O".repeat(data[0].len()));

    let height = data.len();
    let width = data[0].len();
    let mut grid = Vec::with_capacity(width * height);

    for row in &data {
        grid.extend(row.bytes());
    }
    let start = find_guard(&grid, width, height);

    (grid, width, start)
}

fn evaluate(args: (Vec<u8>, usize, Pos)) -> usize {
    let (grid, width, guard) = args;
    get_path(&grid, guard, width)
        .into_par_iter()
        .map(|obs| match is_loop(guard, &grid, obs, width) {
            true => 1,
            false => 0,
        })
        .sum()
}

#[inline(always)]
fn next(state: Pos, grid: &[u8], obs: Obs, width: usize) -> Pos {
    let (x, y, d) = state;
    if d == Dir::Off {
        return (x, y, Dir::Off);
    }

    let (dx, dy, next_direction) = MOVES[d as usize];
    let new_x = (x as isize + dx) as usize;
    let new_y = (y as isize + dy) as usize;

    if obs == (new_x, new_y) {
        return (x, y, next_direction);
    }

    match grid[new_y * width + new_x] {
        79 => (x, y, Dir::Off),
        35 => (x, y, next_direction),
        _ => (new_x, new_y, d),
    }
}

fn get_path(grid: &[u8], start_state: Pos, width: usize) -> PathSet {
    let mut visited = HashSet::new();
    let (mut x, mut y, mut direction) = start_state;

    while direction != Dir::Off {
        visited.insert((x, y));
        let (nx, ny, nd) = next((x, y, direction), grid, (10000, 10000), width);
        x = nx;
        y = ny;
        direction = nd;
    }
    visited.remove(&(start_state.0, start_state.1));
    visited
}

fn is_loop(start_state: Pos, grid: &[u8], obs: Obs, width: usize) -> bool {
    let mut tort = start_state;
    let mut hare = start_state;

    loop {
        tort = next(tort, grid, obs, width);
        if tort.2 == Dir::Off {
            return false;
        }

        hare = next(next(hare, grid, obs, width), grid, obs, width);
        if hare.2 == Dir::Off {
            return false;
        }

        if tort == hare {
            return true;
        }
    }
}

pub fn solve() -> usize {
    evaluate(make_grid(data!().lines().collect()))
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day::Day06, Part::Part2};

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 1604, Day06(Part2));
    }
}
