use super::Direction;

use std::ops::{Add, Div, Mul, Sub};

#[derive(Clone, Copy, Debug, PartialEq, Hash)]
pub struct Point {
    pub x: isize,
    pub y: isize,
}

pub const UP: Point = Point::new(0, -1);
pub const DOWN: Point = Point::new(0, 1);
pub const LEFT: Point = Point::new(-1, 0);
pub const RIGHT: Point = Point::new(1, 0);

impl Point {
    pub const fn new(x: isize, y: isize) -> Self {
        Point { x, y }
    }

    pub fn origin() -> Self {
        Point::new(0, 0)
    }

    fn unit_step(&self, d: Direction) -> Self {
        let Point { x, y } = *self;

        match d {
            Direction::North => Point::new(x, y - 1),
            Direction::South => Point::new(x, y + 1),
            Direction::West => Point::new(x - 1, y),
            Direction::East => Point::new(x + 1, y),
            Direction::NorthEast => Point::new(x + 1, y - 1),
            Direction::NorthWest => Point::new(x - 1, y - 1),
            Direction::SouthEast => Point::new(x + 1, y + 1),
            Direction::SouthWest => Point::new(x - 1, y + 1),
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
        match d {
            Direction::North => self.y = self.y - 1,
            Direction::South => self.y = self.y + 1,
            Direction::West => self.x = self.x - 1,
            Direction::East => self.x = self.x + 1,
            Direction::NorthEast => {
                self.x = self.x + 1;
                self.y = self.y - 1;
            }
            Direction::NorthWest => {
                self.x = self.x - 1;
                self.y = self.y - 1;
            }
            Direction::SouthEast => {
                self.x = self.x + 1;
                self.y = self.y + 1;
            }
            Direction::SouthWest => {
                self.x = self.x - 1;
                self.y = self.y + 1;
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

impl From<(isize, isize)> for Point {
    fn from((x, y): (isize, isize)) -> Self {
        Point { x, y }
    }
}

impl Div for Point {
    type Output = Point;

    fn div(self, other: Self) -> Self::Output {
        let x = self.x / other.x;
        let y = self.y / other.y;
        Point::new(x, y)
    }
}

impl Mul for Point {
    type Output = Point;

    fn mul(self, other: Self) -> Self::Output {
        let x = self.x * other.x;
        let y = self.y * other.y;
        Point::new(x, y)
    }
}

impl Add for Point {
    type Output = Point;

    fn add(self, other: Self) -> Self::Output {
        let x = self.x + other.x;
        let y = self.y + other.y;

        Point::new(x, y)
    }
}

impl Sub for Point {
    type Output = Point;

    fn sub(self, other: Self) -> Self::Output {
        let x = self.x - other.x;
        let y = self.y - other.y;
        Point::new(x, y)
    }
}

impl std::fmt::Display for Point {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
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
