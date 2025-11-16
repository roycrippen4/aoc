pub mod part1;
pub mod part2;

const WIDTH: usize = 101;
const HEIGHT: usize = 103;
const WIDTH_ISIZE: isize = 101;
const HEIGHT_ISIZE: isize = 103;
const HALF_WIDTH: usize = WIDTH / 2;
const HALF_HEIGHT: usize = HEIGHT / 2;

#[derive(Debug, Clone, Copy)]
struct Robot {
    pos_x: isize,
    pos_y: isize,
    vel_x: isize,
    vel_y: isize,
}

impl From<&str> for Robot {
    fn from(s: &str) -> Self {
        let s = s.strip_prefix("p=").unwrap();
        let (pos_str, vel_str) = s.split_once(" ").unwrap();
        let (px_str, py_str) = pos_str.split_once(',').unwrap();
        let (vx_str, vy_str) = vel_str.strip_prefix("v=").unwrap().split_once(',').unwrap();
        let pos_x = px_str.parse().unwrap();
        let pos_y = py_str.parse().unwrap();
        let vel_x = vx_str.parse().unwrap();
        let vel_y = vy_str.parse().unwrap();

        Robot {
            pos_x,
            pos_y,
            vel_x,
            vel_y,
        }
    }
}

fn step(bot: Robot, steps: usize) -> Robot {
    let pos_x = (bot.pos_x + bot.vel_x * steps as isize).rem_euclid(WIDTH_ISIZE);
    let pos_y = (bot.pos_y + bot.vel_y * steps as isize).rem_euclid(HEIGHT_ISIZE);

    Robot {
        pos_x,
        pos_y,
        ..bot
    }
}

fn parse_input(input: &str) -> Vec<Robot> {
    input.trim().split('\n').map(Robot::from).collect()
}
