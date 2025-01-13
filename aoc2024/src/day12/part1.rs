use crate::data;

fn evaluate(data: &str) -> usize {
    dbg!(data);
    0
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day12, Part::Part1},
    };

    use super::{evaluate, solve};

    static SIMPLE: &str = r"AAAA
BBCD
BBCC
EEEC";

    #[test]
    fn test_solve() {
        dbg!(solve());
    }

    #[test]
    fn test_evaluate() {
        let data = example!();
        let result = evaluate(data);
        dbg!(result);
    }
}
