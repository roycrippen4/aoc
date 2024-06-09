// Again, this is such a bad solution...
// But it does get the correct answer.

use std::collections::{HashSet, VecDeque};

fn main() {
    let test_points: Vec<Point> = find_points(&pad(include_str!("test.txt")
        .lines()
        .map(|l| l.to_string())
        .collect()));

    let points = find_points(&pad(include_str!("input.txt")
        .lines()
        .map(|l| l.to_string())
        .collect()));

    println!("Day 01 part a test: {}", solve_a(&test_points)); // 4361
    println!("Day 01 part b test: {}", solve_b(&test_points)); // 467835
    println!("Day 01 part a: {}", solve_a(&points)); // 528819
    println!("Day 01 part b: {}", solve_b(&points)); // 80403602
}

fn solve_a(points: &Vec<Point>) -> u32 {
    let mut result: u32 = 0;
    let mut i: usize = 0;

    while i < points.len() - 1 {
        let current_point = points[i].clone();

        if current_point.value.parse::<u32>().is_ok() {
            result += build_number(&current_point, points);

            while points[i].value.parse::<u32>().is_ok() {
                i += 1;
            }
        } else {
            i += 1;
        }
    }

    result
}

fn solve_b(points: &Vec<Point>) -> usize {
    let symbol_points = points
        .iter()
        .filter(|p| p.value == *"*")
        .cloned()
        .collect::<Vec<Point>>();

    let mut neighbors: Vec<Vec<Point>> = vec![];

    for symbol in symbol_points {
        let ns = find_neighbors(&symbol, points)
            .iter()
            .filter(|&p| p.value.parse::<u32>().is_ok())
            .cloned()
            .collect();

        neighbors.push(ns);
    }

    let filtered_neighbors: Vec<Vec<Point>> = neighbors
        .iter()
        .filter(|&ps| ps.len() >= 2)
        .cloned()
        .collect();

    let mut neighbor_groups: Vec<Vec<Vec<Point>>> = vec![];

    for n in filtered_neighbors {
        let group = group_neighbors(n);
        neighbor_groups.push(group);
    }

    let mut final_result = 0;
    for group in neighbor_groups {
        if group.len() == 1 {
            continue;
        }

        let x = build_number_b(&group[0], points);
        let y = build_number_b(&group[1], points);
        let res = x * y;
        final_result += res;
    }

    final_result
}

fn build_number_b(number_points: &Vec<Point>, points: &Vec<Point>) -> usize {
    let res: usize = 1;

    let mut curr_points_set: HashSet<Point> = number_points
        .iter()
        .flat_map(|p| find_neighbors(p, points))
        .filter(|p| p.value.parse::<u32>().is_ok())
        .collect();

    for point in number_points {
        curr_points_set.insert(point.clone());
    }

    let mut curr_points: Vec<Point> = curr_points_set.into_iter().collect();
    curr_points.sort_by(|a, b| a.x.cmp(&b.x));

    if number_points.len() == curr_points.len() {
        return res
            * curr_points
                .iter()
                .map(|p| p.value.to_owned())
                .collect::<Vec<String>>()
                .concat()
                .parse::<usize>()
                .unwrap();
    }

    build_number_b(&curr_points, points)
}

fn group_neighbors(points: Vec<Point>) -> Vec<Vec<Point>> {
    let mut groups: Vec<HashSet<Point>> = vec![];
    let mut visited: HashSet<usize> = HashSet::new();

    for i in 0..points.len() {
        if visited.contains(&i) {
            continue;
        }

        let mut group: HashSet<Point> = HashSet::new();
        let mut queue: VecDeque<usize> = VecDeque::new();
        queue.push_back(i);

        while let Some(index) = queue.pop_front() {
            if visited.contains(&index) {
                continue;
            }

            visited.insert(index);
            let p1 = points[index].clone();
            group.insert(p1.clone());

            (0..points.len()).for_each(|j| {
                if !visited.contains(&j) && p1.is_neighbor(&points[j]) {
                    queue.push_back(j);
                }
            });
        }

        groups.push(group);
    }

    groups
        .into_iter()
        .map(|group| group.into_iter().collect())
        .collect()
}

#[derive(Debug, Clone, Hash, Eq, PartialEq, PartialOrd, Ord)]
struct Point {
    x: usize,
    y: usize,
    value: String,
}

impl Point {
    fn is_neighbor(&self, other: &Point) -> bool {
        (self.x == other.x) && (self.y == other.y + 1 || self.y == other.y - 1)
            || (self.y == other.y) && (self.x == other.x + 1 || self.x == other.x - 1)
    }
}

