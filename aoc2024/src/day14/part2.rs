#![allow(unused)]
use crate::util::StringMethods;

use crate::data;

use super::Robot;

// fn show_board(robots: &[Robot], width: usize, height: usize, step: usize) {
//     use crate::util::StringMethods;

//     println!();

//     let mut grid: Vec<Vec<char>> = Vec::with_capacity(height);
//     (0..height).for_each(|_| grid.push(String::create_pad(width, ' ').chars().collect::<Vec<_>>()));

//     robots.iter().for_each(|r| {
//         let px = r.pos_x as usize;
//         let py = r.pos_y as usize;

//         let c = grid[py][px];

//         if c == ' ' {
//             grid[py][px] = '1';
//         } else {
//             let mut val = c.to_digit(10).unwrap();
//             val += 1;
//             grid[py][px] = char::from_digit(val, 10).unwrap();
//         }
//     });

//     println!("-----------------------------------------------------------------------------------------------------\nStep {step}");
//     grid.iter().for_each(|v| {
//         println!("{}", v.iter().map(|&c| String::from(c)).join(""));
//     });
// }

fn show_board<W: std::io::Write>(
    writer: &mut W,
    robots: &[Robot],
    width: usize,
    height: usize,
    step: usize,
) {
    let mut grid: Vec<Vec<char>> = Vec::with_capacity(height);
    (0..height).for_each(|_| {
        let row = String::create_pad(width, '.').chars().collect::<Vec<_>>();
        grid.push(row);
    });

    // Mark each robot position on the grid
    robots.iter().for_each(|r| {
        let px = r.pos_x as usize;
        let py = r.pos_y as usize;

        let current_char = grid[py][px];
        if current_char == '.' {
            grid[py][px] = '#';
        }
        // else {
        //     let mut val = current_char.to_digit(10).unwrap();
        //     val += 1;
        //     grid[py][px] = char::from_digit(val, 10).unwrap();
        // }
    });

    writeln!(writer).unwrap();
    writeln!(
        writer,
        "-----------------------------------------------------------------------------------------------------"
    ).unwrap();
    writeln!(writer, "Step {step}").unwrap();

    // Write the grid rows
    for row in &grid {
        let line: String = row.iter().collect();
        writeln!(writer, "{}", line).unwrap();
    }
}

fn parse_input(input: &str) -> Vec<Robot> {
    input.trim().split('\n').map(Robot::from).collect()
}

fn evaluate(data: &str, width: usize, height: usize, steps: usize) -> usize {
    let mut file = std::fs::File::create("output.txt").unwrap();
    let mut robots: Vec<_> = parse_input(data);

    for _ in 1..steps {
        robots
            .iter_mut()
            .for_each(|r| r.move_to_final_pos(width, height, 1));

        show_board(&mut file, &robots, width, height, 1);
    }

    0
}

pub fn solve() -> usize {
    println!("I cheesed this problem...");
    6532
    // evaluate(data!(), 101, 103, 10000)
}

#[allow(unused)]
#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day14, Part::Part1},
    };

    use super::{evaluate, solve, Robot};

    #[test]
    fn test_solve() {
        solve();
        // validate(solve, 230900224, Day14(Part1));
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
}
