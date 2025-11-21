open Util

module Hashtbl = struct
  include Hashtbl

  let find_or_insert_default t k default =
    match find_opt t k with
    | Some v -> v
    | None ->
        add t k default;
        default
end

(** {v
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
    v} *)
module DirKey = struct
  type t = Up | Down | Left | Right | A

  let go_press self next =
    match self with
    | Up -> (
        match next with
        | Up -> [ [ A ] ]
        | Down -> [ [ Down; A ] ]
        | Left -> [ [ Down; Left; A ] ]
        | Right -> [ [ Down; Right; A ]; [ Right; Down; A ] ]
        | A -> [ [ Right; A ] ])
    | Down -> (
        match next with
        | Up -> [ [ Up; A ] ]
        | Down -> [ [ A ] ]
        | Left -> [ [ Left; A ] ]
        | Right -> [ [ Right; A ] ]
        | A -> [ [ Up; Right; A ]; [ Right; Up; A ] ])
    | Left -> (
        match next with
        | Up -> [ [ Right; Up; A ] ]
        | Down -> [ [ Right; A ] ]
        | Left -> [ [ A ] ]
        | Right -> [ [ Right; Right; A ] ]
        | A -> [ [ Right; Right; Up; A ] ])
    | Right -> (
        match next with
        | Up -> [ [ Up; Left; A ]; [ Left; Up; A ] ]
        | Down -> [ [ Left; A ] ]
        | Left -> [ [ Left; Left; A ] ]
        | Right -> [ [ A ] ]
        | A -> [ [ Up; A ] ])
    | A -> (
        match next with
        | Up -> [ [ Left; A ] ]
        | Down -> [ [ Left; Down; A ]; [ Down; Left; A ] ]
        | Left -> [ [ Down; Left; Left; A ] ]
        | Right -> [ [ Down; A ] ]
        | A -> [ [ A ] ])

  let to_char = function
    | Up -> '^'
    | Down -> 'v'
    | Left -> '<'
    | Right -> '>'
    | A -> 'A'

  let to_string = to_char >> Printf.sprintf "%c"
end

let dirs_to_string dirs = dirs |> List.map DirKey.to_string

(** {v
+---+---+---+
| 7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
    | 0 | A |
    +---+---+
    v} *)
