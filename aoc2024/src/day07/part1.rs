use crate::{data, example};

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

fn evaluate(root_value: usize, target: usize, idx: usize, values: &[usize]) -> bool {
    // entire tree has been traversed
    if values.len() == idx {
        return false;
    }

    let left_value = root_value + values[idx];
    let right_value = root_value * values[idx];
    let is_target = left_value == target || right_value == target;
    let all_values_used = values.len() - 1 == idx;

    if is_target && all_values_used {
        return true;
    }

    evaluate(left_value, target, idx + 1, values) || evaluate(right_value, target, idx + 1, values)
}

#[allow(unused)]
fn aoc_example() -> usize {
    fn sum(acc: usize, (target, values): &(usize, Vec<usize>)) -> usize {
        match evaluate(values[0], *target, 1, values) {
            true => acc + target,
            false => acc,
        }
    }

    parse(example!()).iter().fold(0, sum)
}

pub fn solve() -> usize {
    fn sum(acc: usize, (target, values): &(usize, Vec<usize>)) -> usize {
        match evaluate(values[0], *target, 1, values) {
            true => acc + target,
            false => acc,
        }
    }
    parse(data!()).iter().fold(0, sum)
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day::Day07, Part::Part1};

    use super::{aoc_example, evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 303766880536, Day07(Part1));
    }

    #[test]
    fn test_example() {
        assert_eq!(3749, aoc_example());
    }

    #[test]
    fn test_evaluate() {
        let (target, values) = (190, vec![10, 19]);
        assert!(evaluate(values[0], target, 1, &values));

        let (target, values) = (3267, vec![81, 40, 27]);
        assert!(evaluate(values[0], target, 1, &values));

        let (target, values) = (83, vec![17, 5]);
        assert!(!evaluate(values[0], target, 1, &values));

        let (target, values) = (7290, vec![6, 8, 6, 15]);
        assert!(!evaluate(values[0], target, 1, &values));

        let (target, values) = (161011, vec![16, 10, 13]);
        assert!(!evaluate(values[0], target, 1, &values));

        let (target, values) = (192, vec![17, 8, 14]);
        assert!(!evaluate(values[0], target, 1, &values));

        let (target, values) = (21037, vec![9, 7, 18, 13]);
        assert!(!evaluate(values[0], target, 1, &values));

        let (target, values) = (292, vec![11, 6, 16, 20]);
        assert!(evaluate(values[0], target, 1, &values));
    }
}
