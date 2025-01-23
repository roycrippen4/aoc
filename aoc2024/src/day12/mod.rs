pub mod part1;
pub mod part2;

// fn show_neighbor_window(p: Point, grid: &Grid) {
//     let (px, py, pv) = p;
//     let mut values: Vec<Vec<_>> = grid
//         .to_string()
//         .split("\n")
//         .map(|s| {
//             s.split("")
//                 .filter(|s| !s.is_empty())
//                 .map(|s| s.to_string())
//                 .collect::<Vec<_>>()
//         })
//         .filter(|s| !s.is_empty())
//         .collect();

//     grid.neighbors(p).iter().for_each(|(x, y, v)| {
//         values[*y][*x] = rgb!(v, 255, 0, 0);
//     });
//     values[py][px] = rgb!(pv, 255, 0, 0);

//     (0..values.len()).for_each(|y| {
//         let mut s = String::new();
//         (0..values[0].len()).for_each(|x| {
//             s.push_str(&values[y][x]);
//         });
//         println!("{s}");
//     });
// }
