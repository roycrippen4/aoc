use core::fmt;

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
    Day01(Part),
    Day02(Part),
    Day03(Part),
    Day04(Part),
    Day05(Part),
    Day06(Part),
    Day07(Part),
    Day08(Part),
    Day09(Part),
    Day10(Part),
    Day11(Part),
    Day12(Part),
    Day13(Part),
    Day14(Part),
    Day15(Part),
    Day16(Part),
    Day17(Part),
    Day18(Part),
    Day19(Part),
    Day20(Part),
    Day21(Part),
    Day22(Part),
    Day23(Part),
    Day24(Part),
    Day25(Part),
}

impl fmt::Display for Day {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let day_str = match self {
            Day::Day01(part) => format!("Day 01 {part}"),
            Day::Day02(part) => format!("Day 02 {part}"),
            Day::Day03(part) => format!("Day 03 {part}"),
            Day::Day04(part) => format!("Day 04 {part}"),
            Day::Day05(part) => format!("Day 05 {part}"),
            Day::Day06(part) => format!("Day 06 {part}"),
            Day::Day07(part) => format!("Day 07 {part}"),
            Day::Day08(part) => format!("Day 08 {part}"),
            Day::Day09(part) => format!("Day 09 {part}"),
            Day::Day10(part) => format!("Day 10 {part}"),
            Day::Day11(part) => format!("Day 11 {part}"),
            Day::Day12(part) => format!("Day 12 {part}"),
            Day::Day13(part) => format!("Day 13 {part}"),
            Day::Day14(part) => format!("Day 14 {part}"),
            Day::Day15(part) => format!("Day 15 {part}"),
            Day::Day16(part) => format!("Day 16 {part}"),
            Day::Day17(part) => format!("Day 17 {part}"),
            Day::Day18(part) => format!("Day 18 {part}"),
            Day::Day19(part) => format!("Day 19 {part}"),
            Day::Day20(part) => format!("Day 20 {part}"),
            Day::Day21(part) => format!("Day 21 {part}"),
            Day::Day22(part) => format!("Day 22 {part}"),
            Day::Day23(part) => format!("Day 23 {part}"),
            Day::Day24(part) => format!("Day 24 {part}"),
            Day::Day25(part) => format!("Day 25 {part}"),
        };
        write!(f, "{}", day_str)
    }
}
