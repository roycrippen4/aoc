use regex::Regex;
use std::sync::LazyLock;

static RE: LazyLock<Regex> =
    LazyLock::new(|| Regex::new(r"do\(\)|don't\(\)|mul\(\d{1,3},\d{1,3}\)").unwrap());

trait Eval {
    fn evaluate(&self) -> usize;
}

impl Eval for String {
    fn evaluate(&self) -> usize {
        evaluate(self)
    }
}

enum Op {
    Start,
    Stop,
}

impl TryFrom<&str> for Op {
    type Error = &'static str;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "don't()" => Ok(Self::Stop),
            "do()" => Ok(Self::Start),
            _ => Err("failed to parse"),
        }
    }
}

pub fn solve() -> usize {
    include_str!("data/data.txt")
        .chars()
        .filter(|c| !c.is_whitespace())
        .collect::<String>()
        .evaluate()
}

pub fn p2_example() -> usize {
    include_str!("data/example-part2.txt")
        .lines()
        .map(evaluate)
        .sum()
}

fn evaluate(line: &str) -> usize {
    let trimmed: String = line.chars().filter(|c| !c.is_whitespace()).collect();
    let ops: Vec<_> = RE.find_iter(&trimmed).map(|c| c.as_str()).collect();
    let mut execute = true;
    let mut result = 0;

    for op in ops {
        if let Ok(op) = Op::try_from(op) {
            execute = match op {
                Op::Start => true,
                Op::Stop => false,
            };
            continue;
        }

        if execute {
            result += parse_mul(op)
        }
    }

    result
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

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::util::{validate, Day::Day03, Part::Part2};

    use super::{evaluate, p2_example, parse_mul, solve, RE};

    #[test]
    fn test_solve() {
        validate(solve, 93729253, Day03(Part2));
    }

    #[test]
    fn test_example() {
        let result = p2_example();
        assert_eq!(48, result)
    }

    #[test]
    fn test_evaluate() {
        let input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
        evaluate(input);
    }
}
