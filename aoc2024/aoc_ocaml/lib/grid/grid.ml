type 'a t = 'a array array
type position = int * int

let height g = Array.length g
let width g = Array.length g.(0)
let size g = (height g, width g)

let make h w v =
  if h < 1 || w < 1 then invalid_arg "Grid.make";
  Array.make_matrix h w v

let init h w f =
  if h < 1 || w < 1 then invalid_arg "Grid.init";
  Array.init h (fun i -> Array.init w (fun j -> f (i, j)))

let copy g = init (height g) (width g) (fun (i, j) -> g.(i).(j))
let inside g (i, j) = 0 <= i && i < height g && 0 <= j && j < width g
let get g (i, j) = g.(i).(j)
let get_opt g (i, j) = try Some g.(i).(j) with Invalid_argument _ -> None
let set g (i, j) v = g.(i).(j) <- v

let set_opt g (i, j) v =
  try
    g.(i).(j) <- v;
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

let move d (i, j) =
  match d with
  | N -> (i - 1, j)
  | NW -> (i - 1, j - 1)
  | W -> (i, j - 1)
  | SW -> (i + 1, j - 1)
  | S -> (i + 1, j)
  | SE -> (i + 1, j + 1)
  | E -> (i, j + 1)
  | NE -> (i - 1, j + 1)

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
  init w h (fun (i, j) -> g.(j).(w - 1 - i))

let rotate_right g =
  let h = height g and w = width g in
  init w h (fun (i, j) -> g.(h - 1 - j).(i))

let map f g = init (height g) (width g) (fun p -> f p (get g p))

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

let iter f g =
  for i = 0 to height g - 1 do
    for j = 0 to width g - 1 do
      f (i, j) g.(i).(j)
    done
  done

let flatten g = Array.fold_left Array.append [||] g

let enumerate g =
  g
  |> Array.mapi (fun i row -> row |> Array.mapi (fun j value -> (i, j, value)))

let fold f g acc =
  let rec fold ((i, j) as p) acc =
    if i = height g then acc
    else if j = width g then fold (i + 1, 0) acc
    else fold (i, j + 1) (f p g.(i).(j) acc)
  in
  fold (0, 0) acc

let filter f g =
  let f' p v acc = if f p v then p :: acc else acc in
  fold f' g []

let find_opt f g =
  let exception Found of position in
  try
    iter (fun p c -> if f p c then raise (Found p)) g;
    None
  with Found p -> Some p

let find f g =
  let exception Found of position in
  try
    iter (fun p c -> if f p c then raise (Found p)) g;
    raise Not_found
  with Found p -> p

let read c =
  let rec scan rows =
    match input_line c with
    | s -> scan (s :: rows)
    | exception End_of_file ->
        let row s = Array.init (String.length s) (String.get s) in
        let g = Array.map row (Array.of_list (List.rev rows)) in
        if Array.length g = 0 then invalid_arg "Grid.read";
        let w = Array.length g.(0) in
        for i = 1 to height g - 1 do
          if Array.length g.(i) <> w then invalid_arg "Grid.read"
        done;
        g
  in
  scan []

let of_string str =
  let g =
    String.split_on_char '\n' str
    |> Array.of_list
    |> Array.map (fun s -> Array.of_list (Batteries.String.explode s))
  in
  if Array.length g = 0 then invalid_arg "Grid.read";
  let w = Array.length g.(0) in
  for i = 1 to height g - 1 do
    if Array.length g.(i) <> w then invalid_arg "Grid.read"
  done;
  g

let from_file path = In_channel.with_open_text path (fun ic -> read ic)

let print ?(bol = fun _fmt _i -> ())
    ?(eol = fun fmt _i -> Format.pp_print_newline fmt ())
    ?(sep = fun _fmt _p -> ()) p fmt g =
  for i = 0 to height g - 1 do
    bol fmt i;
    for j = 0 to width g - 1 do
      p fmt (i, j) g.(i).(j);
      if j < width g - 1 then sep fmt (i, j)
    done;
    eol fmt i
  done

let print_chars = print (fun fmt _ c -> Format.pp_print_char fmt c)

let%test _ =
  "XMX\nMXA\nAMX" |> of_string |> filter (fun _ v -> v = 'X') |> List.length = 4
