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
