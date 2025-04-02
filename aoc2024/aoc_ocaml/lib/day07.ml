open Util

(* part 1 *)

let split_once delim s =
  match String.split_on_char delim s with
  | first :: second :: _ -> (first, second)
  | _ -> failwith "InvalidString"

let parse_nums s =
  s |> String.trim |> String.split_on_char ' ' |> List.map int_of_string
  |> List.rev

let parse_line s =
  let value, parts = String.trim s |> split_once ':' in
  (int_of_string value, parse_nums parts)

let map =
  read_to_string "/home/roy/dev/aoc/aoc2024/data/day07/data.txt"
  |> String.trim |> String.split_on_char '\n' |> List.map parse_line

let rec eval target = function
  | [] -> false
  | [ v1; v2 ] -> v1 + v2 = target || v1 * v2 = target
  | v :: rest ->
      let is_mul = target % v = 0 && eval (target / v) rest in
      let is_add = target >= v && eval (target - v) rest in
      is_mul || is_add

let sum acc (target, vs) = if eval target vs then acc + target else acc
let solve1 () = map |> List.fold_left sum 0

(* part 2 *)

let ( ^^! ) joined right_side =
  let rec calc_div n d = if n >= 10 then calc_div (n / 10) (d * 10) else d in
  let divisor = calc_div right_side 10 in
  if joined % divisor = right_side then Some (joined / divisor) else None

let ( ^^ ) root next =
  let rec aux mult temp =
    match temp > 0 with
    | true -> aux (mult * 10) (temp / 10)
    | false -> (root * mult) + next
  in
  aux 1 next

let rec eval2 target = function
  | [] ->
      Printf.printf "empty\n";
      false
  | [ v1; v2 ] -> v1 + v2 = target || v1 * v2 = target || v2 ^^ v1 = target
  | v :: rest ->
      let is_mul = target % v = 0 && eval2 (target / v) rest in
      let is_add = target >= v && eval2 (target - v) rest in
      let is_concat =
        match target ^^! v with Some lhs -> eval2 lhs rest | None -> false
      in
      is_mul || is_add || is_concat

let sum acc (target, vs) = if eval2 target vs then acc + target else acc
let solve2 () = map |> List.fold_left sum 0

(* exports *)
let part1 () = validate solve1 303766880536 "07" One
let part2 () = validate solve2 337041851384440 "07" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ = eval 190 (List.rev [ 10; 19 ])
let%test _ = eval 3267 (List.rev [ 81; 40; 27 ])
let%test _ = not (eval 161011 (List.rev [ 16; 10; 13 ]))
let%test _ = eval 292 (List.rev [ 11; 6; 16; 20 ])
let%test _ = 123456 = 123 ^^ 456
let%test _ = 123456 ^^! 456 = Some 123
let%test _ = 123456 ^^! 3456 = Some 12
let%test _ = 123456 ^^! 111 = None
let%test _ = eval2 7290 (List.rev [ 6; 8; 6; 15 ])
let%test _ = eval2 156 (List.rev [ 15; 6 ])
