let read_to_lines filepath =
  In_channel.with_open_text filepath In_channel.input_lines

let read_to_string filepath =
  In_channel.with_open_text filepath In_channel.input_all

let split_to_string delim str =
  String.split_on_char delim str |> List.filter (fun s -> s <> "")

let split_to_int delim str =
  String.split_on_char delim str
  |> List.filter (fun s -> s <> "")
  |> List.map int_of_string

let map_tuple f (a, b) = (f a, f b)
let pop = function x :: xs -> (x, xs) | [] -> failwith "List is empty"

let windows n lst =
  let rec build_window n acc = function
    | [] -> None
    | x :: xs ->
        if n = 1 then Some (List.rev (x :: acc), xs)
        else build_window (n - 1) (x :: acc) xs
  in
  let rec aux acc l =
    match build_window n [] l with
    | None -> List.rev acc
    | Some (win, _) -> aux (win :: acc) (List.tl l)
  in
  aux [] lst

let enumerate_list lst = List.mapi (fun i x -> (i, x)) lst
let enumerate_array arr = Array.mapi (fun i x -> (i, x)) arr

let ( /.. ) i j =
  let rec aux n acc = if n <= i then acc else aux (n - 1) ((n - 1) :: acc) in
  aux j []

let ( /..= ) i j =
  let rec aux n acc = if n < i then acc else aux (n - 1) (n :: acc) in
  aux j []

let ( += ) x y = x := !x + y
let ( +=. ) x y = x := !x +. y
let ( -= ) x y = x := !x - y
let ( -=. ) x y = x := !x -. y
let ( /= ) x y = x := !x / y
let ( /=. ) x y = x := !x /. y
let ( % ) x y = x mod y
let ( %= ) x y = x := !x mod y
let ( *= ) x y = x := !x * y
let ( *=. ) x y = x := !x *. y

let%test _ =
  let x = ref 5 in
  x += 5;
  !x = 10

let%test _ =
  let x = ref 5 in
  x -= 5;
  !x = 0

let%test _ =
  let x = ref 6 in
  x /= 5;
  !x = 1

let%test _ = 6 % 5 = 1
let%test _ = windows 3 [] = []
let%test _ = windows 1 [ 1; 2; 3 ] = [ [ 1 ]; [ 2 ]; [ 3 ] ]
let%test _ = windows 2 [ 1; 2 ] = [ [ 1; 2 ] ]
let%test _ = windows 2 [ 1; 2; 3 ] = [ [ 1; 2 ]; [ 2; 3 ] ]
let%test _ = windows 4 [ 1; 2; 3 ] = []

let%test _ =
  let win = windows 3 [ 1; 2; 3; 4; 5 ] in
  win = [ [ 1; 2; 3 ]; [ 2; 3; 4 ]; [ 3; 4; 5 ] ]

let%test _ = 0 /.. 5 = [ 0; 1; 2; 3; 4 ]
let%test _ = 0 /..= 5 = [ 0; 1; 2; 3; 4; 5 ]
