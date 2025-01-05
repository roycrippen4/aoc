// fn get_grid(example: bool) -> Grid {
//     let input = match example {
//         true => include_str!("data/example.txt"),
//         false => include_str!("data/data.txt"),
//     };
//     Grid::new(input.lines().collect())
// }

#[allow(unused)]
fn example() -> usize {
    // get_grid(true).evaluate()
    0
}

pub fn solve() -> usize {
    // get_grid(false).evaluate()
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
        //     crate::util::Day::Day06,
        //     crate::util::Kind::Part1,
        // );
    }

    #[test]
    fn test_example() {
        dbg!(example());
        // let result = example();
        // assert_eq!(41, result);
    }
}
