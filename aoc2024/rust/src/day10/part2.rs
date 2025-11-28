use super::{find_starting_points, make_grid};
use crate::util::{Entry, Grid};
use crate::{DIRECTIONS, data};

fn neighbors(point: Entry<usize>, grid: &Grid<usize>) -> [Option<Entry<usize>>; 4] {
    let (x, y, v) = point;
    let t = v + 1;
    let h = grid.height as isize;
    let w = grid.width as isize;

    let mut ns = [None; 4];
    let mut i = 0;

    for (dx, dy) in DIRECTIONS {
        let nx = x as isize + dx;
        let ny = y as isize + dy;
        if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let (nx, ny) = (nx as usize, ny as usize);
            if grid[(nx, ny)] == t {
                ns[i] = Some((nx, ny, grid[(nx, ny)]));
                i += 1;
            }
        }
    }

    ns
}

fn score_path(start: Option<Entry<usize>>, grid: &Grid<usize>) -> usize {
    let Some(start) = start else {
        return 0;
    };

    if start.2 == 9 {
        return 1;
    }
    neighbors(start, grid)
        .iter()
        .map(|n| score_path(*n, grid))
        .sum()
}

fn evaluate(data: &str) -> usize {
    let grid = make_grid(data);

    find_starting_points(&grid)
        .into_iter()
        .map(|s| score_path(Some(s), &grid))
        .sum()
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{Day::Day10, validate},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 1116, Day10);
    }

    #[test]
    fn test_evaluate() {
        let data = example!();
        let result = evaluate(data);
        assert_eq!(81, result);
    }
}
