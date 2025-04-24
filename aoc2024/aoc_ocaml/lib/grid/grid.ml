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

let ( % ) = Fun.compose
let map_values f g = init (height g) (width g) (fun (x, y) -> f (get g (x, y)))
let map_coords f g = init (height g) (width g) @@ f
let map_entries f g = init (height g) (width g) (f % entry g)

(* *)

let neighbor4_coords p = [ north p; east p; south p; west p ]
let neighbor4_values g p = p |> neighbor4_coords |> List.map (get_opt g)
let neighbor4_entries g p = p |> neighbor4_coords |> List.map (entry_opt g)

let neighbor8_coords p =
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

let neighbor8_values g p = p |> neighbor8_coords |> List.map (get_opt g)
let neighbor8_entries g p = p |> neighbor8_coords |> List.map (entry_opt g)

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

let iter_entries f g =
  Array.iteri (fun y -> Array.iteri (fun x v -> f (x, y, v))) g

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
  str
  |> String.split_on_char '\n'
  |> Array.of_list
  |> Array.map (Fun.compose Array.of_list Batteries.String.explode)

let of_list l = l |> Array.of_list |> Array.map Array.of_list

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
