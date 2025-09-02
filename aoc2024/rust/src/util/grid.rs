use anyhow::Result;

use super::Direction;
use super::Point;

#[derive(Debug, Clone, PartialEq)]
pub struct Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    inner: Vec<Vec<T>>,
    pub height: usize,
    pub width: usize,
    pub size: usize,
}

impl<T> Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    /// Initializes a `height` by `width` Grid where all values are `value`
    pub fn make(height: usize, width: usize, value: T) -> Self {
        let row: Vec<_> = std::iter::repeat_n(value, width).collect();
        let inner = std::iter::repeat_n(row, height).collect();
        let size = width * height;

        Self {
            size,
            height,
            width,
            inner,
        }
    }

    /// Creates a new grid of `height` by `width` and runs the function `f` for each element in the
    /// grid. `f` will receive a `Point<usize>` for each point in the grid.
    pub fn new(height: usize, width: usize, f: impl Fn(Point<usize>) -> T) -> Self {
        let inner: Vec<Vec<T>> = (0..height)
            .map(|y| (0..width).map(|x| f(Point::new(x, y))).collect())
            .collect();

        Self {
            size: width * height,
            height,
            width,
            inner,
        }
    }

    /// Takes a `Point<usize>` and returns true if that point is contained in the grid
    pub fn inside(&self, p: Point<usize>) -> bool {
        p.y < self.height && p.x < self.width
    }

    /// Makes a new grid with the same dimensions as the current grid with all values initialized to `value`
    pub fn same_size_with(&self, value: T) -> Self {
        Self::make(self.height, self.width, value)
    }

    /// Set the value in the grid.
    /// Directly indexes the grid.
    /// If the point is invalid this function will panic
    pub fn set_unchecked(&mut self, p: Point<usize>, value: T) {
        self[p] = value;
    }

    /// Safely set the value in the grid.
    /// Returns `Ok(())` if the update was successful.
    /// Returns `Err(())` if the update failed.
    pub fn set(&mut self, p: Point<usize>, value: T) -> Result<()> {
        if self.inside(p) {
            self[p] = value;
            Ok(())
        } else {
            anyhow::bail!("Point {p:?} is not inside the grid.")
        }
    }

    pub fn rotate_clockwise_mut(&mut self) {
        if self.inner.is_empty() {
            return;
        }

        let n = self.inner.len();
        for i in 0..n {
            for j in (i + 1)..n {
                unsafe {
                    let pa: *mut T = &mut self.inner[i][j];
                    let pb: *mut T = &mut self.inner[j][i];
                    std::ptr::swap(pa, pb);
                }
            }
        }

        for row in &mut self.inner {
            row.reverse();
        }
    }

    pub fn rotate_counter_clockwise_mut(&mut self) {
        if self.inner.is_empty() {
            return;
        }

        let n = self.inner.len();
        for i in 0..n {
            for j in (i + 1)..n {
                unsafe {
                    let pa: *mut T = &mut self.inner[i][j];
                    let pb: *mut T = &mut self.inner[j][i];
                    std::ptr::swap(pa, pb);
                }
            }
        }

        self.inner.reverse();
    }

    /// Creates a new `Grid` by rotating the provided grid 90-degrees clockwise.
    ///
    /// This is a non-destructive operation that returns a new Grid instance.
    /// It correctly handles non-square grids by swapping width and height.
    pub fn rotate_clockwise(grid: &Self) -> Self {
        Self::new(grid.height, grid.width, |p_new| {
            let p_old = Point::new(p_new.y, (grid.height - 1) - p_new.x);
            grid[p_old].clone()
        })
    }

    /// Creates a new `Grid` by rotating the provided grid 90-degrees counter-clockwise.
    ///
    /// This is a non-destructive operation that returns a new Grid instance.
    /// It correctly handles non-square grids by swapping width and height.
    pub fn rotate_counter_clockwise(grid: &Self) -> Self {
        Self::new(grid.height, grid.width, |p_new| {
            let p_old = Point::new((grid.width - 1) - p_new.y, p_new.x);
            grid[p_old].clone()
        })
    }
}

impl<T> std::fmt::Display for Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if self.inner.is_empty() {
            return Ok(());
        }

        let mut col_widths = vec![0; self.width];
        for row in &self.inner {
            for (i, value) in row.iter().enumerate() {
                let s = format!("{value:?}");
                if s.len() > col_widths[i] {
                    col_widths[i] = s.len();
                }
            }
        }

        for row in &self.inner {
            for (i, value) in row.iter().enumerate() {
                write!(f, " {:>width$?}", value, width = col_widths[i])?;
            }
            writeln!(f)?;
        }

        Ok(())
    }
}

impl<T> std::ops::Index<Point<usize>> for Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    type Output = T;

    fn index(&self, p: Point<usize>) -> &Self::Output {
        &self.inner[p.y][p.x]
    }
}

impl<T> std::ops::IndexMut<Point<usize>> for Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    fn index_mut(&mut self, p: Point<usize>) -> &mut Self::Output {
        &mut self.inner[p.y][p.x]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn get_original_grid() -> Grid<i32> {
        Grid::new(5, 5, |p| p.x as i32 + p.y as i32)
    }

    #[test]
    fn test_rotate_clockwise() {
        let mut grid = get_original_grid();
        let expected_inner = vec![
            vec![4, 3, 2, 1, 0],
            vec![5, 4, 3, 2, 1],
            vec![6, 5, 4, 3, 2],
            vec![7, 6, 5, 4, 3],
            vec![8, 7, 6, 5, 4],
        ];

        let expected = Grid {
            inner: expected_inner,
            width: 5,
            height: 5,
            size: 25,
        };

        grid.rotate_clockwise_mut();
        assert_eq!(grid, expected);
    }

    #[test]
    fn test_rotate_counter_clockwise() {
        let mut grid = get_original_grid();

        let expected = Grid {
            inner: vec![
                vec![4, 5, 6, 7, 8],
                vec![3, 4, 5, 6, 7],
                vec![2, 3, 4, 5, 6],
                vec![1, 2, 3, 4, 5],
                vec![0, 1, 2, 3, 4],
            ],
            width: 5,
            height: 5,
            size: 25,
        };

        grid.rotate_counter_clockwise_mut();
        assert_eq!(grid, expected);
    }

    #[test]
    fn test_both_rotations_cancel_out() {
        let original = get_original_grid();
        let mut grid = original.clone();

        grid.rotate_clockwise_mut();
        grid.rotate_counter_clockwise_mut();

        assert_eq!(grid, original);
    }
}
