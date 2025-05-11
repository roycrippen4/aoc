let read_to_lines filepath =
  In_channel.with_open_text filepath In_channel.input_lines

let read_to_string filepath =
  In_channel.with_open_text filepath In_channel.input_all

let split_to_string delim str =
  String.split_on_char delim str |> List.filter (fun s -> s <> "")

let split_to_int delim str =
  String.split_on_char delim str
  |> List.filter (fun s -> s <> "")
  |> List.map int_of_string

let chars str =
  let rec exp a b = if a < 0 then b else exp (a - 1) (str.[a] :: b) in
  exp (String.length str - 1) []

let map_tuple f (a, b) = (f a, f b)
let map_tuple2 f g (a, b) = (f a, g b)
let map2_tuple f (a1, a2) (b1, b2) = (f a1 b1, f a2 b2)

(* *)

let flip f x y = f y x
let pop = function x :: xs -> (x, xs) | [] -> failwith "List is empty"

let windows n lst =
  let rec build_window n acc = function
    | [] -> None
    | x :: xs ->
        if n = 1 then Some (List.rev (x :: acc), xs)
        else build_window (n - 1) (x :: acc) xs
  in
  let rec aux acc l =
    match build_window n [] l with
    | None -> List.rev acc
    | Some (win, _) -> aux (win :: acc) (List.tl l)
  in
  aux [] lst

let pairs lst =
  let rec aux items = function
    | [] | [ _ ] -> items
    | a :: rest ->
        let item = (a, List.hd rest) in
        aux (item :: items) rest
  in
  aux [] lst |> List.rev

let enumerate_list lst = List.mapi (fun i x -> (i, x)) lst
let enumerate_array arr = Array.mapi (fun i x -> (i, x)) arr

let int_of_char2 = function
  | '0' -> 0
  | '1' -> 1
  | '2' -> 2
  | '3' -> 3
  | '4' -> 4
  | '5' -> 5
  | '6' -> 6
  | '7' -> 7
  | '8' -> 8
  | '9' -> 9
  | _ -> failwith "Invalid_argument"

let char_of_int2 = function
  | 0 -> '0'
  | 1 -> '1'
  | 2 -> '2'
  | 3 -> '3'
  | 4 -> '4'
  | 5 -> '5'
  | 6 -> '6'
  | 7 -> '7'
  | 8 -> '8'
  | 9 -> '9'
  | _ -> failwith "Invalid_argument"

let rec combos = function
  | [] -> []
  | x :: xs ->
      let rec aux y = function [] -> [] | z :: zs -> (y, z) :: aux y zs in
      aux x xs @ combos xs

let pow base exp =
  if exp < 0 then invalid_arg "exponent can not be negative"
  else
    let rec aux acc base = function
      | 0 -> acc
      | 1 -> base * acc
      | e when e mod 2 = 0 -> aux acc (base * base) (e / 2)
      | e -> aux (base * acc) (base * base) ((e - 1) / 2)
    in
    aux 1 base exp

let%test _ = combos [ 1; 2; 3 ] = [ (1, 2); (1, 3); (2, 3) ]

let%test _ =
  combos [ 1; 2; 3; 4 ] = [ (1, 2); (1, 3); (1, 4); (2, 3); (2, 4); (3, 4) ]

let%test _ = windows 3 [] = []
let%test _ = windows 1 [ 1; 2; 3 ] = [ [ 1 ]; [ 2 ]; [ 3 ] ]
let%test _ = windows 2 [ 1; 2 ] = [ [ 1; 2 ] ]
let%test _ = windows 2 [ 1; 2; 3 ] = [ [ 1; 2 ]; [ 2; 3 ] ]
let%test _ = windows 4 [ 1; 2; 3 ] = []

let%test _ =
  let win = windows 3 [ 1; 2; 3; 4; 5 ] in
  win = [ [ 1; 2; 3 ]; [ 2; 3; 4 ]; [ 3; 4; 5 ] ]

let%test _ =
  let lst = [ 'l'; 'o'; 'r'; 'e'; 'm' ] in
  pairs lst = [ ('l', 'o'); ('o', 'r'); ('r', 'e'); ('e', 'm') ]

let%test _ = pairs [ 1; 2 ] = [ (1, 2) ]
let%test _ = pairs [ 1 ] = []
