use std::{
    fmt, iter,
    str::FromStr,
    time::{Duration, Instant},
};

#[macro_export]
macro_rules! example {
    () => {
        include_str!("data/example.txt")
    };
}

#[macro_export]
macro_rules! data {
    () => {
        include_str!("data/data.txt")
    };
}

/// Colors string `s` fg color with `r`, `g`, `b` values using ansci escape codes.
/// `r`, `g`, and `b` values range from 0 to 255;
///
/// # Example
/// ```
/// use aoc2024::rgb;
///
/// println!("{}", rgb!("Red 255", 255, 0, 0));
/// println!("{}", rgb!("Red 200", 200, 0, 0));
/// println!("{}", rgb!("gray", 100, 100, 100));
/// println!("{}", rgb!("orange", 255, 140, 0));
/// ```
#[macro_export]
macro_rules! rgb {
    ($s:expr, $r:expr, $g:expr, $b:expr) => {
        format!("\x1b[38;2;{};{};{}m{}\x1b[0m", $r, $g, $b, $s)
    };
}

pub fn create_pad(len: usize, character: char) -> String {
    iter::repeat(character).take(len).collect()
}

pub fn into_padded_string(str: &&str) -> String {
    str.to_string().pad(4, '.')
}

#[macro_export]
macro_rules! debug {
    () => {
        if DEBUG {
            println!()
        }
    };
    ($($arg:tt)*) => {{
        if DEBUG {
            println!($($arg)*);
        }
    }};
}

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

pub fn unsafe_index(x: isize) -> usize {
    usize::try_from(x).unwrap()
}

pub fn partition<T: Copy + PartialOrd>(array: &mut [T]) -> usize {
    let n = array.len();
    let pivot = array[0];
    let mut i = -1;
    let mut j = n as isize;

    loop {
        loop {
            i += 1;
            if array[unsafe_index(i)] >= pivot {
                break;
            }
        }

        loop {
            j -= 1;
            if j < 0 || array[unsafe_index(j)] <= pivot {
                break;
            }
        }

        if i >= j {
            return unsafe_index(j);
        }

        let temp = array[unsafe_index(i)];
        array[unsafe_index(i)] = array[unsafe_index(j)];
        array[unsafe_index(j)] = temp;
    }
}

pub fn quicksort<T: Copy + PartialOrd>(array: &mut [T]) {
    if array.len() <= 1 {
        return;
    }
    let pi = partition(array);
    let (left, right) = array.split_at_mut(pi + 1);
    quicksort(left);
    quicksort(right);
}

enum TimeRange {
    Seconds,
    MillisecondsSlow,
    MillisecondsMedium,
    MillisecondsFast,
    Nanoseconds,
}

fn get_time_range(t: &Duration) -> TimeRange {
    if t.as_secs() > 0 {
        TimeRange::Seconds
    } else if t.subsec_millis() > 100 {
        TimeRange::MillisecondsSlow
    } else if t.subsec_millis() > 10 {
        TimeRange::MillisecondsMedium
    } else if t.subsec_millis() > 0 {
        TimeRange::MillisecondsFast
    } else {
        TimeRange::Nanoseconds
    }
}

fn colorize_time(t: &Duration) -> String {
    let range = get_time_range(t);
    match range {
        TimeRange::Nanoseconds => rgb!(format!("{:#?}", t), 0, 255, 0),
        TimeRange::MillisecondsFast => rgb!(format!("{:#?}", t), 127, 210, 0),
        TimeRange::MillisecondsMedium => rgb!(format!("{:#?}", t), 255, 165, 0),
        TimeRange::MillisecondsSlow => rgb!(format!("{:#?}", t), 255, 82, 0),
        TimeRange::Seconds => rgb!(format!("{:#?}", t), 255, 0, 0),
    }
}

pub fn validate<T>(func: impl Fn() -> T, expected: T, day: Day) -> Duration
where
    T: PartialEq,
    T: fmt::Debug,
{
    let start = Instant::now();
    let result = func();
    let total_time = start.elapsed();
    let colored_time = colorize_time(&total_time);
    assert_eq!(expected, result);
    println!("{day} solved in {colored_time}");
    total_time
}

pub trait StringMethods {
    fn to_char_vec(&self) -> Vec<char>;
    fn pad_start(&self, n: usize, c: char) -> String;
    fn pad_end(&self, n: usize, c: char) -> String;
    fn pad(&self, n: usize, c: char) -> String;
    fn to_row<F: FromStr>(&self) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug;
}

impl StringMethods for String {
    fn to_char_vec(&self) -> Vec<char> {
        self.chars().collect::<Vec<_>>()
    }

