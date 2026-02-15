use super::{DESIGNS, count};

pub fn solve() -> usize {
    let mut result = 0;
    for design in DESIGNS {
        if count(design) > 0 {
            result += 1;
        }
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
