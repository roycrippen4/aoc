use std::time::{Duration, Instant};

use aoc2024::{
    day01, day02, day03, day04, day05, day06, day07, day08, day09, day10, day11, day12, day13,
    day14, util::colorize_time,
};
use comfy_table::{modifiers::UTF8_ROUND_CORNERS, presets::UTF8_FULL, Table};

type Solver = fn() -> usize;

struct S {
    time: Duration,
}

impl S {
    pub fn new(function: Solver, expected: usize) -> Self {
        let now = Instant::now();
        assert_eq!(function(), expected);
        let time = now.elapsed();
        Self { time }
    }
}

fn main() {
    let mut table = Table::new();
    table
        .load_preset(UTF8_FULL)
        .apply_modifier(UTF8_ROUND_CORNERS)
        .set_width(50)
        .set_header(vec!["Day", "Part 1", "Part 2"]);

    let mut total_time = Duration::from_secs(0);
    for (i, chunk) in get_solutions().chunks_exact(2).enumerate() {
        let [p1, p2] = [&chunk[0], &chunk[1]];
        total_time += p1.time;
        total_time += p2.time;

        table.add_row(vec![
            format!("{i}"),
            colorize_time(&p1.time),
            colorize_time(&p2.time),
        ]);
    }

    println!("\nTotal combined time: {:#?}", total_time);
    println!("{table}");
}

fn get_solutions() -> Vec<S> {
    vec![
        S::new(day01::part1::solve, 1506483),
        S::new(day01::part2::solve, 23126924),
        S::new(day02::part1::solve, 202),
        S::new(day02::part2::solve, 271),
        S::new(day03::part1::solve, 173731097),
        S::new(day03::part2::solve, 93729253),
        S::new(day04::part1::solve, 2483),
        S::new(day04::part2::solve, 1925),
        S::new(day05::part1::solve, 7198),
        S::new(day05::part2::solve, 4230),
        S::new(day06::part1::solve, 4559),
        S::new(day06::part2::solve, 1604),
        S::new(day07::part1::solve, 303766880536),
        S::new(day07::part2::solve, 337041851384440),
        S::new(day08::part1::solve, 244),
        S::new(day08::part2::solve, 912),
        S::new(day09::part1::solve, 6448989155953),
        S::new(day09::part2::solve, 6476642796832),
        S::new(day10::part1::solve, 517),
        S::new(day10::part2::solve, 1116),
        S::new(day11::part1::solve, 220999),
        S::new(day11::part2::solve, 261936432123724),
        S::new(day12::part1::solve, 1361494),
        S::new(day12::part2::solve, 830516),
        S::new(day13::part1::solve, 29436),
        S::new(day13::part2::solve, 103729094227877),
        S::new(day14::part1::solve, 230900224),
        S::new(day14::part2::solve, 6532),
    ]
}
