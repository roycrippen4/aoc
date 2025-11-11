#![allow(unused)]

use super::Grid;
use crate::data;
use crate::util::Point;

fn evaluate(data: &str) -> usize {
    let mut grid = Grid::new(data);
    // let mut seen =
    dbg!(data);
    0
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::example;
    use crate::util::{Day::Day16, Part::Part1, validate};

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
