use std::time::Duration;

use aoc2024::{
    day01,
    util::{validate, Kind},
};

fn main() {
    let mut total_time = Duration::from_secs(0);
    total_time += validate(day01::part1::solve, 1506483, 1, Kind::Part1);
    total_time += validate(day01::part2::solve, 23126924, 1, Kind::Part2);

    println!("Total elapsed time: {:#?}", total_time);
}
