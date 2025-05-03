(** 2‑D integer points – implementation *)

type t = { mutable x : int; mutable y : int }

let make x y = { x; y }
let origin = make 0 0
let up = make 0 (-1)
let down = make 0 1
let left = make (-1) 0
let right = make 1 0
let orthogonal = [| up; down; left; right |]

let diagonal =
  [|
    make (-1) (-1); up; make 1 (-1); left; right; make (-1) 1; down; make 1 1;
  |]

(* ---------- helpers ---------- *)

let clockwise p = make (-p.y) p.x
let counter_clockwise p = make p.y (-p.x)
let manhattan a b = abs (a.x - b.x) + abs (a.y - b.y)
let sign n = if n = 0 then 0 else if n > 0 then 1 else -1
let signum a b = make (sign (a.x - b.x)) (sign (a.y - b.y))

(* ---------- conversions ---------- *)

let of_char = function
  | '^' | 'U' -> up
  | 'v' | 'D' -> down
  | '<' | 'L' -> left
  | '>' | 'R' -> right
  | c -> invalid_arg (Printf.sprintf "Point.of_char: %C" c)

(* ---------- hashing ---------- *)

let hash p = Hashtbl.hash (p.x, p.y)

(* ---------- arithmetic (immutable) ---------- *)

let add a b = make (a.x + b.x) (a.y + b.y)
let sub a b = make (a.x - b.x) (a.y - b.y)
let mul p k = make (p.x * k) (p.y * k)

(* *)

let ( ++ ) a b = add a b
let ( -- ) a b = sub a b
let ( ** ) p k = mul p k

(* ---------- arithmetic (in‑place) ---------- *)

let add_assign p q =
  p.x <- Stdlib.( + ) p.x q.x;
  p.y <- Stdlib.( + ) p.x q.x

let sub_assign p q =
  p.x <- Stdlib.( - ) p.x q.x;
  p.y <- Stdlib.( - ) p.x q.x
