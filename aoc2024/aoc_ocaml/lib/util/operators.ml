let ( /.. ) i j =
  let rec aux n acc = if n <= i then acc else aux (n - 1) ((n - 1) :: acc) in
  aux j []

let ( /..= ) i j =
  let rec aux n acc = if n < i then acc else aux (n - 1) (n :: acc) in
  aux j []

let range i j =
  let rec aux n acc = if n <= i then acc else aux (n - 1) ((n - 1) :: acc) in
  aux j []

let range_i i j =
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
let ( let* ) x f = Option.bind x f

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
let%test _ = 0 /.. 5 = [ 0; 1; 2; 3; 4 ]
let%test _ = 0 /..= 5 = [ 0; 1; 2; 3; 4; 5 ]
