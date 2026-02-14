use std::time::Duration;

use aoc2024 as aoc;
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

fn get_solutions() -> Vec<aoc::Solution> {
    vec![
        aoc::day01::solution(),
        aoc::day02::solution(),
        aoc::day03::solution(),
        aoc::day04::solution(),
        aoc::day05::solution(),
        aoc::day06::solution(),
        aoc::day07::solution(),
        aoc::day08::solution(),
        aoc::day09::solution(),
        aoc::day10::solution(),
        aoc::day11::solution(),
        aoc::day12::solution(),
        aoc::day13::solution(),
        aoc::day14::solution(),
        aoc::day15::solution(),
        aoc::day16::solution(),
        aoc::day17::solution(),
        aoc::day18::solution(),
        aoc::day19::solution(),
    ]
}
