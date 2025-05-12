open Util

let nums =
  "/home/roy/dev/aoc/aoc2024/data/day22/data.txt" |> read_to_string
  |> String.trim |> String.lines |> List.map int_of_string

let next_secret secret =
  let mask24 = (1 lsl 24) - 1 in
  let s1 = (secret lsl 6) lxor secret land mask24 in
  let s2 = s1 / 32 lxor s1 land mask24 in
  (s2 lsl 11) lxor s2 land mask24

let nth_secret secret n =
  let rec aux acc = function 0 -> acc | n -> aux (next_secret acc) (pred n) in
  aux secret n

(* *)

let solve1 () =
  let map_acc acc n = acc + nth_secret n 2000 in
  List.fold_left map_acc 0 nums

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 20215960478 "22" One
let part2 () = validate solve2 42 "22" Two
let solution : solution = { part1; part2 }

(* tests *)
let%test _ = nth_secret 123 1 = 15887950
let%test _ = nth_secret 123 10 = 5908254
let%test _ = nth_secret 1 2000 = 8685429
let%test _ = nth_secret 10 2000 = 4700978
let%test _ = nth_secret 100 2000 = 15273692
let%test _ = nth_secret 2024 2000 = 8667524
