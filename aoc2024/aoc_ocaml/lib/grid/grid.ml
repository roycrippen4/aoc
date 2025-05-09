open Util

type 'a t = 'a array array
type 'a tl = 'a list list
type position = int * int
type 'a entry = int * int * 'a

let height g = Array.length g
let width g = Array.length g.(0)
let size g = (height g, width g)

let make h w v =
  if h < 1 || w < 1 then invalid_arg "Grid.make";
  Array.make_matrix h w v

let init h w f =
  if h < 1 || w < 1 then invalid_arg "Grid.init";
  Array.init h (fun y -> Array.init w (fun x -> f (x, y)))

let copy g = init (height g) (width g) (fun (x, y) -> g.(y).(x))
let inside g (x, y) = 0 <= y && y < height g && 0 <= x && x < width g
let same_size_with v g = init (height g) (width g) (fun _ -> v)

(* *)

let get g (x, y) = g.(y).(x)
let get_opt g (x, y) = try Some g.(y).(x) with Invalid_argument _ -> None

(* *)

let entry g (x, y) = (x, y, get g (x, y))
let entry_opt g (x, y) = get_opt g (x, y) |> Option.map (fun v -> (x, y, v))

(* *)

let set g (x, y) v = g.(y).(x) <- v

let set_opt g (x, y) v =
  try
    g.(y).(x) <- v;
    Some ()
  with Invalid_argument _ -> None

type direction = N | NW | W | SW | S | SE | E | NE

let string_of_direction = function
  | N -> "north"
  | S -> "south"
  | E -> "east"
  | W -> "west"
  | NE -> "northeast"
  | NW -> "northwest"
  | SE -> "southeast"
  | SW -> "southwest"

let move d (x, y) =
  match d with
  | N -> (x, y - 1)
  | NW -> (x - 1, y - 1)
  | W -> (x - 1, y)
  | SW -> (x - 1, y + 1)
  | S -> (x, y + 1)
  | SE -> (x + 1, y + 1)
  | E -> (x + 1, y)
  | NE -> (x + 1, y - 1)

let north = move N
let north_west = move NW
let west = move W
let south_west = move SW
let south = move S
let south_east = move SE
let east = move E
let north_east = move NE

let rotate_left g =
  let h = height g and w = width g in
  init w h (fun (x, y) -> g.(x).(w - 1 - y))

let rotate_right g =
  let h = height g and w = width g in
  init w h (fun (x, y) -> g.(h - 1 - x).(y))

(* *)

let rec pop_last = function
  | [] | [ _ ] -> []
  | hd :: rest -> hd :: pop_last rest

let pop = function [] | [ _ ] -> [] | _ :: rest -> rest

let strip_edge_rows g =
  Array.(g |> to_list |> List.drop 1 |> pop_last |> of_list)

let strip_edge_cols g = Array.(g |> map (to_list >> pop_last >> pop >> of_list))
let strip_edges g = g |> strip_edge_cols |> strip_edge_rows

(* *)

let map_values f g = init (height g) (width g) (fun (x, y) -> f (get g (x, y)))
let map_coords f g = init (height g) (width g) @@ f
let map_entries f g = init (height g) (width g) (f % entry g)

(* *)

let nbor4_coords p = [ north p; east p; south p; west p ]
let nbor4_values p g = p |> nbor4_coords |> List.map (get_opt g)
let nbor4_entries p g = p |> nbor4_coords |> List.map (entry_opt g)

let nbor8_coords p =
  [
    north p;
    north_east p;
    east p;
    south_east p;
    south p;
    south_west p;
    west p;
    north_west p;
  ]

let nbor8_values g p = p |> nbor8_coords |> List.map (get_opt g)
let nbor8_entries g p = p |> nbor8_coords |> List.map (entry_opt g)

let iter4 f g p =
  let f p = if inside g p then f p (get g p) in
  f (north p);
  f (west p);
  f (south p);
  f (east p)

let iter8 f g p =
  let f p = if inside g p then f p (get g p) in
  f (north p);
  f (north_west p);
  f (west p);
  f (south_west p);
  f (south p);
  f (south_east p);
  f (east p);
  f (north_east p)

let fold4 f g p acc =
  let f p acc = if inside g p then f p (get g p) acc else acc in
  acc |> f (north p) |> f (west p) |> f (south p) |> f (east p)

let fold8 f g p acc =
  let f p acc = if inside g p then f p (get g p) acc else acc in
  acc
  |> f (north p)
  |> f (north_west p)
  |> f (west p)
  |> f (south_west p)
  |> f (south p)
  |> f (south_east p)
  |> f (east p)
  |> f (north_east p)

let iter_entries f g = Array.(iteri (fun y -> iteri (fun x v -> f (x, y, v))) g)
let iter_values f g = g |> iter_entries (fun (_, _, v) -> f v)
let iter_coords f g = g |> iter_entries (fun (x, y, _) -> f (x, y))
let flatten g = Array.fold_left Array.append [||] g

let fold f acc g =
  let rec fold (x, y) acc =
    if y = height g then acc
    else if x = width g then fold (0, y + 1) acc
    else fold (x + 1, y) (f acc (x, y, g.(y).(x)))
  in
  fold (0, 0) acc

let filter_entries f g =
  let f' acc entry = if f entry then entry :: acc else acc in
  fold f' [] g

