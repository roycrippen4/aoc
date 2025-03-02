open Util

let lines = read_to_lines "/home/roy/dev/aoc/aoc2024/data/day01/data.txt"

let split_to_side (left, right) line =
  let split_line = split ' ' line |> Array.of_list in
  (int_of_string split_line.(0) :: left, int_of_string split_line.(1) :: right)

let solve1 () =
  let left, right =
    List.fold_left split_to_side ([], []) lines |> map_tuple Array.of_list
  in
  let () = Array.sort compare left in
  let () = Array.sort compare right in
  Array.init (Array.length left) (fun i -> abs (left.(i) - right.(i)))
  |> Array.fold_left ( + ) 0

let part1 () = validate solve1 1506483 "01" One

let parse_line (left, right) line =
  match split ' ' line with
  | [ l; r ] -> (left @ [ int_of_string l ], right @ [ int_of_string r ])
  | _ -> failwith "split failure"

let lookup table n right =
  match Hashtbl.find_opt table n with
  | Some item -> n * item
  | None ->
      let count = List.filter (fun x -> x = n) right |> List.length in
      let () = Hashtbl.add table n count in
      n * count

let solve2 () =
  let left, right = List.fold_left parse_line ([], []) lines in
  let hash = Hashtbl.create 1000 in
  List.fold_left (fun acc n -> acc + lookup hash n right) 0 left

let part2 () = validate solve2 23126924 "01" Two
let solution : solution = { part1; part2 }

let%test "test parse_line" =
  let lefts, rights = parse_line ([], []) "60236   87497" in
  let e_lefts, e_rights = ([ 60236 ], [ 87497 ]) in
  e_lefts = lefts && rights = e_rights

let%test "test parse_line 2" =
  let lefts, rights = parse_line ([], []) "60236   87497" in
  let lefts, rights = parse_line (lefts, rights) "27507   18604" in
  let e_lefts, e_rights = ([ 60236; 27507 ], [ 87497; 18604 ]) in
  e_lefts = lefts && rights = e_rights
