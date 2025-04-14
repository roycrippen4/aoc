open Util

type byte = Hole | Bit of int

let string_of_byte = function Hole -> "." | Bit v -> string_of_int v

let to_int = function
  | '0' -> 0
  | '1' -> 1
  | '2' -> 2
  | '3' -> 3
  | '4' -> 4
  | '5' -> 5
  | '6' -> 6
  | '7' -> 7
  | '8' -> 8
  | '9' -> 9
  | _ -> failwith "Invalid_argument"

let create_mem char_list =
  let sum x y = x + to_int y in
  let size = char_list |> List.fold_left sum 0 in
  let mem = Array.make size Hole in

  let rec aux char_idx mem_idx = function
    | [] -> ()
    | char :: chars ->
        let length = to_int char in
        let next_mem_idx = mem_idx + length in
        if char_idx % 2 = 0 then
          Array.fill mem mem_idx length (Bit (char_idx / 2));
        aux (succ char_idx) next_mem_idx chars
  in

  aux 0 0 char_list;
  mem

let string_of_mem mem =
  mem |> Array.to_list |> List.map string_of_byte |> String.concat ""

let show_mem mem = mem |> string_of_mem |> Printf.printf "%s\n"
let path = "/home/roy/dev/aoc/aoc2024/data/day09/data.txt"
let input = path |> read_to_string |> String.trim |> str_explode
let mem = create_mem input

(* Part 1 *)

let rec scan_for_bit i j id acc =
  if j >= i then
    match mem.(j) with
    | Hole -> scan_for_bit i (pred j) id acc
    | Bit v -> (pred j, succ id, acc + (id * v))
  else (j, id, acc)

let rec loop i (j, id, acc) =
  if i <= j then
    match mem.(i) with
    | Bit v -> loop (succ i) (j, succ id, acc + (id * v))
    | Hole -> loop (succ i) (scan_for_bit i j id acc)
  else acc

let solve1 () = loop 0 (Array.length mem - 1, 0, 0)

(* part 2 *)

let find_hole mem b_start size =
  (* gets the hole end index *)
  let rec get_hole_end = function
    | h_end when h_end <= h_end && mem.(h_end) = Hole -> get_hole_end (h_end + 1)
    | idx -> idx
  in

  let rec scan b_start h_start =
    (* Un-nest the branching pattern matches *)
    let scan_or_return h_start = function
      | h_end when h_end - h_start < size -> scan b_start (h_end + 1)
      | _ -> Some h_start
    in

    if h_start <= b_start then
      match mem.(h_start) with
      | Bit _ -> scan b_start (h_start + 1)
      | Hole -> h_start |> get_hole_end |> scan_or_return h_start
    else None
  in
  scan b_start 0

let find_file mem curr_start =
  let rec next_file_end idx =
    if mem.(idx) = Hole then next_file_end (idx - 1) else idx
  in

  let end_idx = next_file_end (curr_start - 1) in
  let value = mem.(end_idx) in

  let rec scan scan_idx =
    if scan_idx = 0 then (0, end_idx)
    else
      match mem.(scan_idx) with
      | v when v <> value -> (scan_idx + 1, end_idx)
      | _ -> scan (scan_idx - 1)
  in
  scan end_idx

let swap b_start h_start length =
  let b_val = mem.(b_start) in
  let h_val = mem.(h_start) in
  Array.fill mem h_start length b_val;
  Array.fill mem b_start length h_val

let rec loop last_idx count =
  let b_start, b_end = find_file mem last_idx in
  if b_start = 0 then ()
  else
    let slice_len = b_end - b_start + 1 in
    match find_hole mem b_start slice_len with
    | Some h_start ->
        swap b_start h_start slice_len;
        loop b_start (succ count)
    | None -> loop b_start (succ count)

let () = loop (Array.length mem) 0

let solve2 () =
  let calc (acc, idx) = function
    | Bit v -> (acc + (v * idx), idx + 1)
    | Hole -> (acc, idx + 1)
  in
  let result, _ = Array.fold_left calc (0, 0) mem in
  result

(* exports *)

let part1 () = validate solve1 6448989155953 "09" One
let part2 () = validate solve2 6476642796832 "09" Two
let solution : solution = { part1; part2 }
