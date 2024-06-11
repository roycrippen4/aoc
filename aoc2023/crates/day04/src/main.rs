use std::collections::HashSet;

fn main() {
    let test: Vec<&str> = include_str!("test.txt").lines().collect();
    let lines: Vec<&str> = include_str!("input.txt").lines().collect();

    println!("Day 01 part a test: {}", solve_a(&test)); // 13
    println!("Day 01 part b test: {}", solve_b(&test)); // 30
    println!("Day 01 part a: {}", solve_a(&lines)); // 27059
    println!("Day 01 part b: {}", solve_b(&lines)); // 5744979
}

fn solve_a(lines: &[&str]) -> usize {
    lines.iter().map(|l| Card::new(l)).map(|c| c.score()).sum()
}

fn solve_b(lines: &[&str]) -> usize {
    let mut cards: Vec<Card> = lines.iter().map(|l| Card::new(l)).collect();

    (0..cards.len()).for_each(|idx| {
        let matches = &cards[idx].find_matches().len();
        let count = cards[idx].count;

        for i in idx + 1..idx + 1 + matches {
            if i < cards.len() {
                cards[i].count += count
            }
        }
    });

    cards.iter().map(|c| c.count).sum()
}

fn parse(str: &str) -> Vec<usize> {
    let mut nums: Vec<usize> = str
        .split(' ')
        .filter(|c| !c.is_empty())
        .map(|c| c.parse::<usize>().unwrap())
        .collect();

    nums.sort();
    nums
}

fn parse_nums(num_str: &str) -> (Vec<usize>, Vec<usize>) {
    let (win_str, elf_str) = num_str.split_once(" | ").unwrap();
    (parse(win_str), parse(elf_str))
}

#[derive(Debug, Clone)]
struct Card {
    win_nums: Vec<usize>,
    elf_nums: Vec<usize>,
    count: usize,
}

impl Card {
    fn score(&self) -> usize {
        let len: usize = self.find_matches().len();
        match len {
            0 => 0,
            _ => usize::pow(2, (len as u32) - 1),
        }
    }

    fn find_matches(&self) -> Vec<&usize> {
        let set: HashSet<_> = self.win_nums.iter().collect();
        self.elf_nums
            .iter()
            .filter(|&&n| set.contains(&n))
            .collect()
    }

    fn new(line: &str) -> Card {
        let (_, num_part) = line.split_once(':').unwrap();
        let (win_nums, elf_nums) = parse_nums(num_part);

        Card {
            win_nums,
            elf_nums,
            count: 1,
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_score() {
        let cards: Vec<Card> = vec![
            Card {
                win_nums: vec![41, 48, 83, 86, 17],
                elf_nums: vec![83, 86, 6, 31, 17, 9, 48, 53],
                count: 1,
            },
            Card {
                win_nums: vec![13, 32, 20, 16, 61],
                elf_nums: vec![61, 30, 68, 82, 17, 32, 24, 19],
                count: 1,
            },
            Card {
                win_nums: vec![1, 21, 53, 59, 44],
                elf_nums: vec![69, 82, 63, 72, 16, 21, 14, 1],
                count: 1,
            },
            Card {
                win_nums: vec![1, 92, 73, 84, 69],
                elf_nums: vec![59, 84, 76, 51, 58, 5, 54, 83],
                count: 1,
            },
            Card {
                win_nums: vec![7, 83, 26, 28, 32],
                elf_nums: vec![88, 30, 70, 12, 93, 22, 82, 36],
                count: 1,
            },
            Card {
                win_nums: vec![31, 18, 13, 56, 72],
                elf_nums: vec![74, 77, 10, 23, 35, 67, 36, 11],
                count: 1,
            },
        ];

        let result: usize = cards.iter().fold(0, |acc, card| acc + card.score());
        assert_eq!(13, result)
    }
}
