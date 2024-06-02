// Holy fuck... I'm so bad at this language

fn main() {
    let a_test_lines: Vec<String> = include_str!("test-a.txt")
        .lines()
        .map(|l| l.chars().collect())
        .collect();

    let lines: Vec<String> = include_str!("input.txt")
        .lines()
        .map(|l| l.chars().collect())
        .collect();

    let b_test_lines: Vec<String> = include_str!("test-b.txt")
        .lines()
        .map(|l| l.chars().collect())
        .collect();

    println!("Day 01 part a test: {}", solve_a(a_test_lines));
    println!("Day 01 part a: {}", solve_a(lines.clone()));
    println!("Day 01 part b: {}", solve_b(b_test_lines));
    println!("Day 01 part b: {}", solve_b(lines));
}

fn solve_a(lines: Vec<String>) -> u32 {
    let mut res: u32 = 0;
    for line in lines {
        res += parse_line(line.clone());
    }
    res
}

fn solve_b(lines: Vec<String>) -> u32 {
    let mut res = 0;

    for line in lines {
        let slices = create_slices(&line);
        let values: Vec<u32> = slices
            .iter()
            .map(|slice| process_slice(slice))
            .filter(|v| v > &0)
            .collect();
        res += compute_res(values);
    }

    res
}

/// Returns a vector of string slices.
///
/// Returned vec is a sequence of first char, length 3, length 4, length 5 that is shifted then repeated.
///
/// ```rust
/// let slices = create_slices("two1two");
/// // ["t", "two", "two1", "two1t", "w", "wo1", "wo1t", "wo1tw", "o",
/// // "o1t", "o1tw", "o1two", "1", "1tw", "1two", "t", "two" "w", "o"]
/// ```
fn create_slices(line: &str) -> Vec<&str> {
    let mut i: usize = 0;
    let mut slices: Vec<&str> = vec![];

    while i < line.len() {
        let first_char = &line[i..i + 1];
        slices.push(first_char);

        if i + 2 < line.len() {
            slices.push(&line[i..i + 3])
        }

        if i + 3 < line.len() {
            slices.push(&line[i..i + 4])
        }

        if i + 4 < line.len() {
            slices.push(&line[i..i + 5])
        }

        i += 1;
    }
    slices
}

fn compute_res(vals: Vec<u32>) -> u32 {
    let vs: Vec<u32> = vals
        .iter()
        .map(|x| x.to_owned())
        .filter(|&x| x != 0)
        .collect();
    vs[0] * 10 + vs[vs.len() - 1]
}

fn parse_line(line: String) -> u32 {
    let mut first: String = find_val(line.clone());
    first.push_str(&find_val(line.clone().chars().rev().collect()));
    first.parse::<u32>().unwrap()
}

fn find_val(line: String) -> String {
    for char in line.chars() {
        let c = char.to_string();
        if c.parse::<u32>().is_ok() {
            return c;
        }
    }
    "".to_owned()
}

fn match_word(word: &str) -> u32 {
    match word {
        "one" => 1,
        "two" => 2,
        "three" => 3,
        "four" => 4,
        "five" => 5,
        "six" => 6,
        "seven" => 7,
        "eight" => 8,
        "nine" => 9,
        _ => 0,
    }
}

fn process_slice(s: &str) -> u32 {
    if s.len() == 1 {
        let num = s.parse::<u32>();

        if let Ok(num) = num {
            return num;
        }
    }

    match_word(s)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_match_word() {
        assert_eq!(1, match_word("one"));
        assert_eq!(2, match_word("two"));
        assert_eq!(3, match_word("three"));
        assert_eq!(4, match_word("four"));
        assert_eq!(5, match_word("five"));
        assert_eq!(6, match_word("six"));
        assert_eq!(7, match_word("seven"));
        assert_eq!(8, match_word("eight"));
        assert_eq!(9, match_word("nine"));
    }
    #[test]
    fn test_compute_res() {
        assert_eq!(11, compute_res(vec![1, 1]));
        assert_eq!(11, compute_res(vec![1, 3, 1]));
        assert_eq!(99, compute_res(vec![9, 3, 0, 0, 9]));
        assert_eq!(39, compute_res(vec![3, 9, 0, 0, 9]));
        assert_eq!(11, compute_res(vec![1]));
    }

    #[test]
    fn test_create_slices() {
        let expected = vec![
            "t", "two", "two1", "two1n", "w", "wo1", "wo1n", "wo1ni", "o", "o1n", "o1ni", "o1nin",
            "1", "1ni", "1nin", "1nine", "n", "nin", "nine", "i", "ine", "n",
        ];
        let slices = create_slices("two1nine");

        for (idx, expected_slice) in expected.iter().enumerate() {
            assert_eq!(&slices[idx], expected_slice)
        }
    }

    #[test]
    fn test_process_slice() {
        let expected: Vec<u32> = vec![
            0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 9, 0, 0, 0,
        ];
        let slices = create_slices("two1nine");

        for (idx, expected_slice) in expected.iter().enumerate() {
            assert_eq!(expected_slice, &process_slice(slices[idx]))
        }
    }
}
