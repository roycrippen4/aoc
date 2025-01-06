use rayon::prelude::*;

type Mapping = (usize, Vec<usize>);

fn parse_line(l: &str) -> Mapping {
    let (value, parts) = l.split_once(':').unwrap();
    let value = value.trim().parse().unwrap();
    let parts = parts
        .split_whitespace()
        .filter(|s| !s.is_empty())
        .map(|s| s.parse().unwrap())
        .collect();
    (value, parts)
}

fn parse(input: &str) -> Vec<Mapping> {
    input.lines().map(parse_line).collect()
}

#[inline]
fn concatenate_usize(root_value: usize, next_value: usize) -> usize {
    let mut multiplier = 1;
    let mut temp = next_value;
    while temp > 0 {
        multiplier *= 10;
        temp /= 10;
    }
    root_value * multiplier + next_value
}

fn evaluate(root_value: usize, target: usize, idx: usize, values: &[usize]) -> bool {
    if values.len() == idx {
        return false;
    }

    let next_value = values[idx];
    let plus_value = root_value + next_value;
    let concat_value = concatenate_usize(root_value, next_value);
    let mul_value = root_value * next_value;
    let is_target = plus_value == target || mul_value == target || concat_value == target;
    let all_values_used = values.len() - 1 == idx;

    if is_target && all_values_used {
        return true;
    }

    evaluate(plus_value, target, idx + 1, values)
        || evaluate(concat_value, target, idx + 1, values)
        || evaluate(mul_value, target, idx + 1, values)
}

#[allow(unused)]
fn example() -> usize {
    fn sum(acc: usize, (target, values): &(usize, Vec<usize>)) -> usize {
        match evaluate(values[0], *target, 1, values) {
            true => acc + target,
            false => acc,
        }
    }

    parse(include_str!("data/example.txt")).iter().fold(0, sum)
}

pub fn solve() -> usize {
    fn sum(acc: usize, (target, values): (usize, Vec<usize>)) -> usize {
        match evaluate(values[0], target, 1, &values) {
            true => acc + target,
            false => acc,
        }
    }

    parse(include_str!("data/data.txt"))
        .into_par_iter()
        .fold(|| 0, sum)
        .sum()
}

#[cfg(test)]
mod test {
    use crate::util::{perf, validate, Day, Kind};

    use super::{example, solve};

    #[test]
    fn test_solve() {
        validate(solve, 337041851384440, Day::Day07, Kind::Part2);
    }

    #[test]
    fn test_example() {
        assert_eq!(11387, example());
    }

    #[test]
    fn test_perf() {
        perf(solve, 500);
    }
}
