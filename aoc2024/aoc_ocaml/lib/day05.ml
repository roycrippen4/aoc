open Util

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day05/data.txt"

(* parses rules *)
let rule s = String.(trim s |> split ~by:"|") |> map_tuple int_of_string
let parse_rules s = String.split_on_char '\n' s |> List.map rule

(* parses updates *)
let update s = String.split_on_char ',' s |> List.map int_of_string
let parse_updates s = String.(trim s |> split_on_char '\n') |> List.map update

(* Gets the middle element*)
let middle vs = List.nth vs (List.length vs / 2)

let rules, updates =
  let rs, us = String.split input ~by:"\n\n" in
  (parse_rules rs, parse_updates us)

let insert_or_update tbl (k, v) =
  match Hashtbl.find_opt tbl k with
  | None -> Hashtbl.add tbl k [ v ]
  | Some entry -> Hashtbl.replace tbl k (v :: entry)

let rule_tbl =
  let tbl = Hashtbl.create 1024 in
  rules |> List.iter (insert_or_update tbl);
  tbl

let mapping_contains curr next =
  match Hashtbl.find_opt rule_tbl curr with
  | Some mapping -> List.mem next mapping
  | None -> false

let cmp a b = if mapping_contains a b then -1 else 1

let rec is_in_order = function
  | [] | [ _ ] -> true
  | hd :: tl ->
      if mapping_contains hd (List.hd tl) then is_in_order tl else false

(* exports *)

let solve1 () =
  let accumulate acc u = if is_in_order u then acc + middle u else acc in
  List.fold_left accumulate 0 updates

let solve2 () =
  let sort v = List.sort cmp v in
  let filter_map v = if not (is_in_order v) then Some (sort v) else None in
  let accumulate_middles acc lst = acc + middle lst in
  updates |> List.filter_map filter_map |> List.fold_left accumulate_middles 0

let part1 () = validate solve1 7198 "05" One
let part2 () = validate solve2 4230 "05" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ = middle [ 1; 2; 3 ] = 2

let%test _ =
  let tbl = Hashtbl.create 1 in
  let k, v = ("a", 1) in
  let missing_initially = Hashtbl.find_opt tbl k = None in
  insert_or_update tbl (k, v);
  let has_v_after = Hashtbl.find_opt tbl k = Some [ v ] in
  insert_or_update tbl (k, 2);
  let expected_entry = Hashtbl.find tbl k = [ 2; 1 ] in
  missing_initially && has_v_after && expected_entry
