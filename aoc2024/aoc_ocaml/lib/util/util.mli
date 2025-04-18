type solution = Solution.solution
type part = Solution.part

val range : int -> int -> int list
(** Rust-like range operator. End exclusive *)

val ( /.. ) : int -> int -> int list
(** Rust-like range operator. End exclusive *)

val ( /..= ) : int -> int -> int list
(** Rust-like range operator. End inclusive *)

val range_i : int -> int -> int list
(** Rust-like range operator. End inclusive *)

val ( += ) : int ref -> int -> unit
(** Plus equal. [ref x] += [y] *)

val ( +=. ) : float ref -> float -> unit
(** Floating point plus equal. [ref x] +=. [y] *)

val ( *= ) : int ref -> int -> unit
(** Integer times-equal. [ref x] *= [y] *)

val ( *=. ) : float ref -> float -> unit
(** Floating point times-equal. [ref x] *=. [y] *)

val ( -= ) : int ref -> int -> unit
(** Minus equal. [ref x] -= [y] *)

val ( -=. ) : float ref -> float -> unit
(** Floating point minus equal. [ref x] -=. [y] *)

val ( /= ) : int ref -> int -> unit
(** Divide equal. [ref x] /= [y] *)

val ( /=. ) : float ref -> float -> unit
(** Floating point divide equal. [ref x] /=. [y] *)

val ( % ) : int -> int -> int
(** Integer modulo operator. [x] % [y] = [x] mod [y] *)

val ( %= ) : int ref -> int -> unit
(** Modulo Equal. [ref x] %= [y] *)

val ( let* ) : 'a option -> ('a -> 'b option) -> 'b option
(* This is like Gleam's `use` expressions *)

val map_tuple : ('a -> 'b) -> 'a * 'a -> 'b * 'b
(** applies function [f] to the tuple [(a, b)] as [(f a, f b)] *)

val pop : 'a list -> 'a * 'a list
(* Pops the head off of a list. Returns [hd] and rest of the [list] *)

val pp_int_list : int list -> unit
val pp_int_list_list : int list list -> unit
val pp_string_list : string list -> unit
val pp_string_list_list : string list list -> unit
val pp_char_list : char list -> unit
val pp_char_list_list : char list list -> unit

val read_to_lines : string -> string list
(** Returns [string list] from the file contents located at [filepath] separated
    by newlines *)

val read_to_string : string -> string
(** Returns a [string] from the file contents located at [filepath] *)

val slice : string -> int -> int -> string
(** Thin wrapper around [String.sub] *)

val split_to_int : char -> string -> int list
(** Split the string [str] by character [delim] and filter empty results out *)

val split_to_string : char -> string -> string list
(** Split the string [str] by character [delim] and filter empty results out *)

val validate : (unit -> int) -> int -> string -> part -> float
val windows : int -> 'a list -> 'a list list

val combos : 'a list -> ('a * 'a) list
(** Produces the list of unique element pairs in a list *)

val str_explode : string -> char list

val int_of_char2 : char -> int
(** Converts a [char] into an [int]. e.g. ['1'] becomes [1] *)

val char_of_int2 : int -> char
(** Converts an [int] into a [char]. e.g. [1] becomes ['1'] *)

val pow : int -> int -> int
(** [pow base exponent] returns [base] raised to the power of [exponent]. It is
    OK if [base <= 0]. [pow] raises if [exponent < 0], or an integer overflow
    would occur.*)

val todo : unit -> 'a
(** Similar to Rust's [todo!()] macro *)
