use itertools::Itertools;

type Mapping = (usize, Vec<usize>);

fn pretty_print(m: Mapping) {
    let (values, parts) = m;
    println!("{values} => {}", parts.iter().format(", "))
}

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

fn naive(m: Mapping) -> bool {
    let (expected, parts) = m;

    todo!()
}

#[allow(unused)]
fn example() -> usize {
    // get_grid(true).evaluate()
    for (value, parts) in parse(include_str!("data/example.txt")) {
        pretty_print((value, parts));
        // dbg!(value, parts);
    }
    0
}

pub fn solve() -> usize {
    for (value, parts) in parse(include_str!("data/data.txt")) {
        dbg!(value, parts);
    }
    0
}

#[cfg(test)]
mod test {
    #[allow(unused)]
    use crate::util::validate;

    use super::{example, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
        // validate(
        //     solve,
        //     4559,
        //     crate::util::Day::Day07,
        //     crate::util::Kind::Part1,
        // );
    }

    #[test]
    fn test_example() {
        let _ = example();
        // let result = example();
        // assert_eq!(41, result);
    }
}
