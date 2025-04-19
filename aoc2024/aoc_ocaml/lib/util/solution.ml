open Printf

type solution = { part1 : unit -> float; part2 : unit -> float }
type part = One | Two

let int_of_part = function One -> 1 | Two -> 2

let validate f expected day part =
  let start = Unix.gettimeofday () in
  let result = f () in
  let t = Unix.gettimeofday () -. start in
  let part = int_of_part part in

  let pp_err () =
    printf
      "\n\
       \x1b[38;5;209m\x1b[4mError solving Day %s Part %d:\x1b[39m\x1b[24m\n\
       wanted: \x1b[38;5;46m%d\x1b[39m\n\
       found : \x1b[38;5;196m%d\x1b[39m\n\n"
      day part expected result
  in

  if expected <> result then pp_err ()
  else printf "Day %s Part %d solved in %s\n" day part (Time.color_time t);
  t
