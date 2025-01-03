use std::collections::{hash_map::Entry, HashMap};

use crate::debug;

type OrderMap = HashMap<usize, Vec<usize>>;

static DEBUG: bool = false;

/// will panic if values does not have an odd length
fn get_middle<T: Copy>(values: &[T]) -> T {
    assert!(values.len() % 2 != 0);
    let mid_idx = (values.len() - 1) / 2;
    values[mid_idx]
}

fn parse_updates(s: &str) -> Vec<Vec<usize>> {
    s.split('\n')
        .filter(|s| !s.is_empty())
        .map(|s| {
            s.split(',')
                .map(|s| s.parse().expect("Cannot parse to usize"))
                .collect()
        })
        .collect()
}

/// creates a hashmap of the order rules
fn parse_order_rules(s: &str) -> OrderMap {
    let mut map: OrderMap = HashMap::new();
    let pairs: Vec<_> = s
        .split_whitespace()
        .map(|s| s.split('|').map(|s| s.parse().unwrap()).collect::<Vec<_>>())
        .collect();

    for pair in pairs {
        let [key, value] = [pair[0], pair[1]];
        if let Entry::Vacant(e) = map.entry(key) {
            let value = vec![value];
            e.insert(value);
        } else {
            map.get_mut(&key).unwrap().push(value);
        }
    }

    map
}

fn evaluate(update: &[usize], map: &OrderMap) -> usize {
    debug!("{:?}", update);
    for i in 0..update.len() - 1 {
        let key = update[i];
        let value = update[i + 1];
        debug!("{} -> {}", key, value);

        if let Some(mapping) = map.get(&key) {
            if !mapping.contains(&value) {
                debug!("{:?} does not contain {value}\n", mapping);
                return 0;
            }
        } else {
            debug!("Map does not contain key {key}\n");
            return 0;
        }
    }

    let middle = get_middle(update);
    debug!(
        "Order rules followed for {:?}\nReturning {middle}\n",
        update
    );
    middle
}

#[allow(unused)]
fn example() -> usize {
    let input: Vec<String> = include_str!("../data/day05/example.txt")
        .split("\n\n")
        .map(String::from)
        .collect();

    let [rules_raw, order_raw] = [&input[0], &input[1]];
    let map = parse_order_rules(rules_raw);
    let updates = parse_updates(order_raw);
    updates.iter().map(|update| evaluate(update, &map)).sum()
}

pub fn solve() -> usize {
    let input: Vec<String> = include_str!("../data/day05/data.txt")
        .split("\n\n")
        .map(String::from)
        .collect();

    let [rules_raw, order_raw] = [&input[0], &input[1]];
    let map = parse_order_rules(rules_raw);
    let updates = parse_updates(order_raw);
    updates.iter().map(|update| evaluate(update, &map)).sum()
}

#[cfg(test)]
mod test {
    use crate::util::validate;

    use super::{example, get_middle, parse_order_rules, parse_updates, solve};

    #[test]
    fn test_solve() {
        validate(
            solve,
            7198,
            crate::util::Day::Day05,
            crate::util::Kind::Part1,
        );
    }

    #[test]
    fn test_example() {
        let result = example();
        assert_eq!(143, result);
    }

    #[test]
    fn test_parse_updates() {
        let raw =
            "75,47,61,53,29\n97,61,53,29,13\n75,29,13\n75,97,47,61,53\n61,13,29\n97,13,75,29,47\n";
        let expected = vec![
            vec![75, 47, 61, 53, 29],
            vec![97, 61, 53, 29, 13],
            vec![75, 29, 13],
            vec![75, 97, 47, 61, 53],
            vec![61, 13, 29],
            vec![97, 13, 75, 29, 47],
        ];

        assert_eq!(expected, parse_updates(raw));
    }

    #[test]
    fn test_parse_order_rules() {
        let raw = "47|53\n97|13\n97|61\n97|47\n75|29\n61|13\n75|53\n29|13\n97|29\n53|29\n61|53\n97|53\n61|29\n47|13\n75|47\n97|75\n47|61\n75|61\n47|29\n75|13\n53|13";
        let _ = parse_order_rules(raw);
    }

    #[test]
    fn test_get_middle() {
        let input = &[1, 2, 3, 4, 5];
        let result = get_middle(input);
        assert_eq!(3, result);

        let input = &[1, 2, 3, 4, 5, 6, 7];
        let result = get_middle(input);
        assert_eq!(4, result);
    }

    #[test]
    #[should_panic(expected = "assertion failed: values.len() % 2 != 0")]
    fn test_get_middle_panic() {
        get_middle(&[1, 2, 4, 5]); // should panic since even number of items
    }
}
