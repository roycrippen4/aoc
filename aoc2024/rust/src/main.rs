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
        aoc::day01::SOLUTION,
        aoc::day02::SOLUTION,
        aoc::day03::SOLUTION,
        aoc::day04::SOLUTION,
        aoc::day05::SOLUTION,
        aoc::day06::SOLUTION,
        aoc::day07::SOLUTION,
        aoc::day08::SOLUTION,
        aoc::day09::SOLUTION,
        aoc::day10::SOLUTION,
        aoc::day11::SOLUTION,
        aoc::day12::SOLUTION,
        aoc::day13::SOLUTION,
        aoc::day14::SOLUTION,
        aoc::day15::SOLUTION,
        aoc::day16::SOLUTION,
        aoc::day17::SOLUTION,
        aoc::day18::SOLUTION,
        aoc::day19::SOLUTION,
        aoc::day20::SOLUTION,
    ]
}
