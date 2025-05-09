open Util

let path = "/home/roy/dev/aoc/aoc2024/data/day20/data.txt"
let input = path |> read_to_string |> String.trim

module Kind = struct
  type t = Wall | Path | Start | End | Try

  let to_char = function
    | Wall -> '#'
    | Path -> '.'
    | Start -> 'S'
    | End -> 'E'
    | Try -> '*'

  let of_char = function
    | '#' -> Wall
    | '.' -> Path
    | 'S' -> Start
    | 'E' -> End
    | _ -> assert false

  let is_start (_, _, v) = v = Start
  let is_goal (_, _, v) = v = End
  let is_path (_, _, v) = v = Path
  let pp fmt _ k = Format.fprintf fmt "%c" (to_char k)
end

let grid = Grid.(input |> of_string |> strip_edges |> map_values Kind.of_char)

type direction = UpDown | LeftRight

let next_point tbl (x, y, _) =
  let not_in_tbl (x, y) = Hashtbl.mem tbl (x, y) |> not in
  let path_or_end v = Kind.(Path = v || End = v) in
  let is_new (x, y, v) = path_or_end v && not_in_tbl (x, y) in

  grid
  |> Grid.nbor4 (x, y)
  |> List.filter_map identity
  |> List.filter is_new
  |> List.hd

let rec fill_tbl (x, y, v) steps tbl =
  match v with
  | Kind.End ->
      Hashtbl.add tbl (x, y) steps;
      tbl
  | Kind.Path | Kind.Start ->
      Hashtbl.add tbl (x, y) steps;
      let next = next_point tbl (x, y, v) in
      fill_tbl next (succ steps) tbl
  | _ -> assert false

let cheat_diff tbl (x, y, d) =
  let p = (x, y) in
  match d with
  | LeftRight ->
      let l = p |> Grid.west |> Hashtbl.find tbl in
      let r = p |> Grid.east |> Hashtbl.find tbl in
      abs (l - r) - 2
  | UpDown ->
      let u = p |> Grid.north |> Hashtbl.find tbl in
      let d = p |> Grid.south |> Hashtbl.find tbl in
      abs (u - d) - 2

let into_cheat_pt (x, y, v) =
  let v_okay v' = Kind.(v' = Path || v' = Start || v' = End) in
  let same_y (_, y', v') = y' = y && v_okay v' in
  let same_x (x', _, v') = x' = x && v_okay v' in

  let left_right lst = lst |> List.filter same_y |> List.length = 2 in
  let up_down lst = lst |> List.filter same_x |> List.length = 2 in

  let nbors = grid |> Grid.nbor4 (x, y) |> List.filter_map identity in
  let is_lr = left_right nbors in
  let is_ud = up_down nbors in
  let is_candidate = Kind.Wall = v && is_lr <> is_ud in

  match is_candidate with
  | true when is_lr -> Some (x, y, LeftRight)
  | true when is_ud -> Some (x, y, UpDown)
  | _ -> None

(* part 1 *)
let solve1 () =
  let open Grid in
  let start = grid |> find Kind.is_start |> entry grid in
  let path = fill_tbl start 0 (Hashtbl.create 1024) in

  let steps_saved = 100 in
  let gt = fun x -> x >= steps_saved in

  grid
  |> filter (fun _ -> true)
  |> List.filter_map into_cheat_pt
  |> List.map (cheat_diff path)
  |> List.filter gt
  |> List.length

(* part 2 *)
let solve2 () = 42

(* exports *)

let part1 () = validate solve1 1387 "20" One
let part2 () = validate solve2 42 "20" Two
let solution : solution = { part1; part2 }

(* tests *)
