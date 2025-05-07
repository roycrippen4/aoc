open Util

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day19/data.txt"

let matcher_of_string pattern =
  let module Search = Core.String.Search_pattern in
  let pat = Search.create pattern in
  let len = String.length pattern - 1 in
  fun s -> Search.index ~in_:s pat |> Option.map ~f:(fun i -> (i, i + len))

let parse s =
  let split_by ch s = String.(trim s |> split_on_char ch |> List.map trim) in

  let make_matchers s =
    s
    |> split_by ','
    |> List.map (fun s -> (s, String.length s))
    |> List.sort (fun (_, a) (_, b) -> compare a b)
    |> List.map (fst >> matcher_of_string)
  in

  s |> String.split ~by:"\n\n" |> map_tuple2 make_matchers (split_by '\n')

let split_on_slice s (lo, hi) =
  let len = String.length s in
  if lo < 0 || hi < lo || hi >= len then invalid_arg "split_on_slice";

  let l = String.sub s 0 lo in
  let r = String.sub s (hi + 1) (len - hi - 1) in

  (l, r)

let memo = Hashtbl.create 0

let can_combine matchers str =
  let rec aux s =
    if s = "" then true
    else
      match Hashtbl.find_opt memo s with
      | Some v -> v
      | None ->
          let result =
            let split_match matcher = Option.(matcher s >>| split_on_slice s) in
            let try_branches (l, r) = aux l && aux r in
            matchers |> List.filter_map split_match |> List.exists try_branches
          in
          Hashtbl.add memo s result;
          result
  in
  aux str

let solve1 () =
  let matchers, designs = parse input in
  let accumulate acc str = if can_combine matchers str then acc + 1 else acc in
  List.fold_left accumulate 0 designs

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 287 "19" One
let part2 () = validate solve2 42 "19" Two
let solution : solution = { part1; part2 }

(* tests *)
let%test _ =
  let eq (foo, bar) = String.equal foo "foo" && String.equal bar "bar" in
  let s = "fooquxbar" in
  s |> matcher_of_string "qux" |> Option.get |> split_on_slice s |> eq
