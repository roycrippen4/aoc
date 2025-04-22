pub mod part1;
pub mod part2;

#[derive(Clone, Copy, Debug, PartialEq)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

impl From<char> for Direction {
    fn from(ch: char) -> Self {
        match ch {
            '^' => Self::Up,
            '>' => Self::Right,
            '<' => Self::Left,
            'v' => Self::Down,
            _ => unreachable!(),
        }
    }
}

#[derive(Copy, Clone, Debug, PartialEq, PartialOrd, Eq, Ord)]
enum Kind {
    Robot, // '@'
    Box,   // 'O'
    Empty, // '.'
    Wall,  // '#'
}

impl From<char> for Kind {
    fn from(ch: char) -> Self {
        match ch {
            '@' => Self::Robot,
            'O' => Self::Box,
            '.' => Self::Empty,
            '#' => Self::Wall,
            _ => unreachable!("Invalid character found"),
        }
    }
}

impl From<&char> for Kind {
    fn from(ch: &char) -> Self {
        match ch {
            '@' => Self::Robot,
            'O' => Self::Box,
            '.' => Self::Empty,
            '#' => Self::Wall,
            _ => unreachable!("Invalid character found"),
        }
    }
}

impl From<&Kind> for char {
    fn from(kind: &Kind) -> Self {
        match kind {
            Kind::Robot => '@',
            Kind::Box => 'O',
            Kind::Empty => '.',
            Kind::Wall => '#',
        }
    }
}

impl From<Kind> for char {
    fn from(kind: Kind) -> Self {
        match kind {
            Kind::Robot => '@',
            Kind::Box => 'O',
            Kind::Empty => '.',
            Kind::Wall => '#',
        }
    }
}
