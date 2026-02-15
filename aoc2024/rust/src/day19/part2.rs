use super::{DESIGNS, count};

pub fn solve() -> usize {
    let mut result = 0;
    for design in DESIGNS {
        result += count(design)
    }

    result
}

#[cfg(test)]
mod test {
    use super::solve;

    #[test]
    fn test_solve() {
        dbg!(solve());
    }
}
