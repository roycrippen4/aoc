use super::Direction;

use std::ops::{Add, Div, Mul, Sub};

use num_traits::Num;

#[derive(Clone, Copy, Debug, PartialEq, Hash)]
pub struct Point<T> {
    pub x: T,
    pub y: T,
}

pub const UP: Point<i32> = Point::new(0, -1);
pub const DOWN: Point<i32> = Point::new(0, 1);
pub const LEFT: Point<i32> = Point::new(-1, 0);
pub const RIGHT: Point<i32> = Point::new(1, 0);

impl<T> Point<T>
where
    T: Num + Copy,
{
    pub const fn new(x: T, y: T) -> Self {
        Point { x, y }
    }

    pub fn origin() -> Self {
        Point::new(T::zero(), T::zero())
    }

    fn unit_step(&self, d: Direction) -> Self {
        let Point { x, y } = *self;

        let one = T::one();

        match d {
            Direction::North => Point::new(x, y - one),
            Direction::South => Point::new(x, y + one),
            Direction::West => Point::new(x - one, y),
            Direction::East => Point::new(x + one, y),
            Direction::NorthEast => Point::new(x + one, y - one),
            Direction::NorthWest => Point::new(x - one, y - one),
            Direction::SouthEast => Point::new(x + one, y + one),
            Direction::SouthWest => Point::new(x - one, y + one),
        }
    }

    // =============== Immutable ===============

    /// Returns a new point shifted one unit north
    pub fn north(&self) -> Self {
        self.unit_step(Direction::North)
    }

    /// Returns a new point shifted one unit south
    pub fn south(&self) -> Self {
        self.unit_step(Direction::South)
    }

    /// Returns a new point shifted one unit east
    pub fn east(&self) -> Self {
        self.unit_step(Direction::East)
    }

    /// Returns a new point shifted one unit west
    pub fn west(&self) -> Self {
        self.unit_step(Direction::West)
    }

    /// Returns a new point shifted one unit south-east
    pub fn southeast(&self) -> Self {
        self.unit_step(Direction::SouthEast)
    }

    /// Returns a new point shifted one unit south-west
    pub fn southwest(&self) -> Self {
        self.unit_step(Direction::SouthWest)
    }

    /// Returns a new point shifted one unit north-east
    pub fn northeast(&self) -> Self {
        self.unit_step(Direction::NorthEast)
    }

    /// Returns a new point shifted one unit north-west
    pub fn northwest(&self) -> Self {
        self.unit_step(Direction::NorthWest)
    }

    // =============== Mutable ===============

    fn unit_step_mut(&mut self, d: Direction) -> &mut Self {
        let one = T::one();

        match d {
            Direction::North => self.y = self.y - one,
            Direction::South => self.y = self.y + one,
            Direction::West => self.x = self.x - one,
            Direction::East => self.x = self.x + one,
            Direction::NorthEast => {
                self.x = self.x + one;
                self.y = self.y - one;
            }
            Direction::NorthWest => {
                self.x = self.x - one;
                self.y = self.y - one;
            }
            Direction::SouthEast => {
                self.x = self.x + one;
                self.y = self.y + one;
            }
            Direction::SouthWest => {
                self.x = self.x - one;
                self.y = self.y + one;
            }
        };

        self
    }

    /// Mutates this point to move one unit north
    pub fn north_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::North)
    }

    /// Mutates this point to move one unit south
    pub fn south_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::South)
    }

    /// Mutates this point to move one unit east
    pub fn east_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::East)
    }

    /// Mutates this point to move one unit west
    pub fn west_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::West)
    }

    /// Mutates this point to move one unit south-east
    pub fn southeast_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::SouthEast)
    }

    /// Mutates this point to move one unit south-west
    pub fn southwest_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::SouthWest)
    }

    /// Mutates this point to move one unit north-east
    pub fn northeast_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::NorthEast)
    }

    /// Mutates this point to move one unit north-west
    pub fn northwest_mut(&mut self) -> &mut Self {
        self.unit_step_mut(Direction::NorthWest)
    }

    /// Get the coordinates of all orthoganal neighbors from a given point `p`.
    ///
    /// Order of the Array starts at `Direction::North`, rotates clockwise, and ends with
    /// `Direction::West`.
    pub fn nbor4(&self) -> [Self; 4] {
        [self.north(), self.east(), self.south(), self.west()]
    }

    /// Get the coordinates of the eight surrounding neighbors (cardinal and intercardinal directions)
    /// from a given point `p`, often referred to as the [8-wind compass rose](https://en.wikipedia.org/wiki/Points_of_the_compass#8-wind_compass_rose).
    ///
    /// The order of the array starts at `Direction::North` and rotates clockwise.
    pub fn nbor8(&self) -> [Self; 8] {
        [
            self.north(),
            self.northeast(),
            self.east(),
            self.southeast(),
            self.south(),
            self.southwest(),
            self.west(),
            self.northwest(),
        ]
    }
}

impl<T> From<(T, T)> for Point<T> {
    fn from((x, y): (T, T)) -> Self {
        Point { x, y }
    }
}

impl<T> Div for Point<T>
where
    T: Div<Output = T> + num_traits::Num + std::marker::Copy,
{
    type Output = Point<T>;

    fn div(self, other: Self) -> Self::Output {
        let x = self.x / other.x;
        let y = self.y / other.y;
        Point::new(x, y)
    }
}

impl<T> Mul for Point<T>
where
    T: Div<Output = T> + num_traits::Num + std::marker::Copy,
{
    type Output = Point<T>;

    fn mul(self, other: Self) -> Self::Output {
        let x = self.x * other.x;
        let y = self.y * other.y;
        Point::new(x, y)
    }
}

impl<T> Add for Point<T>
where
    T: Div<Output = T> + num_traits::Num + std::marker::Copy,
{
    type Output = Point<T>;

    fn add(self, other: Self) -> Self::Output {
        let x = self.x + other.x;
        let y = self.y + other.y;

        Point::new(x, y)
    }
}

impl<T> Sub for Point<T>
where
    T: Div<Output = T> + num_traits::Num + std::marker::Copy,
{
    type Output = Point<T>;

    fn sub(self, other: Self) -> Self::Output {
        let x = self.x - other.x;
        let y = self.y - other.y;
        Point::new(x, y)
    }
}

impl<T> std::fmt::Display for Point<T>
where
    T: std::fmt::Debug,
{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "({:?}, {:?})", self.x, self.y)
    }
}

#[cfg(test)]
mod test {
    use super::Point;

    #[test]
    fn test_new_point() {
        let x = 5;
        let y = 10;
        let p = Point::new(x, y);
        assert_eq!(p.x, x);
        assert_eq!(p.y, y);
    }

    #[test]
    fn test_add() {
        let p1 = Point::new(5, 5);
        let p2 = Point::new(1, 2);
        let p3 = p1 + p2;
        assert_eq!(p3.x, 6);
        assert_eq!(p3.y, 7);
    }
}
