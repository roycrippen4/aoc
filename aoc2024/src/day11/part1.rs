fn evaluate(data: &str) -> usize {
    dbg!(data);
    0
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::util::{validate, Day::Day11, Part::Part1};

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
        // validate(solve, 517, Day11(Part1));
    }

    #[test]
    fn test_evaluate() {
        let data = include_str!("data/example.txt");
        let result = evaluate(data);
        dbg!(result);
        // assert_eq!(36, result);
    }
}
