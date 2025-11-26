open Util
module Deque = Core.Deque

let swap a b =
  let t = !a in
  a := !b;
  b := t

let path = "/home/roy/dev/aoc/aoc2024/data/day16/data.txt"
let input = path |> read_to_string |> String.trim
let lines = input |> String.lines

(* dimensions *)
let dim = List.length lines
let size = dim * dim

(* parse grid *)
let grid = lines |> List.map chars |> List.flatten |> Array.of_list

(* Easy indexing *)
let ( .%{} ) g (p : Point.t) = g.((p.y * dim) + p.x)
let ( .%{}<- ) g (p : Point.t) v = g.((p.y * dim) + p.x) <- v
let ( ++ ) = Point.( ++ )
let ( -- ) = Point.( -- )

(* Set up queues *)
let seen = Array.init size (fun _ -> [| max_int; max_int; max_int; max_int |])
let directions = Point.[| right; down; left; up |]
let best_paths = Array.init size (fun _ -> false)

(* Helper functions *)
let not_wall pos = grid.%{pos} <> '#'
let is_cheaper (pos, dir, cost) = cost < seen.%{pos}.(dir)
let not_empty dq = not (Deque.is_empty dq)
let point_of_index idx = Point.make (idx mod dim) (idx / dim)

(* get start/end *)
let start = grid |> Array.find_index (( = ) 'S') |> Option.get |> point_of_index
let goal = grid |> Array.find_index (( = ) 'E') |> Option.get |> point_of_index

(* Solution *)
let first = ref (Deque.create ())
let second = ref (Deque.create ())
let lowest = ref max_int

let rec reverse_dfs todo =
  match Deque.dequeue_front !todo with
  | None -> ()
  | Some (pos, dir, cost) ->
      best_paths.%{pos} <- true;

      if pos = start then reverse_dfs todo
      else
        let forward = Point.(pos -- directions.(dir), dir, cost - 1) in
        let left = (pos, (dir + 3) mod 4, cost - 1000) in
        let right = (pos, (dir + 1) mod 4, cost - 1000) in

        [ forward; left; right ]
        |> List.iter (fun (pos, dir, cost) ->
            if cost = seen.%{pos}.(dir) then (
              Deque.enqueue_back !todo (pos, dir, cost);
              seen.%{pos}.(dir) <- max_int));

        reverse_dfs todo

let rec dfs () =
  match Deque.dequeue_front !first with
  | None -> ()
  | Some (_, _, cost) when cost >= !lowest -> dfs ()
  | Some (pos, _, cost) when pos = goal ->
      lowest := cost;
      dfs ()
  | Some (pos, dir, cost) ->
      let forward = (pos ++ directions.(dir), dir, cost + 1) in
      let left = (pos, (dir + 3) mod 4, cost + 1000) in
      let right = (pos, (dir + 1) mod 4, cost + 1000) in

      let update_queue curr_dir ((pos, dir, cost) as state) =
        if not_wall pos && is_cheaper state then (
          let q = if curr_dir = dir then !first else !second in
          Deque.enqueue_back q state;
          seen.%{pos}.(dir) <- cost)
      in

      [ forward; left; right ] |> List.iter (update_queue dir);
      dfs ()

let solve1 () =
  Deque.enqueue_back !first (start, 0, 0);
  seen.%{start}.(0) <- 0;

  while not_empty !first do
    dfs ();
    swap first second
  done;

  !lowest

(* part 2 *)

let solve2 () =
  let todo = ref (Deque.create ()) in

  let queue_unseen dir =
    if seen.%{goal}.(dir) = !lowest then
      Deque.enqueue_back !todo (goal, dir, !lowest)
  in
  [ 0; 1; 2; 3 ] |> List.iter queue_unseen;

  reverse_dfs todo;

  let add_if_true acc bool = if bool then acc + 1 else acc in
  Array.fold_left add_if_true 0 best_paths

(* exports *)

let part1 () = validate solve1 133584 "16" One
let part2 () = validate solve2 622 "16" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ =
  let a = ref 69 in
  let b = ref 420 in
  swap a b;
  !b = 69 && !a = 420