module NumKey = struct
  type t = K7 | K8 | K9 | K4 | K5 | K6 | K1 | K2 | K3 | K0 | KA

  let next_key self dir =
    match self with
    | K7 -> (
        match dir with
        | DirKey.Up -> None
        | DirKey.Down -> Some K4
        | DirKey.Left -> None
        | DirKey.Right -> Some K8
        | _ -> assert false)
    | K8 -> (
        match dir with
        | DirKey.Up -> None
        | DirKey.Down -> Some K5
        | DirKey.Left -> Some K7
        | DirKey.Right -> Some K9
        | _ -> assert false)
    | K9 -> (
        match dir with
        | DirKey.Up -> None
        | DirKey.Down -> Some K6
        | DirKey.Left -> Some K8
        | DirKey.Right -> None
        | _ -> assert false)
    | K4 -> (
        match dir with
        | DirKey.Up -> Some K7
        | DirKey.Down -> Some K1
        | DirKey.Left -> None
        | DirKey.Right -> Some K5
        | A -> assert false)
    | K5 -> (
        match dir with
        | DirKey.Up -> Some K8
        | DirKey.Down -> Some K2
        | DirKey.Left -> Some K4
        | DirKey.Right -> Some K6
        | A -> assert false)
    | K6 -> (
        match dir with
        | DirKey.Up -> Some K9
        | DirKey.Down -> Some K3
        | DirKey.Left -> Some K5
        | DirKey.Right -> None
        | A -> assert false)
    | K1 -> (
        match dir with
        | DirKey.Up -> Some K4
        | DirKey.Down -> None
        | DirKey.Left -> None
        | DirKey.Right -> Some K2
        | A -> assert false)
    | K2 -> (
        match dir with
        | DirKey.Up -> Some K5
        | DirKey.Down -> Some K0
        | DirKey.Left -> Some K1
        | DirKey.Right -> Some K3
        | A -> assert false)
    | K3 -> (
        match dir with
        | DirKey.Up -> Some K6
        | DirKey.Down -> Some KA
        | DirKey.Left -> Some K2
        | DirKey.Right -> None
        | A -> assert false)
    | K0 -> (
        match dir with
        | DirKey.Up -> Some K2
        | DirKey.Down -> None
        | DirKey.Left -> None
        | DirKey.Right -> Some KA
        | A -> assert false)
    | KA -> (
        match dir with
        | DirKey.Up -> Some K3
        | DirKey.Down -> None
        | DirKey.Left -> Some K0
        | DirKey.Right -> None
        | A -> assert false)

  let dir self next =
    match self with
    | K7 -> (
        match next with
        | K8 -> DirKey.Right
        | K4 -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K8 -> (
        match next with
        | K7 -> DirKey.Left
        | K9 -> DirKey.Right
        | K5 -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K9 -> (
        match next with
        | K8 -> DirKey.Left
        | K6 -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K4 -> (
        match next with
        | K7 -> DirKey.Up
        | K5 -> DirKey.Right
        | K1 -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K5 -> (
        match next with
        | K8 -> DirKey.Up
        | K4 -> DirKey.Left
        | K6 -> DirKey.Right
        | K2 -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K6 -> (
        match next with
        | K9 -> DirKey.Up
        | K5 -> DirKey.Left
        | K3 -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K1 -> (
        match next with
        | K4 -> DirKey.Up
        | K2 -> DirKey.Right
        | _ -> failwith "Keys are not neighbors.")
    | K2 -> (
        match next with
        | K5 -> DirKey.Up
        | K1 -> DirKey.Left
        | K3 -> DirKey.Right
        | K0 -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K3 -> (
        match next with
        | K6 -> DirKey.Up
        | K2 -> DirKey.Left
        | KA -> DirKey.Down
        | _ -> failwith "Keys are not neighbors.")
    | K0 -> (
        match next with
        | K2 -> DirKey.Up
        | KA -> DirKey.Right
        | _ -> failwith "Keys are not neighbors.")
    | KA -> (
        match next with
        | K0 -> DirKey.Left
        | K3 -> DirKey.Up
        | _ -> failwith "Keys are not neighbors.")

  let find_all_paths_to self to_key =
    let module Dq = Core.Deque in
    (* Queue for BFS, storing (current key, current path) *)
    let q = Dq.create () in
    Dq.enqueue_back q (self, [ self ]);

    (* Use a map to track the shortest known distance to each node *)
    let shortest = Hashtbl.create 1024 in
    Hashtbl.add shortest self 1;

    let rec nbor_keys path len = function
      | [] -> ()
      | k :: rest ->
          let next_dist = Hashtbl.find_or_insert_default shortest k max_int in

          if len < next_dist then (
            Hashtbl.replace shortest k (len + 1);
            Dq.enqueue_back q (k, k :: path));

          nbor_keys path len rest
    in

    let rec process_q paths min_len =
      let fmap = List.filter_map in
      let len = List.length in

      match Dq.dequeue_front q with
      | None -> paths
      | Some (k, p) when k = to_key -> (
          match len p with
          | l when l < min_len -> process_q [ p ] l
          | l when l = min_len -> process_q (p :: paths) min_len
          | _ -> process_q paths min_len)
      | Some (_, p) when len p >= min_len -> process_q paths min_len
      | Some (k, p) ->
          let keys =
            [ DirKey.Up; DirKey.Down; DirKey.Left; DirKey.Right ]
            |> fmap (next_key k)
          in
          let () = nbor_keys p (len p) keys in
          process_q paths min_len
    in

    process_q [] max_int |> List.map List.rev

  let of_char = function
    | '7' -> K7
    | '8' -> K8
    | '9' -> K9
    | '4' -> K4
    | '5' -> K5
    | '6' -> K6
    | '1' -> K1
    | '2' -> K2
    | '3' -> K3
    | '0' -> K0
    | 'A' -> KA
    | _ -> assert false

  let to_char = function
    | K7 -> '7'
    | K8 -> '8'
    | K9 -> '9'
    | K4 -> '4'
    | K5 -> '5'
    | K6 -> '6'
    | K1 -> '1'
    | K2 -> '2'
    | K3 -> '3'
    | K0 -> '0'
    | KA -> 'A'

  let to_string = to_char >> Printf.sprintf "%c"
end

let find_code_paths code =
  let rec loop acc pairs =
    match pairs with
    | [] -> acc
    | pair :: rest ->
        let a, b = Tuple.map NumKey.of_char pair in
        let paths = NumKey.find_all_paths_to a b in
        let map_base = fun path -> List.map (fun base -> base @ path) acc in
        let acc = List.concat_map map_base paths in

        loop acc rest
  in
  loop [ [] ] (pairs code)

let convert_num_paths_to_directions path =
  let f = fun (a, b) -> if a = b then DirKey.A else NumKey.dir a b in
  List.map f (pairs path) @ [ DirKey.A ]

let cache = Hashtbl.create 1024

let rec seq_len n_bots dirs : int =
  let open List in
  let press_seq () =
    pairs (DirKey.A :: dirs)
    |> map (fun (a, b) ->
        DirKey.go_press a b
        |> map (seq_len (n_bots - 1))
        |> fold_left min max_int)
    |> fold_left ( + ) 0
  in

  let key = (dirs, n_bots) in
  match Hashtbl.find_opt cache key with
  | Some v -> v
  | None ->
      let result = if n_bots = 0 then length dirs else press_seq () in
      Hashtbl.add cache key result;
      result

let shortest_seq_len code n_bots =
  find_code_paths ('A' :: code)
  |> List.map convert_num_paths_to_directions
  |> List.map (seq_len n_bots)
  |> List.fold_left min max_int

let code_num = function
  | c1 :: c2 :: c3 :: _ ->
      let d c = Char.(code c - code '0') in
      (d c1 * 100) + (d c2 * 10) + d c3
  | _ -> assert false

let complexity codes n_bots =
  let sum acc code = acc + (shortest_seq_len code n_bots * code_num code) in
  List.fold_left sum 0 codes

let codes =
  "/home/roy/dev/aoc/aoc2024/data/day21/data.txt" |> read_to_string
  |> String.trim |> String.split_on_char '\n' |> List.map String.explode

let solve1 () = complexity codes 2
let solve2 () = complexity codes 25

(* exports *)
let part1 () = validate solve1 222670 "21" One
let part2 () = validate solve2 271397390297138 "21" Two
let solution : solution = { part1; part2 }