    fn pad_start(&self, n: usize, ch: char) -> String {
        let mut s = self.clone();
        let mut n = n;
        while n != 0 {
            s.insert(0, ch);
            n -= 1;
        }
        s
    }

    fn pad_end(&self, n: usize, ch: char) -> String {
        let mut s = self.clone();
        let mut n = n;
        while n != 0 {
            s.insert(self.len(), ch);
            n -= 1;
        }
        s
    }

    fn pad(&self, n: usize, ch: char) -> String {
        self.pad_start(n, ch).pad_end(n, ch)
    }

    /// Trims whitespace, splits the string at `pat`, filters out empty entries, and parses via
    /// `FromStr`
    fn to_row<F: FromStr>(&self) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug,
    {
        self.trim()
            .split("")
            .filter(|s| !s.trim().is_empty())
            .map(|s| s.to_string().parse().expect("Failed to parse"))
            .collect()
    }
}

impl StringMethods for &str {
    fn to_char_vec(&self) -> Vec<char> {
        self.to_string().to_char_vec()
    }

    fn pad_start(&self, n: usize, c: char) -> String {
        self.to_string().pad_start(n, c)
    }

    fn pad_end(&self, n: usize, c: char) -> String {
        self.to_string().pad_end(n, c)
    }

    fn pad(&self, n: usize, c: char) -> String {
        self.to_string().pad(n, c)
    }

    fn to_row<F: FromStr>(&self) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug,
    {
        self.to_string().to_row()
    }
}

pub fn perf<T>(func: impl Fn() -> T, iterations: usize) {
    let start = Instant::now();
    (0..iterations).for_each(|_| {
        func();
    });
    let colorized_time = colorize_time(&(start.elapsed() / iterations as u32));
    println!("Average: {colorized_time}");
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_partition() {
        let mut input = [5, 3, 8, 4, 2, 7, 1, 10];
        let expected = [1, 3, 2, 4, 8, 7, 5, 10];
        partition(&mut input);
        assert_eq!(expected, input);

        let mut input = [12, 10, 9, 16, 19, 9];
        let expected = [9, 10, 9, 16, 19, 12];
        partition(&mut input);
        assert_eq!(expected, input);
    }

    #[test]
    fn test_quicksort() {
        let data = generate_test_data();
        for (expected, mut input) in data {
            quicksort(&mut input);
            assert_eq!(input, expected);
        }
    }

    #[test]
    fn test_pad_start() {
        let result = "string".to_string().pad_start(3, '.');
        let expected = "...string";
        assert_eq!(expected, result)
    }

    #[test]
    fn test_pad_end() {
        let result = "string".to_string().pad_end(3, '.');
        let expected = "string...";
        assert_eq!(expected, result)
    }

    #[test]
    fn test_pad() {
        let result = "string".to_string().pad(3, '.');
        let expected = "...string...";
        assert_eq!(expected, result)
    }

    #[test]
    fn test_to_char_vec() {
        let string = "string".to_string();
        let expected = ['s', 't', 'r', 'i', 'n', 'g'];
        assert_eq!(string.to_char_vec(), expected)
    }

    fn generate_test_data() -> Vec<(Vec<isize>, Vec<isize>)> {
        vec![
            (vec![-5, -3, 0, 1, 2, 7, 8], vec![7, -3, 8, 1, 2, -5, 0]),
            (vec![1, 1, 1, 1], vec![1, 1, 1, 1]),
            (vec![1, 2, 3, 4, 5], vec![5, 4, 3, 2, 1]),
            (vec![], vec![]),
            (vec![42], vec![42]),
            (vec![-10, -2, 0, 3, 5], vec![0, -2, 5, 3, -10]),
        ]
    }

    #[test]
    fn test_trim_split_filter_parse() {
        let s = String::from("12345");
        assert_eq!(vec![1_usize, 2, 3, 4, 5], s.to_row());
        let s = String::from("1234 5");
        assert_eq!(vec![1_usize, 2, 3, 4, 5], s.to_row());
    }

    #[test]
    fn test_rgb() {
        println!("{}", rgb!("Red 255", 255, 0, 0));
        println!("{}", rgb!("Red 200", 200, 0, 0));
        println!("{}", rgb!("gray", 100, 100, 100));
        println!("{}", rgb!("orange", 255, 140, 0));
    }

    #[test]
    fn test_colorize_time() {
        println!("time: {}", colorize_time(&Duration::from_secs(1)));
        println!("time: {}", colorize_time(&Duration::from_millis(500)));
        println!("time: {}", colorize_time(&Duration::from_millis(50)));
        println!("time: {}", colorize_time(&Duration::from_millis(5)));
        println!("time: {}", colorize_time(&Duration::from_nanos(500)));
    }
}
