open Util
module T = Tuple

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day19/data.txt"
let split_by ch s = String.(trim s |> split_on_char ch |> List.map trim)

let parse s =
  s
  |> String.split_once ~by:"\n\n"
  |> T.bimap ~f1:(split_by ',') ~f2:(split_by '\n')

type pattern = { txt : string; len : int }

let pat s = { txt = s; len = String.length s }

let starts_with s i p =
  let rec loop k = k = p.len || (s.[i + k] = p.txt.[k] && loop (k + 1)) in
  i + p.len <= String.length s && loop 0

let bucket_by_head pats =
  let bs = Array.make 256 [] in
  pats |> List.iter Char.(fun s -> bs.(code s.[0]) <- pat s :: bs.(code s.[0]));
  bs

let can_combine buckets s =
  let n = String.length s in
  let dp = Array.make (n + 1) false in
  dp.(n) <- true;

  let rec try_pats i = function
    | [] -> ()
    | ({ len; _ } as p) :: rest ->
        if i + len <= n && dp.(i + len) && starts_with s i p then dp.(i) <- true
        else try_pats i rest
  in

  let rec loop i =
    if i <> -1 then
      let () = try_pats i buckets.(Char.code s.[i]) in
      pred i |> loop
  in

  pred n |> loop;

  dp.(0)

(* part 2 *)
let count_ways buckets s =
  let n = String.length s in
  let dp = Array.make (n + 1) 0 in
  dp.(n) <- 1;

  let rec try_pats i = function
    | [] -> ()
    | ({ len; _ } as p) :: rest ->
        if i + len <= n && starts_with s i p then
          dp.(i) <- dp.(i) + dp.(i + len);
        try_pats i rest
  in

  let rec loop i =
    if i <> -1 then
      let () = try_pats i buckets.(Char.code s.[i]) in
      pred i |> loop
  in

  pred n |> loop;
  dp.(0)

let patterns, designs = parse input
let buckets = bucket_by_head patterns

let solve1 () =
  let accumulate acc d = if can_combine buckets d then succ acc else acc in
  List.fold_left accumulate 0 designs

let solve2 () =
  let accumulate acc d = acc + count_ways buckets d in
  List.fold_left accumulate 0 designs

(* exports *)

let part1 () = validate solve1 287 "19" One
let part2 () = validate solve2 571894474468161 "19" Two
let solution : solution = { part1; part2 }
