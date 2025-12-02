use std::collections::VecDeque;

use super::{AREA, START, State, dfs, index};
use crate::data;

fn evaluate(data: &str) -> usize {
    let grid: Vec<_> = data.lines().flat_map(|l| l.chars()).collect();
    let mut seen = [[usize::MAX; 4]; AREA];
    let mut first: VecDeque<State> = VecDeque::new();
    let mut second: VecDeque<State> = VecDeque::new();
    let mut lowest: usize = usize::MAX;

    first.push_back((START, 0, 0));
    seen[index(START)][0] = 0;

    while !first.is_empty() {
        dfs(&mut first, &mut second, &mut lowest, &mut seen, &grid);
        std::mem::swap(&mut first, &mut second);
    }

    lowest
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use super::solve;
    use crate::util::Day::Day16;
    use crate::util::validate;

    #[test]
    fn test_solve() {
        validate(solve, 133584, Day16);
    }
}
