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

#[rustfmt::skip]
fn count_corners((x, y, v): (usize, usize, u8), grid: &Grid) -> usize {
    let can_go_left  = x > 0;
    let can_go_right = x + 1 < grid.width;
    let can_go_up    = y > 0;
    let can_go_down  = y + 1 < grid.height;

    let same_left   = can_go_left  && grid.idx(x - 1, y) == v;
    let same_right  = can_go_right && grid.idx(x + 1, y) == v;
    let same_top    = can_go_up    && grid.idx(x, y - 1) == v;
    let same_bottom = can_go_down  && grid.idx(x, y + 1) == v;

    let same_bottom_left  = can_go_down && can_go_left  && grid.idx(x - 1, y + 1) == v;
    let same_bottom_right = can_go_down && can_go_right && grid.idx(x + 1, y + 1) == v;
    let same_top_left     = can_go_up   && can_go_left  && grid.idx(x - 1, y - 1) == v;
    let same_top_right    = can_go_up   && can_go_right && grid.idx(x + 1, y - 1) == v;

    let top_left_is_corner     = (!same_left  && !same_top)    || (same_left  && same_top    && !same_top_left);
    let top_right_is_corner    = (!same_right && !same_top)    || (same_right && same_top    && !same_top_right);
    let bottom_left_is_corner  = (!same_left  && !same_bottom) || (same_left  && same_bottom && !same_bottom_left);
    let bottom_right_is_corner = (!same_right && !same_bottom) || (same_right && same_bottom && !same_bottom_right);

    let corners: u8 = 
          u8::from(top_left_is_corner)
        + u8::from(top_right_is_corner)
        + u8::from(bottom_left_is_corner)
        + u8::from(bottom_right_is_corner);

    corners as usize
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

            let v = grid.idx(x, y);
            let mut q = Vec::from([(x, y)]);
            let mut area = 0;
            let mut sides = 0;
            visited[y * grid.width + x] = true;

            while let Some((cx, cy)) = q.pop() {
                area += 1;
                sides += count_corners((cx, cy, v), &grid);
                for &(dx, dy) in &DIRECTIONS {
                    let (nx, ny) = (cx as isize + dx, cy as isize + dy);
                    let (nx_usize, ny_usize) = (nx as usize, ny as usize);
                    if nx < 0 || nx_usize >= grid.width || ny < 0 || ny_usize >= grid.height {
                        continue;
                    }

                    let (nx, ny) = (nx as usize, ny as usize);
                    let idx = ny * grid.width + nx;

                    if grid.data[idx] != v || std::mem::replace(&mut visited[idx], true) {
                        continue;
                    }

                    q.push((nx, ny));
                }
            }
            total_price += area * sides;
        }
    }

    total_price
}

pub fn solve() -> usize {
    evaluate(include_str!("data/data.txt"))
}

#[cfg(test)]
mod test {
    use super::{Grid, evaluate, solve};
    use crate::day12::part2::count_corners;
    use crate::example;
    use crate::util::Day::Day12;
    use crate::util::validate;

    #[test]
    fn test_solve() {
        validate(solve, 830516, Day12);
    }

    #[test]
    fn test_evaluate() {
        assert_eq!(evaluate("AAAA"), 16);
        assert_eq!(evaluate(SIMPLE), 80);
        assert_eq!(evaluate(E), 236);
        assert_eq!(evaluate(HARD), 368);
        assert_eq!(evaluate(example!()), 1206);
    }

    #[test]
    fn test_corner_detection() {
        let grid = Grid::new(LINE);
        let sides = [(0, 1, b'X'), (1, 1, b'X'), (2, 1, b'X')]
            .iter()
            .map(|p| count_corners(*p, &grid))
            .sum::<usize>();
        assert_eq!(4, sides);

        let grid = Grid::new(L_SHAPE);
        let sides: usize = [(1, 0, b'X'), (1, 1, b'X'), (0, 2, b'X')]
            .iter()
            .map(|p| count_corners(*p, &grid))
            .sum::<usize>();
        assert_eq!(6, sides);

        let grid = Grid::new(BOX);
        let sides = [(1, 1, b'X'), (2, 1, b'X'), (2, 2, b'X'), (1, 2, b'X')]
            .iter()
            .map(|p| count_corners(*p, &grid))
            .sum::<usize>();
        assert_eq!(sides, 4);

        assert_eq!(4, count_corners((1, 1, b'X'), &Grid::new(SINGLETON)));

        let grid = Grid::new(S_SHAPE);
        let sides = [(1, 1, b'X'), (1, 2, b'X'), (2, 2, b'X'), (2, 3, b'X')]
            .iter()
            .map(|p| count_corners(*p, &grid))
            .sum::<usize>();
        assert_eq!(sides, 8);
    }

    const LINE: &str = "
OOO
XXX
OOO
";

    const L_SHAPE: &str = "
OXO
XXO
OOO
";

    const BOX: &str = "
OOOOO
OXXOO
OXXOO
OOOOO
OOOOO
";

    const SINGLETON: &str = "
OOO
OXO
OOO
";

    const S_SHAPE: &str = "
OOOOO
OXOOO
OXXOO
OOXOO
OOOOO
";

    const SIMPLE: &str = "
AAAA
BBCD
BBCC
EEEC
";
    const E: &str = "
EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
";
    const HARD: &str = "
AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA
";
}
