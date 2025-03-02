open Util

let input =
  read_to_lines "/home/roy/dev/aoc/aoc2024/data/day02/data.txt"
  |> List.map (split_to_int ' ')

let pair_is_safe (x, y) d =
  let diff = x - y in
  diff <> 0 && abs diff <= 3 && diff > 0 = d

let first_second lst =
  match lst with a :: b :: _ -> (a, b) | _ -> assert false

let list_is_safe lst =
  let first, second = first_second lst in
  let d = first - second > 0 in
  let wins = windows 2 lst in
  List.for_all (fun win -> pair_is_safe (first_second win) d) wins

let solve1 () =
  let aux acc lst = if list_is_safe lst then succ acc else acc in
  List.fold_left aux 0 input

let solve1_alt () =
  List.fold_left
    (fun acc lst -> if list_is_safe lst then succ acc else acc)
    0 input

let part1 () = validate solve1 202 "02" One
let%test _ = list_is_safe [ 7; 6; 4; 2; 1 ]
let%test _ = not (list_is_safe [ 1; 2; 7; 8; 9 ])
let%test _ = not (list_is_safe [ 9; 7; 6; 2; 1 ])
let%test _ = not (list_is_safe [ 1; 3; 2; 4; 5 ])
let%test _ = not (list_is_safe [ 8; 6; 4; 4; 1 ])
let%test _ = list_is_safe [ 1; 3; 6; 7; 9 ]
let%test _ = solve1 () = 202
