fn main() {
    let test_txt: Vec<&str> = include_str!("test.txt").lines().collect();
    let input_txt: Vec<&str> = include_str!("input.txt").lines().collect();

    println!("Day 01 part a test: {}", solve_a(test_txt.clone())); // 8
    println!("Day 01 part b test: {}", solve_b(test_txt)); // 2286
    println!("Day 01 part a: {}", solve_a(input_txt.clone())); // 2265
    println!("Day 01 part b: {}", solve_b(input_txt)); // 64097
}

#[derive(Debug, Clone, Copy)]
struct Colors {
    red: u32,
    green: u32,
    blue: u32,
}

#[derive(Debug, Clone, Copy)]
struct Game {
    id: u32,
    colors: Colors,
}

impl Game {
    fn new(line: &str) -> Game {
        let (id_part, color_part) = line.split_once(':').unwrap();
        let id = id_part.split_once(' ').unwrap().1.parse::<u32>().unwrap();
        let colors = get_colors(color_part);

        Game { id, colors }
    }

    fn possible_game(self, colors: &Colors) -> bool {
        self.colors.red <= colors.red
            && self.colors.green <= colors.green
            && self.colors.blue <= colors.blue
    }
}

fn get_colors(str: &str) -> Colors {
    let chunks: Vec<Vec<&str>> = str
        .split(';')
        .map(|s| s.split(',').map(|s| s.trim()).collect())
        .collect();

    let mut colors = Colors {
        red: 0,
        green: 0,
        blue: 0,
    };

    for chunk in chunks {
        chunk.iter().for_each(|&item| {
            let (value_str, color) = item.split_once(' ').unwrap();
            let value = value_str.parse::<u32>().unwrap();
            match color {
                "red" if colors.red < value => colors.red = value,
                "green" if colors.green < value => colors.green = value,
                "blue" if colors.blue < value => colors.blue = value,
                _ => (),
            }
        })
    }

    colors
}

#[allow(dead_code)]
fn solve_a(lines: Vec<&str>) -> u32 {
    let mut res: u32 = 0;

    for line in lines {
        let game = Game::new(line);
        if game.possible_game(&Colors {
            red: 12,
            green: 13,
            blue: 14,
        }) {
            res += game.id
        }
    }

    res
}

fn solve_b(lines: Vec<&str>) -> u32 {
    let mut res: u32 = 0;
    for line in lines {
        let game = Game::new(line);
        res += game.colors.red * game.colors.green * game.colors.blue
    }

    res
}
