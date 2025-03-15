open Util

let g = Grid.from_file "/home/roy/dev/aoc/aoc2024/data/day04/data.txt"

let is_mas_part1 = function
  | [ Some 'M'; Some 'A'; Some 'S' ] -> true
  | _ -> false

let xs = Grid.filter (fun _ v -> v = 'X') g

let mas_positions pos dir =
  let m = Grid.move dir pos in
  let a = Grid.move dir m in
  let s = Grid.move dir a in
  [ m; a; s ]

let is_xmas pos dir =
  let get_opt p = Grid.get_opt g p in
  mas_positions pos dir |> List.map get_opt |> is_mas_part1

let make_xmas_list pos =
  [
    is_xmas pos N;
    is_xmas pos S;
    is_xmas pos E;
    is_xmas pos W;
    is_xmas pos NE;
    is_xmas pos NW;
    is_xmas pos SE;
    is_xmas pos SW;
  ]

let count_xmas_part1 pos =
  let count acc = function true -> acc + 1 | false -> acc in
  make_xmas_list pos |> List.fold_left count 0

(* Part 2 *)

let a = Grid.filter (fun _ v -> v = 'A') g

let is_ms = function
  | Some 'M', Some 'S' -> true
  | Some 'S', Some 'M' -> true
  | _ -> false

(* This assumes that we already know [pos] is an ['A'] *)
let count_xmas_part2 pos =
  let nw = Grid.get_opt g (Grid.north_west pos) in
  let sw = Grid.get_opt g (Grid.south_west pos) in
  let ne = Grid.get_opt g (Grid.north_east pos) in
  let se = Grid.get_opt g (Grid.south_east pos) in
  if is_ms (nw, se) && is_ms (ne, sw) then 1 else 0

(* exports *)

let solve1 () = List.fold_left (fun acc pos -> acc + count_xmas_part1 pos) 0 xs
let solve2 () = List.fold_left (fun acc pos -> acc + count_xmas_part2 pos) 0 a
let part1 () = validate solve1 2483 "04" One
let part2 () = validate solve2 1925 "04" Two
let solution : solution = { part1; part2 }
