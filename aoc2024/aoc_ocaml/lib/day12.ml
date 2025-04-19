open Util
module G = Grid

let directions = [ (1, 0); (-1, 0); (0, 1); (0, -1) ]

(* *)

let path = "/home/roy/dev/aoc/aoc2024/data/day12/data.txt"
let lines = path |> read_to_lines |> List.map String.trim
let size = List.length lines
let grid = lines |> List.map str_explode |> List.flatten |> Array.of_list
let seen = Array.init (Array.length grid) (fun _ -> false)

(* helper functions *)

let identity v = v
let idx x y = (y * size) + x

(** Takes the current point and a coordinate offset.
    + Returns [(None, 1)] when the neighbor is out of bounds or the neighbor's
      value does not equal the value of current coordinate
    + Returns [(Some (nx, ny), 0)] if the neighbor is in bounds, equals the
      current coordinate's value, and has not been seen
    + Returns [(None, 0)] if none of the above conditions are met *)
let nbor (x, y) (dx, dy) =
  let nx = x + dx in
  let ny = y + dy in
  let ni = idx nx ny in

  let not_in_bounds = nx < 0 || ny < 0 || nx >= size || ny >= size in
  let nbor_not_same =
    try grid.(ni) <> grid.(idx x y) with Invalid_argument _ -> false
  in

  if not_in_bounds || nbor_not_same then (None, 1)
  else if not seen.(ni) then (Some ni, 0)
  else (None, 0)

(** Iterates over orthoganal neighbors of a given index [i]. Returns all
    neighboring points that need to be added to the stack and the perimeter
    length relative to the current point *)
let walk_neighbors i =
  let p = (i % size, i / size) in
  let points, perimiters = directions |> List.map (nbor p) |> List.split in
  let points = List.filter_map identity points in
  let perimiter = List.fold_left ( + ) 0 perimiters in
  (points, perimiter)

(* Flood-fill search *)
let flood start =
  let rec aux area perimeter = function
    | [] -> area * perimeter
    | i :: rest ->
        if seen.(i) then aux area perimeter rest
        else (
          (* Only side effect? *)
          seen.(i) <- true;
          let points, peri = walk_neighbors i in
          let perimeter = peri + perimeter in
          let area = area + 1 in
          aux area perimeter (points @ rest))
  in
  aux 0 0 [ start ]

(* *)

let solve1 () =
  let indices = Array.init (Array.length grid) identity in
  Array.fold_left (fun acc i -> acc + flood i) 0 indices

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 1361494 "12" One
let part2 () = validate solve2 42 "12" Two
let solution : solution = { part1; part2 }

(* tests *)
