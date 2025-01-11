use crate::example;

const fn even_digits(n: usize) -> bool {
    match n {
        0..=9 => false,                      // 1 digit
        10..=99 => true,                     // 2 digits
        100..=999 => false,                  // 3 digits
        1000..=9999 => true,                 // 4 digits
        10000..=99999 => false,              // 5 digits
        100000..=999999 => true,             // 6 digits
        1000000..=9999999 => false,          // 7 digits
        10000000..=99999999 => true,         // 8 digits
        100000000..=999999999 => false,      // 9 digits
        1000000000..=9999999999 => true,     // 10 digits
        10000000000..=99999999999 => true,   // 11 digits
        100000000000..=999999999999 => true, // 12 digits
        _ => unreachable!(),                 // Fallback for extremely large numbers
    }
}

fn parse_data(data: &str) -> Vec<usize> {
    data.split_whitespace()
        .filter_map(|s| s.parse().ok())
        .collect()
}

fn evaluate(data: &str) -> usize {
    dbg!(data);
    0
}

pub fn solve() -> usize {
    evaluate(example!())
}

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day11, Part::Part1},
    };

    use super::{evaluate, even_digits, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
        // validate(solve, 517, Day11(Part1));
    }

    #[test]
    fn test_parse_data() {
        let data = example!();
    }

    #[test]
    fn test_evaluate() {
        let data = example!();
        let result = evaluate(data);
        dbg!(result);
        // assert_eq!(36, result);
    }

    #[test]
    fn test_even_digits() {
        assert!(!even_digits(101));
        assert!(even_digits(1010));
        assert!(!even_digits(10101));
    }
}
