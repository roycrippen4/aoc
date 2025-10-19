use crate::{data, util::StringMethods};

fn create_grid(input: &str) -> Vec<Vec<char>> {
    let mut data: Vec<String> = input.lines().map(String::into_padded).collect();
    let row_len = data[0].len();
    let pad = String::create_pad(row_len, '.');
    let pad_rows = vec![pad.clone(); 4];
    data.splice(0..0, pad_rows.clone());
    data.extend(pad_rows);
    data.iter().map(String::to_char_vec).collect()
}

const MAS: [char; 3] = ['M', 'A', 'S'];

pub fn solve() -> usize {
    let g = create_grid(data!());
    let mut count = 0;

    for y in 3..g.len() - 3 {
        for x in 3..g.len() - 3 {
            if g[y][x] != 'X' {
                continue;
            }

            if [g[y][x - 1], g[y][x - 2], g[y][x - 3]] == MAS {
                count += 1
            }
            if [g[y - 1][x - 1], g[y - 2][x - 2], g[y - 3][x - 3]] == MAS {
                count += 1
            }
            if [g[y - 1][x], g[y - 2][x], g[y - 3][x]] == MAS {
                count += 1
            }
            if [g[y + 1][x], g[y + 2][x], g[y + 3][x]] == MAS {
                count += 1
            }
            if [g[y - 1][x + 1], g[y - 2][x + 2], g[y - 3][x + 3]] == MAS {
                count += 1
            }
            if [g[y][x + 1], g[y][x + 2], g[y][x + 3]] == MAS {
                count += 1
            }
            if [g[y + 1][x + 1], g[y + 2][x + 2], g[y + 3][x + 3]] == MAS {
                count += 1
            }
            if [g[y + 1][x - 1], g[y + 2][x - 2], g[y + 3][x - 3]] == MAS {
                count += 1
            }
        }
    }

    count
}

#[cfg(test)]
mod test {

    use super::solve;

    use crate::util::{Day::Day04, Part::Part1, validate};

    #[test]
    fn test_solve() {
        validate(solve, 2483, Day04(Part1));
    }
}
