use crate::data;

fn expand(data: &str) -> Vec<Option<usize>> {
    let digits: Vec<usize> = data
        .trim()
        .bytes()
        .filter(|b| b.is_ascii_digit())
        .map(|b| (b - b'0') as usize)
        .collect();

    let capacity = digits.iter().sum();
    let mut result = Vec::with_capacity(capacity);

    for (i, &n) in digits.iter().enumerate() {
        if i % 2 == 0 {
            let value = Some(i / 2);
            for _ in 0..n {
                result.push(value);
            }
        } else {
            for _ in 0..n {
                result.push(None);
            }
        }
    }

    result
}

fn evaluate(data: &str) -> usize {
    let data = expand(data);
    let mut id = 0;
    let mut result = 0;
    let (mut i, mut j) = (0, data.len() - 1);

    while i <= j {
        if let Some(next) = data[i] {
            result += id * next;
            id += 1;
        } else {
            while i <= j {
                if let Some(next) = data[j] {
                    result += id * next;
                    id += 1;
                    j -= 1;
                    break;
                }
                j -= 1
            }
        }
        i += 1;
    }
    result
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {

    use crate::{
        example,
        util::{validate, Day::Day09, Part::Part1},
    };

    use super::{evaluate, expand, solve};

    #[test]
    fn test_solve() {
        validate(solve, 6448989155953, Day09(Part1));
    }

    #[test]
    fn test_evaluate_simple() {
        let data = "12345";
        dbg!(evaluate(data));
    }

    #[test]
    fn test_evaluate() {
        dbg!(evaluate(example!()));
    }

    #[test]
    fn test_expand() {
        let result = expand("12345");
        let expected = [
            Some(0),
            None,
            None,
            Some(1),
            Some(1),
            Some(1),
            None,
            None,
            None,
            None,
            Some(2),
            Some(2),
            Some(2),
            Some(2),
            Some(2),
        ];
        assert_eq!(result, expected);

        let result = expand("2333133121414131402");
        let expected = [
            Some(0),
            Some(0),
            None,
            None,
            None,
            Some(1),
            Some(1),
            Some(1),
            None,
            None,
            None,
            Some(2),
            None,
            None,
            None,
            Some(3),
            Some(3),
            Some(3),
            None,
            Some(4),
            Some(4),
            None,
            Some(5),
            Some(5),
            Some(5),
            Some(5),
            None,
            Some(6),
            Some(6),
            Some(6),
            Some(6),
            None,
            Some(7),
            Some(7),
            Some(7),
            None,
            Some(8),
            Some(8),
            Some(8),
            Some(8),
            Some(9),
            Some(9),
        ];
        assert_eq!(result, expected);
    }
}
