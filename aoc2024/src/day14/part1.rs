use super::Robot;
use crate::data;

fn parse_input(input: &str) -> Vec<Robot> {
    input.trim().split('\n').map(Robot::from).collect()
}

fn evaluate(data: &str, width: usize, height: usize, steps: usize) -> usize {
    let mut robots: Vec<_> = parse_input(data);
    robots
        .iter_mut()
        .for_each(|r| r.move_to_final_pos(width, height, steps));

    let skip_x = width / 2;
    let skip_y = height / 2;
    let mut top_left_count = 0;
    let mut top_right_count = 0;
    let mut bot_left_count = 0;
    let mut bot_right_count = 0;

    for robot in robots {
        let (x, y) = robot.get_position();
        if x == skip_x || y == skip_y {
            continue;
        }

        match (x < skip_x, y < skip_y) {
            (true, true) => top_left_count += 1,
            (true, false) => bot_left_count += 1,
            (false, true) => top_right_count += 1,
            (false, false) => bot_right_count += 1,
        };
    }

    top_left_count * top_right_count * bot_left_count * bot_right_count
}

pub fn solve() -> usize {
    evaluate(data!(), 101, 103, 100)
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day14, Part::Part1},
    };

    use super::{evaluate, solve, Robot};

    #[test]
    fn test_solve() {
        validate(solve, 230900224, Day14(Part1));
    }

    #[test]
    fn test_evaluate() {
        let result = evaluate(example!(), 11, 7, 100);
        assert_eq!(result, 12);
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
