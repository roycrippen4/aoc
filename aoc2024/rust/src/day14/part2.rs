use rayon::prelude::*;

use crate::data;

use super::{parse_input, HEIGHT, WIDTH};

pub fn solve() -> usize {
    let robots = parse_input(data!());

    (1..WIDTH * HEIGHT)
        .into_par_iter()
        .filter_map(|i| {
            let mut occupied = [[false; WIDTH as usize]; HEIGHT as usize];
            for robot in robots.iter().map(|r| r.update(i)) {
                occupied[robot.pos_y as usize][robot.pos_x as usize] = true;
            }

            for row in &occupied {
                let mut run_length = 0;
                for &cell in row {
                    if cell {
                        run_length += 1;
                    } else {
                        run_length = 0;
                    }

                    if run_length >= 11 {
                        return Some(i);
                    }
                }
            }

            None
        })
        .collect::<Vec<_>>()[0] as usize
}

#[cfg(test)]
mod test {
    use crate::{
        day14::Robot,
        util::{validate, Day::Day14, Part::Part2},
    };

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 6532, Day14(Part2));
    }

    #[test]
    fn test_find_final_pos() {
        let expected_x = 1;
        let expected_y = 3;
        let width = 11;
        let height = 7;
        let steps = 5;

        let mut robot = Robot::from("p=2,4 v=2,-3");
        robot.move_to_final_pos(width, height, steps);

        assert_eq!(robot.pos_x, expected_x);
        assert_eq!(robot.pos_y, expected_y);
    }
}
