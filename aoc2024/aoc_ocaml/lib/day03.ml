open Util

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day03/data.txt"
let trim mat = slice mat 4 (String.length mat - 1)
let split_on_comma s = split_to_string ',' s
let multiply_tuple (x, y) = x * y
let tuple_of_list_pair = function x :: y :: _ -> (x, y) | _ -> assert false

let eval_mul acc lst =
  acc + (tuple_of_list_pair lst |> map_tuple int_of_string |> multiply_tuple)

let solve1 () =
  let re = Re.Perl.compile_pat "mul\\(\\d{1,3},\\d{1,3}\\)" in
  List.map trim (Re.matches re input)
  |> List.map split_on_comma
  |> List.fold_left eval_mul 0

let solve2 () =
  let pat = "do\\(\\)|don't\\(\\)|mul\\(\\d{1,3},\\d{1,3}\\)" in
  let re = Re.Perl.compile_pat pat in
  let rec filter_donts acc collect = function
    | [] -> acc
    | tok :: rest -> (
        match tok with
        | "do()" -> filter_donts acc true rest
        | "don't()" -> filter_donts acc false rest
        | _ -> (
            match collect with
            | true -> filter_donts (tok :: acc) collect rest
            | false -> filter_donts acc collect rest))
  in
  let matches = filter_donts [] true (Re.matches re input) in
  List.map trim matches |> List.map split_on_comma |> List.fold_left eval_mul 0

let part1 () = validate solve1 173731097 "03" One
let part2 () = validate solve2 93729253 "03" Two
let solution : solution = { part1; part2 }
