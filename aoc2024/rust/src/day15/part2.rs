use std::str::FromStr;

use crate::data;
use crate::util::{Entry, Grid, Point};

#[repr(u8)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Kind {
    Bot,
    Start,
    End,
    Empty,
    Wall,
}

impl From<Kind> for char {
    fn from(k: Kind) -> Self {
        match k {
            Kind::Bot => '@',
            Kind::Start => '[',
            Kind::End => ']',
            Kind::Empty => '.',
            Kind::Wall => '#',
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

impl From<char> for Direction {
    fn from(ch: char) -> Self {
        match ch {
            '^' => Direction::Up,
            'v' => Direction::Down,
            '<' => Direction::Left,
            '>' => Direction::Right,
            _ => unreachable!(),
        }
    }
}

#[derive(Default)]
struct Scratch {
    seen: Vec<u32>,
    epoch: u32,
    moves: Vec<Entry<Kind>>,
    w: usize,
    h: usize,
}

impl Scratch {
    fn new(w: usize, h: usize) -> Self {
        Self {
            seen: vec![0; w * h],
            epoch: 1,
            moves: Vec::with_capacity(256),
            w,
            h,
        }
    }

    #[inline]
    fn idx(&self, x: isize, y: isize) -> usize {
        (y * self.w as isize + x) as usize
    }

    #[inline]
    fn mark(&mut self) -> u32 {
        let e = self.epoch;
        self.epoch = self.epoch.wrapping_add(1);
        if self.epoch == 0 {
            self.seen.fill(0);
            self.epoch = 1;
        }
        e
    }
}

fn collect_moves(grid: &Grid<Kind>, p: Point, dy: isize, s: &mut Scratch, tag: u32) -> bool {
    let k = grid[p];
    if !matches!(k, Kind::Start | Kind::End) {
        return false;
    }

    let ox = if k == Kind::Start { p.x + 1 } else { p.x - 1 };
    let i1 = s.idx(p.x, p.y);
    let i2 = s.idx(ox, p.y);
    if s.seen[i2] == tag {
        return true;
    }

    s.seen[i1] = tag;
    s.seen[i2] = tag;

    let ny = match p.y.checked_add(dy) {
        Some(v) if v >= 0 && (v as usize) < s.h => v,
        _ => return false,
    };

    let ok1 = match grid[(p.x, ny)] {
        Kind::Start | Kind::End => collect_moves(grid, Point::new(p.x, ny), dy, s, tag),
        Kind::Empty => true,
        _ => false,
    };
    if !ok1 {
        return false;
    }

    let ok2 = match grid[(ox, ny)] {
        Kind::Start | Kind::End => collect_moves(grid, Point::new(ox, ny), dy, s, tag),
        Kind::Empty => true,
        _ => false,
    };
    if !ok2 {
        return false;
    }

    s.moves.push((p.x, p.y, k));
    s.moves.push((ox, p.y, grid[(ox, p.y)]));
    true
}

fn move_vert(grid: &mut Grid<Kind>, bot: &mut Point, p: Point, up: bool, s: &mut Scratch) {
    let dy = if up { -1 } else { 1 };
    let tag = s.mark();
    s.moves.clear();

    if !collect_moves(grid, p, dy, s, tag) {
        return;
    }

    for (x, y, k) in s.moves.drain(..) {
        grid[(x, y)] = Kind::Empty;
        grid[(x, (y + dy))] = k;
    }
    bot.y = p.y;
}

fn step(b: &mut Point, g: &mut Grid<Kind>, d: Direction, s: &mut Scratch) {
    match d {
        Direction::Left => match g[(b.x - 1, b.y)] {
            Kind::End => move_left(b.x - 3, b, g),
            Kind::Empty => b.x -= 1,
            _ => (),
        },
        Direction::Right => match g[(b.x + 1, b.y)] {
            Kind::Start => move_right(b.x + 3, b, g),
            Kind::Empty => b.x += 1,
            _ => (),
        },
        vert => {
            let up = vert == Direction::Up;
            let dy = if up { b.y - 1 } else { b.y + 1 };
            let dp = Point::new(b.x, dy);
            match g[(b.x, dy)] {
                Kind::Start | Kind::End => move_vert(g, b, dp, up, s),
                Kind::Empty => b.y = dy,
                _ => (),
            }
        }
    }
}

fn parse_grid(s: &str) -> Grid<Kind> {
    let mut grid_string = String::with_capacity(s.len() * 2);

    const WALL: &str = "##";
    const BOX: &str = "[]";
    const EMPTY: &str = "..";
    const GUARD: &str = "@.";

    s.chars().for_each(|c| match c {
        '#' => grid_string.push_str(WALL),
        'O' => grid_string.push_str(BOX),
        '.' => grid_string.push_str(EMPTY),
        '@' => grid_string.push_str(GUARD),
        '\n' => grid_string.push('\n'),
        c => unreachable!("{c} is an invalid character!"),
    });

    Grid::from_str(&grid_string)
        .unwrap()
        .map_values(|v| match v {
            '@' => Kind::Bot,
            '[' => Kind::Start,
            ']' => Kind::End,
            '.' => Kind::Empty,
            '#' => Kind::Wall,
            _ => unreachable!(),
        })
}

fn parse_directions(s: &str) -> Vec<Direction> {
    s.lines()
        .flat_map(|l| l.chars())
        .map(Direction::from)
        .collect()
}

fn parse_input(data: &str) -> (Grid<Kind>, Vec<Direction>) {
    data.trim()
        .split_once("\n\n")
        .map(|(g, d)| (parse_grid(g.trim()), parse_directions(d.trim())))
        .unwrap()
}

fn get_bot(grid: &mut Grid<Kind>) -> Point {
    let (x, y, _) = grid.find_replace(|(_, _, k)| *k == Kind::Bot, Kind::Empty);
    Point::new(x, y)
}

fn move_right(x: isize, bot: &mut Point, grid: &mut Grid<Kind>) {
    let mut x = x;

    loop {
        match grid[(x, bot.y)] {
            Kind::Start => x += 2,
            Kind::Empty => loop {
                if x == bot.x {
                    bot.x += 1;
                    return;
                }
                _ = grid.set((x, bot.y), grid[(x - 1, bot.y)]);
                x -= 1;
            },
            _ => break,
        }
    }
}

fn move_left(x: isize, bot: &mut Point, grid: &mut Grid<Kind>) {
    let mut x = x;

    loop {
        match grid[(x, bot.y)] {
            Kind::End => x -= 2,
            Kind::Empty => loop {
                if x == bot.x {
                    bot.x -= 1;
                    return;
                }
                _ = grid.set((x, bot.y), grid[(x + 1, bot.y)]);
                x += 1;
            },
            _ => break,
        }
    }
}

fn evaluate(data: &str) -> usize {
    let (mut grid, directions) = parse_input(data);
    let mut bot = get_bot(&mut grid);
    let mut scratch = Scratch::new(grid.width, grid.height);

    for d in directions {
        step(&mut bot, &mut grid, d, &mut scratch);
    }

    // sum directly (avoid building a Vec)
    let mut acc = 0usize;
    for y in 0..grid.height {
        for x in 0..grid.width {
            if grid[(x as isize, y as isize)] == Kind::Start {
                acc += 100 * y + x;
            }
        }
    }
    acc
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use super::{evaluate, solve};
    use crate::example;

    #[test]
    fn test_solve() {
        assert_eq!(solve(), 1535509);
    }

    #[test]
    fn test_evaluate() {
        let result = evaluate(example!());
        dbg!(result);
    }
}
