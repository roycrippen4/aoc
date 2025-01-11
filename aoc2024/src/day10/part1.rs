use std::collections::HashSet;

use rayon::prelude::*;

use crate::util::StringMethods;

type Visited = HashSet<(usize, usize)>;
type Point = (usize, usize, usize);

fn neighbors(point: Point, grid: &[Vec<usize>]) -> Vec<Point> {
    let (x, y, v) = point;
    let max_height = grid.len();
    let max_width = grid[0].len();
    let target_value = v + 1;
    let mut neighbors = vec![];

    if x < max_width - 1 && grid[y][x + 1] == target_value {
        neighbors.push((x + 1, y, grid[y][x + 1]));
    }
    if x != 0 && grid[y][x - 1] == target_value {
        neighbors.push((x - 1, y, grid[y][x - 1]));
    }
    if y != 0 && grid[y - 1][x] == target_value {
        neighbors.push((x, y - 1, grid[y - 1][x]));
    }
    if y < max_height - 1 && grid[y + 1][x] == target_value {
        neighbors.push((x, y + 1, grid[y + 1][x]));
    }
    neighbors
}

fn create_grid(data: &str) -> Vec<Vec<usize>> {
    data.trim().split("\n").map(|s| s.to_row()).collect()
}

fn find_starting_points(grid: &[Vec<usize>]) -> Vec<Point> {
    let mut points = vec![];
    for y in 0..grid.len() {
        for x in 0..grid[0].len() {
            let value = grid[y][x];
            if value == 0 {
                points.push((x, y, 0));
            }
        }
    }

    points
}

fn score_path(start: Point, grid: &[Vec<usize>], visited: Option<&mut Visited>) -> usize {
    let visited = match visited {
        Some(v) => v,
        None => &mut HashSet::with_capacity(grid.len() * grid[0].len()),
    };

    let (x, y, v) = start;
    visited.insert((x, y));
    if v == 9 {
        return 1;
    }

    let neighbors: Vec<_> = neighbors(start, grid)
        .into_iter()
        .filter(|(nx, ny, _): &Point| !visited.contains(&(*nx, *ny)))
        .collect();

    if neighbors.is_empty() {
        return 0;
    }

    neighbors
        .iter()
        .map(|n| score_path(*n, grid, Some(visited)))
        .sum()
}

fn evaluate(data: &str) -> usize {
    let grid = create_grid(data);
    let starts = find_starting_points(&grid);
    starts.par_iter().map(|s| score_path(*s, &grid, None)).sum()
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[cfg(test)]
mod test {
    use crate::{
        day10::part1::score_path,
        util::{validate, Day::Day10, Part::Part1},
    };

    use super::{create_grid, evaluate, neighbors, solve};

    #[test]
    fn test_solve() {
        validate(solve, 517, Day10(Part1));
    }

    #[test]
    fn test_evaluate() {
        let data = include_str!("data/example.txt");
        let result = evaluate(data);
        assert_eq!(36, result);
    }

    #[test]
    fn test_score_path() {
        let grid = create_grid(SIMPLE);
        let result = score_path((3, 0, 0), &grid, None);
        assert_eq!(2, result);

        let grid = create_grid(include_str!("data/example.txt"));
        let result = score_path((2, 0, 0), &grid, None);
        assert_eq!(5, result);
    }

    #[test]
    fn test_valid_neighbors() {
        let grid = create_grid(SIMPLE);
        let neighbors = neighbors((3, 0, 0), &grid);
        assert_eq!(1, neighbors.len());
    }

    static SIMPLE: &str = r"9990999
9991999
9992999
6543456
7999997
8111118
9111119";
}
