use std::str::FromStr;

pub mod part1;
pub mod part2;

pub fn find_starting_points(grid: &crate::util::Grid<usize>) -> Vec<crate::util::Entry<usize>> {
    (0..grid.height)
        .flat_map(|y| (0..grid.width).filter_map(move |x| (grid[(x, y)] == 0).then_some((x, y, 0))))
        .collect()
}

pub fn make_grid(data: &str) -> crate::util::Grid<usize> {
    crate::util::Grid::from_str(data).unwrap().as_usize()
}
