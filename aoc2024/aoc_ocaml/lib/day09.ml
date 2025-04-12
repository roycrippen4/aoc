open Util

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

let create_memory char_list =
  let sum x y = x + to_int y in
  let size = char_list |> List.fold_left sum 0 in
  let memory = Array.make size None in

  let rec aux char_idx mem_idx = function
    | [] -> ()
    | char :: chars ->
        let length = to_int char in
        let next_mem_idx = mem_idx + length in
        let value = if char_idx % 2 = 0 then Some (char_idx / 2) else None in
        Array.fill memory mem_idx length value;
        aux (succ char_idx) next_mem_idx chars
  in

  aux 0 0 char_list;
  memory

let show_memory memory =
  memory
  |> Array.to_list
  |> List.map (function None -> "." | Some v -> string_of_int v)
  |> String.concat ""
  |> Printf.printf "%s\n"

let path = "/home/roy/dev/aoc/aoc2024/data/day09/data.txt"
let input = path |> read_to_string |> String.trim |> str_explode
let memory = create_memory input

(* Part 1 *)

let solve1 () =
  let id = ref 0 in
  let result = ref 0 in
  let len = Array.length memory in
  let i = ref 0 in
  let j = ref (len - 1) in

  let scan_reverse () =
    try
      while i <= j do
        match memory.(!j) with
        | Some next ->
            result += (!id * next);
            id += 1;
            j -= 1;
            raise Exit
        | None -> j -= 1
      done
    with Exit -> ()
  in

  while i <= j do
    i += 1;
    match memory.(!i - 1) with
    | Some next ->
        result += (!id * next);
        id += 1
    | None -> scan_reverse ()
  done;
  !result

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 6448989155953 "09" One
let part2 () = validate solve2 42 "09" Two
let solution : solution = { part1; part2 }

(* tests *)

(* let%test _ = *)
(*   let () = Printf.printf "%s\n" (Memory.to_string memory) in *)
(*   let () = Memory.pp Format.std_formatter memory in *)
(*   true *)
