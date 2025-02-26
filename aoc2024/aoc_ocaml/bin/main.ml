open Lib

let lines = readlines "../data/day01/data.txt"

let split_to_side (left, right) line =
  let split_line = split ' ' line |> Array.of_list in
  (split_line.(0) :: left, split_line.(1) :: right)

let evaluate () =
  let left, right =
    Array.fold_left split_to_side ([], []) lines
    |> map_tuple Array.of_list
    |> map_tuple (Array.map int_of_string)
  in

  let () = Array.sort compare left in
  let () = Array.sort compare right in

  Array.init (Array.length left) (fun i -> abs (left.(i) - right.(i)))
  |> Array.fold_left ( + ) 0

let () = validate evaluate 1506483 "01" "1"
