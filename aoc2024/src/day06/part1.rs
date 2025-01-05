use std::fmt;

use crate::util::StringMethods;

fn into_padded_string(str: &&str) -> String {
    let mut s = str.to_string();
    s.pad(1, 'O');
    s
}

#[allow(clippy::needless_range_loop)]
/// returns (x, y) coordinates and direction of the guard's starting position
fn find_guard(grid: &[Vec<char>]) -> (usize, usize, Direction) {
    let row_len = grid[0].len();
    let col_len = grid.len();

    for y in 0..col_len {
        for x in 0..row_len {
            let ch = grid[y][x];
            if ['^', '>', '<', 'v', '9'].contains(&ch) {
                let direction = Direction::from(ch);
                assert_ne!(direction, Direction::OffMap);
                return (x, y, direction);
            }
        }
    }
    unreachable!() // we should always find a guard
}

#[derive(Clone, Copy, Debug, PartialEq)]
struct Point {
    pub x: usize,
    pub y: usize,
}

#[derive(Clone, Copy, Debug, PartialEq)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
    OffMap,
}

impl From<char> for Direction {
    fn from(ch: char) -> Self {
        match ch {
            '^' => Self::Up,
            '>' => Self::Right,
            '<' => Self::Left,
            'v' => Self::Down,
            '9' => Self::OffMap,
            _ => unreachable!(),
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
struct Grid {
    pub grid: Vec<Vec<char>>,
    pub pos: Point,
    pub direction: Direction,
}

impl Grid {
    pub fn new(data: Vec<&str>) -> Self {
        let mut data: Vec<_> = data.iter().map(into_padded_string).collect();
        data.insert(0, "O".repeat(data[0].len()));
        data.insert(data.len(), "O".repeat(data[0].len()));
        let grid: Vec<_> = data.iter().map(|r| r.to_char_vec()).collect();
        let (x, y, direction) = find_guard(&grid);
        Self {
            grid,
            pos: Point { x, y },
            direction,
        }
    }

    pub fn evaluate(&mut self) -> usize {
        while self.direction != Direction::OffMap {
            self.grid[self.pos.y][self.pos.x] = 'X';
            match self.direction {
                Direction::Up => self.move_up(),
                Direction::Down => self.move_down(),
                Direction::Left => self.move_left(),
                Direction::Right => self.move_right(),
                Direction::OffMap => (),
            }
        }

        self.grid
            .iter()
            .flat_map(|row| row.iter())
            .filter(|&&char| char == 'X')
            .count()
    }

    fn move_up(&mut self) {
        self.direction = Direction::Up;
        match self.grid[self.pos.y - 1][self.pos.x] {
            '#' => self.direction = Direction::Right,  // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.pos.y -= 1,                      // update
        }
    }

    fn move_right(&mut self) {
        self.direction = Direction::Right;
        match self.grid[self.pos.y][self.pos.x + 1] {
            '#' => self.direction = Direction::Down,   // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.pos.x += 1,                      // update
        }
    }

    fn move_down(&mut self) {
        self.direction = Direction::Down;
        match self.grid[self.pos.y + 1][self.pos.x] {
            '#' => self.direction = Direction::Left,   // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.pos.y += 1,                      // update
        }
    }

    fn move_left(&mut self) {
        self.direction = Direction::Left;
        match self.grid[self.pos.y][self.pos.x - 1] {
            '#' => self.direction = Direction::Up,     // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.pos.x -= 1,                      // update
        }
    }
}

impl fmt::Display for Grid {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let printable: String = self
            .grid
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

#[allow(unused)]
fn example() -> usize {
    get_grid(true).evaluate()
}

pub fn solve() -> usize {
    get_grid(false).evaluate()
}

#[cfg(test)]
mod test {
    use crate::util::validate;

    use super::{example, solve};

    #[test]
    fn test_solve() {
        validate(
            solve,
            4559,
            crate::util::Day::Day06,
            crate::util::Kind::Part1,
        );
    }

    #[test]
    fn test_example() {
        let result = example();
        assert_eq!(41, result);
    }
}
