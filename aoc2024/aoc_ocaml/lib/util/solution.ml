type solution = { part1 : unit -> float; part2 : unit -> float }
type part = One | Two

let int_of_part = function One -> 1 | Two -> 2

let validate (f : unit -> int) (expected : int) (day : string) (part : part) =
  let start = Unix.gettimeofday () in
  let result = f () in
  let t = Unix.gettimeofday () -. start in
  let () = assert (result == expected) in
  let ts = Time.colorize_time t in
  let part = int_of_part part in
  let () = Printf.printf "Day %s Part %d solved in %s\n" day part ts in
  t
