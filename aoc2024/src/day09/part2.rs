#![allow(unused)]

fn evaluate(data: &str) -> usize {
    0
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
        // validate(solve, 244, Day::Day08, Kind::Part1);
    }

    #[test]
    fn test_evaluate() {
        let data = include_str!("data/example.txt");
        dbg!(evaluate(data));
        // assert_eq!(14, evaluate(data));
    }
}
