use regex::Regex;
use std::sync::LazyLock;

static RE: LazyLock<Regex> = LazyLock::new(|| Regex::new(r"mul\(\d{1,3},\d{1,3}\)").unwrap());

pub fn solve() -> usize {
    include_str!("data/data.txt").lines().map(evaluate).sum()
}

pub fn p1_example() -> usize {
    include_str!("data/example.txt").lines().map(evaluate).sum()
}

fn evaluate(line: &str) -> usize {
    RE.find_iter(line)
        .map(|c| c.as_str())
        .fold(0, |mut acc, s| {
            acc += parse_mul(s);
            acc
        })
}

fn parse_mul(s: &str) -> usize {
    let parts: Vec<_> = s
        .replace("mul", "")
        .replace(['(', ')'], "")
        .split(',')
        .map(|s| s.parse::<usize>().unwrap())
        .collect();

    let [x, y] = [parts[0], parts[1]];
    x * y
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day, Kind};

    use super::{p1_example, parse_mul, solve};

    #[test]
    fn test_solve() {
        validate(solve, 173731097, Day::Day03, Kind::Part1);
    }

    #[test]
    fn test_example() {
        let result = p1_example();
        assert_eq!(161, result)
    }

    #[test]
    fn test_parse_mul() {
        let result = ["mul(2,4)", "mul(5,5)", "mul(11,8)", "mul(8,5)"]
            .iter()
            .fold(0, |mut acc, &s| {
                acc += parse_mul(s);
                acc
            });
        assert_eq!(161, result)
        // validate(func, expected, day, kind)
    }
}
