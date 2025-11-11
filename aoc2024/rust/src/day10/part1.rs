use std::str::FromStr;

use crate::data;
use crate::util::{Entry, Grid};

// type Visited = HashSet<(usize, usize, usize)>;

fn neighbors(
    point: Entry<usize>,
    g: &Grid<usize>,
    visited: &Grid<bool>,
) -> [Option<Entry<usize>>; 4] {
    let (x, y, v) = point;
    let t = v + 1;

    let mut ns = [None; 4];

    if x < g.width - 1 && g[(x + 1, y)] == t && !visited[(x + 1, y)] {
        ns[0] = Some((x + 1, y, g[(x + 1, y)]))
    }

    if x != 0 && g[(x - 1, y)] == t && !visited[(x - 1, y)] {
        ns[1] = Some((x - 1, y, g[(x - 1, y)]))
    }

    if y != 0 && g[(x, y - 1)] == t && !visited[(x, y - 1)] {
        ns[2] = Some((x, y - 1, g[(x, y - 1)]));
    }

    if y < g.height - 1 && g[(x, y + 1)] == t && !visited[(x, y + 1)] {
        ns[3] = Some((x, y + 1, g[(x, y + 1)]));
    }

    ns
}

fn find_starting_points(grid: &Grid<usize>) -> Vec<Entry<usize>> {
    (0..grid.height)
        .flat_map(|y| (0..grid.width).filter_map(move |x| (grid[(x, y)] == 0).then_some((x, y, 0))))
        .collect()
}

fn score_path(start: Entry<usize>, grid: &Grid<usize>, visited: Option<&mut Grid<bool>>) -> usize {
    let visited = match visited {
        Some(v) => v,
        None => &mut Grid::make(grid.height, grid.width, false),
    };

    let (x, y, v) = start;
    visited[(x, y)] = true;

    if v == 9 {
        return 1;
    }

    neighbors(start, grid, visited)
        .into_iter()
        .flatten()
        .map(|n| score_path(n, grid, Some(visited)))
        .sum()
}

fn evaluate(data: &str) -> usize {
    let grid = Grid::from_str(data).unwrap().as_usize();
    find_starting_points(&grid)
        .iter()
        .map(|s| score_path(*s, &grid, None))
        .sum()
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use std::str::FromStr;

    use crate::{
        example,
        util::{Day::Day10, Grid, Part::Part1, validate},
    };

    use super::{evaluate, score_path, solve};

    #[test]
    fn test_solve() {
        validate(solve, 517, Day10(Part1));
    }

    #[test]
    fn test_evaluate() {
        let data = example!();
        let result = evaluate(data);
        assert_eq!(36, result);
    }

    #[test]
    fn test_score_path() {
        let grid = Grid::from_str(SIMPLE).unwrap().as_usize();
        let result = score_path((3, 0, 0), &grid, None);
        assert_eq!(2, result);

        let grid = Grid::from_str(example!()).unwrap().as_usize();
        let result = score_path((2, 0, 0), &grid, None);
        assert_eq!(5, result);
    }

    const SIMPLE: &str = r"9990999
9991999
9992999
6543456
7999997
8111118
9111119";
}
