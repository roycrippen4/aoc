use std::ops::{Add, Div, Mul, Sub};

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Point<T> {
    pub x: T,
    pub y: T,
}

impl<T: Div<Output = T>> Div for Point<T> {
    type Output = Point<T>;

    fn div(self, other: Self) -> Self::Output {
        let x = self.x / other.x;
        let y = self.y / other.y;
        Point::new(x, y)
    }
}

impl<T: Mul<Output = T>> Mul for Point<T> {
    type Output = Point<T>;

    fn mul(self, other: Self) -> Self::Output {
        let x = self.x * other.x;
        let y = self.y * other.y;
        Point::new(x, y)
    }
}

impl<T: Add<Output = T>> Add for Point<T> {
    type Output = Point<T>;

    fn add(self, other: Self) -> Self::Output {
        let x = self.x + other.x;
        let y = self.y + other.y;

        Point::new(x, y)
    }
}

impl<T: Sub<Output = T>> Sub for Point<T> {
    type Output = Point<T>;

    fn sub(self, other: Self) -> Self::Output {
        let x = self.x - other.x;
        let y = self.y - other.y;
        Point::new(x, y)
    }
}

impl<T> Point<T> {
    pub fn new(x: T, y: T) -> Self {
        Point { x, y }
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
