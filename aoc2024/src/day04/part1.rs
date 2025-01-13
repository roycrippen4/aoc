use crate::{
    data,
    util::{create_pad, into_padded_string, StringMethods},
};

fn create_grid(input: &str) -> Vec<Vec<char>> {
    let mut data: Vec<String> = input.lines().map(|s| into_padded_string(&s)).collect();
    let row_len = data[0].len();
    let pad = create_pad(row_len, '.');
    let pad_rows = vec![pad.clone(); 4];
    data.splice(0..0, pad_rows.clone());
    data.extend(pad_rows);
    data.into_iter().map(|r| r.to_char_vec()).collect()
}

static XMAS: [char; 4] = ['X', 'M', 'A', 'S'];

pub fn solve() -> usize {
    let g = create_grid(data!());
    (3..g.len() - 3)
        .map(|y| {
            (3..g[0].len() - 3)
                .map(|x| {
                    let mut count = 0;
                    if [g[y][x], g[y][x - 1], g[y][x - 2], g[y][x - 3]] == XMAS {
                        count += 1
                    }
                    if [g[y][x], g[y - 1][x - 1], g[y - 2][x - 2], g[y - 3][x - 3]] == XMAS {
                        count += 1
                    }
                    if [g[y][x], g[y - 1][x], g[y - 2][x], g[y - 3][x]] == XMAS {
                        count += 1
                    }
                    if [g[y][x], g[y + 1][x], g[y + 2][x], g[y + 3][x]] == XMAS {
                        count += 1
                    }
                    if [g[y][x], g[y - 1][x + 1], g[y - 2][x + 2], g[y - 3][x + 3]] == XMAS {
                        count += 1
                    }
                    if [g[y][x], g[y][x + 1], g[y][x + 2], g[y][x + 3]] == XMAS {
                        count += 1
                    }
                    if [g[y][x], g[y + 1][x + 1], g[y + 2][x + 2], g[y + 3][x + 3]] == XMAS {
                        count += 1
                    }
                    if [g[y][x], g[y + 1][x - 1], g[y + 2][x - 2], g[y + 3][x - 3]] == XMAS {
                        count += 1
                    }
                    count
                })
                .sum::<usize>()
        })
        .sum()
}

#[cfg(test)]
mod test {

    use super::solve;

    use crate::util::{perf, validate, Day::Day04, Part::Part1};

    #[test]
    fn test_solve() {
        validate(solve, 2483, Day04(Part1));
    }

    #[test]
    fn bench() {
        perf(solve, 500);
    }
}
