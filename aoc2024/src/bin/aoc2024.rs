use std::time::Duration;

use aoc2024::{
    day01, day02, day03, day04, day05, day06, day07, day08, day09, day10, day11,
    util::{validate, Day::*, Part::*},
};

fn main() {
    let mut total_time = Duration::from_secs(0);
    total_time += validate(day01::part1::solve, 1506483, Day01(Part1));
    total_time += validate(day01::part2::solve, 23126924, Day01(Part2));
    total_time += validate(day02::part1::solve, 202, Day02(Part1));
    total_time += validate(day02::part2::solve, 271, Day02(Part2));
    total_time += validate(day03::part1::solve, 173731097, Day03(Part1));
    total_time += validate(day03::part2::solve, 93729253, Day03(Part2));
    total_time += validate(day04::part1::solve, 2483, Day04(Part1));
    total_time += validate(day04::part2::solve, 1925, Day04(Part2));
    total_time += validate(day05::part1::solve, 7198, Day05(Part1));
    total_time += validate(day05::part2::solve, 4230, Day05(Part2));
    total_time += validate(day06::part1::solve, 4559, Day06(Part1));
    total_time += validate(day06::part2::solve, 1604, Day06(Part1));
    total_time += validate(day07::part1::solve, 303766880536, Day07(Part1));
    total_time += validate(day07::part2::solve, 337041851384440, Day07(Part2));
    total_time += validate(day08::part1::solve, 244, Day08(Part1));
    total_time += validate(day08::part2::solve, 912, Day08(Part2));
    total_time += validate(day09::part1::solve, 6448989155953, Day09(Part1));
    total_time += validate(day09::part2::solve, 6476642796832, Day09(Part2));
    total_time += validate(day10::part1::solve, 517, Day10(Part1));
    total_time += validate(day10::part2::solve, 1116, Day10(Part2));
    total_time += validate(day11::part1::solve, 220999, Day11(Part1));
    total_time += validate(day11::part2::solve, 261936432123724, Day11(Part2));
    println!("Total elapsed time: {:#?}", total_time);
}
