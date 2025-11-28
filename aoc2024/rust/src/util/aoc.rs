use core::fmt;
use std::time::Duration;

use comfy_table::Table;

use crate::util::colorize_time;

#[derive(Debug, Clone, Copy)]
pub enum Part {
    Part1,
    Part2,
}

impl fmt::Display for Part {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let s = match self {
            Part::Part1 => "Part 1",
            Part::Part2 => "Part 2",
        };
        write!(f, "{s}")
    }
}

#[derive(Debug, Clone, Copy)]
pub enum Day {
    Day01,
    Day02,
    Day03,
    Day04,
    Day05,
    Day06,
    Day07,
    Day08,
    Day09,
    Day10,
    Day11,
    Day12,
    Day13,
    Day14,
    Day15,
    Day16,
    Day17,
    Day18,
    Day19,
    Day20,
    Day21,
    Day22,
    Day23,
    Day24,
    Day25,
}

impl From<Day> for usize {
    fn from(value: Day) -> Self {
        match value {
            Day::Day01 => 1,
            Day::Day02 => 2,
            Day::Day03 => 3,
            Day::Day04 => 4,
            Day::Day05 => 5,
            Day::Day06 => 6,
            Day::Day07 => 7,
            Day::Day08 => 8,
            Day::Day09 => 9,
            Day::Day10 => 10,
            Day::Day11 => 11,
            Day::Day12 => 12,
            Day::Day13 => 13,
            Day::Day14 => 14,
            Day::Day15 => 15,
            Day::Day16 => 16,
            Day::Day17 => 17,
            Day::Day18 => 18,
            Day::Day19 => 19,
            Day::Day20 => 20,
            Day::Day21 => 21,
            Day::Day22 => 22,
            Day::Day23 => 23,
            Day::Day24 => 24,
            Day::Day25 => 25,
        }
    }
}

impl fmt::Display for Day {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let day_str = match self {
            Day::Day01 => "Day 01",
            Day::Day02 => "Day 02",
            Day::Day03 => "Day 03",
            Day::Day04 => "Day 04",
            Day::Day05 => "Day 05",
            Day::Day06 => "Day 06",
            Day::Day07 => "Day 07",
            Day::Day08 => "Day 08",
            Day::Day09 => "Day 09",
            Day::Day10 => "Day 10",
            Day::Day11 => "Day 11",
            Day::Day12 => "Day 12",
            Day::Day13 => "Day 13",
            Day::Day14 => "Day 14",
            Day::Day15 => "Day 15",
            Day::Day16 => "Day 16",
            Day::Day17 => "Day 17",
            Day::Day18 => "Day 18",
            Day::Day19 => "Day 19",
            Day::Day20 => "Day 20",
            Day::Day21 => "Day 21",
            Day::Day22 => "Day 22",
            Day::Day23 => "Day 23",
            Day::Day24 => "Day 24",
            Day::Day25 => "Day 25",
        };
        write!(f, "{day_str}")
    }
}

pub struct Runner {
    pub expected: usize,
    pub f: fn() -> usize,
}

impl Runner {
    /// Convenience wrapper to call `self.f`
    pub fn run(&self) -> usize {
        (self.f)()
    }

    /// Validates that `self.expected` == `self.f()`
    pub fn validate(&self, day: Day, part: Part) {
        assert_eq!(
            self.expected,
            self.run(),
            "\x1b[31m{day} {part} produced the wrong answer\x1b[0m",
        );
    }

    /// Validates that `self.expected` == `self.f()`
    /// returns the amount of time it took to run
    pub fn timed_validate(&self, day: Day, part: Part) -> Duration {
        let now = std::time::Instant::now();
        self.validate(day, part);
        now.elapsed()
    }
}

pub struct Solution {
    pub day: Day,
    pub p1: Runner,
    pub p2: Runner,
}

impl Solution {
    /// Runs both parts and returns the sum of both parts runtime durations
    pub fn solve(&self, table: &mut Table) -> Duration {
        let p1 = self.p1.timed_validate(self.day, Part::Part1);
        let p2 = self.p2.timed_validate(self.day, Part::Part2);
        let day: usize = self.day.into();

        table.add_row(vec![
            day.to_string(),
            colorize_time(&p1),
            colorize_time(&p2),
        ]);

        p1 + p2
    }
}
