open Util

type point = { x : int; y : int; v : int }
type grid = int Grid.t

module Visited = Set.Make (struct
  type t = int * int

  let compare = compare
end)

let grid =
  "/home/roy/dev/aoc/aoc2024/data/day10/data.txt"
  |> read_to_string
  |> String.trim
  |> Grid.of_string
  |> Grid.map (fun _ c -> int_of_char2 c)

let gheight = Grid.height grid
let gwidth = Grid.width grid

let show_grid () =
  let rec print_row = function
    | [] -> Printf.printf "\n"
    | hd :: tl ->
        Printf.printf "%d" hd;
        print_row tl
  in

  let rec print_rows = function
    | [] -> ()
    | row :: rest ->
        print_row row;
        print_rows rest
  in

  grid |> Grid.to_list |> print_rows

let () = show_grid ()
let solve1 () = 42

let get_neighbors p g =
  let get_neighbor x y = { x; y; v = Grid.get g (y, x) } in

  let { x; y; v } = p in
  let target = v + 1 in
  let neighbors = [] in

  let neighbors =
    if x < gwidth - 1 && Grid.get g (y, x) = target then
      get_neighbor (x + 1) y :: neighbors
    else neighbors
  in

  let neighbors =
    if x <> 0 && Grid.get g (y, x - 1) = target then
      get_neighbor (x - 1) y :: neighbors
    else neighbors
  in

  let neighbors =
    if y <> 0 && Grid.get g (y - 1, x) = target then
      get_neighbor x (y - 1) :: neighbors
    else neighbors
  in

  let neighbors =
    if y < gheight - 1 && Grid.get g (y + 1, x) = target then
      get_neighbor x (y + 1) :: neighbors
    else neighbors
  in

  neighbors

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 42 "10" One
let part2 () = validate solve2 42 "10" Two
let solution : solution = { part1; part2 }

(* tests *)
