open Util

module StringList = struct
  let compare = compare

  type t = string list
end

module SS = Set.Make (String)
module SLS = Set.Make (StringList)
module Dq = Core.Deque
module L = List
module H = Hashtbl

let vertices, edges =
  let process_line (vertices, edges) line =
    let open H in
    let left, right = String.split_once ~by:"-" line in

    let s = (try find edges left with _ -> SS.empty) |> SS.add right in
    replace edges left s;

    let s = (try find edges right with _ -> SS.empty) |> SS.add left in
    replace edges right s;

    (vertices |> SS.add left |> SS.add right, edges)
  in

  read_to_lines "/home/roy/dev/aoc/aoc2024/data/day23/data.txt"
  |> L.fold_left process_line (SS.empty, H.create 3380)

let nbors c v =
  L.fold_left (fun acc v -> SS.inter acc (H.find edges v)) (H.find edges v) c

let find_cliques_n n =
  let rec loop dq cs =
    match Dq.dequeue_front dq with
    | None -> cs
    | Some (_, c) when L.length c = n -> loop dq (SLS.add (L.sort compare c) cs)
    | Some (v, c) ->
        nbors c v
        |> SS.filter (fun n -> String.compare n v > 0)
        |> SS.iter (fun n -> Dq.enqueue_back dq (n, n :: c));
        loop dq cs
  in

  let dq =
    SS.to_list vertices |> Array.of_list
    |> Array.map (fun v -> (v, [ v ]))
    |> Dq.of_array
  in

  loop dq SLS.empty

let solve1 () =
  let has_t = List.find_opt (fun s -> s.[0] = 't') >> Option.is_some in
  SLS.fold (fun c acc -> if has_t c then succ acc else acc) (find_cliques_n 3) 0

(* part 2 *)

let rec bron_kerbosch r p x =
  let open SS in
  if is_empty p && is_empty x then r
  else
    let p_set = union p x in
    let p_guess = choose p_set in

    let u =
      let get_best v (best, c) =
        let common = cardinal (H.find edges v |> inter p) in
        if common > best then (common, v) else (best, c)
      in
      fold get_best p_set (-1, p_guess) |> snd
    in

    let rec loop p x best = function
      | [] -> best
      | v :: vs ->
          let ns = H.find edges v in
          let clq = bron_kerbosch (add v r) (inter p ns) (inter x ns) in
          let best = if cardinal clq > cardinal best then clq else best in
          loop (remove v p) (add v x) best vs
    in

    loop p x empty (H.find edges u |> diff p |> to_list)

let solve2 () = bron_kerbosch SS.empty vertices SS.empty |> SS.cardinal

(* exports *)

let part1 () = validate solve1 1337 "23" One
let part2 () = validate solve2 13 "23" Two
let solution : solution = { part1; part2 }

(* tests *)
