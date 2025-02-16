pub mod part1;
pub mod part2;

fn into_isize_vec(line: &str) -> Vec<isize> {
    line.split_whitespace()
        .map(|s| s.parse().expect("Cannot parse to usize"))
        .collect()
}

pub fn in_range(vals: &[isize]) -> bool {
    vals.windows(2)
        .all(|win| (-3..=-1).contains(&(win[0] - win[1])))
}
