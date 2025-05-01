(** {1 Functorised binary max-heap}

    The element with the **largest** result of [Ord.compare] is considered the
    highest-priority one and will be returned first by {!pop} / {!peek}. The
    interface mirrors the {!module:Stdlib.Set.Make} functor: you provide a
    module with an element type and a total ordering, and you obtain a heap
    specialised to that ordering. *)

(** Signature of the ordering required by the heap. Identical to
    {!module-type:Stdlib.Set.OrderedType}. *)
module type OrderedType = sig
  type t
  (** Type of elements stored in the heap. *)

  val compare : t -> t -> int
  (** [compare a b] must return a negative integer if [a] is smaller than [b],
      [0] if they are equal, and a positive integer if [a] is greater than [b].
  *)
end

(** {2 Heap functor} *)
module Make (Ord : OrderedType) : sig
  type t
  (** Abstract type of heaps whose elements are of type [Ord.t]. *)

  (** {3 Construction} *)

  val create : unit -> t
  (** An empty heap. *)

  val of_list : Ord.t list -> t
  (** Build a heap containing all elements of the list. Takes \(O(n \log n)\)
      time. *)

  (** {3 Queries} *)

  val length : t -> int
  (** Number of elements currently stored. *)

  val is_empty : t -> bool
  (** [true] iff the heap contains no elements. *)

  val peek : t -> Ord.t option
  (** Return the maximum element without removing it, or [None] if the heap is
      empty. Runs in \(O(1)\). *)

  (** {3 Updates} *)

  val push : t -> Ord.t -> unit
  (** [push h v] inserts [v] into [h]. Amortised \(O(\log n)\). *)

  val pop : t -> Ord.t option
  (** Removes and returns the maximum element, or [None] if the heap is empty.
      Runs in \(O(\log n)\). *)
end
