(** Returns [string array] from the file contents located at [filepath] separated by newlines *)
let read_to_lines filepath =
  In_channel.with_open_text filepath In_channel.input_lines

let read_to_string filepath =
  In_channel.with_open_text filepath In_channel.input_all

(** Split the string [str] by character [delim] and filter empty results out  *)
let split_to_string delim str =
  String.split_on_char delim str |> List.filter (fun s -> s <> "")

(** Split the string [str] by character [delim] and filter empty results out  *)
let split_to_int delim str =
  String.split_on_char delim str
  |> List.filter (fun s -> s <> "")
  |> List.map int_of_string

(** applies function [f] to the tuple [(a, b)] as [(f a, f b)] *)
let map_tuple f (a, b) = (f a, f b)

(** Colors string `s` fg color with `r`, `g`, `b` values using ansci escape codes.
   `r`, `g`, and `b` values range from 0 to 255; *)
let rgb str r g b = Printf.sprintf "\x1b[38;2;%d;%d;%dm%s\x1b[0m" r g b str

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

let ( /.. ) i j =
  let rec aux n acc = if n <= i then acc else aux (n - 1) ((n - 1) :: acc) in
  aux j []

let ( /..= ) i j =
  let rec aux n acc = if n < i then acc else aux (n - 1) (n :: acc) in
  aux j []

let%test _ = windows 3 [] = []
let%test _ = windows 1 [ 1; 2; 3 ] = [ [ 1 ]; [ 2 ]; [ 3 ] ]
let%test _ = windows 2 [ 1; 2 ] = [ [ 1; 2 ] ]
let%test _ = windows 2 [ 1; 2; 3 ] = [ [ 1; 2 ]; [ 2; 3 ] ]
let%test _ = windows 4 [ 1; 2; 3 ] = []

let%test _ =
  let win = windows 3 [ 1; 2; 3; 4; 5 ] in
  win = [ [ 1; 2; 3 ]; [ 2; 3; 4 ]; [ 3; 4; 5 ] ]

let%test _ = 0 /.. 5 = [ 0; 1; 2; 3; 4 ]
let%test _ = 0 /..= 5 = [ 0; 1; 2; 3; 4; 5 ]
