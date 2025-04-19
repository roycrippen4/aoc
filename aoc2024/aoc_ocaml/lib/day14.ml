open Util
open Batteries

let width = 101
let height = 103

type robot = { px : int; py : int; vx : int; vy : int }

module Robot = struct
  type t = robot

  let goto_last_pos r steps =
    let px = (((r.px + (r.vx * steps)) mod width) + width) mod width in
    let py = (((r.py + (r.vy * steps)) mod height) + height) mod height in
    { px; py; vx = r.vx; vy = r.vy }

  let pos r = (r.px, r.py)

  let update r steps =
    {
      px = (((r.px + (r.px * steps)) mod width) + width) mod width;
      py = (((r.py + (r.py * steps)) mod height) + height) mod height;
      vx = r.vx;
      vy = r.vy;
    }

  let of_string s =
    s
    |> String.split ~by:" "
    |> map_tuple (String.chop ~l:2 ~r:0)
    |> map_tuple (String.split ~by:",")
    |> map_tuple (map_tuple int_of_string)
    |> fun ((px, py), (vx, vy)) -> { px; py; vx; vy }

  let show r =
    Printf.printf "{ px: %d, py: %d, vx: %d, vy: %d }\n" r.px r.py r.vx r.vy
end

let r = Robot.of_string "p=0,4 v=3,-3"

(* *)

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day14/data.txt"
let bots = input |> String.split_on_char '\n' |> List.map Robot.of_string
let solve1 () = 42

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 42 "14" One
let part2 () = validate solve2 42 "14" Two
let solution : solution = { part1; part2 }

(* tests *)
