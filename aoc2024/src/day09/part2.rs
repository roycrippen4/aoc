use crate::data;

fn collect_files(data: &[Option<usize>]) -> Vec<(usize, usize)> {
    let mut files = Vec::new();
    let mut end = data.len() - 1;

    while end > 0 {
        while end > 0 && data[end].is_none() {
            end -= 1;
        }
        if data[end].is_none() && end == 0 {
            break;
        }
        let value = data[end].unwrap();
        let mut start = end;
        while start > 0 && data[start - 1] == Some(value) {
            start -= 1;
        }

        files.push((start, end));
        if start == 0 {
            break;
        } else {
            end = start - 1;
        }
    }
    files
}

fn collect_gaps(data: &[Option<usize>]) -> Vec<(usize, usize)> {
    let mut gaps = Vec::new();
    let mut i = 0;
    while i < data.len() {
        if data[i].is_none() {
            let gap_start = i;
            while i < data.len() && data[i].is_none() {
                i += 1;
            }
            let gap_len = i - gap_start;
            gaps.push((gap_start, gap_len));
        } else {
            i += 1;
        }
    }
    gaps
}

fn shift(data: &mut [Option<usize>]) {
    let files = collect_files(data);
    let mut gaps = collect_gaps(data);
    for &(file_start, file_end) in files.iter() {
        let file_size = file_end - file_start + 1;

        if let Some(gap_idx) = gaps
            .iter()
            .position(|&(gstart, glen)| gstart + glen <= file_start && glen >= file_size)
        {
            let (gstart, glen) = gaps[gap_idx];
            let (left, right) = data.split_at_mut(file_start);
            left[gstart..gstart + file_size].swap_with_slice(&mut right[0..file_size]);
            let new_gstart = gstart + file_size;
            let new_glen = glen - file_size;
            if new_glen == 0 {
                gaps.remove(gap_idx);
            } else {
                gaps[gap_idx] = (new_gstart, new_glen);
            }
        }
    }
}

fn expand(data: &str) -> Vec<Option<usize>> {
    let digits: Vec<usize> = data
        .trim()
        .bytes()
        .filter(|b| b.is_ascii_digit())
        .map(|b| (b - b'0') as usize)
        .collect();

    let mut result = Vec::with_capacity(digits.iter().sum());
    for (i, &n) in digits.iter().enumerate() {
        if i % 2 == 0 {
            for _ in 0..n {
                result.push(Some(i / 2));
            }
        } else {
            for _ in 0..n {
                result.push(None);
            }
        }
    }
    shift(&mut result);
    result
}

fn evaluate(input: &str) -> usize {
    let accumulate = |acc: usize, (i, v): (usize, &Option<usize>)| match v {
        Some(v) => acc + (v * i),
        None => acc,
    };
    expand(input).iter().enumerate().fold(0, accumulate)
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use crate::util::{validate, Day::Day09, Part::Part2};

    use super::{collect_files, collect_gaps, evaluate, expand, solve};

    static EXAMPLE: &str = "2333133121414131402";

    #[test]
    fn test_solve() {
        validate(solve, 6476642796832, Day09(Part2));
    }

    #[test]
    fn test_collect_gaps() {
        let gaps = collect_gaps(&DATA);
        dbg!(gaps);
    }

    #[test]
    fn test_collect_files() {
        let files = collect_files(&DATA);
        dbg!(files);
    }

    #[test]
    fn test_evaluate() {
        let result = evaluate(EXAMPLE);
        assert_eq!(2858, result);
    }

    #[test]
    fn test_expand() {
        let result = into_string(&expand(EXAMPLE));
        assert_eq!("00992111777.44.333....5555.6666.....8888..", result);
    }

    static DATA: [Option<usize>; 42] = [
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

    fn into_string(values: &[Option<usize>]) -> String {
        let m = |v: &Option<usize>| match v {
            Some(v) => v.to_string(),
            None => ".".to_string(),
        };

        values.iter().map(m).collect()
    }
}
