use super::{A, B, C, run};

pub fn solve() -> usize {
    run(A, B, C)
        .iter()
        .map(usize::to_string)
        .fold(String::new(), |s1, s2| s1 + &s2)
        .parse()
        .unwrap()
}

#[cfg(test)]
mod test {
    use super::*;
    use crate::util::Day::Day17;
    use crate::util::validate;

    #[test]
    fn test_solve() {
        validate(solve, 657457310, Day17);
    }
}
