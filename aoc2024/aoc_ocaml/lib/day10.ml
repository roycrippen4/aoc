open Util
module G = Grid

type grid = int G.t
type point = { x : int; y : int; v : int }

let string_of_position (y, x) = Printf.sprintf "x: %d y: %d" x y

let string_of_point { x; y; v } =
  Printf.sprintf "{ x: %d; y: %d; v: %d }\n" x y v

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day10/data.txt"

let create_grid str =
  String.trim str |> G.of_string |> G.map (fun _ c -> int_of_char2 c)

let grid = create_grid input
let gheight = G.height grid
let gwidth = G.width grid

let show_grid g =
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

  g |> G.to_list |> print_rows

let get_neighbors p g =
  let point_of_entry = function
    | Some (y, x, v) -> if v = p.v + 1 then Some { x; y; v } else None
    | None -> None
  in
  G.neighbor4_entries g (p.y, p.x) |> List.filter_map point_of_entry

let get_start_points g =
  g |> G.filter (fun _ v -> v = 0) |> List.map (fun (y, x) -> { x; y; v = 0 })

let score_path p g =
  let visited = Hashtbl.create 0 in

  let rec aux p =
    Hashtbl.add visited p true;
    let not_visited p = not (Hashtbl.mem visited p) in

    if p.v = 9 then 1
    else
      let ns = get_neighbors p g |> List.filter not_visited in
      if List.is_empty ns then 0
      else ns |> List.map aux |> List.fold_left ( + ) 0
  in
  aux p

let solve1 () =
  let starting_points = get_start_points grid in

  let rec aux acc = function
    | [] -> acc
    | p :: ps -> aux (acc + score_path p grid) ps
  in

  aux 0 starting_points

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 517 "10" One
let part2 () = validate solve2 42 "10" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ =
  let ns =
    String.trim {|
9990999
9991999
9992999
6543456
7999997
8111118
9111119
|}
    |> create_grid
    |> get_neighbors { x = 3; y = 0; v = 0 }
  in
  let len_is_one = List.length ns = 1 in
  let n_is_same = List.hd ns = { x = 3; y = 1; v = 1 } in
  len_is_one && n_is_same

let%test _ =
  let eq a b = a = b in
  {|
9990999
9991999
9992999
6543456
7999997
8111118
9111119
|}
  |> String.trim
  |> create_grid
  |> score_path { x = 3; y = 0; v = 0 }
  |> eq 2
  && "/home/roy/dev/aoc/aoc2024/data/day10/example.txt"
     |> read_to_string
     |> String.trim
     |> create_grid
     |> score_path { x = 2; y = 0; v = 0 }
     |> eq 5
