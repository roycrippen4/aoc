open Util
module G = Grid
module String = Batteries.String

type direction = Up | Down | Left | Right
type kind = Bot | Box | Empty | Wall
type bot = { mutable x : int; mutable y : int }

let string_of_grid s =
  s
  |> G.of_string
  |> G.map_values (function
       | '@' -> Bot
       | 'O' -> Box
       | '.' -> Empty
       | '#' -> Wall
       | _ -> assert false)

let string_of_directions s =
  s
  |> String.split_on_char '\n'
  |> List.map String.explode
  |> List.flatten
  |> List.map (function
       | '^' -> Up
       | 'v' -> Down
       | '<' -> Left
       | '>' -> Right
       | _ -> assert false)

let input = "/home/roy/dev/aoc/aoc2024/data/day15/data.txt" |> read_to_string

let grid, directions =
  let ( <$> ) f g (x, y) = (f x, g y) in
  input
  |> String.trim
  |> String.split ~by:"\n\n"
  |> map_tuple String.trim
  |> (string_of_grid <$> string_of_directions)

let is_bot _ k = k = Bot
let set_bot (x, y, _) = { x; y }
let bot = G.find_replace is_bot Empty grid |> set_bot

let rec move_right x =
  match grid.(bot.y).(x + 1) with
  | Box -> move_right (x + 1)
  | Empty ->
      bot.x <- bot.x + 1;
      grid.(bot.y).(bot.x) <- Empty;
      grid.(bot.y).(x + 1) <- Box
  | _ -> ()

let rec move_left x =
  match grid.(bot.y).(x - 1) with
  | Box -> move_left (x - 1)
  | Empty ->
      bot.x <- bot.x - 1;
      grid.(bot.y).(bot.x) <- Empty;
      grid.(bot.y).(x - 1) <- Box
  | _ -> ()

let rec move_down y =
  match grid.(y + 1).(bot.x) with
  | Box -> move_down (y + 1)
  | Empty ->
      bot.y <- bot.y + 1;
      grid.(bot.y).(bot.x) <- Empty;
      grid.(y + 1).(bot.x) <- Box
  | _ -> ()

let rec move_up y =
  match grid.(y - 1).(bot.x) with
  | Box -> move_up (y - 1)
  | Empty ->
      bot.y <- bot.y - 1;
      grid.(bot.y).(bot.x) <- Empty;
      grid.(y - 1).(bot.x) <- Box
  | _ -> ()

let next = function
  | Up -> (
      match grid.(bot.y - 1).(bot.x) with
      | Box -> move_up (bot.y - 1)
      | Empty -> bot.y <- bot.y - 1
      | _ -> ())
  | Down -> (
      match grid.(bot.y + 1).(bot.x) with
      | Box -> move_down (bot.y + 1)
      | Empty -> bot.y <- bot.y + 1
      | _ -> ())
  | Left -> (
      match grid.(bot.y).(bot.x - 1) with
      | Box -> move_left (bot.x - 1)
      | Empty -> bot.x <- bot.x - 1
      | _ -> ())
  | Right -> (
      match grid.(bot.y).(bot.x + 1) with
      | Box -> move_right (bot.x + 1)
      | Empty -> bot.x <- bot.x + 1
      | _ -> ())

(* part1 *)

let solve1 () =
  let accumulate acc = function
    | x, y, k when k = Box -> (100 * y) + x + acc
    | _ -> acc
  in
  List.iter (fun d -> next d) directions;
  grid |> G.fold accumulate 0

(************************** part 2 **************************)

(* type kind2 = Bot | BoxStart | BoxEnd | Empty | Wall *)
(**)
(* let transform = function *)
(*   | '#' -> "##" *)
(*   | 'O' -> "[]" *)
(*   | '.' -> ".." *)
(*   | '@' -> "@." *)
(*   | '\n' -> "\n" *)
(*   | _ -> assert false *)
(**)
(* let kind_of_char = function *)
(*   | '@' -> Bot *)
(*   | '[' -> BoxStart *)
(*   | ']' -> BoxEnd *)
(*   | '.' -> Empty *)
(*   | '#' -> Wall *)
(*   | _ -> assert false *)
(**)
(* let char_of_kind = function *)
(*   | Bot -> '@' *)
(*   | BoxStart -> '[' *)
(*   | BoxEnd -> ']' *)
(*   | Empty -> '.' *)
(*   | Wall -> '#' *)
(**)
(* let string_of_grid s = *)
(*   let buf = Buffer.create (String.length s * 2) in *)
(*   s |> String.iter (fun c -> Buffer.add_string buf (transform c)); *)
(*   Buffer.contents buf |> G.of_string |> G.map_values kind_of_char *)
(**)
(* let parse str = *)
(*   str *)
(*   |> String.trim *)
(*   |> Batteries.String.split ~by:"\n\n" *)
(*   |> map_tuple String.trim *)
(*   |> (string_of_grid <$> string_of_directions) *)
(**)
(* let pp_kind fmt _ k = fprintf fmt "%c" (char_of_kind k) *)
(* let show_grid grid = G.print pp_kind std_formatter grid *)

(* *)

(* let example_input = *)
(*   "#######\n#...#.#\n#.....#\n#..OO@#\n#..O..#\n#.....#\n#######\n\n<vv<<^^<<^^" *)
(**)
(* let grid, directions = parse example_input *)
(* let width = G.width grid *)
(* let bot = G.find (fun _ k -> k = Bot) grid |> fun (x, y) -> { x; y } *)
(* let show_bot () = printf "bot_x: %d, bot_y: %d\n" bot.x bot.y *)

let solve2 () =
  (* show_grid grid; *)
  (* next Left; *)
  (* show_grid grid; *)
  (* let accumulate acc = function *)
  (*   | x, y, k when k = BoxStart -> (100 * y) + x + acc *)
  (*   | _ -> acc *)
  (* in *)
  (* List.iter (fun d -> next d) directions; *)
  (* grid |> G.fold accumulate 0 *)
  42

(* exports *)

let part1 () = validate solve1 1526673 "15" One
let part2 () = validate solve2 42 "15" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ =
  string_of_directions "<^^>>>vv<v>>v<<"
  = [
      Left;
      Up;
      Up;
      Right;
      Right;
      Right;
      Down;
      Down;
      Left;
      Down;
      Right;
      Right;
      Down;
      Left;
      Left;
    ]

(* [ Left; Down; Down; Left; Left; Up; Up; Left; Left; Up; Up ] = direction *)
