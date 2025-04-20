open Util
open Batteries

let width = 101
let height = 103
let size = width * height
let lines = read_to_lines "/home/roy/dev/aoc/aoc2024/data/day14/data.txt"

type robot = { mutable px : int; mutable py : int; vx : int; vy : int }

module Robot = struct
  type t = robot

  let step_n r ~steps =
    {
      px = (((r.px + (r.vx * steps)) mod width) + width) mod width;
      py = (((r.py + (r.vy * steps)) mod height) + height) mod height;
      vx = r.vx;
      vy = r.vy;
    }

  let step r =
    r.px <- (((r.px + r.vx) mod width) + width) mod width;
    r.py <- (((r.py + r.vy) mod height) + height) mod height

  let of_string s =
    s
    |> String.trim
    |> String.split ~by:" "
    |> map_tuple (String.chop ~l:2 ~r:0)
    |> map_tuple (String.split ~by:",")
    |> map_tuple (map_tuple int_of_string)
    |> fun ((px, py), (vx, vy)) -> { px; py; vx; vy }

  let show r =
    Printf.printf "{ px: %d, py: %d, vx: %d, vy: %d }\n" r.px r.py r.vx r.vy
end

let update_counts skipx skipy r =
  let x, y = (r.px, r.py) in
  if x = skipx || y = skipy then (0, 0, 0, 0)
  else
    match (x < skipx, y < skipy) with
    | true, true -> (1, 0, 0, 0)
    | false, true -> (0, 1, 0, 0)
    | true, false -> (0, 0, 1, 0)
    | false, false -> (0, 0, 0, 1)

let calc_safty bots =
  let skipx = width / 2 in
  let skipy = height / 2 in
  let mul (a, b, c, d) = a * b * c * d in
  let sum4 (a1, b1, c1, d1) (a2, b2, c2, d2) =
    (a1 + a2, b1 + b2, c1 + c2, d1 + d2)
  in
  let accumulate acc bot = bot |> update_counts skipx skipy |> sum4 acc in
  bots |> List.fold_left accumulate (0, 0, 0, 0) |> mul

let solve1 () =
  lines
  |> List.map Robot.of_string
  |> List.map (Robot.step_n ~steps:100)
  |> calc_safty

(* part 2 *)

let occupied = Array.make size (-1)
let idx x y = (y * width) + x

let has_run step =
  let rec rows base =
    if base >= size then false
    else
      let rec scan x run =
        if run > 6 then true
        else if x = width then rows (base + width) (* next row *)
        else
          let run' = if occupied.(base + x) = step then run + 1 else 0 in
          scan (x + 1) run'
      in
      scan 0 0
  in
  rows 0

let rec search step bots =
  let mark_bot bot =
    Robot.step bot;
    occupied.(idx bot.px bot.py) <- step
  in

  bots |> Array.iter mark_bot;
  if has_run step then step else search (step + 1) bots

let solve2 () =
  let bots = lines |> Array.of_list |> Array.map Robot.of_string in
  search 1 bots

(* exports *)

let part1 () = validate solve1 230900224 "14" One
let part2 () = validate solve2 6532 "14" Two
let solution : solution = { part1; part2 }

(* tests *)
