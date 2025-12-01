use std::collections::VecDeque;

use crate::data;

use super::{AREA, BestPaths, DIRECTIONS, END, START, Seen, State, dfs, index};

fn rev_dfs(todo: &mut VecDeque<State>, best_paths: &mut BestPaths, seen: &mut Seen) {
    let Some((pos, dir, cost)) = todo.pop_front() else {
        return;
    };
    best_paths[index(pos)] = true;

    if pos == START {
        return rev_dfs(todo, best_paths, seen);
    }

    let fwd = (pos - DIRECTIONS[dir], dir, cost - 1);
    let left = (pos, (dir + 3) % 4, cost - 1000);
    let right = (pos, (dir + 1) % 4, cost - 1000);

    for (pos, dir, cost) in [fwd, left, right] {
        let idx = index(pos);
        if cost == seen[idx][dir] {
            todo.push_back((pos, dir, cost));
            seen[idx][dir] = usize::MAX;
        }
    }

    rev_dfs(todo, best_paths, seen);
}

fn evaluate(data: &str) -> usize {
    let grid: Vec<_> = data.lines().flat_map(|l| l.chars()).collect();

    let mut seen = [[usize::MAX; 4]; AREA];
    let mut best_paths: BestPaths = [false; AREA];

    let mut first: VecDeque<State> = VecDeque::new();
    let mut second: VecDeque<State> = VecDeque::new();
    let mut lowest: usize = usize::MAX;

    first.push_back((START, 0, 0));
    seen[index(START)][0] = 0;

    while !first.is_empty() {
        dfs(&mut first, &mut second, &mut lowest, &mut seen, &grid);
        std::mem::swap(&mut first, &mut second);
    }

    let mut todo = VecDeque::new();
    for dir in [0, 1, 2, 3] {
        if seen[index(END)][dir] == lowest {
            todo.push_back((END, dir, lowest));
        }
    }

    rev_dfs(&mut todo, &mut best_paths, &mut seen);

    best_paths
        .into_iter()
        .fold(0, |acc, bool| if bool { acc + 1 } else { acc })
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use super::solve;
    use crate::util::{Day::Day16, validate};

    #[test]
    fn test_solve() {
        validate(solve, 622, Day16);
    }
}
