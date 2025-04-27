open Util
module G = Grid

type grid = int G.t
type point = { x : int; y : int; v : int }

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day10/data.txt"

let create_grid str =
  String.trim str |> G.of_string |> G.map_values int_of_char2

let grid = create_grid input
let gheight = G.height grid
let gwidth = G.width grid

let get_neighbors p =
  let point_of_entry = function
    | Some (x, y, v) -> if v = p.v + 1 then Some { x; y; v } else None
    | None -> None
  in
  grid |> G.neighbor4_entries (p.x, p.y) |> List.filter_map point_of_entry

let start_points =
  grid
  |> G.filter_entries (fun (_, _, v) -> v = 0)
  |> List.map (fun (x, y, _) -> { x; y; v = 0 })

let solve1 () =
  let score_path p =
    let visited = Hashtbl.create 0 in

    let rec aux p =
      Hashtbl.add visited p true;
      let not_visited p = not (Hashtbl.mem visited p) in

      if p.v = 9 then 1
      else
        let ns = get_neighbors p |> List.filter not_visited in
        if List.is_empty ns then 0
        else ns |> List.map aux |> List.fold_left ( + ) 0
    in
    aux p
  in

  let rec solve acc = function
    | [] -> acc
    | p :: ps -> solve (acc + score_path p) ps
  in

  solve 0 start_points

(* part 2 *)

let solve2 () =
  let rec score_path p =
    if p.v = 9 then 1
    else p |> get_neighbors |> List.map score_path |> List.fold_left ( + ) 0
  in

  let rec solve acc = function
    | [] -> acc
    | p :: ps -> solve (acc + score_path p) ps
  in

  solve 0 start_points

(* exports *)

let part1 () = validate solve1 517 "10" One
let part2 () = validate solve2 1116 "10" Two
let solution : solution = { part1; part2 }

(* tests *)
