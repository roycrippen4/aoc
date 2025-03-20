open Util

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day06/data.txt"

type direction = N | S | E | W
type guard = int * int * direction
type kind = Guard | Block | Empty

module PosSet = Set.Make (struct
  type t = int * int * direction

  let compare = compare
end)

let kind_of_char = function
  | '^' -> Guard
  | '.' -> Empty
  | '#' -> Block
  | _ -> raise Not_found

let create_grid s =
  let grid = Hashtbl.create (String.length s) in
  let x = ref 0 in
  let y = ref 0 in
  let guard = ref (-1, -1, S) in

  let process_char c =
    match c with
    | '\n' ->
        incr y;
        x := 0
    | '^' ->
        Hashtbl.add grid (!x, !y) Empty;
        guard := (!x, !y, N)
    | _ ->
        Hashtbl.add grid (!x, !y) (kind_of_char c);
        incr x
  in

  String.iter process_char s;
  (grid, !guard)

let rotate = function N -> E | E -> S | S -> W | W -> N

let next_pos x y = function
  | N -> (x, y - 1)
  | S -> (x, y + 1)
  | E -> (x + 1, y)
  | W -> (x - 1, y)

let rec step grid (x, y, d) =
  let dx, dy = next_pos x y d in
  match Hashtbl.find_opt grid (dx, dy) with
  | None -> None
  | Some Empty -> Some (dx, dy, d)
  | Some Block -> step grid (x, y, rotate d)
  | _ -> assert false

(* exports *)

let solve1 () =
  let grid, guard_start = create_grid input in

  let rec go guard acc =
    match guard with
    | None -> acc
    | Some (x, y, d) ->
        let next_g = step grid (x, y, d) in
        go next_g (PosSet.add (x, y, d) acc)
  in
  go (Some guard_start) PosSet.empty |> PosSet.cardinal

let solve2 () = 42
let part1 () = validate solve1 4559 "06" One
let part2 () = validate solve2 42 "06" Two
let solution : solution = { part1; part2 }

let%test _ =
  let answer = solve1 () in
  Printf.printf "\nanswer: %d\n\n" answer;
  true
