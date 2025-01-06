use std::fmt;

use crate::util::{create_pad, into_padded_string, StringMethods};

fn is_xmas(chs: &[char]) -> bool {
    let s: String = chs.iter().collect();
    s == "XMAS"
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
        (0..4).for_each(|_| data.insert(0, pad.clone()));
        let col_len = data.len();
        (0..4).for_each(|_| data.insert(col_len, pad.clone()));
        Self {
            data: data.iter().map(|r| r.to_char_vec()).collect(),
        }
    }

    fn left(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y][x - 1],
            self.data[y][x - 2],
            self.data[y][x - 3],
        ]
    }
    fn left_up(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y - 1][x - 1],
            self.data[y - 2][x - 2],
            self.data[y - 3][x - 3],
        ]
    }
    fn up(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y - 1][x],
            self.data[y - 2][x],
            self.data[y - 3][x],
        ]
    }
    fn down(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y + 1][x],
            self.data[y + 2][x],
            self.data[y + 3][x],
        ]
    }
    fn right_up(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y - 1][x + 1],
            self.data[y - 2][x + 2],
            self.data[y - 3][x + 3],
        ]
    }
    fn right(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y][x + 1],
            self.data[y][x + 2],
            self.data[y][x + 3],
        ]
    }
    fn right_down(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y + 1][x + 1],
            self.data[y + 2][x + 2],
            self.data[y + 3][x + 3],
        ]
    }
    fn left_down(&self, x: usize, y: usize) -> Vec<char> {
        vec![
            self.data[y][x],
            self.data[y + 1][x - 1],
            self.data[y + 2][x - 2],
            self.data[y + 3][x - 3],
        ]
    }

    fn get_lines(&self, x: usize, y: usize) -> Vec<Vec<char>> {
        vec![
            self.left_up(x, y),
            self.up(x, y),
            self.right_up(x, y),
            self.left(x, y),
            self.right(x, y),
            self.left_down(x, y),
            self.down(x, y),
            self.right_down(x, y),
        ]
    }

    fn in_bounds(&self, x: usize, y: usize) -> bool {
        x >= 4 && x <= self.data[0].len() - 4 && y >= 4 && y <= self.data.len() - 4
    }

    pub fn count_xmas(&self, x: usize, y: usize) -> usize {
        if !self.in_bounds(x, y) {
            return 0;
        }

        self.get_lines(x, y)
            .iter()
            .map(|l| is_xmas(l))
            .filter(|b| *b)
            .count()
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

    for y in 3..grid.data.len() {
        for x in 3..grid.data[0].len() {
            count += grid.count_xmas(x, y);
        }
    }

    count
}

pub fn p1_example() -> usize {
    let grid = get_grid(true);
    let mut count = 0;

    for y in 3..grid.data.len() {
        for x in 3..grid.data[0].len() {
            count += grid.count_xmas(x, y);
        }
    }

    count
}

#[cfg(test)]
mod test {
    use crate::day04::part1::{is_xmas, p1_example, solve};

    use super::get_grid;

    #[test]
    fn test_solve() {
        dbg!(solve());
    }

    #[test]
    fn test_example() {
        let result = p1_example();
        assert_eq!(18, result);
    }

    #[test]
    fn test_is_xmas() {
        assert!(is_xmas(&['X', 'M', 'A', 'S']));
        assert!(!is_xmas(&['M', 'X', 'A', 'S']));
    }

    #[test]
    fn test_in_bounds() {
        let grid = get_grid(true);
        println!("{grid}");
        let len = grid.data.len();
        assert!(!grid.in_bounds(len, len));
        assert!(!grid.in_bounds(len - 1, len - 1));
        assert!(!grid.in_bounds(len - 2, len - 2));
        assert!(!grid.in_bounds(len - 3, len - 3));
        assert!(grid.in_bounds(len - 4, len - 4));

        assert!(!grid.in_bounds(0, 0));
        assert!(!grid.in_bounds(1, 1));
        assert!(!grid.in_bounds(2, 2));
        assert!(!grid.in_bounds(3, 3));
        assert!(grid.in_bounds(4, 4));
        assert!(grid.in_bounds(5, 5));
        assert!(grid.in_bounds(6, 6));
        assert!(!grid.in_bounds(3, 6));
    }
}
