use hashbrown::HashMap;

use crate::data;

fn num_digits(mut n: usize) -> usize {
    if n == 0 {
        return 1;
    }
    let mut digits = 0;
    while n > 0 {
        n /= 10;
        digits += 1;
    }
    digits
}

fn split_in_half(n: usize) -> (usize, usize) {
    let half = num_digits(n) / 2;
    let divisor = 10_usize.pow(half as u32);
    (n / divisor, n % divisor)
}

fn evaluate(data: &str, iterations: usize) -> usize {
    let mut stones: HashMap<usize, usize> = HashMap::new();

    for s in data.split_whitespace() {
        let val = s.parse::<usize>().unwrap();
        *stones.entry(val).or_insert(0) += 1;
    }

    for _ in 0..iterations {
        let mut new_stones: HashMap<usize, usize> = HashMap::new();
        for (&val, &amount) in stones.iter() {
            if val == 0 {
                *new_stones.entry(1).or_insert(0) += amount;
            } else {
                let d = num_digits(val);
                if d % 2 == 0 {
                    let (first, second) = split_in_half(val);
                    *new_stones.entry(first).or_insert(0) += amount;
                    *new_stones.entry(second).or_insert(0) += amount;
                } else {
                    *new_stones.entry(val * 2024).or_insert(0) += amount;
                }
            }
        }
        stones = new_stones
    }

    stones.values().sum()
}

pub fn solve() -> usize {
    evaluate(data!(), 75)
}

#[cfg(test)]
mod test {

    use crate::util::{validate, Day::Day11, Part::Part2};

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 261936432123724, Day11(Part2));
    }

    #[test]
    fn test_evaluate() {
        let result = evaluate("125 17", 25);
        dbg!(result);
    }
}
