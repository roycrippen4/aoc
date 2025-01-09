fn evaluate(data: &str) -> usize {
    println!("{data}");
    0
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[allow(unused)]
#[cfg(test)]
mod test {

    use crate::util::{validate, Day::Day10, Part::Part2};

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        // validate(solve, 6448989155953, Day10(Part1));
    }

    #[test]
    fn test_evaluate() {
        // let data = include_str!("data/example.txt");
        // dbg!(evaluate(data));
    }
}