let filter_coords f g =
  let f' acc (x, y, _) = if f (x, y) then (x, y) :: acc else acc in
  fold f' [] g

let filter_values f g =
  let f' acc (_, _, v) = if f v then v :: acc else acc in
  fold f' [] g

let find f g =
  let exception Found of position in
  try
    iter_entries (fun (x, y, v) -> if f (x, y, v) then raise (Found (x, y))) g;
    raise Not_found
  with Found p -> p

let find_opt f g = try Some (find f g) with Not_found -> None

let find_replace f v g =
  let ((x, y) as p) = find f g in
  let old = get g p in
  set g p v;
  (x, y, old)

let read c =
  let rec scan rows =
    match input_line c with
    | s -> scan (s :: rows)
    | exception End_of_file ->
        let row s = Array.init (String.length s) (String.get s) in
        let g = Array.map row (Array.of_list (List.rev rows)) in
        if Array.length g = 0 then invalid_arg "Grid.read";
        let w = Array.length g.(0) in
        for y = 1 to height g - 1 do
          if Array.length g.(y) <> w then invalid_arg "Grid.read"
        done;
        g
  in
  scan []

let of_string str =
  let open Array in
  str |> String.lines |> of_list |> map (of_list % String.explode)

let of_list l = Array.(l |> of_list |> map of_list)

let to_list g =
  let rec aux acc = function
    | [] -> acc
    | hd :: tl -> aux (Array.to_list hd :: acc) tl
  in
  aux [] (Array.to_list g) |> List.rev

let from_file path = In_channel.with_open_text path read

let print 
    ?(bol = fun _fmt _i -> ())
    ?(sep = fun _fmt _p -> ()) 
    ?(eol = fun fmt _i -> Format.pp_print_newline fmt ())
    p 
    fmt 
    g =
  for y = 0 to height g - 1 do
    bol fmt y;
    for x = 0 to width g - 1 do
      p fmt (x, y) g.(y).(x);
      if x < width g - 1 then sep fmt (x, y)
    done;
    eol fmt y
  done
  [@@ocamlformat "disable"]

let print_chars = print (fun fmt _ c -> Format.pp_print_char fmt c)

(*------------------------------------------------------------------*)
(*  Point‑aware helpers                                             *)
(*------------------------------------------------------------------*)

let pos_of_point p = (p.Point.x, p.Point.y)
let point_of_pos (x, y) = Point.make x y
let inside_pt g p = pos_of_point p |> inside g

(* *)

let get_pt g p = get g (pos_of_point p)
let get_pt_opt g p = get_opt g (pos_of_point p)

(* *)

let set_pt g p v = set g (pos_of_point p) v
let set_pt_opt g p v = set_opt g (pos_of_point p) v

let find_value_pt needle g =
  match find_opt (fun (_, _, v) -> v = needle) g with
  | None -> None
  | Some (x, y) -> Some (Point.make x y)

let ( .%{} ) g p = get g (p.Point.x, p.Point.y)
let ( .%{}<- ) g p v = set g (p.Point.x, p.Point.y) v

module type Walkable = sig
  type cell
  type t

  val compare : t -> t -> int
  val add : t -> t -> t
  val zero : t
  val passable : cell -> bool
  val cost : cell -> t
end

module Dijkstra (W : Walkable) = struct
  module P = Point

  module Node = struct
    type t = W.t * (int * int)

    let compare (d1, _) (d2, _) = W.compare d2 d1 (* ← flipped *)
  end

  module Q = Bheap.Make (Node)

  let walk (g : W.cell t) (start : P.t) (goal : P.t) : P.t list option =
    let start_pos = (start.x, start.y) and goal_pos = (goal.x, goal.y) in

    if not (inside g start_pos && inside g goal_pos) then None
    else if not (W.passable (get g start_pos) && W.passable (get g goal_pos))
    then None
    else
      let dist = Hashtbl.create 97 and prev = Hashtbl.create 97 in
      Hashtbl.add dist start_pos W.zero;

      let pq = Q.create () in
      Q.push pq (W.zero, start_pos);

      (* helper to rebuild the path once we reach the goal *)
      let rec reconstruct p acc =
        let pt = P.make (fst p) (snd p) in
        match Hashtbl.find_opt prev p with
        | None -> List.rev (pt :: acc)
        | Some pre -> reconstruct pre (pt :: acc)
      in

      let rec loop () =
        match Q.pop pq with
        | None -> None
        | Some (d, u) -> (
            match Hashtbl.find_opt dist u with
            | Some best when W.compare d best > 0 -> loop ()
            | _ ->
                if u = goal_pos then Some (reconstruct u []) (* success *)
                else (
                  nbor4_coords u
                  |> List.iter (fun v ->
                         if inside g v then
                           let cell = get g v in
                           if W.passable cell then
                             let alt = W.add d (W.cost cell) in
                             match Hashtbl.find_opt dist v with
                             | None ->
                                 Hashtbl.add dist v alt;
                                 Hashtbl.add prev v u;
                                 Q.push pq (alt, v)
                             | Some old when W.compare alt old < 0 ->
                                 Hashtbl.replace dist v alt;
                                 Hashtbl.replace prev v u;
                                 Q.push pq (alt, v)
                             | _ -> ());
                  loop ()))
      in
      loop ()
end
