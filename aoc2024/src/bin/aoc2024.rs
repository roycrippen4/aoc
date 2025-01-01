use std::time::Duration;

use aoc2024::{
    day01, day02,
    util::{validate, Day, Kind},
};

fn main() {
    let mut total_time = Duration::from_secs(0);
    total_time += validate(day01::part1::solve, 1506483, Day::Day01, Kind::Part1);
    total_time += validate(day01::part2::solve, 23126924, Day::Day01, Kind::Part2);
    total_time += validate(day02::part1::solve, 202, Day::Day02, Kind::Part1);
    total_time += validate(day02::part2::solve, 271, Day::Day02, Kind::Part2);

    println!("Total elapsed time: {:#?}", total_time);
}
