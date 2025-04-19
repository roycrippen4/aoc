pub mod part1;
pub mod part2;

const WIDTH: isize = 101;
const HEIGHT: isize = 103;

#[derive(Debug, Clone, Copy)]
struct Robot {
    pos_x: isize,
    pos_y: isize,
    vel_x: isize,
    vel_y: isize,
}

impl Robot {
    pub fn move_to_final_pos(&mut self, width: isize, height: isize, steps: isize) {
        self.pos_x = (((self.pos_x + self.vel_x * steps) % width) + width) % width;
        self.pos_y = (((self.pos_y + self.vel_y * steps) % height) + height) % height;
    }

    pub fn get_position(&self) -> (usize, usize) {
        (self.pos_x as usize, self.pos_y as usize)
    }

    pub fn update(&self, steps: isize) -> Self {
        Self {
            pos_x: (((self.pos_x + self.vel_x * steps) % WIDTH) + WIDTH) % WIDTH,
            pos_y: (((self.pos_y + self.vel_y * steps) % HEIGHT) + HEIGHT) % HEIGHT,
            vel_x: self.vel_x,
            vel_y: self.vel_y,
        }
    }
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

fn parse_input(input: &str) -> Vec<Robot> {
    input.trim().split('\n').map(Robot::from).collect()
}

fn update_counts(robot: &Robot, skip_x: usize, skip_y: usize) -> (usize, usize, usize, usize) {
    let (x, y) = robot.get_position();
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

fn calculate_safty(robots: &[Robot], width: isize, height: isize) -> usize {
    let skip_x = (width / 2) as usize;
    let skip_y = (height / 2) as usize;
    let (tl, tr, bl, br) = robots
        .iter()
        .map(|bot| update_counts(bot, skip_x, skip_y))
        .reduce(|(a, b, c, d), (tl, tr, bl, br)| (tl + a, tr + b, bl + c, br + d))
        .unwrap();

    tl * tr * bl * br
}
