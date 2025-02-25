open Lib.Util

let map_tuple f (a, b) = (f a, f b)

let split_to_side (left, right) line =
  let split_line = split ' ' line |> Array.of_list in
  (split_line.(0) :: left, split_line.(1) :: right)

let lines = readlines "../data/day01/data.txt" |> Array.to_list

let left, right =
  List.fold_left split_to_side ([], []) lines
  |> map_tuple Array.of_list
  |> map_tuple (Array.map int_of_string)

let () = Array.sort compare left
let () = Array.sort compare right

let evaluate arr1 arr2 =
  Array.init (Array.length arr1) (fun i -> abs (arr1.(i) - arr2.(i)))
  |> Array.fold_left ( + ) 0 |> string_of_int

let () = print_endline (evaluate left right)
