use std::time::Duration;

use aoc2024::{
    Solution, day01, day02, day03, day04, day05, day06, day07, day08, day09, day10, day11, day12,
    day13, day14, day15, day16,
};

use comfy_table::Table;
use comfy_table::modifiers::UTF8_ROUND_CORNERS;
use comfy_table::presets::UTF8_FULL;

fn main() {
    let mut table = Table::new();
    table
        .load_preset(UTF8_FULL)
        .apply_modifier(UTF8_ROUND_CORNERS)
        .set_width(50)
        .set_header(vec!["Day", "Part 1", "Part 2"]);

    let mut total_time = Duration::from_secs(0);
    for solution in get_solutions() {
        total_time += solution.solve(&mut table);
    }

    println!("\nTotal combined time: {total_time:#?}");
    println!("{table}");
}

fn get_solutions() -> Vec<Solution> {
    vec![
        day01::solution(),
        day02::solution(),
        day03::solution(),
        day04::solution(),
        day05::solution(),
        day06::solution(),
        day07::solution(),
        day08::solution(),
        day09::solution(),
        day10::solution(),
        day11::solution(),
        day12::solution(),
        day13::solution(),
        day14::solution(),
        day15::solution(),
        day16::solution(),
    ]
}
