use std::{fmt, iter};

use crate::util::StringMethods;

fn create_pad(len: usize, character: char) -> String {
    iter::repeat(character).take(len).collect()
}

fn into_padded_string(str: &&str) -> String {
    let mut s = str.to_string();
    s.pad(3, '.');
    s
}

#[allow(unused)]
fn is_mas(chs: &[char]) -> bool {
    let s: String = chs.iter().collect();
    let r: String = chs.iter().rev().collect();
    s == "MAS" || r == "MAS"
}

#[derive(Debug)]
struct Grid {
    data: Vec<Vec<char>>,
}

impl Grid {
    pub fn new(data: Vec<&str>) -> Self {
        let mut data: Vec<String> = data.iter().map(into_padded_string).collect();
        let row_len = data[0].len();
        let pad = create_pad(row_len, '.');
        (0..3).for_each(|_| data.insert(0, pad.clone()));
        let col_len = data.len();
        (0..3).for_each(|_| data.insert(col_len, pad.clone()));
        Self {
            data: data.iter().map(|r| r.to_char_vec()).collect(),
        }
    }

    fn get_cross(&self, x: usize, y: usize) -> (Vec<char>, Vec<char>) {
        (
            vec![
                self.data[y - 1][x - 1],
                self.data[y][x],
                self.data[y + 1][x + 1],
            ],
            vec![
                self.data[y - 1][x + 1],
                self.data[y][x],
                self.data[y + 1][x - 1],
            ],
        )
    }

    pub fn evaluate(&self, x: usize, y: usize) -> usize {
        let (cross0, cross1) = self.get_cross(x, y);
        match is_mas(&cross0) && is_mas(&cross1) {
            true => 1,
            false => 0,
        }
    }
}

impl fmt::Display for Grid {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let printable: String = self
            .data
            .iter()
            .map(|v| v.iter().collect::<String>())
            .collect::<Vec<_>>()
            .join("\n");
        write!(f, "{printable}")
    }
}

fn get_grid(example: bool) -> Grid {
    let input = match example {
        true => include_str!("data/example.txt"),
        false => include_str!("data/data.txt"),
    };
    Grid::new(input.lines().collect())
}

pub fn solve() -> usize {
    let grid = get_grid(false);
    let mut count = 0;

    for y in 4..grid.data.len() - 4 {
        for x in 4..grid.data[0].len() - 4 {
            count += grid.evaluate(x, y);
        }
    }

    count
}

pub fn p1_example() -> usize {
    let grid = get_grid(true);
    let mut count = 0;

    for y in 4..grid.data.len() - 4 {
        for x in 4..grid.data[0].len() - 4 {
            count += grid.evaluate(x, y);
        }
    }

    count
}

#[cfg(test)]
mod test {
    use crate::day04::part2::{is_mas, p1_example, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
    }

    #[test]
    fn test_example() {
        let result = p1_example();
        assert_eq!(9, result);
    }

    #[test]
    fn test_is_mas() {
        assert!(is_mas(&['M', 'A', 'S']));
        assert!(!is_mas(&['X', 'A', 'S']));
    }
}
