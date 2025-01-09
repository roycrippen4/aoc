use std::{
    fmt, iter,
    str::FromStr,
    time::{Duration, Instant, SystemTime, UNIX_EPOCH},
};

pub fn create_pad(len: usize, character: char) -> String {
    iter::repeat(character).take(len).collect()
}

pub fn into_padded_string(str: &&str) -> String {
    let mut s = str.to_string();
    s.pad(4, '.');
    s
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

// pub enum Kind {
//     Example,
//     Part1,
//     Part2,
// }

// impl fmt::Display for Kind {
//     fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
//         let res = match self {
//             Kind::Example => "Example",
//             Kind::Part1 => "Part 1",
//             Kind::Part2 => "Part 2",
//         };
//         write!(f, "{res}")
//     }
// }

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

pub fn validate<T>(func: impl Fn() -> T, expected: T, day: Day) -> Duration
where
    T: PartialEq,
    T: fmt::Debug,
{
    let start = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
    let result = func();
    let end = SystemTime::now().duration_since(UNIX_EPOCH).unwrap();
    let total = end - start;
    assert_eq!(expected, result);
    println!("{day} solved in {:#?}", total);
    total
}

pub trait StringMethods {
    fn to_char_vec(&self) -> Vec<char>;
    fn pad_start(&mut self, n: usize, c: char);
    fn pad_end(&mut self, n: usize, c: char);
    fn pad(&mut self, n: usize, c: char);
    fn trim_split_filter(self, pat: &str) -> Vec<String>;
    fn tsfp<F: FromStr>(self, pat: &str) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug;
}

impl StringMethods for String {
    fn to_char_vec(&self) -> Vec<char> {
        self.chars().collect::<Vec<_>>()
    }

    fn pad_start(&mut self, n: usize, ch: char) {
        let mut n = n;
        while n != 0 {
            self.insert(0, ch);
            n -= 1;
        }
    }

    fn pad_end(&mut self, n: usize, ch: char) {
        let mut n = n;
        while n != 0 {
            self.insert(self.len(), ch);
            n -= 1;
        }
    }

    fn pad(&mut self, n: usize, ch: char) {
        self.pad_start(n, ch);
        self.pad_end(n, ch);
    }

    fn trim_split_filter(self, pat: &str) -> Vec<String> {
        self.trim()
            .split(pat)
            .filter(|&s| !s.is_empty())
            .map(String::from)
            .collect()
    }

    /// Trims whitespace, splits the string at `pat`, filters out empty entries, and parses via
    /// `FromStr`
    fn tsfp<F: FromStr>(self, pat: &str) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug,
    {
        self.trim()
            .split(pat)
            .filter(|&s| !s.is_empty())
            .map(|s| s.to_string().parse().expect("Failed to parse"))
            .collect()
    }
}

pub fn perf<T>(func: impl Fn() -> T, iterations: usize) {
    let start = Instant::now();
    (0..iterations).for_each(|_| {
        func();
    });
    println!("Average: {:?}", start.elapsed() / iterations as u32);
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
        let mut string = "string".to_string();
        let expected = "...string";
        string.pad_start(3, '.');
        assert_eq!(string, expected)
    }

    #[test]
    fn test_pad_end() {
        let mut string = "string".to_string();
        let expected = "string...";
        string.pad_end(3, '.');
        assert_eq!(string, expected)
    }

    #[test]
    fn test_pad() {
        let mut string = "string".to_string();
        let expected = "...string...";
        string.pad(3, '.');
        assert_eq!(string, expected)
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
    fn test_trim_split_filter() {
        let s = "12345".to_string();
        assert_eq!(vec!["1", "2", "3", "4", "5"], s.trim_split_filter(""));
    }

    #[test]
    fn test_trim_split_filter_parse() {
        let s = String::from("12345");
        assert_eq!(vec![1_usize, 2, 3, 4, 5], s.tsfp(""));
    }
}
