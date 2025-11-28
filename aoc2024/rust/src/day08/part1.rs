use std::collections::{HashMap, HashSet};

use crate::data;

type Row = Vec<char>;
type Mapping = HashMap<char, Vec<(usize, usize)>>;
type Point = (usize, usize);

fn rotate_point(p: Point, pivot: Point, width: usize, height: usize) -> Option<Point> {
    let (x, y) = p;
    let (px, py) = pivot;
    let x2 = px.checked_mul(2).and_then(|two_px| two_px.checked_sub(x))?;
    let y2 = py.checked_mul(2).and_then(|two_py| two_py.checked_sub(y))?;

    if x2 < width && y2 < height {
        Some((x2, y2))
    } else {
        None
    }
}

fn get_antennas(grid: &[Row]) -> Mapping {
    let mut map: Mapping = HashMap::new();

    for y in 0..grid.len() {
        for x in 0..grid[0].len() {
            let c = grid[y][x];
            if c.is_alphanumeric() {
                map.entry(c)
                    .and_modify(|vec| vec.push((x, y)))
                    .or_insert(vec![(x, y)]);
            }
        }
    }

    map
}

fn evaluate(data: &str) -> usize {
    let grid: Vec<_> = data.lines().map(|r| r.chars().collect()).collect();
    let antennas = get_antennas(&grid);
    let width = grid[0].len();
    let height = grid.len();
    let mut nodes: HashSet<Point> = HashSet::new();

    for positions in antennas.values() {
        for i in 0..positions.len() - 1 {
            for j in i + 1..positions.len() {
                if let Some(p) = rotate_point(positions[i], positions[j], width, height) {
                    nodes.insert(p);
                };
                if let Some(p) = rotate_point(positions[j], positions[i], width, height) {
                    nodes.insert(p);
                }
            }
        }
    }
    nodes.len()
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {

    use crate::{
        example,
        util::{Day::Day08, validate},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 244, Day08);
    }

    #[test]
    fn test_example() {
        let data = example!();
        assert_eq!(14, evaluate(data));
    }

    #[test]
    fn test_simple_example() {
        let data = include_str!("./data/example-simple.txt");
        assert_eq!(2, evaluate(data))
    }
    #[test]
    fn test_simple_example2() {
        let data = include_str!("./data/example-simple2.txt");
        assert_eq!(4, evaluate(data));
    }
}
