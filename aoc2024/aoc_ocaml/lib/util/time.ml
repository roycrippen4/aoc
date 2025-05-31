open Printf

type timerange = Sec | MilSlow | MilMed | MilFast | Micro

let string_of_timerange = function Sec -> "s" | Micro -> "µs" | _ -> "ms"
let rgb s r g b = s |> sprintf "\x1b[38;2;%d;%d;%dm%s\x1b[0m" r g b

(** [get_time_range t] takes a time [t] in microseconds and categorizes it. *)
let get_time_range = function
  | t when t > 1.0 -> Sec
  | t when t > 0.1 -> MilSlow
  | t when t > 0.01 -> MilMed
  | t when t > 0.001 -> MilFast
  | _ -> Micro

let color_seconds t = rgb (t ^ string_of_timerange Sec) 255 0 0
let color_mil_slow t = rgb (t ^ string_of_timerange MilSlow) 255 82 0
let color_mil_med t = rgb (t ^ string_of_timerange MilMed) 255 165 0
let color_mil_fast t = rgb (t ^ string_of_timerange MilFast) 127 210 0
let color_micro t = rgb (t ^ string_of_timerange Micro) 0 255 0

let color_time t =
  match get_time_range t with
  | Sec -> string_of_float t |> color_seconds
  | MilSlow -> t *. 1000.0 |> sprintf "%.3f" |> color_mil_slow
  | MilMed -> t *. 1000.0 |> sprintf "%.3f" |> color_mil_med
  | MilFast -> t *. 1000.0 |> sprintf "%.3f" |> color_mil_fast
  | Micro -> t *. 1000000.0 |> int_of_float |> string_of_int |> color_micro

let pp_time t =
  match get_time_range t with
  | Sec -> string_of_float t |> sprintf "%ss"
  | MilSlow -> t *. 1000.0 |> sprintf "%.3fms"
  | MilMed -> t *. 1000.0 |> sprintf "%.3fms"
  | MilFast -> t *. 1000.0 |> sprintf "%.3fms"
  | Micro -> t *. 1000000.0 |> int_of_float |> string_of_int |> sprintf "%sµs"
