fn main() {
    let a_test_lines: Vec<String> = include_str!("test-a.txt")
        .lines()
        .map(|l| l.chars().collect())
        .collect();

    let input_txt: Vec<String> = include_str!("input.txt")
        .lines()
        .map(|l| l.chars().collect())
        .collect();

    println!("Day 01 part a test: {}", solve_a(a_test_lines));
    println!("Day 01 part a: {}", solve_a(input_txt));
}

#[derive(Debug)]
struct Colors {
    red: u32,
    green: u32,
    blue: u32,
}

#[derive(Debug, Clone, Copy)]
struct Game {
    id: u32,
    red: u32,
    green: u32,
    blue: u32,
}

impl Game {
    fn get_id(id_str: &str) -> u32 {
        id_str.parse::<u32>().unwrap()
    }

    fn new(line: &str) -> Game {
        let (id_part, color_part) = line.split_once(':').unwrap();
        let id = Game::get_id(id_part.split_once(' ').unwrap().1);
        let colors = get_colors(color_part);

        Game {
            id,
            red: colors.red,
            green: colors.green,
            blue: colors.blue,
        }
    }

    fn possible_game(self, colors: &Colors) -> bool {
        self.red <= colors.red && self.green <= colors.green && self.blue <= colors.blue
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

            if color == "red" && colors.red < value {
                colors.red = value;
            }

            if color == "green" && colors.green < value {
                colors.green = value;
            }

            if color == "blue" && colors.blue < value {
                colors.blue = value;
            }
        })
    }

    colors
}

fn solve_a(lines: Vec<String>) -> u32 {
    let mut res: u32 = 0;

    let configuration = Colors {
        red: 12,
        green: 13,
        blue: 14,
    };

    for line in lines {
        let game = Game::new(&line);
        if game.possible_game(&configuration).to_owned() {
            res += game.id
        }
    }

    res
}
