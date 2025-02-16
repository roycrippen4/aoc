use crate::data;

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

pub fn solve() -> usize {
    data!()
        .lines()
        .map(into_isize_vec)
        .fold(0, |acc, v| if is_safe(&v) { acc + 1 } else { acc })
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day::Day02, Part::Part1};

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 202, Day02(Part1));
    }
}
