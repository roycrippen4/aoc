open Util
module H = Hashtbl
module G = Grid

let path = "/home/roy/dev/aoc/aoc2024/data/day20/data.txt"
let input = path |> read_to_string |> String.trim

type kind = Wall | Path | Start | End

let kind_of_char = function
  | '#' -> Wall
  | '.' -> Path
  | 'S' -> Start
  | 'E' -> End
  | _ -> assert false

let kind_is_start (_, _, v) = v = Start
and kind_is_goal (_, _, v) = v = End

let grid = G.(input |> of_string |> strip_edges |> map_values kind_of_char)
let start = G.(grid |> find (fun (_, _, v) -> v = Start) |> entry grid)

let width = G.width grid
and height = G.height grid

let make_path () =
  let s = Array.make_matrix height width (-1) in

  let rec walk (x, y, v) i acc =
    s.(y).(x) <- i;
    let acc = (x, y, v) :: acc in

    if v = End then acc
    else
      let is_valid (x, y, v) = s.(y).(x) = -1 && (v = Path || v = End) in
      let valid_opt = function Some p when is_valid p -> Some p | _ -> None in
      let next = List.(G.nbor4 (x, y) grid |> filter_map valid_opt |> hd) in

      walk next (i + 1) acc
  in

  (s, walk start 0 [])

let steps, path = make_path ()

let diamond20 =
  let rec row dx l acc =
    if dx > l then acc
    else
      let dy = l - dx in
      let acc = (dx, dy, l) :: acc in
      let acc = if dx <> 0 then (-dx, dy, l) :: acc else acc in
      let acc = if dy <> 0 then (dx, -dy, l) :: acc else acc in
      let acc = if dx <> 0 && dy <> 0 then (-dx, -dy, l) :: acc else acc in
      row (dx + 1) l acc
  in
  let rec layers l acc = if l = 0 then acc else layers (l - 1) (row 0 l acc) in
  layers 20 []

let cheats (cx, cy) radius =
  let center_steps = steps.(cy).(cx) in
  let rec loop acc = function
    | [] -> acc
    | (dx, dy, dist) :: rest ->
        if dist > radius then loop acc rest
        else
          let x, y = (cx + dx, cy + dy) in
          let inside x y = x >= 0 && x < width && y >= 0 && y < height in
          if not (inside x y) then loop acc rest
          else
            let s = steps.(y).(x) in
            if s > center_steps then
              let saved_steps = s - center_steps - dist in
              let acc = if saved_steps >= 100 then acc + 1 else acc in
              loop acc rest
            else loop acc rest
  in
  loop 0 diamond20

let solve radius =
  List.fold_left (fun acc (x, y, _) -> acc + cheats (x, y) radius) 0 path

let solve1 () = solve 2
let solve2 () = solve 20

(* exports *)

let part1 () = validate solve1 1387 "20" One
let part2 () = validate solve2 1015092 "20" Two
let solution : solution = { part1; part2 }
