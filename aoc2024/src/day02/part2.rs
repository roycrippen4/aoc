use super::into_isize_vec;

fn expand(values: &[isize]) -> Vec<Vec<isize>> {
    (0..values.len())
        .map(|i| {
            let mut minus_one = Vec::with_capacity(values.len() - 1);
            minus_one.extend_from_slice(&values[..i]);
            minus_one.extend_from_slice(&values[i + 1..]);
            minus_one
        })
        .collect()
}

fn validate(values: &[isize]) -> bool {
    values.windows(2).all(|window| {
        let diff = window[0] - window[1];
        (-3..=-1).contains(&diff)
    }) || values.windows(2).all(|window| {
        let diff = window[0] - window[1];
        (1..=3).contains(&diff)
    })
}

fn is_safe(values: &[isize]) -> bool {
    validate(values) || expand(values).iter().any(|v| validate(v))
}

pub fn solve() -> usize {
    include_str!("../data/day02/data.txt")
        .lines()
        .map(into_isize_vec)
        .fold(0, |acc, v| if is_safe(&v) { acc + 1 } else { acc })
}

#[cfg(test)]
mod test {
    use crate::day02::into_isize_vec;

    use super::is_safe;

    #[test]
    fn test_is_safe() {
        let result = include_str!("../data/day02/data.txt")
            .lines()
            .map(into_isize_vec)
            .filter(|v| is_safe(v))
            .collect::<Vec<_>>()
            .len();
        dbg!(result);
    }
}
