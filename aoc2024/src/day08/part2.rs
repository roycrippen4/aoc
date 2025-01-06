#![allow(unused)]
use crate::util::{create_pad, StringMethods};

type Mapping = (usize, Vec<usize>);

fn into_padded_string(str: &&str) -> String {
    let mut s = str.to_string();
    s.pad(4, '.');
    s
}

#[derive(Debug)]
struct Grid {
    data: Vec<Vec<char>>,
}

impl Grid {
    pub fn new(data: Vec<&str>) -> Self {
        let mut data: Vec<String> = data.iter().map(into_padded_string).collect();
        let row_len = data[0].len();
        let pad = create_pad(row_len, '.');
        (0..4).for_each(|_| data.insert(0, pad.clone()));
        let col_len = data.len();
        (0..4).for_each(|_| data.insert(col_len, pad.clone()));
        Self {
            data: data.iter().map(|r| r.to_char_vec()).collect(),
        }
    }
}

#[allow(unused)]
fn example(data: &str) -> usize {
    0
}

pub fn solve() -> usize {
    // include_str!("data/data.txt");
    0
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day, Kind};

    use super::{example, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
        // validate(solve, 303766880536, Day::Day07, Kind::Part1);
    }

    #[test]
    fn test_example() {
        let data = include_str!("data/example.txt");
        let _ = example(data);
        // assert_eq!(3749, example());
    }

    #[test]
    fn test_simple_example() {
        let data = include_str!("./data/example-simple.txt");
        let _ = example(data);
        // assert_eq!(3749, example());
    }
    #[test]
    fn test_simple_example2() {
        let data = include_str!("./data/example-simple2.txt");
        let _ = example(data);
        // assert_eq!(3749, example());
    }
}
