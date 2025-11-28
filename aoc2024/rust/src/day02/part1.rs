use crate::data;

use super::into_isize_vec;

/// determines if a given string is safe
fn is_safe(values: &[isize]) -> bool {
    let direction = values[1] - values[0] > 0;
    for w in values.windows(2) {
        let diff = w[1] - w[0];
        if diff == 0 || diff.abs() > 3 || (diff > 0) != direction {
            return false;
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
    use crate::util::{Day::Day02, validate};

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 202, Day02);
    }
}
