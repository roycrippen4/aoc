use std::collections::HashMap;
use std::collections::hash_map::Entry;

use crate::data;
use crate::util::StringMethods;

type OrderMap = HashMap<usize, Vec<usize>>;

/// will panic if values does not have an odd length
fn get_middle<T: Copy>(values: &[T]) -> T {
    assert!(!values.len().is_multiple_of(2));
    let mid_idx = (values.len() - 1) / 2;
    values[mid_idx]
}

fn parse_updates(s: &str) -> Vec<Vec<usize>> {
    s.lines()
        .filter(StringMethods::is_not_empty)
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

fn is_in_order(update: &[usize], map: &OrderMap) -> bool {
    for i in 0..update.len() - 1 {
        if let Some(mapping) = map.get(&update[i]) {
            if !mapping.contains(&update[i + 1]) {
                return false;
            }
        } else {
            return false;
        }
    }

    true
}

// MAPPINGS
// 29 -> 13
// 47 -> 13, 53, 29, 61
// 53 -> 13, 29
// 61 -> 13, 29, 53
// 75 -> 13, 29, 47, 53, 61
// 97 -> 13, 29, 47, 53, 61, 75
//
// ALGO: Naive swap
// ORDER 97, 13, 75, 29, 47
// 1. 97 --> 13
// 2. 13 -!> 75 order => 97, 75, 13, 29, 47
// 3. 75 --> 13
// 4. 13 -!> 29 order => 97, 75, 29, 13, 47
// 5. 29 --> 13
// 6. 13 -!> 47 order => 97, 75, 29, 47, 13
// 7. 47 --> 13
// 8. is_in_order(97, 75, 29, 47, 13)? false. rerun
// 9. 97 --> 75
//10. 75 --> 29
//11. 29 -!> 47 order => 97, 75, 47, 29, 13
//12. 47 --> 29
//13. 29 --> 13
// DONE. 97, 75, [47], 29, 13
//
// DONE. 61, [29], 13
//
// ORDER 61, 13, 29
// 1. 61 --> 13
// 2. 13 -!> 29 order => 61, 29, 13
// 3. 29 --> 13
// DONE. 61, [29], 13
//
//
// ORDER 75, 97, 47, 61, 53
// 1. 75 -!> 97 order => 97, 75, 47, 61, 53
// 2. 97 --> 75
// 3. 75 --> 47
// 4. 47 --> 61
// 5. 61 --> 53
// DONE. 97, 75, [47], 61, 53

// ALGO: Naive swap
// ORDER 97, 13, 75, 29, 47
// 1. 97 --> 13
// 2. 13 -!> 75 order => 97, 75, 13, 29, 47
// 3. 75 --> 13
// 4. 13 -!> 29 order => 97, 75, 29, 13, 47
// 5. 29 --> 13
// 6. 13 -!> 47 order => 97, 75, 29, 47, 13
// 7. 47 --> 13
// 8. is_in_order(97, 75, 29, 47, 13)? false. rerun
// 9. 97 --> 75
//10. 75 --> 29
//11. 29 -!> 47 order => 97, 75, 47, 29, 13
//12. 47 --> 29
//13. 29 --> 13
// DONE. 97, 75, [47], 29, 13
fn fix_order(update: &mut [usize], map: &OrderMap) -> Vec<usize> {
    for i in 0..update.len() - 1 {
        if let Some(mapping) = map.get(&update[i]) {
            if !mapping.contains(&update[i + 1]) {
                update.swap(i, i + 1);
            }
        } else {
            update.swap(i, i + 1);
        }
    }

    if is_in_order(update, map) {
        return Vec::from(update);
    }

    fix_order(update, map) // my tail always be recursing
}

pub fn solve() -> usize {
    let input: Vec<String> = data!().split("\n\n").map(String::from).collect();

    let [rules_raw, order_raw] = [&input[0], &input[1]];
    let map = parse_order_rules(rules_raw);
    parse_updates(order_raw)
        .iter_mut()
        .filter(|u| !is_in_order(u, &map))
        .map(|u| get_middle(&fix_order(u, &map)))
        .sum()
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{Day::Day05, validate},
    };

    use super::{OrderMap, fix_order, get_middle, parse_order_rules, parse_updates, solve};

    #[test]
    fn test_solve() {
        validate(solve, 4230, Day05);
    }

    #[test]
    fn test_fix_order() {
        let map = get_map();
        let result = fix_order(&mut [75, 97, 47, 61, 53], &map);
        let expected = vec![97, 75, 47, 61, 53];
        assert_eq!(expected, result);

        let result = fix_order(&mut [61, 13, 29], &map);
        let expected = vec![61, 29, 13];
        assert_eq!(expected, result);

        let result = fix_order(&mut [97, 13, 75, 29, 47], &map);
        let expected = vec![97, 75, 47, 29, 13];
        assert_eq!(expected, result);
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

    fn get_map() -> OrderMap {
        parse_order_rules(
            &example!()
                .split("\n\n")
                .map(String::from)
                .collect::<Vec<String>>()[0],
        )
    }
}
