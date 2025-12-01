use super::{LEN, PROGRAM, run};

const POW8: [usize; 16] = [
    1,
    8,
    64,
    512,
    4096,
    32768,
    262144,
    2097152,
    16777216,
    134217728,
    1073741824,
    8589934592,
    68719476736,
    549755813888,
    4398046511104,
    35184372088832,
];

fn update_factors(factors: &mut [usize], output: &[usize]) {
    let mut i = LEN;

    while i > 0 {
        let i_ = i - 1;
        if output.len() < i_ || output[i_] != PROGRAM[i_] {
            factors[i_] += 1;
            break;
        }

        i -= 1;
    }
}

fn get_initial_a(factors: &[usize]) -> usize {
    let mut a = 0;
    let mut i = 0;

    while i != LEN {
        a += POW8[i] * factors[i];
        i += 1;
    }

    a
}

pub fn solve() -> usize {
    let mut factors: Vec<usize> = std::iter::repeat_n(0, LEN).collect();

    loop {
        let a = get_initial_a(&factors);
        let output = run(a, 0, 0);

        if output == PROGRAM {
            return a;
        }
        update_factors(&mut factors, &output);
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_solve() {
        dbg!(solve());
    }
}
