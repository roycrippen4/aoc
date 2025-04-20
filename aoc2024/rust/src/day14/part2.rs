use rayon::prelude::*;

use crate::data;

use super::{HEIGHT, WIDTH, parse_input, step};

const RUN: usize = 11;

#[inline]
fn has_run(row: [bool; WIDTH]) -> bool {
    let mut len = 0;
    for cell in row {
        len = if cell { len + 1 } else { 0 };
        if len >= RUN {
            return true;
        }
    }
    false
}

pub fn solve() -> usize {
    let robots = parse_input(data!());

    (1usize..(WIDTH * HEIGHT * 2))
        .into_par_iter()
        .find_first(|num_steps| {
            let mut grid = [[false; WIDTH]; HEIGHT];
            for r in robots.iter().map(|r| step(*r, *num_steps)) {
                grid[r.pos_y as usize][r.pos_x as usize] = true;
            }

            grid.into_iter().any(has_run).then_some(step).is_some()
        })
        .unwrap()
}

#[cfg(test)]
mod test {
    use crate::util::{Day::Day14, Part::Part2, validate};

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 6532, Day14(Part2));
    }
}
