use super::{HALF_HEIGHT, HALF_WIDTH, Robot, parse_input, step};
use crate::data;

fn update_counts(robot: Robot, skip_x: usize, skip_y: usize) -> (usize, usize, usize, usize) {
    let (x, y) = (robot.pos_x as usize, robot.pos_y as usize);
    if x == skip_x || y == skip_y {
        return (0, 0, 0, 0);
    }

    match (x < skip_x, y < skip_y) {
        (true, true) => (1, 0, 0, 0),
        (false, true) => (0, 1, 0, 0),
        (true, false) => (0, 0, 1, 0),
        (false, false) => (0, 0, 0, 1),
    }
}

pub fn evaluate(data: &str, steps: usize) -> usize {
    let (tl, tr, bl, br) = parse_input(data)
        .into_iter()
        .map(|bot| update_counts(step(bot, steps), HALF_WIDTH, HALF_HEIGHT))
        .reduce(|(a, b, c, d), (tl, tr, bl, br)| (tl + a, tr + b, bl + c, br + d))
        .unwrap();
    tl * tr * bl * br
}

pub fn solve() -> usize {
    evaluate(data!(), 100)
}

#[cfg(test)]
mod test {
    use crate::{
        day14::Robot,
        util::{Day::Day14, Part::Part1, validate},
    };

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 230900224, Day14(Part1));
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
