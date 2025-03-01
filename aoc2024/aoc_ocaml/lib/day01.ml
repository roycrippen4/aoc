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

type entry = { mutable l_count : int; mutable r_count : int }

let count_occurances right n = List.length (List.filter (fun x -> x = n) right)

let insert_new_entry hash right left_n =
  Hashtbl.add hash left_n
    { l_count = 1; r_count = count_occurances right left_n }

let update_entry hash left_n =
  let entry = Hashtbl.find hash left_n in
  entry.l_count <- entry.l_count + 1

let update_hash hash right left_n =
  match Hashtbl.mem hash left_n with
  | false -> insert_new_entry hash right left_n
  | true -> update_entry hash left_n

let solve2 () =
  let left, right = List.fold_left parse_line ([], []) lines in
  let hash = Hashtbl.create 1000 in
  let () = List.iter (fun n -> update_hash hash right n) left in
  let result = ref 0 in
  let () =
    Hashtbl.iter
      (fun key { l_count; r_count } ->
        result := !result + (key * l_count * r_count))
      hash
  in
  !result

let part2 () = validate solve2 23126924 "01" Two
let solution : solution = { part1; part2 }

let%test "test solve2" =
  let left, right = List.fold_left parse_line ([], []) lines in
  let hash = Hashtbl.create 1000 in
  let () = List.iter (fun n -> update_hash hash right n) left in
  let result = ref 0 in
  let () =
    Hashtbl.iter
      (fun key { l_count; r_count } ->
        result := !result + (key * l_count * r_count))
      hash
  in
  !result = 23126924

let%test "test parse_line" =
  let lefts, rights = parse_line ([], []) "60236   87497" in
  let e_lefts, e_rights = ([ 60236 ], [ 87497 ]) in
  e_lefts = lefts && rights = e_rights

let%test "test parse_line 2" =
  let lefts, rights = parse_line ([], []) "60236   87497" in
  let lefts, rights = parse_line (lefts, rights) "27507   18604" in
  let e_lefts, e_rights = ([ 60236; 27507 ], [ 87497; 18604 ]) in
  e_lefts = lefts && rights = e_rights
