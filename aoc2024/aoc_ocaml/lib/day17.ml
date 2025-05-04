open Util

let a = 59590048
let b = 0
let c = 0
let len = 16
let program = [| 2; 4; 1; 5; 7; 5; 0; 3; 1; 6; 4; 3; 5; 5; 3; 0 |]

let pow8 =
  [|
    1;
    8;
    64;
    512;
    4096;
    32768;
    262144;
    2097152;
    16777216;
    134217728;
    1073741824;
    8589934592;
    68719476736;
    549755813888;
    4398046511104;
    35184372088832;
  |]

let run initial_a initial_b initial_c =
  let rec loop a b c pc output =
    let get_combo = function 4 -> a | 5 -> b | 6 -> c | n -> n in

    if pc = len then output
    else
      let literal = program.(pc + 1) in
      let combo = get_combo literal in
      let pc_next = pc + 2 in

      match program.(pc) with
      | 0 -> loop (a lsr combo) b c pc_next output
      | 1 -> loop a (b lxor literal) c pc_next output
      | 2 -> loop a (combo mod 8) c pc_next output
      | 3 -> loop a b c (if a <> 0 then literal else pc_next) output
      | 4 -> loop a (b lxor c) c pc_next output
      | 5 -> loop a b c pc_next (output @ [ combo mod 8 ])
      | 6 -> loop a (a lsr combo) c pc_next output
      | 7 -> loop a b (a lsr combo) pc_next output
      | _ -> assert false
  in

  loop initial_a initial_b initial_c 0 [] |> Array.of_list

let solve1 () =
  let concat vs = vs |> Array.to_list |> String.concat "" in
  run a b c |> Array.map string_of_int |> concat |> int_of_string

(* part 2 *)

let update_factors factors output =
  let rec loop i =
    let i = i - 1 in
    if i = -1 then ()
    else if Array.length output < i || output.(i) <> program.(i) then
      factors.(i) <- factors.(i) + 1
    else loop i
  in
  loop len

let get_init_a factors =
  let rec loop a i =
    if i = len then a
    else
      let a = a + (pow8.(i) * factors.(i)) in
      loop a (i + 1)
  in

  loop 0 0

let solve2 () =
  let factors = Array.make len 0 in

  let rec loop () =
    let init_a = get_init_a factors in
    let output = run init_a 0 0 in
    if output = program then init_a
    else
      let () = update_factors factors output in
      loop ()
  in
  loop ()

(* exports *)

let part1 () = validate solve1 657457310 "17" One
let part2 () = validate solve2 105875099912602 "17" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ =
  let expected = [| 0; 0; 0; 0; 0; 0; 0; 0; 2; 6; 3; 5; 4; 0; 0; 3 |] in
  let factors = [| 0; 0; 0; 0; 0; 0; 0; 0; 1; 6; 3; 5; 4; 0; 0; 3 |] in
  let output = [| 3; 3; 3; 3; 3; 3; 1; 7; 5; 6; 4; 3; 5; 5; 3; 0 |] in
  update_factors factors output;
  factors = expected

let%test _ =
  let factors = [| 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 4; 0; 2; 0; 0; 3 |] in
  let expected = 105694850187264 in
  expected = get_init_a factors
