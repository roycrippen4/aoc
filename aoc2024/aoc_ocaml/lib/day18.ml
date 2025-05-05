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

let grid =
  let open String in
  let ( >> ) f g x = g (f x) in

  let size = 71 in
  let n_walls = 1024 in
  let g = Grid.init size size (fun _ -> Kind.Empty) in

  "/home/roy/dev/aoc/aoc2024/data/day18/data.txt"
  |> read_to_string
  |> trim
  |> split_on_char '\n'
  |> List.map (split ~by:"," >> map_tuple int_of_string >> Point.of_tuple)
  |> List.take n_walls
  |> List.iter (fun p -> g.Grid.%{p} <- Kind.Wall);
  g

let solve1 () =
  let module Dijkstra = Grid.Dijkstra (Kind) in
  Dijkstra.walk grid { x = 0; y = 0 } { x = 70; y = 70 }
  |> Option.get
  |> List.length
  |> pred

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 506 "18" One
let part2 () = validate solve2 42 "18" Two
let solution : solution = { part1; part2 }

(* tests *)
