let bimap ~f1 ~f2 (a, b) = (f1 a, f2 b)
let map f (a, b) = (f a, f b)
let map2 f (a1, a2) (b1, b2) = (f a1 b1, f a2 b2)
let map_fst f (a, b) = (f a, b)
let map_snd f (a, b) = (a, f b)
let swap (a, b) = (b, a)

let iter f (a, b) =
  f a;
  f b

let fold f (a, b) (acc : 'acc) = f (f acc a) b
let to_list (a, b) = [ a; b ]

let of_list_exn = function
  | [ a; b ] -> (a, b)
  | _ -> raise (Invalid_argument "Input list must have exactly two elements")

let of_list = function [ a; b ] -> Some (a, b) | _ -> None
let uncurry f (a, b) = f a b
let curry f a b = f (a, b)
let zip (a1, b1) (a2, b2) = ((a1, a2), (b1, b2))
let unzip ((a1, a2), (b1, b2)) = ((a1, b1), (a2, b2))
