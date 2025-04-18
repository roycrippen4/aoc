open Util

module H = struct
  include Hashtbl

  let of_list lst = lst |> List.to_seq |> of_seq
  let to_list tbl = tbl |> to_seq |> List.of_seq

  let insert_or_incr tbl key amount =
    match find_opt tbl key with
    | None -> add tbl key (0 + amount)
    | Some value -> replace tbl key (value + amount)
end

let digit_count = function
  | n when n < 10 -> 1
  | n when n < 100 -> 2
  | n when n < 1_000 -> 3
  | n when n < 10_000 -> 4
  | n when n < 100_000 -> 5
  | n when n < 1_000_000 -> 6
  | n when n < 10_000_000 -> 7
  | n when n < 100_000_000 -> 8
  | n when n < 1_000_000_000 -> 9
  | n when n < 10_000_000_000 -> 10
  | n when n < 100_000_000_000 -> 11
  | n when n < 10_00_000_000_000 -> 12
  | n when n < 100_00_000_000_000 -> 13
  | _ -> 14

let pow10 = [| 1; 10; 100; 1000; 10000; 100000; 1000000; 10000000 |]

let do_blink stones (value, amount) =
  if value = 0 then H.insert_or_incr stones 1 amount
  else
    let count = digit_count value in
    if count land 1 = 0 then (
      let div = pow10.(count lsr 1) in
      H.insert_or_incr stones (value / div) amount;
      H.insert_or_incr stones (value mod div) amount)
    else H.insert_or_incr stones (value * 2024) amount

let rec blink it stones new_stones =
  if it = 0 then H.fold (fun _ v acc -> acc + v) stones 0
  else (
    H.clear new_stones;
    H.iter (fun k v -> do_blink new_stones (k, v)) stones;
    blink (it - 1) new_stones stones)

let initial_stones =
  read_to_string "/home/roy/dev/aoc/aoc2024/data/day11/data.txt"
  |> String.trim
  |> String.split_on_char ' '
  |> List.map (fun v -> (int_of_string v, 1))

let solve iterations =
  initial_stones |> H.of_list |> fun stones ->
  let new_stones = H.create 5000 in
  blink iterations stones new_stones

let solve1 () = solve 25
let solve2 () = solve 75

(* exports *)

let part1 () = validate solve1 220999 "11" One
let part2 () = validate solve2 261936432123724 "11" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ =
  let tbl = [ ("a", 1) ] |> H.of_list in
  H.insert_or_incr tbl "a" 3;
  H.insert_or_incr tbl "b" 0;
  H.find tbl "a" = 4 && Hashtbl.find tbl "b" = 0
