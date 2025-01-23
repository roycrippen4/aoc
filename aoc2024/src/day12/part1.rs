use crate::DIRECTIONS;

#[derive(Debug, Default)]
struct Grid {
    data: Vec<u8>,
    height: usize,
    width: usize,
}

impl Grid {
    pub fn new(input: &str) -> Self {
        let data: Vec<Vec<u8>> = input
            .trim()
            .split('\n')
            .map(|s| s.chars().map(|c| c as u8).collect())
            .collect();

        let height = data.len();
        let width = data[0].len();
        let data: Vec<u8> = data.into_iter().flatten().collect();

        Self {
            height,
            data,
            width,
        }
    }

    #[inline(always)]
    pub fn idx(&self, x: usize, y: usize) -> u8 {
        self.data[self.width * y + x]
    }
}

fn evaluate(data: &str) -> usize {
    let grid = Grid::new(data);
    let mut visited = vec![false; grid.width * grid.height];
    let mut total_price = 0;

    for y in 0..grid.height {
        for x in 0..grid.width {
            if visited[y * grid.width + x] {
                continue;
            }

            let current = grid.idx(x, y);
            let mut area = 0;
            let mut perimiter = 0;
            let mut q = Vec::from([(x, y)]);
            visited[y * grid.width + x] = true;

            while let Some((cx, cy)) = q.pop() {
                area += 1;

                for &(dx, dy) in &DIRECTIONS {
                    let nx = cx as isize + dx;
                    let ny = cy as isize + dy;
                    let out_of_bounds =
                        nx < 0 || nx >= grid.width as isize || ny < 0 || ny >= grid.height as isize;

                    if out_of_bounds {
                        perimiter += 1;
                        continue;
                    }

                    let nx = nx as usize;
                    let ny = ny as usize;

                    if grid.idx(nx, ny) != current {
                        perimiter += 1;
                    } else {
                        let idx = ny * grid.width + nx;
                        if !visited[idx] {
                            visited[idx] = true;
                            q.push((nx, ny));
                        }
                    }
                }
            }
            total_price += area * perimiter
        }
    }

    total_price
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{validate, Day::Day12, Part::Part1},
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

    static HARDER: &str = r"OOOOO
OXOXO
OOOOO
OXOXO
OOOOO";

    static SIMPLE: &str = r"AAAA
BBCD
BBCC
EEEC";
}
