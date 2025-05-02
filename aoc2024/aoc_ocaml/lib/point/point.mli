(**
  {1 2‑dimensional points (integer coordinates)}

  This module offers a compact, ergonomic point type designed to work hand‑in‑hand
  with a {!module:Grid} implementation for Advent‑of‑Code–style puzzles and other
  grid‑based problems.

  Much like the original Rust version, it provides infix operators so you can write
  expressions such as

  {[
    open Point

    let a = make 1 2
    and b = make 3 4
    and k = 2 in

    assert (a + b = make 4 6);
    assert (a - b = make (-2) (-2));
    assert (a * k = make 2 4)
  ]}

  In addition there are helpers for 90‑degree rotations ({!clockwise} /
  {!counter_clockwise}) and for computing the
  {{:https://en.wikipedia.org/wiki/Taxicab_geometry} Manhattan distance}
  between two points.

  The public interface is split into four sections:

  {ul
    {- Constructors and predefined constants.}
    {- Pure (immutable) arithmetic operators.}
    {- In‑place (“_assign”) arithmetic for mutable updates.}
    {- Utility functions (rotation, distance, hashing, …).}
  }
*)

(** The point record.  Coordinates are mutable so that {e in‑place} helpers
    (`add_assign`, `sub_assign`) can update a value without allocation. *)
type t = { mutable x : int; mutable y : int }

(*------------------------------------------------------------------*)
(** {1 Constructors and constants} *)

val make   : int -> int -> t
val origin : t  (** (0,0) *)

(** Compass directions (unit steps).  Suitable for e.g. flood‑fill. *)
val up    : t  (** ( 0,-1) *)
val down  : t  (** ( 0, 1) *)
val left  : t  (** (-1, 0) *)
val right : t  (** ( 1, 0) *)

val orthogonal : t array
  (** [| up; down; left; right |] *)

val diagonal : t array
  (** Eight neighbours laid out left→right, top→bottom:
      {[
        (-1,-1)  (0,-1)  ( 1,-1)
        (-1, 0)  (0, 0)  ( 1, 0)
        (-1, 1)  (0, 1)  ( 1, 1)
      ]} *)

(*------------------------------------------------------------------*)
(** {1 Utility functions} *)

val clockwise         : t -> t
  (** Rotate 90° clockwise: (x,y) ↦ (-y,x) *)

val counter_clockwise : t -> t
  (** Rotate 90° counter‑clockwise: (x,y) ↦ (y,-x) *)

val manhattan : t -> t -> int
  (** Manhattan (taxicab) distance. *)

val signum : t -> t -> t
  (** Component‑wise sign of the delta between two points. *)

val of_char : char -> t
  (** Convert a direction character:
      ['^'|'U' → up], ['v'|'D' → down],
      ['<'|'L' → left], ['>'|'R' → right]. *)

val hash : t -> int
  (** Deterministic hash value, suitable for {!Hashtbl}. *)

(*------------------------------------------------------------------*)
(** {1 Pure arithmetic (immutable)} *)

val ( + ) : t -> t -> t
val ( - ) : t -> t -> t
val ( * ) : t -> int -> t   (** Scalar multiply *)

(*------------------------------------------------------------------*)
(** {1 In‑place arithmetic (mutating)} *)

val add_assign : t -> t -> unit
val sub_assign : t -> t -> unit
