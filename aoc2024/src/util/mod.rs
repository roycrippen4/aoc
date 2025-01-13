mod aoc;
pub mod macros;
mod quicksort;
mod string_methods;
mod timing;

pub use aoc::{Day, Part};
pub use quicksort::quicksort;
pub use string_methods::StringMethods;
pub use timing::{perf, validate};
