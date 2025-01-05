#![allow(unused)]
use std::{
    collections::{HashMap, HashSet},
    fmt,
};

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
                // assert_ne!(direction, Direction::OffMap);
                return (x, y, direction);
            }
        }
    }
    unreachable!() // we should always find a guard
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
struct Point {
    pub x: usize,
    pub y: usize,
}

impl Point {
    pub fn new(x: usize, y: usize) -> Self {
        Self { x, y }
    }
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
            _ => Self::OffMap,
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
struct Grid {
    pub grid: Vec<Vec<char>>,
    guard_pos: Point,
    initial_pos: Point,
    obs_pos: Point,
    direction: Direction,
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
            initial_pos: Point { x, y },
            guard_pos: Point { x, y },
            direction,
            obs_pos: Point::new(0, 0),
        }
    }

    fn reset(&mut self) {
        // self.grid[self.initial_pos.y][self.initial_pos.x] = '^';
        self.guard_pos = self.initial_pos;
        self.direction = Direction::Up;

        // assert_eq!(self.grid[self.obs_pos.y][self.obs_pos.x], '#');
        self.grid[self.obs_pos.y][self.obs_pos.x] = '.';
        self.obs_pos = Point::new(0, 0);

        // for row in &mut self.grid {
        //     for ch in row.iter_mut() {
        //         if *ch == 'X' {
        //             *ch = '.';
        //         }
        //     }
        // }
    }

    /// Inserts a new obstruction.
    ///
    /// Will panic if `pt` contains the following:
    ///   - the guard's initial position
    ///   - An existing obstruction
    ///   - Out of bounds
    pub fn insert_obstruction(&mut self, pt: Point) {
        // assert_ne!(pt, self.initial_pos); // not on guard initial pos
        // assert_ne!(pt.x, self.grid[0].len()); // x in far bounds
        // assert_ne!(pt.x, 0); // x in near bounds
        // assert_ne!(pt.y, self.grid.len()); // y in far bounds
        // assert_ne!(pt.y, 0); // y in near bounds
        self.obs_pos = pt;
        self.grid[pt.y][pt.x] = '#';
    }

    fn get_path(&mut self) -> HashSet<Point> {
        let mut set = HashSet::new();

        while self.direction != Direction::OffMap {
            set.insert(Point::new(self.guard_pos.x, self.guard_pos.y));
            // self.grid[self.guard_pos.y][self.guard_pos.x] = 'X';
            match self.direction {
                Direction::Up => self.move_up(),
                Direction::Down => self.move_down(),
                Direction::Left => self.move_left(),
                Direction::Right => self.move_right(),
                Direction::OffMap => (),
            }
        }

        set.remove(&self.initial_pos);
        self.reset();
        set
    }

    fn is_loop(&mut self, limit: usize) -> bool {
        // assert_eq!(self.guard_pos, self.initial_pos);

        let mut map: HashMap<Point, usize> = HashMap::new();
        map.insert(self.guard_pos, 1);

        while self.direction != Direction::OffMap {
            // self.grid[self.guard_pos.y][self.guard_pos.x] = 'X';

            *map.entry(self.guard_pos).or_insert(1) += 1;
            if map.values().any(|&count| count >= limit) {
                return true;
            }

            match self.direction {
                Direction::Up => self.move_up(),
                Direction::Down => self.move_down(),
                Direction::Left => self.move_left(),
                Direction::Right => self.move_right(),
                Direction::OffMap => (),
            }
        }

        false
    }

    pub fn evaluate(&mut self) -> usize {
        dbg!("eval");
        let mut count = 0;
        let mut iterations = 0;

        let path = self.get_path();
        for pos in self.get_path() {
            iterations += 1;
            self.insert_obstruction(pos);
            if self.is_loop(10) {
                count += 1;
            }
            if iterations % 100 == 0 {
                println!("{}/{} complete", iterations, path.len());
            }
            self.reset();
        }

        count
    }

    fn move_up(&mut self) {
        self.direction = Direction::Up;
        match self.grid[self.guard_pos.y - 1][self.guard_pos.x] {
            '#' => self.direction = Direction::Right,  // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.guard_pos.y -= 1,                // update
        }
    }

    fn move_right(&mut self) {
        self.direction = Direction::Right;
        match self.grid[self.guard_pos.y][self.guard_pos.x + 1] {
            '#' => self.direction = Direction::Down,   // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.guard_pos.x += 1,                // update
        }
    }

    fn move_down(&mut self) {
        self.direction = Direction::Down;
        match self.grid[self.guard_pos.y + 1][self.guard_pos.x] {
            '#' => self.direction = Direction::Left,   // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.guard_pos.y += 1,                // update
        }
    }

    fn move_left(&mut self) {
        self.direction = Direction::Left;
        match self.grid[self.guard_pos.y][self.guard_pos.x - 1] {
            '#' => self.direction = Direction::Up,     // rotate
            'O' => self.direction = Direction::OffMap, // Done
            _ => self.guard_pos.x -= 1,                // update
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

    // let mut grid = get_grid(false);
    // dbg!(grid.get_path().len());
    // 1
}

#[cfg(test)]
mod test {
    use crate::{
        day06::part2::Point,
        util::{self, validate},
    };

    use super::{example, get_grid, solve};

    #[test]
    fn test_solve() {
        validate(solve, 1604, util::Day::Day06, util::Kind::Part1);
    }

    #[test]
    fn test_example() {
        let result = example();
        assert_eq!(6, result);
    }

    #[test]
    fn test_is_loop() {
        let mut grid = get_grid(true);
        grid.insert_obstruction(Point::new(4, 7));
        assert!(grid.is_loop(5));
        grid.reset();
        assert!(!grid.is_loop(5))
    }
}
