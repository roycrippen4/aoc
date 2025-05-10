open Util

let grid = Grid.from_file "/home/roy/dev/aoc/aoc2024/data/day08/data.txt"
let width = Grid.width grid
let height = Grid.height grid
let antennas = Hashtbl.create 1024

module PointSet = Set.Make (struct
  type t = int * int

  let compare = compare
end)

(* Ported from rust std *)
let is_alphanumeric = function
  | '0' .. '9' | 'A' .. 'Z' | 'a' .. 'z' -> true
  | _ -> false

let%test _ = not (is_alphanumeric '\\')
let%test _ = not (is_alphanumeric '?')
let%test _ = is_alphanumeric '1'
let%test _ = is_alphanumeric 'a'

(**)

let update_antennas (x, y, v) =
  if is_alphanumeric v then
    match Hashtbl.find_opt antennas v with
    | None -> Hashtbl.add antennas v [ (x, y) ]
    | Some entry -> Hashtbl.replace antennas v ((x, y) :: entry)

let () = Grid.iter update_antennas grid

(* Unsigned integer subtraction of [x] - [y] with underflow protection *)
let ( -| ) x y = if x < 1 || y < 0 || y > x then None else Some (x - y)

(* Unsigned integer multiplication of [x] * [y] with overflow protection *)
let ( *| ) x y =
  let gt_zero = x < 0 || y < 0 in
  let not_zero = x <> 0 && y <> 0 in
  if gt_zero || (not_zero && y > max_int / x) then None else Some (x * y)

let rotate_point (x, y) (px, py) =
  let* x2 = Option.and_then (fun two_px -> two_px -| x) (px *| 2) in
  let* y2 = Option.and_then (fun two_py -> two_py -| y) (py *| 2) in
  if x2 < width && y2 < height then Some (x2, y2) else None

let insert_if_some p1 p2 acc =
  let insert_if_some' p acc = match p with Some p -> p :: acc | None -> acc in
  let rot1 = rotate_point p1 p2 in
  let rot2 = rotate_point p2 p1 in
  acc |> insert_if_some' rot1 |> insert_if_some' rot2

let process_positions _ positions acc =
  let rec process_positions' ps acc =
    match ps with
    | [] -> acc
    | (p1, p2) :: rest -> process_positions' rest (insert_if_some p1 p2 acc)
  in
  process_positions' (combos positions) acc

let solve1 () =
  Hashtbl.fold process_positions antennas []
  |> PointSet.of_list |> PointSet.cardinal

(* part 2 *)

let insert_while p1 p2 acc =
  let rec insert_while' a b acc =
    match rotate_point a b with
    | Some c -> insert_while' b c (c :: acc)
    | None -> acc
  in
  p1 :: p2 :: acc |> insert_while' p1 p2 |> insert_while' p2 p1

let process_positions _ positions acc =
  let rec process_positions' ps acc =
    match ps with
    | [] -> acc
    | (p1, p2) :: rest -> process_positions' rest (insert_while p1 p2 acc)
  in
  process_positions' (combos positions) acc

let solve2 () =
  Hashtbl.fold process_positions antennas []
  |> PointSet.of_list |> PointSet.cardinal

(* exports *)

let part1 () = validate solve1 244 "08" One
let part2 () = validate solve2 912 "08" Two
let solution : solution = { part1; part2 }

(* tests *)
