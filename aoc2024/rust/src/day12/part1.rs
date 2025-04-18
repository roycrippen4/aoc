use std::sync::LazyLock;

use crate::DIRECTIONS;

static _SIZE: LazyLock<usize> = LazyLock::new(|| 5);

fn make_grid(input: &str) -> (usize, Vec<u8>) {
    let data: Vec<Vec<_>> = input
        .trim()
        .split('\n')
        .map(|s| s.chars().map(|c| c as u8).collect())
        .collect();

    let size = data.len();
    let grid: Vec<_> = data.into_iter().flatten().collect();

    (size, grid)
}

#[inline(always)]
fn idx(x: usize, y: usize, size: usize) -> usize {
    size * y + x
}

fn evaluate(input: &str) -> usize {
    let (size, grid) = make_grid(input);
    let mut visited = vec![false; size * size];

    let xyc = |i: usize| (i % size, i / size, grid[i]);

    (0..grid.len()).fold(0, |acc, i| {
        if visited[i] {
            acc
        } else {
            acc + walk_area(xyc(i), (size, &grid), &mut visited)
        }
    })
}

fn walk_area(
    (x, y, c): (usize, usize, u8),
    (size, grid): (usize, &[u8]),
    visited: &mut [bool],
) -> usize {
    let mut area = 0;
    let mut perimeter = 0;
    let mut q = Vec::from([(x, y)]);
    visited[y * size + x] = true;

    while let Some((cx, cy)) = q.pop() {
        area += 1;
        walk_perimeter((cx, cy, c), (size, grid), &mut q, &mut perimeter, visited);
    }

    area * perimeter
}

fn walk_perimeter(
    (cx, cy, c): (usize, usize, u8),
    (size, grid): (usize, &[u8]),
    queue: &mut Vec<(usize, usize)>,
    perimeter: &mut usize,
    visited: &mut [bool],
) {
    let cx_i = cx as isize;
    let cy_i = cy as isize;
    let size_i = size as isize;

    for &(dx, dy) in &DIRECTIONS {
        let nx_i = cx_i + dx;
        let ny_i = cy_i + dy;

        if nx_i < 0 || nx_i >= size_i || ny_i < 0 || ny_i >= size_i {
            *perimeter += 1;
            continue;
        }

        let nx = nx_i as usize;
        let ny = ny_i as usize;
        let idx = idx(nx, ny, size);
        if grid[idx] != c {
            *perimeter += 1;
        } else if !visited[idx] {
            visited[idx] = true;
            queue.push((nx, ny));
        }
    }
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day12, Part::Part1},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 1361494, Day12(Part1));
    }

    #[test]
    fn test_evaluate() {
        assert_eq!(evaluate(SIMPLE), 140);
        assert_eq!(evaluate(HARDER), 772);
        assert_eq!(evaluate(example!()), 1930);
    }

    const HARDER: &str = r"OOOOO
OXOXO
OOOOO
OXOXO
OOOOO";

    const SIMPLE: &str = r"AAAA
BBCD
BBCC
EEEC";
}
