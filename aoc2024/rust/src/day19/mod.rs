use std::sync::LazyLock;

use crate::{Day, Runner, Solution};

mod part1;
mod part2;

static TRIE: LazyLock<Vec<Trie>> = LazyLock::new(build_trie);

const INPUT: &str = crate::data!();
const DESIGN_END_INDEX: usize = {
    let mut design_start_index: usize = 0;
    let bytes = INPUT.as_bytes();

    loop {
        if design_start_index >= bytes.len() {
            break;
        }
        let byte = bytes[design_start_index];
        if byte == b'\n' {
            break;
        }

        design_start_index += 1;
    }

    design_start_index
};

const PATTERNS_STR: &str = &INPUT[..DESIGN_END_INDEX];
const PATTERNS_COUNT: usize = crate::count_char!(PATTERNS_STR, b',') + 1;
const PATTERNS: [&[u8]; PATTERNS_COUNT] = {
    let bytes = PATTERNS_STR.as_bytes();
    let text = PATTERNS_STR;

    let mut patterns: [&[u8]; PATTERNS_COUNT] = [&[]; PATTERNS_COUNT];
    let mut pattern_index: usize = 0;
    let mut start: usize = 0;
    let mut end: usize = start + 1;

    while end < bytes.len() {
        if pattern_index == PATTERNS_COUNT - 1 {
            patterns[pattern_index] = &text.as_bytes()[start..];
            break;
        }

        if bytes[end] == b',' {
            patterns[pattern_index] = &text.as_bytes()[start..end];
            start = end + 2;
            end = start + 1;
            pattern_index += 1;
            continue;
        }

        end += 1;
    }

    patterns
};

const DESIGNS_STR: &str = INPUT[DESIGN_END_INDEX + 2..].trim_ascii(); // + 2 to skip newlines
const DESIGNS_COUNT: usize = crate::count_char!(DESIGNS_STR, b'\n') + 1;
const DESIGNS_STR_ARRAY: [&str; DESIGNS_COUNT] = crate::split_str!(const DESIGNS_STR, '\n');
const DESIGNS: [&[u8]; DESIGNS_COUNT] = {
    let mut designs: [&[u8]; DESIGNS_COUNT] = [&[]; DESIGNS_COUNT];
    let mut i = 0;

    while i < DESIGNS_COUNT {
        designs[i] = DESIGNS_STR_ARRAY[i].as_bytes();

        i += 1;
    }

    designs
};

fn get_index(b: u8) -> usize {
    match b {
        b'b' => 0,
        b'w' => 1,
        b'u' => 2,
        b'r' => 3,
        b'g' => 4,
        _ => 0,
    }
}

#[derive(Debug, Default)]
struct Trie {
    term: bool,
    n: [usize; 5],
}

fn build_trie() -> Vec<Trie> {
    let mut t: Vec<Trie> = vec![Trie::default()];

    for pattern in PATTERNS {
        let mut ti = 0;

        for &byte in pattern {
            let ch = get_index(byte);
            let mut ni = t[ti].n[ch];

            if ni == 0 {
                ni = t.len();
                t[ti].n[ch] = ni;
                t.push(Trie::default());
            }
            ti = ni
        }
        t[ti].term = true
    }
    t
}

fn match_trie(design: &[u8], lengths: &mut [Option<usize>; 5]) {
    lengths.fill(None);
    let mut ti: usize = 0;
    let mut length_index: usize = 0;

    for i in 0..=design.len() {
        if TRIE[ti].term {
            lengths[length_index] = Some(i);
            length_index += 1;
        }
        if i == design.len() {
            break;
        }
        ti = TRIE[ti].n[get_index(design[i])];
        if ti == 0 {
            break;
        }
    }
}

fn count(design: &[u8]) -> usize {
    let mut d = vec![0; design.len() + 1];
    let mut lengths = [None; 5];
    d[0] = 1;

    for i in 0..design.len() {
        match_trie(&design[i..], &mut lengths);

        for &l in lengths.iter().flatten() {
            d[i + l] += d[i];
        }
    }

    d[d.len() - 1]
}

pub const SOLUTION: Solution = Solution {
    day: Day::Day19,
    p1: Runner {
        expected: 287,
        f: part1::solve,
    },
    p2: Runner {
        expected: 571894474468161,
        f: part2::solve,
    },
};
