use super::Kind;
use crate::day18::{END, START, make_grid};
use crate::util::dijkstra::walk;

pub fn solve() -> usize {
    walk::<Kind, Kind>(&make_grid(), START, END).unwrap().len() - 1
}

#[cfg(test)]
mod test {
    use super::solve;

    #[test]
    fn test_solve() {
        dbg!(solve());
    }
}
