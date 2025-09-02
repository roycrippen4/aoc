#[derive(Debug, Clone, Copy, PartialEq, PartialOrd, Hash)]
pub enum Direction {
    North,
    NorthWest,
    West,
    SouthWest,
    South,
    SouthEast,
    East,
    NorthEast,
}

impl std::fmt::Display for Direction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = match self {
            Self::North => "north".to_string(),
            Self::South => "south".to_string(),
            Self::East => "east".to_string(),
            Self::West => "west".to_string(),
            Self::NorthEast => "northeast".to_string(),
            Self::NorthWest => "northwest".to_string(),
            Self::SouthEast => "southeast".to_string(),
            Self::SouthWest => "southwest".to_string(),
        };

        write!(f, "{s}")
    }
}
