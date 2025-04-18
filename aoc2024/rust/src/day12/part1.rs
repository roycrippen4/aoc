use crate::{DIRECTIONS, data};

fn evaluate(input: &str) -> usize {
    let trimmed = input.trim();
    let size = trimmed.lines().count();
    let grid: Vec<u8> = trimmed.lines().flat_map(|l| l.bytes()).collect();
    let mut seen = vec![false; grid.len()];

    (0..grid.len()).fold(0, |acc, i| acc + flood(i, &grid, size, &mut seen))
}

fn flood(start: usize, g: &[u8], size: usize, seen: &mut [bool]) -> usize {
    let mut stack = vec![start];
    let mut area = 0;
    let mut peri = 0;
    let current = g[start];

    while let Some(i) = stack.pop() {
        if seen[i] {
            continue;
        }

        seen[i] = true;
        area += 1;

        let (x, y) = (i % size, i / size);
        for (dx, dy) in DIRECTIONS {
            let nx = x as isize + dx;
            let ny = y as isize + dy;

            if nx < 0 || ny < 0 || nx >= size as isize || ny >= size as isize {
                peri += 1;
                continue;
            }

            let ni = ny as usize * size + nx as usize;
            if g[ni] != current {
                peri += 1
            } else if !seen[ni] {
                stack.push(ni);
            }
        }
    }

    area * peri
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{Day::Day12, Part::Part1, validate},
    };

    use super::{evaluate, solve};

    #[test]
    fn test_solve() {
        validate(solve, 1361494, Day12(Part1));
    }

    #[test]
    fn test_evaluate() {
        assert_eq!(evaluate(SIMPLE), 140);
        assert_eq!(evaluate(HARDER), 772);
        assert_eq!(evaluate(example!()), 1930);
    }

    const HARDER: &str = r"OOOOO
OXOXO
OOOOO
OXOXO
OOOOO";

    const SIMPLE: &str = r"AAAA
BBCD
BBCC
EEEC";
}
