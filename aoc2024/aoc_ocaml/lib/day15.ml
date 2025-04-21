open Util
open Batteries
module G = Grid

type direction = Up | Down | Left | Right

let direction_of_char = function
  | '^' -> Up
  | 'v' -> Down
  | '<' -> Left
  | '>' -> Right
  | _ -> assert false

let char_of_direction = function
  | Up -> '^'
  | Down -> 'v'
  | Left -> '<'
  | Right -> '>'

type kind = Bot | Box | Empty | Wall

let x = int_of_string

let kind_of_char = function
  | '@' -> Bot
  | 'O' -> Box
  | '.' -> Empty
  | '#' -> Wall
  | _ -> assert false

let char_of_kind = function
  | Bot -> '@'
  | Box -> 'O'
  | Empty -> '.'
  | Wall -> '#'

let string_of_directions s = s |> str_explode |> List.map direction_of_char
let string_of_grid s = s |> G.of_string |> G.map_values kind_of_char
let ( <$> ) f g (x, y) = (f x, g y)

let grid, directions =
  "/home/roy/dev/aoc/aoc2024/data/day15/data.txt"
  |> read_to_string
  |> String.split ~by:"\n\n"
  |> map_tuple String.trim
  |> (string_of_grid <$> string_of_directions)

(* let botx, boty = () *)

(* part1 *)

let solve1 () = 42

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 42 "15" One
let part2 () = validate solve2 42 "15" Two
let solution : solution = { part1; part2 }

(* tests *)
