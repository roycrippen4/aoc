open Util

let split_to_side (left, right) line =
  let sl, sr = String.split ~by:"   " line |> Tuple.map int_of_string in
  (sl :: left, sr :: right)

let rec parse_lines tup = function
  | [] -> tup
  | line :: rest -> parse_lines (split_to_side tup line) rest

let left, right =
  read_to_lines "/home/roy/dev/aoc/aoc2024/data/day01/data.txt"
  |> parse_lines ([], [])

let solve1 () =
  let rec eval acc = function
    | [], [] -> acc
    | l :: l_rest, r :: r_rest -> eval (acc + abs (l - r)) (l_rest, r_rest)
    | _ -> failwith "Invalid_argument"
  in
  eval 0 (List.sort compare left, List.sort compare right)

let into_frequency_map lst =
  let map = Hashtbl.create 500 in
  let f x =
    let count = try Hashtbl.find map x with Not_found -> 0 in
    Hashtbl.replace map x (count + 1)
  in
  List.iter f lst;
  map

let solve2 () =
  let left_map, right_map = Tuple.map into_frequency_map (left, right) in
  let aux n count acc =
    match Hashtbl.find_opt right_map n with
    | Some count_right -> acc + (n * count * count_right)
    | None -> acc
  in
  Hashtbl.fold aux left_map 0

let part1 () = validate solve1 1506483 "01" One
let part2 () = validate solve2 23126924 "01" Two
let solution : solution = { part1; part2 }
