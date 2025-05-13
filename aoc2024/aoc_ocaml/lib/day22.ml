open Util

let nums =
  "/home/roy/dev/aoc/aoc2024/data/day22/data.txt" |> read_to_string
  |> String.trim |> String.lines |> List.map int_of_string

let take_step secret =
  let mask24 = (1 lsl 24) - 1 in
  let s1 = (secret lsl 6) lxor secret land mask24 in
  let s2 = (s1 lsr 5) lxor s1 land mask24 in
  (s2 lsl 11) lxor s2 land mask24

let nth_step secret n =
  let rec aux acc = function 0 -> acc | n -> aux (take_step acc) (pred n) in
  aux secret n

let solve1 () =
  let map_acc acc n = acc + nth_step n 2000 in
  List.fold_left map_acc 0 nums

(* part 2 *)
let encode (a, b, c, d) =
  let off x = x + 9 in
  (((((off a * 19) + off b) * 19) + off c) * 19) + off d

let solve2 () =
  let max_seq = 19 * 19 * 19 * 19 in
  let sums = Array.make max_seq 0 in
  let seen = Array.make max_seq (-1) in

  List.iteri
    (fun i secret ->
      let diffs = Array.make 4 0 in
      let idx = ref 0 in
      let last = ref secret in

      for step = 0 to 1999 do
        let prev = !last mod 10 in
        let next = take_step !last in
        let value = next mod 10 in
        let diff = value - prev in
        last := next;

        let p = step land 3 in
        (if step < 3 then diffs.(p) <- diff
         else if step = 3 then
           let () = diffs.(p) <- diff in
           idx := encode (diffs.(0), diffs.(1), diffs.(2), diffs.(3))
         else
           let oldest = diffs.(p) in
           idx := ((!idx - ((oldest + 9) * 19 * 19 * 19)) * 19) + (diff + 9);
           diffs.(p) <- diff);

        if step >= 3 && seen.(!idx) <> i then (
          seen.(!idx) <- i;
          sums.(!idx) <- sums.(!idx) + value)
      done)
    nums;

  Array.fold_left Int.max 0 sums

(* exports *)

let part1 () = validate solve1 20215960478 "22" One
let part2 () = validate solve2 2221 "22" Two
let solution : solution = { part1; part2 }

(* tests *)
let%test _ = nth_step 123 1 = 15887950
let%test _ = nth_step 123 10 = 5908254
let%test _ = nth_step 1 2000 = 8685429
let%test _ = nth_step 10 2000 = 4700978
let%test _ = nth_step 100 2000 = 15273692
let%test _ = nth_step 2024 2000 = 8667524
