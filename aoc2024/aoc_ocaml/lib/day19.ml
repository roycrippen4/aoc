open Util

let example =
  "r, wr, b, g, bwu, rb, gb, br\n\n\
   brwrr\n\
   bggr\n\
   gbbr\n\
   rrbgbr\n\
   ubwu\n\
   bwurrg\n\
   brgr\n\
   bbrgwb"

let path = "/home/roy/dev/aoc/aoc2024/data/day19/data.txt"
let input = read_to_string path

let[@warning "-26-27-39"] parse s =
  let open! Batteries.String in
  todo ()

let solve1 () = 42

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 42 "19" One
let part2 () = validate solve2 42 "19" Two
let solution : solution = { part1; part2 }

(* tests *)
