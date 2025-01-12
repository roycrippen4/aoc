use rayon::prelude::*;

use crate::{data, util::StringMethods};

type Point = (usize, usize, usize);

static DIRECTIONS: [(isize, isize); 4] = [(1, 0), (-1, 0), (0, 1), (0, -1)];

fn neighbors(point: Point, grid: &[Vec<usize>]) -> Vec<Point> {
    let (x, y, v) = point;
    let target_value = v + 1;
    let max_height = grid.len() as isize;
    let max_width = grid[0].len() as isize;
    let mut neighbors = Vec::new();

    for (dx, dy) in DIRECTIONS {
        let nx = x as isize + dx;
        let ny = y as isize + dy;
        if nx >= 0 && nx < max_width && ny >= 0 && ny < max_height {
            let (nx, ny) = (nx as usize, ny as usize);
            if grid[ny][nx] == target_value {
                neighbors.push((nx, ny, grid[ny][nx]));
            }
        }
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

fn score_path(start: Point, grid: &[Vec<usize>]) -> usize {
    if start.2 == 9 {
        return 1;
    }
    neighbors(start, grid)
        .iter()
        .map(|n| score_path(*n, grid))
        .sum()
}

fn evaluate(data: &str) -> usize {
    let grid = create_grid(data);
    let starts = find_starting_points(&grid);
    starts.par_iter().map(|s| score_path(*s, &grid)).sum()
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day10, Part::Part2},
    };

    use super::{create_grid, evaluate, score_path, solve};

    #[test]
    fn test_solve() {
        validate(solve, 1116, Day10(Part2));
    }

    #[test]
    fn test_evaluate() {
        let data = example!();
        let result = evaluate(data);
        assert_eq!(81, result);
    }

    #[test]
    fn test_score_path() {
        let grid = create_grid(SIMPLE1);
        let result = score_path((0, 0, 0), &grid);
        assert_eq!(227, result);

        let grid = create_grid(example!());
        let result = score_path((2, 0, 0), &grid);
        assert_eq!(20, result);
    }

    static SIMPLE1: &str = "012345
123456
234567
345678
496789
567891";
}
