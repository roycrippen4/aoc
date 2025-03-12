open Util

let xmas = [| 'x'; 'm'; 'a'; 's' |]

let example =
  "MMMSXXMASM\n\
   MSAMXMSMSA\n\
   AMXSXMAAMM\n\
   MSAMASMSMX\n\
   XMASAMXAMM\n\
   XXAMMXXAMA\n\
   SMSMSASXSS\n\
   SAXAMASAAA\n\
   MAMMMXMMMM\n\
   MXMXAXMASX"

let is_xmas pos g =
  let v = Grid.get_opt g pos in

let evaluate () =
  let _ = Grid.of_string example in
  ()

let () = evaluate ()

(**)

let solve1 () = 42
let solve2 () = 42
let part1 () = validate solve1 42 "04" One
let part2 () = validate solve2 42 "04" Two
let solution : solution = { part1; part2 }

(**)
