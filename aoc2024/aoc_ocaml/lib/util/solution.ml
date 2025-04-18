open Printf

type solution = { part1 : unit -> float; part2 : unit -> float }
type part = One | Two

let color_time = Time.colorize_time
let int_of_part = function One -> 1 | Two -> 2

let validate f expected day part =
  let start = Unix.gettimeofday () in
  let result = f () in
  let t = Unix.gettimeofday () -. start in
  let part = int_of_part part in

  let pp_err () =
    printf {|
Error solving Day %s Part %d:
wanted: %d
found : %d

|} day part
      expected result
  in

  if expected <> result then pp_err ()
  else printf "Day %s Part %d solved in %s\n" day part (color_time t);
  t

(* thread 'day11::part1::test::test_solve' panicked at src/util/timing.rs:52:5: *)
(* assertion `left == right` failed *)
(*   left: 220998 *)
(*  right: 220999 *)
