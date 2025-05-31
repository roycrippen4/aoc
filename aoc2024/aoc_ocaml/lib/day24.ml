open Util

module H = struct
  include Hashtbl

  let keys tbl = tbl |> to_seq_keys |> List.of_seq
  let values tbl = tbl |> to_seq_values |> List.of_seq
  let to_list tbl = tbl |> to_seq |> List.of_seq
end

type symbol = int * int * int

let symbol_of_string s =
  String.explode s |> List.map int_of_char |> function
  | [ a; b; c ] -> (a, b, c)
  | _ -> invalid_arg "list must only contain 3 chars"

let string_of_symbol (a, b, c) =
  [ a; b; c ] |> List.map Char.chr |> String.implode

type expr =
  | And of (symbol * symbol)
  | Or of (symbol * symbol)
  | Xor of (symbol * symbol)

let string_of_expr expr =
  let open Printf in
  match expr with
  | And (a, b) -> sprintf "%s AND %s" (string_of_symbol a) (string_of_symbol b)
  | Or (a, b) -> sprintf "%s OR %s" (string_of_symbol a) (string_of_symbol b)
  | Xor (a, b) -> sprintf "%s XOR %s" (string_of_symbol a) (string_of_symbol b)

type values = (symbol, bool) H.t
type exprs = (symbol, expr) H.t

let values, exprs =
  let open String in
  let tuples3 l =
    let rec loop tups = function
      | [] -> tups
      | lst -> (
          match List.(take 3 lst, drop 3 lst) with
          | [ a; b; c ], rest -> loop ((a, b, c) :: tups) rest
          | _ -> tups)
    in
    loop [] l |> List.rev
  in

  let tuples5 l =
    let rec loop tups = function
      | [] -> tups
      | lst -> (
          match List.(take 5 lst, drop 5 lst) with
          | [ a; b; c; d; e ], rest -> loop ((a, b, c, d, e) :: tups) rest
          | _ -> tups)
    in
    loop [] l |> List.rev
  in

  let split_on_delims = split_on_chars ~on:[ '\n'; ':'; ' ' ] in

  let parse_values s : values =
    split_on_delims s |> tuples3
    |> List.map (fun (label, _, v) -> (symbol_of_string label, v <> "0"))
    |> List.to_seq |> H.of_seq
  in

  let parse_exprs s : exprs =
    let parse_expr (a, op, b, _, c) : symbol * expr =
      let a = symbol_of_string a in
      let b = symbol_of_string b in
      let a, b = if a > b then (b, a) else (a, b) in
      let c = symbol_of_string c in

      match op with
      | "AND" -> (c, And (a, b))
      | "OR" -> (c, Or (a, b))
      | "XOR" -> (c, Xor (a, b))
      | _ -> invalid_arg "failed to parse expression"
    in
    split_on_delims s |> tuples5 |> List.map parse_expr |> List.to_seq
    |> H.of_seq
  in

  read_to_string "/home/roy/dev/aoc/aoc2024/data/day24/data.txt"
  |> String.split_once ~by:"\n\n"
  |> Tuple.bimap ~f1:parse_values ~f2:parse_exprs

let rec eval symbol values exprs : bool =
  try H.find values symbol
  with Not_found ->
    let value =
      match H.find exprs symbol with
      | And (a, b) -> eval a values exprs && eval b values exprs
      | Or (a, b) -> eval a values exprs || eval b values exprs
      | Xor (a, b) -> eval a values exprs <> eval b values exprs
    in

    H.add values symbol value;
    value

let solve1 () =
  let values, exprs = (H.copy values, H.copy exprs) in
  H.keys exprs |> List.iter (fun symbol -> ignore (eval symbol values exprs));

  values |> H.to_list
  |> List.filter (fun ((l, _, _), _) -> l = 122)
  |> List.sort compare
  |> List.mapi (fun i v -> (i, v))
  |> List.fold_left (fun acc (i, (_, v)) -> if v then acc + pow 2 i else acc) 0

(* part 2 *)

(*
    'x' -> 120
    'y' -> 121
    'z' -> 122
    '0' -> 48
*)

let bits = H.keys exprs |> List.filter (fun (v, _, _) -> v = 122) |> List.length
let last_bit = (((bits - 1) / 10) + 48, ((bits - 1) mod 10) + 48)
let first_bit = (48, 48)

let build_adder = function
  | (122, 48, 48), And ((120, 48, 48), (121, 48, 48)) -> None
  | (122, z1, z2), Or (_, _) when (z1, z2) = last_bit -> None
  | ((122, _, _) as wire), (And _ | Or _) -> Some wire
  | output, Xor ((120, x1, x2), (121, y1, y2))
    when (x1, x2) <> first_bit && (y1, y2) <> first_bit ->
      if
        H.values exprs
        |> List.exists (function
             | And (a, b) when a = output || b = output -> true
             | _ -> false)
      then None
      else Some output
  | _, Xor ((120, _, _), (121, _, _)) -> None
  | (122, _, _), Xor _ -> None
  | wire, Xor _ -> Some wire
  | output, And ((120, x1, x2), (121, y1, y2))
    when (x1, x2) <> first_bit && (y1, y2) <> first_bit ->
      if
        H.values exprs
        |> List.exists (function
             | Or (a, b) when a = output || b = output -> true
             | _ -> false)
      then None
      else Some output
  | _ -> None

let solve2 () =
  assert (
    exprs |> H.to_list
    |> List.filter_map build_adder
    |> List.sort compare |> List.map string_of_symbol |> String.concat ","
    = "dqr,dtk,pfw,shh,vgs,z21,z33,z39");
  42

(* exports *)

let part1 () = validate solve1 42883464055378 "24" One
let part2 () = validate solve2 42 "24" Two
let solution : solution = { part1; part2 }

(* tests *)
