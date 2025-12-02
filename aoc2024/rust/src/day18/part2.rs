use super::{END, Kind, START, get_points, make_grid};
use crate::util::dijkstra::walk;
use crate::util::{Grid, Point};

fn fill_graph(stop_idx: usize, points: &[Point], old_grid: &Grid<Kind>) -> Grid<Kind> {
    let mut new_grid = old_grid.clone();
    let mut idx = 1024;

    loop {
        new_grid[points[idx]] = Kind::Wall;

        if idx == stop_idx {
            break;
        }

        idx += 1;
    }

    new_grid
}

fn search(lo: usize, hi: usize, points: &[Point], old_grid: &Grid<Kind>) -> usize {
    if lo == hi {
        return lo;
    }

    let mid = (lo + hi) >> 1;
    let graph = fill_graph(mid, points, old_grid);

    match walk::<Kind, Kind>(&graph, START, END) {
        Some(_) => search(mid + 1, hi, points, old_grid),
        None => search(lo, mid, points, old_grid),
    }
}

pub fn solve() -> usize {
    let points = get_points();
    let grid = make_grid();

    let idx = search(1024, points.len() - 1, &points, &grid);
    let point = points[idx];

    (point.x * point.y) as usize
}

#[cfg(test)]
mod test {
    use super::solve;

    #[test]
    fn test_solve() {
        dbg!(solve());
    }
}
