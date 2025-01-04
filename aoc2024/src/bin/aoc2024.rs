use std::time::Duration;

use aoc2024::{
    day01, day02, day03, day04, day05, day06,
    util::{validate, Day, Kind},
};

fn main() {
    let mut total_time = Duration::from_secs(0);
    total_time += validate(day01::part1::solve, 1506483, Day::Day01, Kind::Part1);
    total_time += validate(day01::part2::solve, 23126924, Day::Day01, Kind::Part2);
    total_time += validate(day02::part1::solve, 202, Day::Day02, Kind::Part1);
    total_time += validate(day02::part2::solve, 271, Day::Day02, Kind::Part2);
    total_time += validate(day03::part1::solve, 173731097, Day::Day03, Kind::Part1);
    total_time += validate(day03::part2::solve, 93729253, Day::Day03, Kind::Part2);
    total_time += validate(day04::part1::solve, 2483, Day::Day04, Kind::Part1);
    total_time += validate(day04::part2::solve, 1925, Day::Day04, Kind::Part2);
    total_time += validate(day05::part1::solve, 7198, Day::Day05, Kind::Part1);
    total_time += validate(day05::part2::solve, 4230, Day::Day05, Kind::Part2);
    total_time += validate(day06::part1::solve, 4559, Day::Day05, Kind::Part1);

    println!("Total elapsed time: {:#?}", total_time);
}
