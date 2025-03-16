open Util
open Batteries

let example = read_to_string "/home/roy/dev/aoc/aoc2024/data/day05/data.txt"
let _rules, _updates = String.split example ~by:"\n\n"
let middle vs = List.nth vs (List.length vs / 2)
let to_rule s = String.(trim s |> split ~by:"|") |> map_tuple int_of_string
let rules = String.split_on_char '\n' _rules |> List.map to_rule
let to_update s = String.split_on_char ',' s |> List.map int_of_string
let updates = String.(trim _updates |> split_on_char '\n') |> List.map to_update

let insert_or_update tbl (k, v) =
  match Hashtbl.find_opt tbl k with
  | None -> Hashtbl.add tbl k [ v ]
  | Some entry -> Hashtbl.replace tbl k (v :: entry)

let rule_tbl =
  let tbl = Hashtbl.create 1024 in
  rules |> List.iter (insert_or_update tbl);
  tbl

let mapping_contians curr next =
  match Hashtbl.find_opt rule_tbl curr with
  | Some mapping -> List.mem next mapping
  | None -> false

let eval update =
  let rec go = function
    | [] -> middle update
    | [ _ ] -> middle update
    | curr :: rest -> (
        match mapping_contians curr (List.hd rest) with
        | false -> raise Not_found
        | true -> go rest)
  in
  try go update with Not_found -> 0

(* exports *)

let solve1 () = List.fold_left (fun acc v -> acc + eval v) 0 updates
let solve2 () = 42
let part1 () = validate solve1 7198 "05" One
let part2 () = validate solve2 42 "04" Two
let solution : solution = { part1; part2 }

(* tests *)
let%test _ = middle [ 1; 2; 3 ] = 2
let%test _ = to_rule "53|13" = (53, 13)

let%test _ =
  let tbl = Hashtbl.create 1 in
  let k, v = ("a", 1) in
  let missing_initially = Hashtbl.find_opt tbl k = None in
  insert_or_update tbl (k, v);
  let has_v_after = Hashtbl.find_opt tbl k = Some [ v ] in
  insert_or_update tbl (k, 2);
  let expected_entry = Hashtbl.find tbl k = [ 2; 1 ] in
  missing_initially && has_v_after && expected_entry
