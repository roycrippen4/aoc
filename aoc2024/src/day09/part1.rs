use std::iter;

use crate::util::StringMethods;

#[allow(unused)]
fn pretty_print(values: &[Option<usize>]) {
    let to_string = |v: &Option<usize>| match v {
        Some(v) => v.to_string(),
        None => ".".to_string(),
    };
    println!("{}", values.iter().map(to_string).collect::<String>());
}

fn expand(data: Vec<usize>) -> Vec<Option<usize>> {
    data.iter()
        .enumerate()
        .flat_map(|(i, &n)| {
            if i % 2 == 0 {
                iter::repeat_n(Some(i / 2), n).collect::<Vec<_>>()
            } else {
                iter::repeat_n(None, n).collect::<Vec<_>>()
            }
        })
        .collect()
}

fn evaluate(data: &str) -> usize {
    let data = expand(data.to_string().tsfp(""));
    let mut id = 0;
    let mut result = 0;
    let mut i = 0;
    let mut j = data.len() - 1;

    while i <= j {
        if let Some(next) = data[i] {
            result += id * next;
            id += 1;
        } else {
            while i <= j {
                if let Some(next) = data[j] {
                    result += id * next;
                    id += 1;
                    j -= 1;
                    break;
                }
                j -= 1
            }
        }
        i += 1;
    }
    result
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[allow(unused)]
#[cfg(test)]
mod test {

    use crate::{
        day09::part1::{expand, pretty_print},
        util::{validate, Day, Kind, StringMethods},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 6448989155953, Day::Day09, Kind::Part1);
    }

    #[test]
    fn test_evaluate_simple() {
        let data = "12345";
        dbg!(evaluate(data));
        // assert_eq!(14, evaluate(data));
    }

    #[test]
    fn test_evaluate() {
        let data = include_str!("data/example.txt");
        dbg!(evaluate(data));
    }

    #[test]
    fn test_expand() {
        let input = "12345".to_string().tsfp("");
        let result = expand(input);
        let expected = [
            Some(0),
            None,
            None,
            Some(1),
            Some(1),
            Some(1),
            None,
            None,
            None,
            None,
            Some(2),
            Some(2),
            Some(2),
            Some(2),
            Some(2),
        ];
        assert_eq!(result, expected);

        let input = "2333133121414131402".to_string().tsfp("");
        let result = expand(input);
        let expected = [
            Some(0),
            Some(0),
            None,
            None,
            None,
            Some(1),
            Some(1),
            Some(1),
            None,
            None,
            None,
            Some(2),
            None,
            None,
            None,
            Some(3),
            Some(3),
            Some(3),
            None,
            Some(4),
            Some(4),
            None,
            Some(5),
            Some(5),
            Some(5),
            Some(5),
            None,
            Some(6),
            Some(6),
            Some(6),
            Some(6),
            None,
            Some(7),
            Some(7),
            Some(7),
            None,
            Some(8),
            Some(8),
            Some(8),
            Some(8),
            Some(9),
            Some(9),
        ];
        assert_eq!(result, expected);
    }
}
