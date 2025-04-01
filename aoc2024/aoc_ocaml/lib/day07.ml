open Util

(* part 1 *)

let split_once delim s =
  match String.split_on_char delim s with
  | first :: second :: _ -> (first, second)
  | _ -> failwith "InvalidString"

let parse_nums s =
  s |> String.trim |> String.split_on_char ' ' |> List.map int_of_string

let parse_line s =
  let value, parts = String.trim s |> split_once ':' in
  (int_of_string value, parse_nums parts)

let map =
  read_to_string "/home/roy/dev/aoc/aoc2024/data/day07/data.txt"
  |> String.trim |> String.split_on_char '\n' |> List.map parse_line

let eval target vs =
  let rec aux root target = function
    | [] -> root = target
    | hd :: rest -> aux (root + hd) target rest || aux (root * hd) target rest
  in
  match vs with
  | [] -> false (* shouldn't happen *)
  | hd :: tl -> aux hd target tl

let sum acc (target, vs) = if eval target vs then acc + target else acc
let solve1 () = map |> List.fold_left sum 0

(* part 2 *)

let concat root next =
  let rec aux mult temp =
    match temp > 0 with
    | true -> aux (mult * 10) (temp / 10)
    | false -> (root * mult) + next
  in
  aux 1 next

let eval target vs =
  let rec aux root target = function
    | [] -> root = target
    | hd :: rest ->
        if root > target then false
        else
          aux (root + hd) target rest
          || aux (root * hd) target rest
          || aux (concat root hd) target rest
  in
  match vs with
  | [] -> false (* shouldn't happen *)
  | hd :: tl -> aux hd target tl

let sum acc (target, vs) = if eval target vs then acc + target else acc
let solve2 () = map |> List.fold_left sum 0

(* exports *)
let part1 () = validate solve1 303766880536 "07" One
let part2 () = validate solve2 337041851384440 "07" Two
let solution : solution = { part1; part2 }

let%test _ =
  let answer = solve2 () in
  Printf.printf "answer: %d\n" answer;
  true
