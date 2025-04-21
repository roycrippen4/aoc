open Util

module Array = struct
  include Array

  (** Replaces element at [i] with [v] and returns the original value *)
  let replace arr i v =
    let orig = arr.(i) in
    arr.(i) <- v;
    orig
end

let input_str = read_to_string "/home/roy/dev/aoc/aoc2024/data/day12/data.txt"
let split = String.split_on_char
let trim = String.trim

let create_grid str =
  let lines = str |> trim |> split '\n' |> List.map trim in
  let size = List.length lines in
  let grid = lines |> List.map str_explode |> List.flatten |> Array.of_list in
  (size, grid)

let size, grid = create_grid input_str

(* helpers *)

let directions = [ (1, 0); (-1, 0); (0, 1); (0, -1) ]
let identity v = v
let idx x y = (y * size) + x

(** Takes the current point and a coordinate offset.
    + Returns [(None, 1)] when the neighbor is out of bounds or the neighbor's
      value does not equal the value of current coordinate
    + Returns [(Some (nx, ny), 0)] if the neighbor is in bounds, equals the
      current coordinate's value, and has not been seen
    + Returns [(None, 0)] if none of the above conditions are met *)
let nbor seen (x, y) (dx, dy) =
  let nx, ny = (x + dx, y + dy) in
  let ni = idx nx ny in
  let i = idx x y in

  let out_of_bounds = nx < 0 || ny < 0 || nx >= size || ny >= size in
  let not_same = try grid.(ni) <> grid.(i) with Invalid_argument _ -> false in

  if out_of_bounds || not_same then (None, 1)
  else if not seen.(ni) then (Some ni, 0)
  else (None, 0)

(** Iterates over orthoganal neighbors of a given index [i]. Returns all
    neighboring points that need to be added to the stack and the perimeter
    length relative to the current point *)
let walk_neighbors seen i =
  let p = (i mod size, i / size) in
  let points, perimiters = directions |> List.map (nbor seen p) |> List.split in
  let points = List.filter_map identity points in
  let perimiter = List.fold_left ( + ) 0 perimiters in
  (points, perimiter)

(* Flood-fill search *)
let flood seen start =
  let rec aux area perimeter = function
    | [] -> area * perimeter
    | i :: rest ->
        if seen.(i) then aux area perimeter rest
        else (
          seen.(i) <- true;
          let points, peri = walk_neighbors seen i in
          let perimeter = peri + perimeter in
          let area = area + 1 in
          aux area perimeter (points @ rest))
  in
  aux 0 0 [ start ]

(* *)

let solve1 () =
  let len = Array.length grid in
  let seen = Array.init len (fun _ -> false) in
  let indices = Array.init len identity in
  Array.fold_left (fun acc i -> acc + flood seen i) 0 indices

(* part 2 *)

let count_corners (x, y, v) =
  let l = x > 0 in
  let r = x + 1 < size in
  let t = y > 0 in
  let b = y + 1 < size in

  let sl = l && grid.(idx (x - 1) y) = v in
  let sr = r && grid.(idx (x + 1) y) = v in
  let st = t && grid.(idx x (y - 1)) = v in
  let sb = b && grid.(idx x (y + 1)) = v in

  let sbl = b && l && grid.(idx (x - 1) (y + 1)) = v in
  let sbr = b && r && grid.(idx (x + 1) (y + 1)) = v in
  let stl = t && l && grid.(idx (x - 1) (y - 1)) = v in
  let str = t && r && grid.(idx (x + 1) (y - 1)) = v in

  let tlc = ((not sl) && not st) || (sl && st && not stl) in
  let trc = ((not sr) && not st) || (sr && st && not str) in
  let blc = ((not sl) && not sb) || (sl && sb && not sbl) in
  let brc = ((not sr) && not sb) || (sr && sb && not sbr) in

  let tl = if tlc then 1 else 0 in
  let tr = if trc then 1 else 0 in
  let bl = if blc then 1 else 0 in
  let br = if brc then 1 else 0 in
  tl + tr + bl + br

let nbor seen (x, y) (dx, dy) =
  let nx, ny = (x + dx, y + dy) in
  let ni = idx nx ny in
  if
    nx < 0
    || ny < 0
    || nx >= size
    || ny >= size
    || grid.(ni) <> grid.(idx x y)
    || seen.(ni)
  then None
  else Some ni

let walk_neighbors seen (x, y) =
  directions |> List.filter_map (nbor seen (x, y))

let flood seen start =
  let rec aux area sides = function
    | [] -> area * sides
    | i :: rest ->
        if seen.(i) then aux area sides rest
        else (
          seen.(i) <- true;
          let x, y, v = (i mod size, i / size, grid.(i)) in
          let area = area + 1 in
          let sides = sides + count_corners (x, y, v) in
          let points = walk_neighbors seen (x, y) in
          aux area sides (points @ rest))
  in
  aux 0 0 [ start ]

let solve2 () =
  let len = Array.length grid in
  let seen = Array.init len (fun _ -> false) in
  let indices = Array.init len identity in
  Array.fold_left (fun acc i -> acc + flood seen i) 0 indices

(* exports *)

let part1 () = validate solve1 1361494 "12" One
let part2 () = validate solve2 830516 "12" Two
let solution : solution = { part1; part2 }
