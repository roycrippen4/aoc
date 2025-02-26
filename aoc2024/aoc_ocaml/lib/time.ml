open Util

type timerange = Sec | MilSlow | MilMed | MilFast | Micro

let string_of_timerange = function Sec -> "s" | Micro -> "µs" | _ -> "ms"

(** [get_time_range t] takes a time [t] in microseconds and categorizes it. *)
let get_time_range t =
  match t with
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

let colorize_time t =
  let range = get_time_range t in
  match range with
  | Sec -> color_seconds (string_of_float t)
  | MilSlow -> t *. 1000.0 |> Printf.sprintf "%.3f" |> color_mil_slow
  | MilMed -> t *. 1000.0 |> Printf.sprintf "%.3f" |> color_mil_med
  | MilFast -> t *. 1000.0 |> Printf.sprintf "%.3f" |> color_mil_fast
  | Micro -> t *. 1000000.0 |> int_of_float |> string_of_int |> color_micro

let validate f expected day part =
  let start = Unix.gettimeofday () in
  let result = f () in
  let t = Unix.gettimeofday () -. start |> colorize_time in
  let () = assert (result == expected) in
  Printf.printf "Day %s Part %s solved in %s\n" day part t
