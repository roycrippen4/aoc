open Util

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day06/data.txt"

type direction = N | S | E | W
type kind = Guard | Block | Empty

module PosSet = Set.Make (struct
  type t = int * int

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
        guard := (!x, !y, N);
        incr x
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

let grid, guard_start = create_grid input
let gx, gy, _ = guard_start

let rec step (x, y, d) =
  let dx, dy = next_pos x y d in
  match Hashtbl.find_opt grid (dx, dy) with
  | None -> None
  | Some Empty -> Some (dx, dy, d)
  | Some Block -> step (x, y, rotate d)
  | _ -> assert false

let guard_path =
  let rec go guard acc =
    match guard with
    | None -> acc
    | Some (x, y, d) ->
        let next_g = step (x, y, d) in
        go next_g (PosSet.add (x, y) acc)
  in
  go (Some guard_start) PosSet.empty

let solve1 () = PosSet.cardinal guard_path

(* part 2 *)

let is_some_then f = function Some x -> f x | None -> None
let step_twice hare = step hare |> is_some_then step
let pop = function x :: xs -> (x, xs) | [] -> failwith "List is empty"

let rec is_loop = function
  | Some t, Some h ->
      let tort = step t in
      let hare = step_twice h in

      if tort = hare then true else is_loop (tort, hare)
  | _ -> false

let reset_old = function
  | Some old_obs -> Hashtbl.replace grid old_obs Empty
  | None -> ()

let solve2 () =
  let old_obs = ref None in
  let t = Some guard_start in
  let h = Some guard_start in

  let rec loop acc = function
    | [] -> acc
    | obs :: rest ->
        reset_old !old_obs;
        old_obs := Some obs;
        Hashtbl.replace grid obs Block;

        if is_loop (t, h) then loop (succ acc) rest else loop acc rest
  in

  loop 0 (PosSet.to_list guard_path |> List.filter (fun pos -> pos <> (gx, gy)))

(* exports *)

let part1 () = validate solve1 4559 "06" One
let part2 () = validate solve2 1604 "06" Two
let solution : solution = { part1; part2 }
