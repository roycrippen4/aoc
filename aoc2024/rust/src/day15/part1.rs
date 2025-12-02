use std::fmt::Display;

use super::{Direction, Kind};
use crate::data;

struct Grid {
    data: Vec<Vec<Kind>>,
    bot_x: usize,
    bot_y: usize,
}

#[allow(clippy::needless_range_loop)]
fn get_bot_pos(data: &[Vec<Kind>]) -> (usize, usize) {
    for y in 0..data.len() {
        for x in 0..data[0].len() {
            if data[y][x] == Kind::Robot {
                return (x, y);
            }
        }
    }

    unreachable!("Failed to find robot position!")
}

impl Grid {
    pub fn new(input: &str) -> Self {
        let lines: Vec<_> = input
            .lines()
            .filter(|l| !l.chars().all(|c| c == '#'))
            .collect();
        let data: Vec<_> = lines
            .iter()
            .map(|l| {
                l.chars()
                    .skip(1)
                    .take(lines[0].len() - 2)
                    .map(Kind::from)
                    .collect::<Vec<Kind>>()
            })
            .collect();
        let (bot_x, bot_y) = get_bot_pos(&data);

        Self { data, bot_x, bot_y }
    }

    fn move_bot(&mut self, x: usize, y: usize) {
        self.data[self.bot_y][self.bot_x] = Kind::Empty;
        self.data[y][x] = Kind::Robot;
        self.bot_x = x;
        self.bot_y = y;
    }

    fn move_right(&mut self, x: usize) {
        if x != self.data[0].len() - 1 {
            match self.data[self.bot_y][x + 1] {
                Kind::Box => self.move_right(x + 1),
                Kind::Empty => {
                    self.move_bot(self.bot_x + 1, self.bot_y);
                    self.data[self.bot_y][x + 1] = Kind::Box;
                }
                _ => (),
            }
        }
    }

    fn move_left(&mut self, x: usize) {
        if x != 0 {
            match self.data[self.bot_y][x - 1] {
                Kind::Box => self.move_left(x - 1),
                Kind::Empty => {
                    self.move_bot(self.bot_x - 1, self.bot_y);
                    self.data[self.bot_y][x - 1] = Kind::Box;
                }
                _ => (),
            }
        }
    }

    fn move_up(&mut self, y: usize) {
        if y != 0 {
            match self.data[y - 1][self.bot_x] {
                Kind::Box => self.move_up(y - 1),
                Kind::Empty => {
                    self.move_bot(self.bot_x, self.bot_y - 1);
                    self.data[y - 1][self.bot_x] = Kind::Box;
                }
                _ => (),
            }
        }
    }

    fn move_down(&mut self, y: usize) {
        if y != self.data.len() - 1 {
            match self.data[y + 1][self.bot_x] {
                Kind::Box => self.move_down(y + 1),
                Kind::Empty => {
                    self.move_bot(self.bot_x, self.bot_y + 1);
                    self.data[y + 1][self.bot_x] = Kind::Box;
                }
                _ => (),
            }
        }
    }

    pub fn next(&mut self, dir: Direction) {
        let up_ok = self.bot_y != 0;
        let down_ok = self.bot_y != self.data.len() - 1;
        let left_ok = self.bot_x != 0;
        let right_ok = self.bot_x != self.data[0].len() - 1;
        match dir {
            Direction::Up if up_ok => match self.data[self.bot_y - 1][self.bot_x] {
                Kind::Box => self.move_up(self.bot_y - 1),
                Kind::Empty => self.move_bot(self.bot_x, self.bot_y - 1),
                _ => (),
            },
            Direction::Down if down_ok => match self.data[self.bot_y + 1][self.bot_x] {
                Kind::Box => self.move_down(self.bot_y + 1),
                Kind::Empty => self.move_bot(self.bot_x, self.bot_y + 1),
                _ => (),
            },
            Direction::Left if left_ok => match self.data[self.bot_y][self.bot_x - 1] {
                Kind::Box => self.move_left(self.bot_x - 1),
                Kind::Empty => self.move_bot(self.bot_x - 1, self.bot_y),
                _ => (),
            },
            Direction::Right if right_ok => match self.data[self.bot_y][self.bot_x + 1] {
                Kind::Box => self.move_right(self.bot_x + 1),
                Kind::Empty => self.move_bot(self.bot_x + 1, self.bot_y),
                _ => (),
            },
            _ => (),
        }
    }
}

