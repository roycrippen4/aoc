open Util
module String = Batteries.String

(* part 1 *)

module Kind = struct
  type cell = Wall | Empty | Path
  type t = int

  let compare = compare
  let add = ( + )
  let zero = 0
  let passable cell = cell = Empty
  let cost _ = 1

  (* *)
  let char_of_kind = function Wall -> '#' | Empty -> '.' | Path -> 'O'
  let pp_kind fmt _ k = Format.fprintf fmt "%c" (char_of_kind k)
end

let show_grid grid = Grid.print Kind.pp_kind Format.std_formatter grid

let points =
  let ( >> ) f g x = g (f x) in
  let open String in
  "/home/roy/dev/aoc/aoc2024/data/day18/data.txt"
  |> read_to_string
  |> trim
  |> split_on_char '\n'
  |> List.map (split ~by:"," >> map_tuple int_of_string >> Point.of_tuple)

let grid =
  let size = 71 in
  let g = Grid.init size size (fun _ -> Kind.Empty) in
  points |> List.take 1024 |> List.iter (fun p -> g.Grid.%{p} <- Kind.Wall);
  g

let start = Point.{ x = 0; y = 0 }
let goal = Point.{ x = 70; y = 70 }

module Dijkstra = Grid.Dijkstra (Kind)

let solve1 () =
  Dijkstra.walk grid start goal |> Option.get |> List.length |> pred

(* part 2 *)
let points = Array.of_list points

let fill_graph stop_idx =
  let new_grid = Grid.copy grid in

  let rec loop idx =
    new_grid.Grid.%{points.(idx)} <- Kind.Wall;
    if idx = stop_idx then new_grid else loop (idx + 1)
  in

  loop 1024

let rec search lo hi =
  if lo = hi then lo
  else
    let mid = (lo + hi) lsr 1 in
    let graph = fill_graph mid in
    match Dijkstra.walk graph start goal with
    | None -> search lo mid
    | Some _ -> search (mid + 1) hi

let solve2 () =
  let idx = search 1024 (Array.length points - 1) in
  let point = points.(idx) in
  point.x * point.y

(* exports *)

let part1 () = validate solve1 506 "18" One
let part2 () = validate solve2 372 "18" Two
let solution : solution = { part1; part2 }

(* tests *)
