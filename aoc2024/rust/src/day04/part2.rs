use crate::{data, util::StringMethods};

const MAS: [char; 3] = ['M', 'A', 'S'];
const SAM: [char; 3] = ['S', 'A', 'M'];

fn create_grid(input: &str) -> Vec<Vec<char>> {
    let mut data: Vec<String> = input.lines().map(String::into_padded).collect();
    let row_len = data[0].len();
    let pad = String::create_pad(row_len, '.');
    (0..4).for_each(|_| data.insert(0, pad.clone()));
    let col_len = data.len();
    (0..4).for_each(|_| data.insert(col_len, pad.clone()));
    data.iter().map(|r| r.to_char_vec()).collect()
}

pub fn solve() -> usize {
    let grid = create_grid(data!());
    (4..grid.len() - 4)
        .map(|y| {
            (4..grid[0].len() - 4)
                .map(|x| {
                    let cross1 = unsafe {
                        [
                            *grid.get_unchecked(y - 1).get_unchecked(x - 1),
                            *grid.get_unchecked(y).get_unchecked(x),
                            *grid.get_unchecked(y + 1).get_unchecked(x + 1),
                        ]
                    };
                    let cross2 = unsafe {
                        [
                            *grid.get_unchecked(y - 1).get_unchecked(x + 1),
                            *grid.get_unchecked(y).get_unchecked(x),
                            *grid.get_unchecked(y + 1).get_unchecked(x - 1),
                        ]
                    };
                    if (cross1 == SAM || cross1 == MAS) && (cross2 == SAM || cross2 == MAS) {
                        1
                    } else {
                        0
                    }
                })
                .sum::<usize>()
        })
        .sum()
}

#[cfg(test)]
mod test {

    use super::solve;

    use crate::util::{Day::Day04, Part::Part2, validate};

    #[test]
    fn test_solve() {
        validate(solve, 1925, Day04(Part2));
    }
}
