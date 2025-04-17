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

let get_neighbors p (g : grid) : point list =
  let point_of_entry = function
    | Some (y, x, v) -> if v = p.v + 1 then Some { x; y; v } else None
    | None -> None
  in
  Grid.neighbor4_entries g (p.y, p.x) |> List.filter_map point_of_entry

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 42 "10" One
let part2 () = validate solve2 42 "10" Two
let solution : solution = { part1; part2 }

(* tests *)
