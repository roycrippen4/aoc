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

fn calculate_safty(robots: &[Robot], width: isize, height: isize) -> usize {
    let skip_x = (width / 2) as usize;
    let skip_y = (height / 2) as usize;
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

// fn render(robots: &[Robot]) -> String {
//     let mut grid: Vec<Vec<char>> = (0..HEIGHT)
//         .map(|_| ".".repeat(WIDTH as usize).chars().collect())
//         .collect();

//     for robot in robots {
//         grid[robot.pos_y as usize][robot.pos_x as usize] = '#';
//     }

//     grid.iter()
//         .map(|row| row.iter().collect::<String>())
//         .collect()
// }
