use crate::data;
use crate::util::quicksort;

fn into_tuple(line: &str) -> (usize, usize) {
    let mut pair = line.split("  ");
    let left = pair.next().unwrap().trim().parse().unwrap();
    let right = pair.next().unwrap().trim().parse().unwrap();
    (left, right)
}

pub fn solve() -> usize {
    let (mut left, mut right): (Vec<_>, Vec<_>) = data!().lines().map(into_tuple).unzip();
    quicksort(&mut left);
    quicksort(&mut right);

    let mut total = 0;
    let mut i = 0;
    loop {
        if i == left.len() {
            break;
        }
        total += left[i].abs_diff(right[i]);
        i += 1;
    }

    total
}

#[cfg(test)]
mod test {
    use super::solve;
    use crate::util::Day::Day01;
    use crate::util::validate;

    #[test]
    fn test_solve() {
        validate(solve, 1506483, Day01);
    }
}
