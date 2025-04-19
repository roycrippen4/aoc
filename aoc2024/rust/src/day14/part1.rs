use super::{HEIGHT, WIDTH, calculate_safty, parse_input};
use crate::data;

pub fn evaluate(data: &str, steps: isize, width: Option<isize>, height: Option<isize>) -> usize {
    let mut robots: Vec<_> = parse_input(data);
    let width = width.unwrap_or(WIDTH);
    let height = height.unwrap_or(HEIGHT);
    robots
        .iter_mut()
        .for_each(|r| r.move_to_final_pos(width, height, steps));

    calculate_safty(&robots, width, height)
}

pub fn solve() -> usize {
    evaluate(data!(), 100, None, None)
}

#[cfg(test)]
mod test {
    use crate::{
        day14::Robot,
        example,
        util::{Day::Day14, Part::Part1, validate},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 230900224, Day14(Part1));
    }

    #[test]
    fn test_evaluate() {
        assert_eq!(evaluate(example!(), 100, Some(11), Some(7)), 12);
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

    #[test]
    fn make_robot() {
        let s = "p=24,28 v=-92,3";
        let robot = Robot::from(s);

        assert_eq!(robot.pos_x, 24);
        assert_eq!(robot.pos_y, 28);
        assert_eq!(robot.vel_x, -92);
        assert_eq!(robot.vel_y, 3);
    }
}
