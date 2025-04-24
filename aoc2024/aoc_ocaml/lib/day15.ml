open Util
module G = Grid
module String = Batteries.String

(* BoxEnd is only used in part 2 *)
type kind = Bot | Start | End | Empty | Wall
type direction = Up | Down | Left | Right
type bot = { mutable x : int; mutable y : int }

let string_of_grid s =
  s
  |> G.of_string
  |> G.map_values (function
       | '@' -> Bot
       | 'O' -> Start
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

let ( <$> ) f g (x, y) = (f x, g y)
let input = "/home/roy/dev/aoc/aoc2024/data/day15/data.txt" |> read_to_string

let grid, directions =
  input
  |> String.trim
  |> String.split ~by:"\n\n"
  |> map_tuple String.trim
  |> (string_of_grid <$> string_of_directions)

let get_bot grid =
  G.find_replace (fun (_, _, k) -> k = Bot) Empty grid |> fun (x, y, _) ->
  { x; y }

let bot = get_bot grid

let rec move_horiz x offset =
  match grid.(bot.y).(x + offset) with
  | Start -> move_horiz (x + offset) offset
  | Empty ->
      bot.x <- bot.x + offset;
      grid.(bot.y).(bot.x) <- Empty;
      grid.(bot.y).(x + offset) <- Start
  | _ -> ()

let rec move_vert y offset =
  match grid.(y + offset).(bot.x) with
  | Start -> move_vert (y + offset) offset
  | Empty ->
      bot.y <- bot.y + offset;
      grid.(bot.y).(bot.x) <- Empty;
      grid.(y + offset).(bot.x) <- Start
  | _ -> ()

let next = function
  | (Up | Down) as v -> (
      let offset = if v = Up then -1 else 1 in
      match grid.(bot.y + offset).(bot.x) with
      | Start -> move_vert (bot.y + offset) offset
      | Empty -> bot.y <- bot.y + offset
      | _ -> ())
  | (Left | Right) as h -> (
      let offset = if h = Left then -1 else 1 in
      match grid.(bot.y).(bot.x + offset) with
      | Start -> move_horiz (bot.x + offset) offset
      | Empty -> bot.x <- bot.x + offset
      | _ -> ())

(* part1 *)

let solve1 () =
  let accumulate acc = function
    | x, y, k when k = Start -> (100 * y) + x + acc
    | _ -> acc
  in
  List.iter (fun d -> next d) directions;
  grid |> G.fold accumulate 0

(************************** part 2 **************************)

let string_of_grid s =
  let buf = Buffer.create (String.length s * 2) in

  let add_to_buf = function
    | '#' -> Buffer.add_string buf "##"
    | 'O' -> Buffer.add_string buf "[]"
    | '.' -> Buffer.add_string buf ".."
    | '@' -> Buffer.add_string buf "@."
    | '\n' -> Buffer.add_string buf "\n"
    | _ -> assert false
  in

  String.iter add_to_buf s;

  Buffer.contents buf
  |> G.of_string
  |> G.map_values (function
       | '@' -> Bot
       | '[' -> Start
       | ']' -> End
       | '.' -> Empty
       | '#' -> Wall
       | _ -> assert false)

let parse str =
  str
  |> String.trim
  |> Batteries.String.split ~by:"\n\n"
  |> map_tuple String.trim
  |> (string_of_grid <$> string_of_directions)

let pp_kind fmt _ k =
  Format.fprintf fmt "%c"
    (match k with
    | Bot -> '@'
    | Start -> '['
    | End -> ']'
    | Empty -> '.'
    | Wall -> '#')

let show_grid grid bot =
  grid.(bot.y).(bot.x) <- Bot;
  G.print pp_kind Format.std_formatter grid;
  grid.(bot.y).(bot.x) <- Empty;
  print_endline ""

let g, directions = parse input
let width = G.width g
let height = G.height g
let bot = get_bot g
let is_wall x y = g.(y).(x) = Wall
let in_bounds x y = G.inside g (x, y)

let move_right x =
  let rec shift_right x =
    if x = bot.x then bot.x <- bot.x + 1
    else (
      g.(bot.y).(x) <- g.(bot.y).(x - 1);
      shift_right (x - 1))
  in

  let rec aux x =
    match g.(bot.y).(x) with
    | Start -> aux (x + 2)
    | Empty -> shift_right x
    | _ -> ()
  in

  aux x

let move_left x =
  let rec shift_left x =
    if x = bot.x then bot.x <- bot.x - 1
    else (
      g.(bot.y).(x) <- g.(bot.y).(x + 1);
      shift_left (x + 1))
  in

  let rec aux x =
    match g.(bot.y).(x) with
    | End -> aux (x - 2)
    | Empty -> shift_left x
    | _ -> ()
  in

  aux x

let false_array = fun _ -> Array.init width (fun _ -> false)
let make_seen () = Array.init height false_array

let move_vert x y up =
  let dy = if up then -1 else 1 in
  let seen = make_seen () in

  let rec get_moves x y =
    match g.(y).(x) with
    | (Start | End) as k ->
        let ox = if k = Start then x + 1 else x - 1 in
        if seen.(y).(ox) then Some []
        else (
          seen.(y).(x) <- true;
          seen.(y).(ox) <- true;
          let ty = y + dy in

          let* l1 =
            match g.(ty).(x) with
            | Start | End -> get_moves x ty
            | Empty -> Some []
            | _ -> None
          in

          let* l2 =
            match g.(ty).(ox) with
            | Start | End -> get_moves ox ty
            | Empty -> Some []
            | _ -> None
          in

          Some (l1 @ l2 @ [ (x, y, k); (ox, y, g.(y).(ox)) ]))
    | _ -> None
  in

  let apply_move (x, y, k) =
    g.(y).(x) <- Empty;
    g.(y + dy).(x) <- k
  in

  match get_moves x y with
  | None -> ()
  | Some moves ->
      moves |> List.iter apply_move;
      bot.y <- y

let next d =
  match d with
  | Left -> (
      match g.(bot.y).(bot.x - 1) with
      | End -> move_left (bot.x - 3)
      | Empty -> bot.x <- bot.x - 1
      | _ -> ())
  | Right -> (
      match g.(bot.y).(bot.x + 1) with
      | Start -> move_right (bot.x + 3)
      | Empty -> bot.x <- bot.x + 1
      | _ -> ())
  | (Up | Down) as d -> (
      let up = d = Up in
      let dy = if up then bot.y - 1 else bot.y + 1 in

      match g.(dy).(bot.x) with
      | Start | End -> move_vert bot.x dy up
      | Empty -> bot.y <- dy
      | _ -> ())

let solve2 () =
  List.iter next directions;
  g
  |> G.filter_entries (fun (_, _, v) -> v = Start)
  |> List.fold_left (fun acc (x, y, _) -> acc + (100 * y) + x) 0

(* exports *)

let part1 () = validate solve1 1526673 "15" One
let part2 () = validate solve2 1535509 "15" Two
let solution : solution = { part1; part2 }
