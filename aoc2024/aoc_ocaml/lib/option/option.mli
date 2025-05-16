(** {1 Option — nullable / optional values}

    A value of type ['a Option.t] represents the presence or absence of a value
    of type ['a].

    {[
      Some 3          (* a present value  *)
      None            (* an absent value *)
    ]}

    Options are ubiquitous:

    - as return types of partial functions,
    - as fields that may be “unset”,
    - as arguments with sensible defaults,
    - as a safer replacement for nullable pointers.

    Most functions in this module are zero-allocation wrappers around simple
    pattern-matches, designed to keep call-sites readable and expressive. *)

(** The option type itself (alias to the stdlib definition). Either [{!None}] or
    [{!Some} v]. *)
type 'a t = 'a option = None | Some of 'a  (** @canonical Option.t *)

(*------------------------------------------------------------------*)
(** {1 Construction} *)

val none : 'a option
(** [none] is a synonym for [None].

    {[
      assert (Option.none = None)
    ]} *)

val some : 'a -> 'a option
(** [some v] is [Some v].

    {[
      assert (Option.some 42 = Some 42)
    ]} *)

(*------------------------------------------------------------------*)
(** {1 Inspection / extraction} *)

val is_none : 'a option -> bool
(** [is_none o] is [true] iff [o] is [None].

    {[
      assert (Option.is_none None);
      assert (not (Option.is_none (Some 0)))
    ]} *)

val is_some : 'a option -> bool
(** [is_some o] is [true] iff [o] is [Some _].

    {[
      assert (Option.is_some (Some "x"));
      assert (not (Option.is_some None))
    ]} *)

val is_some_and : ('a -> bool) -> 'a option -> bool
(** [is_some_and p o] is [true] when [o] is [Some v] and [p v] holds.

    {[
      assert (Option.is_some_and (( > ) 1) (Some 3));
      assert (not (Option.is_some_and (( > ) 1) (Some 0)));
      assert (not (Option.is_some_and (( > ) 1) None))
    ]} *)

val value : 'a option -> default:'a -> 'a
(** [value o ~default] returns the contained value or [default].

    {[
      assert (Option.value (Some 5) ~default:0 = 5);
      assert (Option.value None ~default:0 = 0)
    ]} *)

val get : 'a option -> 'a
(** [get o] unconditionally extracts the value, raising if absent.

    @raise Invalid_argument if [o] is [None].

    {[
      assert (Option.get (Some "ok") = "ok")
      (* Option.get None  (* raises Invalid_argument *) *)
    ]} *)

val expect : string -> 'a option -> 'a
(** [expect msg o] behaves like {!get} but raises with a user message.

    {[
      assert (Option.expect "impossible" (Some 1) = 1)
    ]} *)

(*------------------------------------------------------------------*)
(** {1 Transformation (map / bind / filter …)} *)

val map : f:('a -> 'b) -> 'a t -> 'b t
(** [map ~f o] is [None] if [o] is [None] and [Some (f v)] otherwise.

    {[
      assert (Option.map ~f:String.length (Some "abc") = Some 3);
      assert (Option.map ~f:String.length None = None)
    ]} *)

val bind : 'a option -> ('a -> 'b option) -> 'b option
(** Left-to-right monadic bind. [bind o f] is [f v] when [o = Some v].

    {[
      let halve n = if n mod 2 = 0 then Some (n / 2) else None in
      assert (Option.bind (Some 4) halve = Some 2);
      assert (Option.bind (Some 3) halve = None)
    ]} *)

val and_then : ('a -> 'b t) -> 'a t -> 'b t
(** Alias for {!bind}, written in pipeline order.

    {[
      let open Option in
      assert (and_then (fun x -> Some (x + 1)) (Some 1) = Some 2)
    ]} *)

val filter : ('a -> bool) -> 'a t -> 'a t
(** [filter p o] keeps the value only when the predicate holds.

    {[
      assert (Option.filter (fun x -> x > 0) (Some 3) = Some 3);
      assert (Option.filter (fun x -> x > 0) (Some (-1)) = None)
    ]} *)

val map_or : 'b -> ('a -> 'b) -> 'a t -> 'b
(** [map_or default f o] returns [f v] when [o = Some v] and [default]
    otherwise.

    {[
      assert (Option.map_or 0 String.length (Some "abc") = 3);
      assert (Option.map_or 0 String.length None = 0)
    ]} *)

val unwrap_or : 'a -> 'a t -> 'a
(** [unwrap_or default o] is {!value} with positional arguments.

    {[
      assert (Option.unwrap_or 99 None = 99);
      assert (Option.unwrap_or 99 (Some 42) = 42)
    ]} *)

val unwrap_or_else : (unit -> 'a) -> 'a t -> 'a
(** Lazily‐computed default; the thunk is called only when needed.

    {[
      let expensive () =
        print_endline "run";
        0
      in
      assert (Option.unwrap_or_else expensive (Some 1) = 1)
      (* thunk skipped *)
    ]} *)

val unwrap : 'a option -> 'a
(** Alias for {!get}. *)

(*------------------------------------------------------------------*)
(** {1 Combination / boolean logic} *)

val or_ : 'a -> 'a t -> 'a

(** [or_ a b] returns [a] if it is [Some _] else [b].

    {[
      assert (Option.or_ (Some 1) (Some 2) = Some 1);
      assert (Option.or_ None (Some 2) = Some 2);
      assert (Option.or_ None None = None)
    ]} *)

val or_else : (unit -> 'a) -> 'a t -> 'a

(** Lazy version of {!or_}. The supplier is evaluated only if needed.

    {[
      let default () = Some 0 in
      assert (Option.or_else default (Some 5) = Some 5)
    ]} *)

val and_ : 'a t -> 'b t -> 'a t
(** [and_ a b] returns [b] if [a] is [Some _] else [None] (mirrors {b Rust’s}
    [Option::and]).

    {[
      assert (Option.and_ (Some 1) (Some "x") = Some "x");
      assert (Option.and_ None (Some "x") = None)
    ]} *)

val is_none_or : ('a -> bool) -> 'a t -> bool
(** [is_none_or p o] is [true] for [None] and for [Some v] if [p v] holds
    (¬present ∨ predicate).

    {[
      assert (Option.is_none_or (( = ) 0) (Some 0));
      assert (Option.is_none_or (( = ) 0) None);
      assert (not (Option.is_none_or (( = ) 0) (Some 1)))
    ]} *)

(*------------------------------------------------------------------*)
(** {1 Folding / iteration} *)

val fold : none:'b -> some:('a -> 'b) -> 'a option -> 'b
(** Catamorphism over an option.

    {[
      assert (Option.fold ~none:0 ~some:(fun x -> x) (Some 5) = 5);
      assert (Option.fold ~none:0 ~some:(fun x -> x) None = 0)
    ]} *)

val iter : ('a -> unit) -> 'a option -> unit
(** [iter f o] calls [f] on the value for its side-effect.

    {[
      let r = ref 0 in
      Option.iter (fun x -> r := !r + x) (Some 3);
      assert (!r = 3)
    ]} *)

(*------------------------------------------------------------------*)
(** {1 Conversion} *)

val join : 'a option option -> 'a option
(** Flattens one level of option nesting.

    {[
      assert (Option.join (Some (Some 3)) = Some 3);
      assert (Option.join (Some None) = None)
    ]} *)

val to_result : none:'e -> 'a option -> ('a, 'e) result
(** Convert to a result, using [none] as the error.

    {[
      assert (Option.to_result ~none:"err" (Some 1) = Ok 1);
      assert (Option.to_result ~none:"err" None = Error "err")
    ]} *)

val ok_or : 'e -> 'a option -> ('a, 'e) result
(** Infix-friendly synonym for {!to_result}, argument order flipped.

    {[
      assert (Option.ok_or "err" (Some 9) = Ok 9)
    ]} *)

val ok_or_else : (unit -> ('a, 'e) result) -> 'a option -> ('a, 'e) result
(** Lazy error supplier.

    {[
      assert (Option.ok_or_else (fun () -> Error "boom") (Some 2) = Ok 2)
    ]} *)

val to_list : 'a option -> 'a list
(** [to_list o] is [[]] for [None] and [[v]] for [Some v].

    {[
      assert (Option.to_list (Some 7) = [ 7 ]);
      assert (Option.to_list None = [])
    ]} *)

val to_seq : 'a option -> 'a Seq.t
(** Same as {!to_list} but as a sequence.

    {[
      assert (Seq.length (Option.to_seq (Some 1)) = 1)
    ]} *)

(*------------------------------------------------------------------*)
(** {1 Comparison predicates} *)

val equal : ('a -> 'a -> bool) -> 'a option -> 'a option -> bool
(** Structural equality with user-supplied element predicate.

    {[
      assert (Option.equal ( = ) (Some 1) (Some 1));
      assert (not (Option.equal ( = ) (Some 1) None))
    ]} *)

val compare : ('a -> 'a -> int) -> 'a option -> 'a option -> int
(** Total ordering with [None < Some _].

    {[
      assert (Option.compare compare None (Some 0) < 0);
      assert (Option.compare compare (Some 0) (Some 1) < 0)
    ]} *)

(*------------------------------------------------------------------*)
(** {1 Applicative & infix helpers} *)

val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
(** Infix alias for {!map} (pronounced “bind-map”).

    {[
      assert (Some 3 >>| succ = Some 4)
    ]} *)

val ( <*> ) : ('a -> 'b) t -> 'a t -> 'b t
(** Applicative apply.

    {[
      assert (Some succ <*> Some 3 = Some 4);
      assert (Some succ <*> None = None)
    ]} *)

val ( *> ) : 'a t -> 'b t -> 'b t
(** Sequence, keep right.

    {[
      assert (Some 1 *> Some 2 = Some 2);
      assert (None *> Some 2 = None)
    ]} *)

val ( <* ) : 'a t -> 'b t -> 'a t
(** Sequence, keep left.

    {[
      assert (Some 1 <* Some 2 = Some 1);
      assert (Some 1 <* None = None)
    ]} *)
