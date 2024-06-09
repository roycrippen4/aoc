// use std::iter;

// pub fn add(left: usize, right: usize) -> usize {
//     left + right
// }

// pub struct Point {
//     #[allow(unused)]
//     x: usize,
//     #[allow(unused)]
//     y: usize,
// }

// pub struct GridPoint<T> {
//     #[allow(unused)]
//     pos: Point,
//     #[allow(unused)]
//     value: T,
// }

// impl<T> GridPoint<T> {
//     #[allow(unused)]
//     fn new(x: usize, y: usize, value: T) -> GridPoint<T> {
//         GridPoint {
//             pos: Point { x, y },
//             value,
//         }
//     }
// }

// pub struct Grid<T> {
//     #[allow(unused)]
//     points: Vec<GridPoint<T>>,

//     #[allow(unused)]
//     width: usize,

//     #[allow(unused)]
//     height: usize,
// }

// //            ~~~~~
// // xxx        ~xxx~
// // xxx   to   ~xxx~
// // xxx        ~xxx~
// //            ~~~~~
// fn pad_lines(lines: Vec<&str>) -> Vec<Vec<&str>> {
//     let mut new_lines: Vec<Vec<&str>> = lines
//         .iter()
//         .map(|&line| {
//             let mut strs: Vec<&str> = line.split("").collect();
//             strs.splice(0..0, iter::once("~"));
//             strs.push("~");
//             strs
//         })
//         .collect();

//     let width = lines.len() + 2;

//     // let horizontal_str: String = "~".to_string().repeat(width);
//     // let horizontal_pad: Vec<&str> = horizontal_str.split("").collect();
//     new_lines.push("~".to_string().repeat(width).split("").collect());
//     new_lines.splice(
//         0..0,
//         iter::once("~".to_string().repeat(width).split("").collect()),
//     );

//     new_lines
// }

// impl<T> Grid<T> {
//     fn new(lines: Vec<&str>) -> Grid<T> {

//         // let pad_lines: Vec<&str> = vec!["-"];
//     }
// }

// #[cfg(test)]
// mod tests {
//     use super::*;

//     #[test]
//     fn it_works() {
//         let result = add(2, 2);
//         assert_eq!(result, 4);
//     }

//     #[test]
//     fn it_creates_a_point() {
//         let expected: Point = Point { x: 1, y: 2 };
//         assert_eq!(expected.x, 1);
//         assert_eq!(expected.y, 2);
//     }

//     #[test]
//     fn it_creates_a_grid_point() {
//         let exp1 = GridPoint::new(1, 2, "hello");
//         assert_eq!(exp1.pos.x, 1);
//         assert_eq!(exp1.pos.y, 2);
//         assert_eq!(exp1.value, "hello");

//         let exp2: GridPoint<usize> = GridPoint::new(0, 0, 10);
//         assert_eq!(exp2.pos.x, 0);
//         assert_eq!(exp2.pos.y, 0);
//         assert_eq!(exp2.value, 10);
//     }
// }
