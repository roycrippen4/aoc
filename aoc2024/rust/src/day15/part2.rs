#![allow(unused)]

use crate::data;
use crate::util::Grid;

enum Kind {
    Bot,
    Start,
    End,
    Empty,
    Wall,
}

enum Direction {
    Up,
    Down,
    Left,
    Right,
}

fn evaluate(_data: &str) -> usize {
    0
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{Day::Day15, Part::Part2, validate},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
    }

    #[test]
    fn test_evaluate() {
        let result = evaluate(example!());
        dbg!(result);
    }
}
