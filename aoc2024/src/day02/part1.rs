use super::into_isize_vec;

/// determines if a given string is safe
fn is_safe(values: &[isize]) -> bool {
    let mut direction = None;
    for w in values.windows(2) {
        let diff = w[1] - w[0];
        if diff == 0 {
            return false;
        }

        if direction.is_none() {
            if diff > 0 {
                direction = Some(true);
            } else {
                direction = Some(false);
            }
        }

        match direction {
            Some(true) if !(1..=3).contains(&diff) => return false,
            Some(false) if !(-3..=-1).contains(&diff) => return false,
            _ => {}
        }
    }

    true
}

pub fn solve() -> isize {
    include_str!("data/data.txt")
        .lines()
        .map(into_isize_vec)
        .fold(0, |acc, v| if is_safe(&v) { acc + 1 } else { acc })
}

#[allow(unused)]
fn p1_example() -> usize {
    include_str!("data/example.txt")
        .lines()
        .map(into_isize_vec)
        .map(|v| is_safe(&v))
        .fold(0, |acc, safe| if safe { acc + 1 } else { acc })
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day, Kind};

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 202, Day::Day02, Kind::Part1);
    }
}
