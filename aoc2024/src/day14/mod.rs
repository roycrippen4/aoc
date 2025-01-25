pub mod part1;
pub mod part2;

#[derive(Debug)]
struct Robot {
    pos_x: isize,
    pos_y: isize,
    vel_x: isize,
    vel_y: isize,
}

impl Robot {
    pub fn move_to_final_pos(&mut self, width: usize, height: usize, steps: usize) {
        let width = width as isize;
        let height = height as isize;
        self.pos_x = (((self.pos_x + self.vel_x * steps as isize) % width) + width) % width;
        self.pos_y = (((self.pos_y + self.vel_y * steps as isize) % height) + height) % height;
    }

    pub fn get_position(&self) -> (usize, usize) {
        (self.pos_x as usize, self.pos_y as usize)
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
