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
let ( %= ) x y = x := !x mod y
let ( *= ) x y = x := !x * y
let ( *=. ) x y = x := !x *. y
let ( let* ) x f = Option.bind x f
let ( /- ) n d = if n >= 0 || n mod d = 0 then n / d else pred (n / d)
let ( /+ ) n d = if n <= 0 || n mod d = 0 then n / d else succ (n / d)
let ( ** ) a b = General.pow a b

(* Combinators and function application *)

let ( >> ) f g = fun x -> g (f x)
let ( % ) f g = fun x -> f (g x)
let ( <$> ) h f = h % f
let ( <*> ) f_a_b f_a = fun x -> (f_a_b x) (f_a x)

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

let%test _ = 0 /.. 5 = [ 0; 1; 2; 3; 4 ]
let%test _ = 0 /..= 5 = [ 0; 1; 2; 3; 4; 5 ]
let%test _ = -3 /- 2 = -2
let%test _ = 7 /- 3 = 2
let%test _ = 7 /+ 3 = 3
let%test _ = -7 /+ 3 = -2
let%test _ = 9 /+ 3 = 3