fn find_neighbors(point: &Point, points: &Vec<Point>) -> Vec<Point> {
    let mut neighbors: Vec<Point> = vec![];

    for neighbor in points {
        match (neighbor.x, neighbor.y) {
            (x, y) if x == point.x + 1 && y == point.y - 1 => neighbors.push(neighbor.clone()),
            (x, y) if x == point.x + 1 && y == point.y => neighbors.push(neighbor.clone()),
            (x, y) if x == point.x + 1 && y == point.y + 1 => neighbors.push(neighbor.clone()),
            (x, y) if x == point.x - 1 && y == point.y - 1 => neighbors.push(neighbor.clone()),
            (x, y) if x == point.x - 1 && y == point.y => neighbors.push(neighbor.clone()),
            (x, y) if x == point.x - 1 && y == point.y + 1 => neighbors.push(neighbor.clone()),
            (x, y) if x == point.x && y == point.y - 1 => neighbors.push(neighbor.clone()),
            (x, y) if x == point.x && y == point.y + 1 => neighbors.push(neighbor.clone()),
            _ => {}
        }
    }

    neighbors
}

fn pad(lines: Vec<String>) -> Vec<Vec<String>> {
    let mut new_lines: Vec<Vec<String>> = lines
        .iter()
        .map(|l| {
            l.split("")
                .map(|s| match s {
                    "" => "~".to_string(),
                    _ => s.to_string(),
                })
                .collect()
        })
        .collect();

    let pad_row: Vec<String> = "~"
        .to_string()
        .repeat(lines[0].len() + 2)
        .split("")
        .map(|s| s.to_string())
        .filter(|s| !s.is_empty())
        .collect();

    new_lines.insert(0, pad_row.clone());
    new_lines.push(pad_row);

    new_lines
}

fn find_points(grid: &[Vec<String>]) -> Vec<Point> {
    let mut points: Vec<Point> = vec![];

    (1..grid.len() - 1).for_each(|i| {
        (1..grid[i].len() - 1).for_each(|j| {
            let value = grid[i][j].clone();
            points.push(Point { x: j, y: i, value })
        })
    });

    points
}

fn find_point(x: usize, y: usize, points: &[Point]) -> Point {
    let new_point = points.iter().find(|p| p.x == x && p.y == y);

    match new_point {
        Some(new_point) => new_point.clone(),
        _ => points
            .iter()
            .find(|p| p.x == 1 && p.y == y + 1)
            .unwrap()
            .clone(),
    }
}

fn build_number(start_point: &Point, points: &Vec<Point>) -> u32 {
    let mut number_points: Vec<Point> = vec![start_point.clone()];
    let mut next = find_point(start_point.x + 1, start_point.y, points);

    while next.value.parse::<u32>().is_ok() {
        number_points.push(next.clone());
        next = find_point(next.x + 1, next.y, points);
    }

    let result: u32 = number_points
        .iter()
        .map(|p| p.value.to_owned())
        .collect::<Vec<String>>()
        .concat()
        .parse()
        .unwrap();

    let mut all_neighbors: Vec<Point> = vec![];
    for point in number_points {
        let neighbors = find_neighbors(&point, points);
        all_neighbors.extend(neighbors)
    }

    for neighbor in all_neighbors {
        if is_symbol(&neighbor) {
            return result;
        }
    }

    0
}

fn is_symbol(point: &Point) -> bool {
    !(point.value.parse::<u32>().is_ok() || point.value == *".")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_symbol() {
        assert!(!is_symbol(&Point {
            x: 0,
            y: 0,
            value: ".".to_string()
        }));

        assert!(!is_symbol(&Point {
            x: 0,
            y: 0,
            value: "5".to_string()
        }));

        assert!(is_symbol(&Point {
            x: 0,
            y: 0,
            value: "%".to_string()
        }));
    }

    #[test]
    fn test_find_point() {
        let points = find_points(&pad(include_str!("test.txt")
            .lines()
            .map(|l| l.to_string())
            .collect()));

        let expected = Point {
            x: 1,
            y: 5,
            value: "6".to_string(),
        };

        let result = find_point(1, 5, &points);

        assert_eq!(expected.x, result.x);
        assert_eq!(expected.y, result.y);
        assert_eq!(expected.value, result.value);

        assert!(!is_symbol(&Point {
            x: 0,
            y: 0,
            value: ".".to_string()
        }));
    }

    #[test]
    fn test_build_number_string() {
        let points = find_points(&pad(include_str!("test.txt")
            .lines()
            .map(|l| l.to_string())
            .collect()));

        let start_point = points[0].clone();

        let result = build_number(&start_point, &points);
        assert_eq!(467, result)
    }
}
