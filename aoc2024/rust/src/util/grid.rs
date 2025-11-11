use anyhow::Result;
use std::str::FromStr;

use super::Point;

pub type Entry<T> = (usize, usize, T);

#[derive(Debug, Clone, PartialEq)]
pub struct Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    inner: Vec<Vec<T>>,
    pub height: usize,
    pub width: usize,
}

impl<T> Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    // ==========================================================
    // ===================== Static Methods =====================
    // ==========================================================

    /// Initializes a `height` by `width` Grid where all values are `value`
    pub fn make(height: usize, width: usize, value: T) -> Self {
        let row: Vec<_> = std::iter::repeat_n(value, width).collect();
        let inner = std::iter::repeat_n(row, height).collect();

        Self {
            height,
            width,
            inner,
        }
    }

    /// Creates a new `Grid` of `height` by `width`.
    pub fn new(height: usize, width: usize) -> Self {
        Self {
            height,
            width,
            inner: vec![],
        }
    }

    /// Creates a new `Grid` by rotating the provided grid 90-degrees clockwise.
    ///
    /// This is a non-destructive operation that returns a new Grid instance.
    /// It correctly handles non-square grids by swapping width and height.
    ///
    /// [WARN!]: This should only be used with square, e.g. 3x3, grids!
    pub fn rotate_clockwise(g: &Self) -> Self {
        Self::new(g.height, g.width)
            .map_coords(|p| g[Point::new(p.y, (g.height - 1) - p.x)].clone())
    }

    /// Creates a new `Grid` by rotating the provided grid 90-degrees counter-clockwise.
    ///
    /// This is a non-destructive operation that returns a new Grid instance.
    /// It correctly handles non-square grids by swapping width and height.
    ///
    /// [WARN!]: This should only be used with square, e.g. 3x3, grids!
    pub fn rotate_counter_clockwise(grid: &Self) -> Self {
        Self::new(grid.height, grid.width).map_coords(|p_new| {
            let p_old = Point::new((grid.width - 1) - p_new.y, p_new.x);
            grid[p_old].clone()
        })
    }

    // ==========================================================
    // ===================== Immutable API ======================
    // ==========================================================

    /// Takes a `Point<usize>` and returns true if that point is contained in the grid
    pub fn inside<P: GridPoint>(&self, p: P) -> bool {
        let (x, y) = p.to_coordinate_pair();
        y < self.height && x < self.width
    }

    /// Makes a new grid with the same dimensions as the current grid with all values initialized to `value`
    pub fn same_size_with(&self, value: T) -> Self {
        Self::make(self.height, self.width, value)
    }

    /// Safely gets an immutable reference to a value in the grid.
    ///
    /// This method is generic and accepts any type that implements the `GridIndex`
    /// trait, such as `Point<usize>` or `(usize, usize)`.
    ///
    /// Returns `Some(&T)` if the coordinates are within the grid bounds,
    /// otherwise returns `None`.
    pub fn get<P: GridPoint>(&self, idx: P) -> Option<&T> {
        let (x, y) = idx.to_coordinate_pair();
        if y < self.height && x < self.width {
            Some(&self[(x, y)])
        } else {
            None
        }
    }

    /// Searches for an element's position in the grid that satisfies a predicate.
    pub fn find_position<P>(&self, mut pred: P) -> Option<(usize, usize)>
    where
        P: FnMut(Entry<&T>) -> bool,
    {
        self.entries().find(|e| pred(*e)).map(|(x, y, _)| (x, y))
    }

    pub fn find<P>(&self, mut pred: P) -> Option<Entry<&T>>
    where
        P: FnMut(Entry<&T>) -> bool,
    {
        self.entries().find(|e| pred(*e))
    }

    /// Searches for the first element in the grid that satisfies the predicate `p` in the grid,
    /// replaces that element with `v`, and returns the entry original element.
    pub fn find_replace<P>(&mut self, pred: P, v: T) -> Entry<T>
    where
        P: FnMut(Entry<&T>) -> bool,
    {
        let (x, y, old_value) = self.find(pred).unwrap();
        let old_value = old_value.clone();

        self.set_unchecked((x, y), v);

        (x, y, old_value)
    }

    /// Returns the values of the cardinal neighbors around point `p`.
    /// If a value does not exist or is outside the `grid` the value will be `None`.
    /// Otherwise the value will be `Some(T)`.
    pub fn nbor4_values<P: GridPoint>(&self, p: P) -> [Option<&T>; 4] {
        p.to_point().nbor4().map(|p| self.get(p))
    }

    /// Get the `entries` - `(x, y, T)` of all cardinal neighbors around point `p`.
    /// A neighbor is [None] if it is out of bounds.
    /// Order of the list starts at `N` and rotates clockwise.
    pub fn nbor4<P: GridPoint>(&self, p: P) -> [Option<Entry<&T>>; 4] {
        p.to_point()
            .nbor4()
            .map(|p| self.get(p).map(|v| (p.x, p.y, v)))
    }

    /// Returns the values of the cardinal and intercardinal neighbors around point `p`.
    /// If a value does not exist or is outside the `grid` the value will be `None`.
    /// Otherwise the value will be `Some(T)`.
    pub fn nbor8_values<P: GridPoint>(&self, p: P) -> [Option<&T>; 8] {
        p.to_point().nbor8().map(|p| self.get(p))
    }

    /// Get the entries of all cardinal and intercardinal neighbors around point `p`.
    /// A neighbor is [None] if it is out of bounds.
    /// Order of the list starts at `N` and rotates clockwise.
    pub fn nbor8<P: GridPoint>(&self, p: P) -> [Option<Entry<&T>>; 8] {
        p.to_point()
            .nbor8()
            .map(|p| self.get(p).map(|v| (p.x, p.y, v)))
    }

    /// Returns an iterator over the entries in the grid
    pub fn entries(&self) -> impl Iterator<Item = (usize, usize, &T)> + '_ {
        self.inner
            .iter()
            .enumerate()
            .flat_map(|(y, row)| row.iter().enumerate().map(move |(x, v)| (x, y, v)))
    }

    /// Filters the `grid` by predicate `p` for each entry in the `grid`
    pub fn filter<P>(&self, mut p: P) -> Vec<Entry<&T>>
    where
        P: FnMut(Entry<&T>) -> bool,
    {
        self.entries().filter(|&entry| p(entry)).collect()
    }

    /// Returns all values `T` that match predicate `P` for each element in the grid.
    pub fn filter_values<P>(&self, mut p: P) -> Vec<&T>
    where
        P: FnMut(&T) -> bool,
    {
        self.inner.iter().flatten().filter(|&v| p(v)).collect()
    }

    /// Returns all coordinates `(x, y)` that satisfy the predicate `P` over each `coordinate` in
    /// the `grid`
    pub fn filter_coords<P>(&self, mut p: P) -> Vec<(usize, usize)>
    where
        P: FnMut((usize, usize)) -> bool,
    {
        self.entries().fold(vec![], |mut acc, (x, y, _)| {
            if p((x, y)) {
                acc.push((x, y));
            }
            acc
        })
    }

    // ==========================================================
    // ===================== Grid Mutations =====================
    // ==========================================================

    /// Safely gets a mutable reference to a value in the grid.
    ///
    /// This method is generic and accepts any type that implements the `GridIndex`
    /// trait, such as `Point<usize>` or `(usize, usize)`.
    ///
    /// Returns `Some(&mut T)` if the coordinates are within the grid bounds,
    /// otherwise returns `None`.
    pub fn get_mut<P: GridPoint>(&mut self, p: P) -> Option<&mut T> {
        let (x, y) = p.to_coordinate_pair();
        if y < self.height && x < self.width {
            Some(&mut self[(x, y)])
        } else {
            None
        }
    }

    /// Applies the function `f` to each coordinate `p` in the `grid`, replacing the original value
    pub fn map_coords(mut self, f: impl Fn(Point<usize>) -> T) -> Self {
        self.inner = (0..self.height)
            .map(|y| (0..self.width).map(|x| f(Point::new(x, y))).collect())
            .collect();

        self
    }

    /// Set the value in the grid.
    /// Directly indexes the grid without checking bounds.
    /// If the point is invalid this function will panic
    pub fn set_unchecked<P: GridPoint>(&mut self, p: P, value: T) {
        self[p] = value;
    }

    /// Safely set the value in the grid.
    /// Returns `Ok(self)` if the update was successful.
    /// Returns `Err` if the update failed.
    pub fn set<P: GridPoint>(&mut self, p: P, value: T) -> Result<&mut Self> {
        if self.inside(p) {
            self[p] = value;
            Ok(self)
        } else {
            anyhow::bail!("Point {p:?} is not inside the grid.")
        }
    }

    /// In-place, clockwise rotation of the grid
    /// [WARN!]: This should only be used with square, e.g. 3x3, grids!
    pub fn rotate_clockwise_mut(&mut self) -> &mut Self {
        if self.inner.is_empty() {
            return self;
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

        self
    }

    /// In-place, counter-clockwise rotation of the grid
    /// [WARN!]: This should only be used with square, e.g. 3x3, grids!
    pub fn rotate_counter_clockwise_mut(&mut self) -> &mut Self {
        if self.inner.is_empty() {
            return self;
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
        self
    }

    /// Strips the first and last columns from the grid
    pub fn strip_bounding_cols(&mut self) -> &mut Self {
        if self.width < 3 {
            return self;
        }

        for row in &mut self.inner {
            row.remove(0);
            row.pop();
        }

        self.width -= 2;

        self
    }

    /// Strips the first and last rows from the grid
    pub fn strip_bounding_rows(&mut self) -> &mut Self {
        if self.height < 3 {
            return self;
        }

        self.inner.remove(0);
        self.inner.pop();
        self.height -= 2;

        self
    }

    /// Strips the entire boundary around the grid
    pub fn strip_boundaries(&mut self) -> &mut Self {
        if self.width < 3 || self.height < 3 {
            return self;
        }

        self.strip_bounding_rows().strip_bounding_cols()
    }

    pub fn row_mut(&mut self, y: usize) -> Option<&mut Vec<T>> {
        self.inner.get_mut(y)
    }

    // ==========================================================
    // ===================== Consuming API ======================
    // ==========================================================

    /// Returns an iterator over the `Entry<T>` for each element in the grid. Consumes the grid.
    pub fn into_entries(self) -> impl Iterator<Item = Entry<T>> {
        self.inner
            .into_iter()
            .enumerate()
            .flat_map(|(y, row)| row.into_iter().enumerate().map(move |(x, v)| (x, y, v)))
    }

    /// Folds over the grid via application of `f` over each entry, consuming the grid
    pub fn fold<F, Acc>(self, accum: Acc, f: F) -> Acc
    where
        F: FnMut(Acc, Entry<T>) -> Acc,
    {
        self.into_entries().fold(accum, f)
    }

    /// Applies the function `f` to each entry in the `grid`, producing a new grid
    pub fn map<F, U>(self, f: F) -> Grid<U>
    where
        F: Fn(Entry<T>) -> U,
        U: std::fmt::Debug + Clone,
    {
        let inner = self
            .inner
            .into_iter()
            .enumerate()
            .map(|(y, row)| {
                row.into_iter()
                    .enumerate()
                    .map(|(x, v)| f((x, y, v)))
                    .collect()
            })
            .collect();

        Grid {
            inner,
            width: self.width,
            height: self.height,
        }
    }

    /// Applies the function `f` to each value `v` in the `grid`, replacing the original value
    pub fn map_values<F, U>(self, f: F) -> Grid<U>
    where
        F: Fn(T) -> U,
        U: std::fmt::Debug + Clone,
    {
        let inner = self
            .inner
            .into_iter()
            .map(|row| row.into_iter().map(&f).collect())
            .collect();

        Grid {
            inner,
            width: self.width,
            height: self.height,
        }
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

impl FromStr for Grid<char> {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        let lines: Vec<&str> = s.lines().collect();
        let height = lines.len();
        let chars: Vec<Vec<_>> = lines.iter().map(|l| l.chars().collect()).collect();
        let width = chars[0].len();

        Ok(Grid {
            inner: chars,
            height,
            width,
        })
    }
}

impl<T> From<Vec<Vec<T>>> for Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    fn from(inner: Vec<Vec<T>>) -> Self {
        let width = inner[0].len();
        let height = inner.len();
        Grid {
            inner,
            width,
            height,
        }
    }
}

impl<T> From<&[Vec<T>]> for Grid<T>
where
    T: std::fmt::Debug + Clone,
{
    fn from(inner: &[Vec<T>]) -> Self {
        let width = inner[0].len();
        let height = inner.len();
        Grid {
            inner: inner.to_vec(),
            width,
            height,
        }
    }
}

/// A trait for types that can be converted into grid coordinates.
pub trait GridPoint: std::fmt::Debug + Copy + Clone {
    /// Returns the (x, y) coordinates represented by this index.
    fn to_coordinate_pair(&self) -> (usize, usize);

    /// Returns the `Point<usize>` represented by this index.
    fn to_point(&self) -> Point<usize>;
}

impl GridPoint for Point<usize> {
    fn to_coordinate_pair(&self) -> (usize, usize) {
        (self.x, self.y)
    }

    fn to_point(&self) -> Point<usize> {
        *self
    }
}

impl GridPoint for (usize, usize) {
    fn to_coordinate_pair(&self) -> (usize, usize) {
        *self
    }

    fn to_point(&self) -> Point<usize> {
        Point::new(self.0, self.1)
    }
}

impl<T, P> std::ops::IndexMut<P> for Grid<T>
where
    P: GridPoint,
    T: std::fmt::Debug + Clone,
{
    fn index_mut(&mut self, p: P) -> &mut Self::Output {
        let (x, y) = p.to_coordinate_pair();
        &mut self.inner[y][x]
    }
}

impl<T, P> std::ops::Index<P> for Grid<T>
where
    P: GridPoint,
    T: std::fmt::Debug + Clone,
{
    type Output = T;

    fn index(&self, p: P) -> &Self::Output {
        let (x, y) = p.to_coordinate_pair();
        &self.inner[y][x]
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn get_original_grid() -> Grid<i32> {
        Grid::new(5, 5).map_coords(|p| p.x as i32 + p.y as i32)
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

    #[test]
    fn test_strip_bounding_rows_mut() {
        let mut grid = Grid::new(5, 3).map_coords(|p| (p.y * 10 + p.x) as i32);
        grid.strip_bounding_rows();

        let expected_inner = vec![vec![10, 11, 12], vec![20, 21, 22], vec![30, 31, 32]];

        assert_eq!(grid.height, 3);
        assert_eq!(grid.width, 3); // Width should be unchanged
        assert_eq!(grid.inner, expected_inner);
    }

    #[test]
    fn test_strip_boundaries_mut_happy_path() {
        let mut grid = Grid::new(5, 4).map_coords(|p| (p.y * 10 + p.x) as i32);
        let expected = Grid::new(3, 2).map_coords(|p| ((p.y + 1) * 10 + (p.x + 1)) as i32);

        grid.strip_boundaries();

        assert_eq!(grid.height, 3, "Grid height should be reduced by 2");
        assert_eq!(grid.width, 2, "Grid width should be reduced by 2");
        assert_eq!(grid, expected, "The inner data of the grid is incorrect");
    }

    #[test]
    fn test_strip_boundaries_mut_minimum_size() {
        let mut grid = Grid::new(3, 3).map_coords(|p| (p.y * 10 + p.x) as i32);
        let expected = Grid::new(1, 1).map_coords(|_| 11);
        grid.strip_boundaries();

        assert_eq!(grid, expected);
    }

    #[test]
    fn test_strip_boundaries_mut_too_small_to_strip() {
        let mut narrow_grid = Grid::new(5, 2).map_coords(|p| p.x as i32);
        let expected_narrow = narrow_grid.clone(); // Save the original state
        narrow_grid.strip_boundaries();
        assert_eq!(
            narrow_grid, expected_narrow,
            "Grid with width < 3 should not be changed"
        );

        let mut short_grid = Grid::new(2, 5).map_coords(|p| p.x as i32);
        let expected_short = short_grid.clone(); // Save the original state
        short_grid.strip_boundaries();
        assert_eq!(
            short_grid, expected_short,
            "Grid with height < 3 should not be changed"
        );

        let mut valid_grid = Grid::new(3, 5).map_coords(|p| p.x as i32);
        let expected_valid = Grid::new(1, 3).map_coords(|p| (p.x + 1) as i32);
        valid_grid.strip_boundaries();
        assert_eq!(valid_grid, expected_valid, "A 3x5 grid should be stripped");
    }
}
