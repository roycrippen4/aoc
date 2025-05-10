open Util

type prize = { x : int; y : int }
type button = { x : int; y : int; cost : int }
type machine = button * button * prize

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day13/data.txt"

let prize_of_string s =
  String.chop s ~l:9 ~r:0 |> String.split ~by:", Y=" |> map_tuple int_of_string
  |> fun (x, y) -> { x; y }

let button_of_string s =
  let left, right = s |> String.split ~by:": " in
  let cost = if String.ends_with left "A" then 3 else 1 in
  let x = String.sub right 2 2 |> int_of_string in
  let y = String.sub right 8 2 |> int_of_string in
  { x; y; cost }

let parse_machine s =
  String.(s |> trim |> lines |> List.map trim) |> function
  | [ a; b; c ] -> (button_of_string a, button_of_string b, prize_of_string c)
  | _ -> failwith "unreachable"

let is_positive_integer v =
  v > 0. && v |> modf |> fst |> classify_float == FP_zero

let get_cheapest ((a, b, p) : machine) =
  let determinant = (a.x * b.y) - (a.y * b.x) in
  if determinant <> 0 then
    let determinant_f = float determinant in
    let pxby = float (p.x * b.y) in
    let bxpy = float (b.x * p.y) in
    let i = (pxby -. bxpy) /. determinant_f in
    if not (is_positive_integer i) then 0
    else
      let axpy = float (a.x * p.y) in
      let pxay = float (p.x * a.y) in
      let j = (axpy -. pxay) /. determinant_f in

      if not (is_positive_integer j) then 0
      else
        let i = int_of_float i in
        let j = int_of_float j in
        (i * a.cost) + (j * b.cost)
  else 0

let machines =
  input |> String.split_on_string ~by:"\n\n" |> List.map parse_machine

let solve1 () = machines |> List.fold_left (fun acc m -> acc + get_cheapest m) 0

(* part 2 *)

let solve2 () =
  let update_target ((a, b, p) : machine) : machine =
    let p = { x = p.x + 10000000000000; y = p.y + 10000000000000 } in
    (a, b, p)
  in

  let accumulate acc m = acc + (m |> update_target |> get_cheapest) in
  machines |> List.fold_left accumulate 0

(* exports *)

let part1 () = validate solve1 29436 "13" One
let part2 () = validate solve2 103729094227877 "13" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ =
  let text =
    "Button A: X+94, Y+34\nButton B: X+22, Y+67\nPrize: X=8400, Y=5400"
  in
  let expected_a = { x = 94; y = 34; cost = 3 } in
  let expected_b = { x = 22; y = 67; cost = 1 } in
  let expected_prize = { x = 8400; y = 5400 } in
  let a, b, prize = parse_machine text in
  a = expected_a && b = expected_b && prize = expected_prize

let%test _ =
  let b = button_of_string "Button A: X+94, Y+34" in
  b.cost = 3 && b.x = 94 && b.y = 34

let%test _ =
  let b = button_of_string "Button B: X+22, Y+67" in
  b.cost = 1 && b.x = 22 && b.y = 67

let%test _ =
  let p = prize_of_string "Prize: X=8400, Y=5400" in
  p.x = 8400 && p.y = 5400

let%test _ =
  "Button A: X+94, Y+34\nButton B: X+22, Y+67\nPrize: X=8400, Y=5400"
  |> parse_machine |> get_cheapest = 280

let%test _ = not (is_positive_integer (-1.0001))
let%test _ = not (is_positive_integer (-1.0))
let%test _ = not (is_positive_integer 1.0001)
let%test _ = not (is_positive_integer 1.00000001)
let%test _ = is_positive_integer 10.0
let%test _ = is_positive_integer 100.0
let%test _ = is_positive_integer 1000.0000
let%test _ = not (is_positive_integer 10000.000001)
