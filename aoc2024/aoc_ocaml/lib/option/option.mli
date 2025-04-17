(** Optional values.

    Type [Option] represents an optional value: every [Option] is either [Some]
    and contains a value, or [None], and does not. [Option] types are very
    common in code, as they have a number of uses:

    * Initial values * Return values for functions that are not defined over
    their entire input range (partial functions) * Return value for otherwise
    reporting simple errors, where [None] is returned on error * Optional struct
    fields * Struct fields that can be loaned or "taken" * Optional function
    arguments * Nullable pointers * Swapping things out of difficult situations

    [Option]s are commonly paired with pattern matching to query the presence of
    a value and take action, always accounting for the [None] case. *)

(** The type for option values. Either [None] or a value [Some v]. *)
type 'a t = 'a option = None | Some of 'a (**)

val none : 'a option
(** [none] is [None]. *)

val some : 'a -> 'a option
(** [some v] is [Some v]. *)

val value : 'a option -> default:'a -> 'a
(** [value o ~default] is [v] if [o] is [Some v] and [default] otherwise. *)

val get : 'a option -> 'a
(** [get o] is [v] if [o] is [Some v] and raise otherwise.

    @raise Invalid_argument if [o] is [None]. *)

val bind : 'a option -> ('a -> 'b option) -> 'b option
(** [bind o f] is [f v] if [o] is [Some v] and [None] if [o] is [None]. *)

val join : 'a option option -> 'a option
(** [join oo] is [Some v] if [oo] is [Some (Some v)] and [None] otherwise. *)

val map : ('a -> 'b) -> 'a option -> 'b option
(** [map f o] is [None] if [o] is [None] and [Some (f v)] if [o] is [Some v]. *)

val fold : none:'a -> some:('b -> 'a) -> 'b option -> 'a
(** [fold ~none ~some o] is [none] if [o] is [None] and [some v] if [o] is
    [Some v]. *)

val iter : ('a -> unit) -> 'a option -> unit
(** [iter f o] is [f v] if [o] is [Some v] and [()] otherwise. *)

(** {1:preds Predicates and comparisons} *)

val is_none : 'a option -> bool
(** [is_none o] is [true] if and only if [o] is [None]. *)

val is_some : 'a option -> bool
(** [is_some o] is [true] if and only if [o] is [Some o]. *)

val equal : ('a -> 'a -> bool) -> 'a option -> 'a option -> bool
(** [equal eq o0 o1] is [true] if and only if [o0] and [o1] are both [None] or
    if they are [Some v0] and [Some v1] and [eq v0 v1] is [true]. *)

val compare : ('a -> 'a -> int) -> 'a option -> 'a option -> int
(** [compare cmp o0 o1] is a total order on options using [cmp] to compare
    values wrapped by [Some _]. [None] is smaller than [Some _] values. *)

(** {1:convert Converting} *)

val to_result : none:'e -> 'a option -> ('a, 'e) result
(** [to_result ~none o] is [Ok v] if [o] is [Some v] and [Error none] otherwise.
*)

val to_list : 'a option -> 'a list
(** [to_list o] is [[]] if [o] is [None] and [[v]] if [o] is [Some v]. *)

val to_seq : 'a option -> 'a Seq.t
(** [to_seq o] is [o] as a sequence. [None] is the empty sequence and [Some v]
    is the singleton sequence containing [v]. *)

val is_some_and : ('a -> bool) -> 'a t -> bool
(** Returns [true] if the option is a [Some] and the value inside of it matches
    a predicate.
    {0 Examples}
    {[
      let x = Some 2
      let () = assert (Option.is_some_and (fun x -> x > 1) x)
      let x = Some 0
      let () = assert (not (Option.is_some_and (fun x -> x > 1) x))
      let x = None
      let () = assert (not (Option.is_some_and (fun x -> x > 1)))
    ]} *)

val filter : ('a -> bool) -> 'a t -> 'a t
val unwrap_or_else : (unit -> 'a) -> 'a t -> 'a
val unwrap_or : 'a -> 'a t -> 'a

val unwrap : 'a option -> 'a
(** Alias for [Option.get]. [unwrap o] is [v] if [o] is [Some v] and raise
    otherwise.

    @raise Invalid_argument if [o] is [None]. *)

val or_else : (unit -> 'a) -> 'a t -> 'a
val or_ : 'a -> 'a t -> 'a
val ok_or_else : (unit -> ('a, 'b) result) -> 'a t -> ('a, 'b) result
val ok_or : 'a -> 'b t -> ('b, 'a) result
val map_or : 'a -> ('b -> 'a) -> 'b t -> 'a
val is_none_or : ('a -> bool) -> 'a t -> bool
val expect : string -> 'a t -> 'a
val and_then : ('a -> 'b t) -> 'a t -> 'b t
val and_ : 'a t -> 'b t -> 'a t
