pub fn solve() -> usize {
    // include_str!("../data/day03/data.txt")
    //     .chars()
    //     .filter(|c| !c.is_whitespace())
    //     .collect::<String>()
    //     .evaluate()
    1
}

pub fn p2_example() -> usize {
    // include_str!("../data/day03/example-part2.txt")
    //     .lines()
    //     .map(evaluate)
    //     .sum()
    1
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day, Kind};

    use super::{evaluate, p2_example, parse_mul, solve, RE};

    #[test]
    fn test_solve() {
        validate(solve, 93729253, Day::Day03, Kind::Part1);
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
