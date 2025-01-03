#[allow(unused)]
fn example() -> usize {
    // let input: Vec<String> = include_str!("../data/day06/example.txt")
    //     .split("\n\n")
    //     .map(String::from)
    //     .collect();
    1
}

pub fn solve() -> usize {
    // let input: Vec<String> = include_str!("../data/day06/data.txt")
    //     .split("\n\n")
    //     .map(String::from)
    //     .collect();
    1
}

#[cfg(test)]
mod test {
    // use crate::util::validate;

    use super::{example, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
        // validate(
        //     solve,
        //     7198,
        //     crate::util::Day::Day05,
        //     crate::util::Kind::Part1,
        // );
    }

    #[test]
    fn test_example() {
        let result = example();
        dbg!(result);
        // assert_eq!(143, result);
    }
}