impl Display for Grid {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let pad: String = std::iter::repeat_n('#', self.data[0].len() + 2).collect();
        writeln!(f, "{pad}")?;

        for y in 0..self.data.len() {
            let mut line = String::from('#');
            for x in 0..self.data[y].len() {
                line.push(char::from(self.data[y][x]));
            }

            line.push('#');
            writeln!(f, "{line}")?;
        }

        writeln!(f, "{pad}")
    }
}

fn parse_input(input: &str) -> (Grid, Vec<Direction>) {
    let (grid_part, dir_part) = input.split_once("\n\n").unwrap();
    let grid = Grid::new(grid_part);
    let directions = dir_part
        .chars()
        .filter(|c| !c.is_whitespace())
        .map(Direction::from)
        .collect();

    (grid, directions)
}

fn evaluate(data: &str) -> usize {
    let (mut grid, directions) = parse_input(data);
    for d in directions {
        grid.next(d);
    }

    let mut result = 0;
    for y in 0..grid.data.len() {
        for x in 0..grid.data[0].len() {
            if grid.data[y][x] == Kind::Box {
                let score = 100 * (y + 1) + (x + 1);
                result += score;
            }
        }
    }

    result
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use super::{Direction, Grid, Kind, evaluate, solve};
    use crate::example;
    use crate::util::Day::Day15;
    use crate::util::validate;

    #[test]
    fn test_solve() {
        validate(solve, 1526673, Day15);
    }

    #[test]
    fn test_evaluate() {
        assert_eq!(evaluate(example!()), 10092)
    }

    #[test]
    fn test_evaluate_simple() {
        assert_eq!(evaluate(SIMPLE), 2028)
    }

    #[test]
    fn up_multi_box() {
        let mut grid = Grid::new(
            "
########
#......#
#...O..#
#...O..#
#...@..#
#......#
#......#
########",
        );
        assert_eq!((grid.bot_x, grid.bot_y), (3, 3));
        assert_eq!(grid.data[1][3], Kind::Box);
        assert_eq!(grid.data[2][3], Kind::Box);
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 2));
        assert_eq!(grid.data[0][3], Kind::Box);
        assert_eq!(grid.data[1][3], Kind::Box);
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 2));
        assert_eq!(grid.data[0][3], Kind::Box);
        assert_eq!(grid.data[1][3], Kind::Box);
    }

    #[test]
    fn up_single_box() {
        let mut grid = Grid::new(
            "
########
#......#
#...O..#
#......#
#...@..#
#......#
#......#
########",
        );
        assert_eq!((grid.bot_x, grid.bot_y), (3, 3));
        assert_eq!(grid.data[1][3], Kind::Box);
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 2));
        assert_eq!(grid.data[1][3], Kind::Box);
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 1));
        assert_eq!(grid.data[0][3], Kind::Box);
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 1));
        assert_eq!(grid.data[0][3], Kind::Box);
    }

    #[test]
    fn up_no_box() {
        let mut grid = Grid::new(
            "
########
#......#
#......#
#......#
#...@..#
#......#
#......#
########",
        );

        assert_eq!((grid.bot_x, grid.bot_y), (3, 3));
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 2));
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 1));
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        grid.next(Direction::Up);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
    }

    #[test]
    fn down_multi_box() {
        let mut grid = Grid::new(
            "
########
#......#
#......#
#...@..#
#...O..#
#...O..#
#......#
########",
        );

        assert_eq!((grid.bot_x, grid.bot_y), (3, 2));
        assert_eq!(grid.data[4][3], Kind::Box);
        assert_eq!(grid.data[3][3], Kind::Box);
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 3));
        assert_eq!(grid.data[4][3], Kind::Box);
        assert_eq!(grid.data[5][3], Kind::Box);
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 3));
        assert_eq!(grid.data[4][3], Kind::Box);
        assert_eq!(grid.data[5][3], Kind::Box);
    }

    #[test]
    fn down_single_box() {
        let mut grid = Grid::new(
            "
########
#......#
#......#
#...@..#
#......#
#...O..#
#......#
########",
        );

        assert_eq!((grid.bot_x, grid.bot_y), (3, 2));
        assert_eq!(grid.data[4][3], Kind::Box);
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 3));
        assert_eq!(grid.data[4][3], Kind::Box);
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 4));
        assert_eq!(grid.data[5][3], Kind::Box);
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 4));
        assert_eq!(grid.data[5][3], Kind::Box);
    }

    #[test]
    fn down_no_box() {
        let mut grid = Grid::new(
            "
########
#......#
#......#
#...@..#
#......#
#......#
#......#
########",
        );

        assert_eq!((grid.bot_x, grid.bot_y), (3, 2));
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 3));
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 4));
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 5));
        grid.next(Direction::Down);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 5));
    }

    #[test]
    fn left_multiple_box() {
        let mut grid = Grid::new(
            "
########
#.O.O.@#
########",
        );
        assert_eq!(grid.data[0][1], Kind::Box);
        assert_eq!(grid.data[0][3], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (5, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][1], Kind::Box);
        assert_eq!(grid.data[0][3], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (4, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][1], Kind::Box);
        assert_eq!(grid.data[0][2], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][0], Kind::Box);
        assert_eq!(grid.data[0][1], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (2, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][0], Kind::Box);
        assert_eq!(grid.data[0][1], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (2, 0));
    }

    #[test]
    fn left_single_box() {
        let mut grid = Grid::new(
            "
########
#..O.@.#
########",
        );
        assert_eq!(grid.data[0][2], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (4, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][2], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][1], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (2, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][0], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (1, 0));
        grid.next(Direction::Left);
        assert_eq!(grid.data[0][0], Kind::Box);
        assert_eq!((grid.bot_x, grid.bot_y), (1, 0));
    }

    #[test]
    fn right_multiple_box() {
        let mut grid = Grid::new(
            "
########
#@.O.O.#
########",
        );
        assert_eq!((grid.bot_x, grid.bot_y), (0, 0));
        assert_eq!(grid.data[0][2], Kind::Box);
        assert_eq!(grid.data[0][4], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (1, 0));
        assert_eq!(grid.data[0][2], Kind::Box);
        assert_eq!(grid.data[0][4], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (2, 0));
        assert_eq!(grid.data[0][3], Kind::Box);
        assert_eq!(grid.data[0][4], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        assert_eq!(grid.data[0][4], Kind::Box);
        assert_eq!(grid.data[0][5], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        assert_eq!(grid.data[0][4], Kind::Box);
        assert_eq!(grid.data[0][5], Kind::Box);
    }

    #[test]
    fn right_single_box() {
        let mut grid = Grid::new(
            "
########
#@.O...#
########",
        );
        assert_eq!((grid.bot_x, grid.bot_y), (0, 0));
        assert_eq!(grid.data[0][2], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (1, 0));
        assert_eq!(grid.data[0][2], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (2, 0));
        assert_eq!(grid.data[0][3], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        assert_eq!(grid.data[0][4], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (4, 0));
        assert_eq!(grid.data[0][5], Kind::Box);
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (4, 0));
        assert_eq!(grid.data[0][5], Kind::Box);
    }

    #[test]
    fn right_no_box() {
        let mut grid = Grid::new(
            "
########
#@.....#
########",
        );
        assert_eq!((grid.bot_x, grid.bot_y), (0, 0));
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (1, 0));
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (2, 0));
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (4, 0));
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (5, 0));
        grid.next(Direction::Right);
        assert_eq!((grid.bot_x, grid.bot_y), (5, 0));
    }

    #[test]
    fn left_no_box() {
        let mut grid = Grid::new(
            "
########
#....@.#
########",
        );
        assert_eq!((grid.bot_x, grid.bot_y), (4, 0));
        grid.next(Direction::Left);
        assert_eq!((grid.bot_x, grid.bot_y), (3, 0));
        grid.next(Direction::Left);
        assert_eq!((grid.bot_x, grid.bot_y), (2, 0));
        grid.next(Direction::Left);
        assert_eq!((grid.bot_x, grid.bot_y), (1, 0));
        grid.next(Direction::Left);
        assert_eq!((grid.bot_x, grid.bot_y), (0, 0));
        grid.next(Direction::Left);
        assert_eq!((grid.bot_x, grid.bot_y), (0, 0));
    }

    #[test]
    fn parse_directions() {
        let directions: Vec<_> = "<^^>>>vv<v>>v<<"
            .trim()
            .chars()
            .map(Direction::from)
            .collect();

        assert_eq!(
            vec![
                Direction::Left,
                Direction::Up,
                Direction::Up,
                Direction::Right,
                Direction::Right,
                Direction::Right,
                Direction::Down,
                Direction::Down,
                Direction::Left,
                Direction::Down,
                Direction::Right,
                Direction::Right,
                Direction::Down,
                Direction::Left,
                Direction::Left,
            ],
            directions
        );
    }

    const SIMPLE: &str = "
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<";
}
