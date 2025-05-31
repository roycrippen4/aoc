open Util

let encode g : int =
  let bit_of = function
    | '#' -> 1
    | '.' -> 0
    | _ -> invalid_arg "BOO YOU SUCK"
  in

  let cell acc ch : int = (acc lsl 1) lor bit_of ch in
  Array.fold_left (fun acc row -> Array.fold_left cell acc row) 0 g

let collision l k = l land k <> 0
let fits_allowing_gaps l k = not (collision l k)

let solve1 () =
  let lock_row = List.init 5 (fun _ -> '#') in
  let locks, keys =
    let is_lock s = String.explode s |> List.take 5 = lock_row in
    let to_binary = List.map (Grid.of_string >> encode) in

    read_to_string "/home/roy/dev/aoc/aoc2024/data/day25/data.txt"
    |> String.trim
    |> String.split_on_string ~by:"\n\n"
    |> List.partition is_lock |> Tuple.map to_binary
  in

  let key_count acc l =
    let fold acc' k = if fits_allowing_gaps l k then acc' + 1 else acc' in
    acc + List.fold_left fold 0 keys
  in

  locks |> List.fold_left key_count 0

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 2885 "25" One
let part2 () = validate solve2 42 "25" Two
let solution : solution = { part1; part2 }
