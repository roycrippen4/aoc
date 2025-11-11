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
        util::{Day::Day16, Part::Part2, validate},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        dbg!(solve());
    }

    #[test]
    fn test_evaluate() {
        let result = evaluate(example!());
        dbg!(result);
    }
}
