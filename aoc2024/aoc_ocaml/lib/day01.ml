open Util

let lines = read_to_lines "/home/roy/dev/aoc/aoc2024/data/day01/data.txt"

let split_to_side (left, right) line =
  let split_line = split_to_string ' ' line |> Array.of_list in
  (int_of_string split_line.(0) :: left, int_of_string split_line.(1) :: right)

let solve1 () =
  let left, right =
    List.fold_left split_to_side ([], []) lines |> map_tuple Array.of_list
  in
  let () = Array.sort compare left in
  let () = Array.sort compare right in
  Array.init (Array.length left) (fun i -> abs (left.(i) - right.(i)))
  |> Array.fold_left ( + ) 0

let into_frequency_map lst =
  let map = Hashtbl.create 500 in
  let f x =
    let count = try Hashtbl.find map x with Not_found -> 0 in
    Hashtbl.replace map x (count + 1)
  in
  List.iter f lst;
  map

let parse lines =
  let rec inner_parse acc_left acc_right = function
    | [] -> (List.rev acc_left, List.rev acc_right)
    | line :: rest -> (
        match
          line |> String.split_on_char ' '
          |> List.filter (fun s -> s <> "")
          |> List.map int_of_string
        with
        | [ l; r ] -> inner_parse (l :: acc_left) (r :: acc_right) rest
        | _ -> assert false)
  in
  inner_parse [] [] lines

let count_elems lst n = n * (List.filter (fun x -> x = n) lst |> List.length)

let solve2 () =
  let left_map, right_map = parse lines |> map_tuple into_frequency_map in
  Hashtbl.fold
    (fun n count acc ->
      match Hashtbl.find_opt right_map n with
      | Some count_right -> acc + (n * count * count_right)
      | None -> acc)
    left_map 0

let part1 () = validate solve1 1506483 "01" One
let part2 () = validate solve2 23126924 "01" Two
let solution : solution = { part1; part2 }
