use std::collections::HashMap;

use crate::data;

fn into_tuple(line: &str) -> (usize, usize) {
    let mut pair = line.split("  ");
    let left = pair.next().unwrap().trim().parse().unwrap();
    let right = pair.next().unwrap().trim().parse().unwrap();
    (left, right)
}

fn create_lookup(arr: &[usize]) -> HashMap<usize, usize> {
    let mut map: HashMap<usize, usize> = HashMap::new();
    arr.iter().for_each(|&n| *map.entry(n).or_insert(0) += 1);
    map
}

pub fn solve() -> usize {
    let (left, right): (Vec<_>, Vec<_>) = data!().lines().map(into_tuple).unzip();

    let left = create_lookup(&left);
    let right = create_lookup(&right);
    let mut total = 0;

    for (key, l_value) in &left {
        let r_value = *right.get(key).unwrap_or(&0);
        total += key * r_value * l_value
    }

    total
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day::Day01, Part::Part2};

    use super::solve;

    #[test]
    fn test_solve() {
        validate(solve, 23126924, Day01(Part2));
    }
}
