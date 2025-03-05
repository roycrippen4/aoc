open Util

let input = read_to_string "../data/day03/data.txt"
let re_part1 = Re.Perl.compile_pat "mul\\(\\d{1,3},\\d{1,3}\\)"
let trim mat = slice mat 4 (String.length mat - 1)
let split_on_comma s = Re.split (Re.compile (Re.char ',')) s
let multiply_tuple (x, y) = x * y
let tuple_of_list_pair = function x :: y :: _ -> (x, y) | _ -> assert false

let eval_mul acc lst =
  acc + (tuple_of_list_pair lst |> map_tuple int_of_string |> multiply_tuple)

let solve1 () =
  List.map trim (Re.matches re_part1 input)
  |> List.map split_on_comma |> List.fold_left eval_mul 0

(* Just let me space this out ocamlformat *)
let%test _ =
  let () = Printf.printf "answer: %d\n" (solve1 ()) in
  true
