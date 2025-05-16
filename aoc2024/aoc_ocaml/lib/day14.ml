open Util

let width = 101
let height = 103
let size = width * height
let lines = read_to_lines "/home/roy/dev/aoc/aoc2024/data/day14/data.txt"

type robot = { px : int; py : int; vx : int; vy : int }

module Robot = struct
  type t = robot

  let step_n r ~steps =
    {
      px = (((r.px + (r.vx * steps)) mod width) + width) mod width;
      py = (((r.py + (r.vy * steps)) mod height) + height) mod height;
      vx = r.vx;
      vy = r.vy;
    }

  let of_string s =
    String.trim s |> String.split ~by:" "
    |> Tuple.map (String.chop ~l:2 ~r:0)
    |> Tuple.map (String.split ~by:",")
    |> Tuple.map (Tuple.map int_of_string)
    |> fun ((px, py), (vx, vy)) -> { px; py; vx; vy }
end

let bots = lines |> List.map Robot.of_string

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

let solve1 () = bots |> List.map (Robot.step_n ~steps:100) |> calc_safty

(* part 2 *)
let occupied = Array.make size (-1)
let row_count = Array.make height 0

let has_run step =
  let found = ref false in

  for row = 0 to height - 1 do
    if row_count.(row) >= 7 then
      let run = ref 0 in
      let base = row * width in

      for x = 0 to width - 1 do
        if occupied.(base + x) = step then (
          incr run;
          if !run = 7 then found := true)
        else run := 0
      done
  done;

  !found

let rec search step =
  Array.fill row_count 0 height 0;

  bots
  |> List.iter (fun bot ->
         let x = (bot.px + (bot.vx * step mod width) + width) mod width in
         let y = (bot.py + (bot.vy * step mod height) + height) mod height in
         occupied.((y * width) + x) <- step;
         row_count.(y) <- row_count.(y) + 1);

  if has_run step then step else search (step + 1)

let solve2 () = search 1

(* exports *)
let part1 () = validate solve1 230900224 "14" One
let part2 () = validate solve2 6532 "14" Two
let solution : solution = { part1; part2 }
