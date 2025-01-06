use std::collections::{HashMap, HashSet};

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

fn place_nodes(p1: Point, p2: Point, width: usize, height: usize, nodes: &mut HashSet<Point>) {
    nodes.insert(p1);
    nodes.insert(p2);

    let mut a = p1;
    let mut b = p2;
    while let Some(next) = rotate_point(a, b, width, height) {
        nodes.insert(next);
        a = b;
        b = next;
    }

    let mut a = p2;
    let mut b = p1;
    while let Some(next) = rotate_point(a, b, width, height) {
        nodes.insert(next);
        a = b;
        b = next;
    }
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
                let p1 = positions[i];
                let p2 = positions[j];
                place_nodes(p1, p2, width, height, &mut nodes);
            }
        }
    }
    nodes.len()
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[cfg(test)]
mod test {

    use crate::util::{validate, Day, Kind};

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 912, Day::Day08, Kind::Part1);
    }

    #[test]
    fn test_example() {
        let data = include_str!("data/example.txt");
        assert_eq!(34, evaluate(data));
    }

    #[test]
    fn test_example_part2() {
        let data = include_str!("data/example-part2.txt");
        assert_eq!(9, evaluate(data))
    }
}
