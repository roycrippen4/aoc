(** Helpers for 2-tuples (pairs). All functions are left-to-right when order
    matters. *)

val bimap : f1:('a -> 'b) -> f2:('c -> 'd) -> 'a * 'c -> 'b * 'd
(** [bimap ~f1 ~f2 (x, y)] applies two {e different} unary functions to the two
    slots of a pair, returning [(f1 x, f2 y)].

    {[
      let r =
        bimap ~f1:String.length ~f2:String.uppercase_ascii ("abc", "de")
      in
      assert (r = (3, "DE"))
    ]} *)

val map : ('a -> 'b) -> 'a * 'a -> 'b * 'b
(** [map f (x, y)] returns [(f x, f y)] — it applies the same unary function to
    both components of the pair.

    {[
      assert (map succ (1, 1) = (2, 2))
    ]} *)

val map_snd : ('a -> 'b) -> 'c * 'a -> 'c * 'b
(** [map_snd f (x, y)] returns [(x, f y)] — it applies [f] to the {e second}
    component and leaves the first untouched.

    {[
      assert (map_snd succ (10, 1) = (10, 2))
    ]} *)

val map_fst : ('a -> 'b) -> 'a * 'c -> 'b * 'c
(** [map_fst f (x, y)] returns [(f x, y)] — it applies [f] to the {e first}
    component and leaves the second untouched.

    {[
      assert (map_fst succ (1, "foo") = (2, "foo"))
    ]} *)

val map2 : ('a -> 'b -> 'c) -> 'a * 'a -> 'b * 'b -> 'c * 'c
(** [map2 f (a1, a2) (b1, b2)] returns [(f a1 b1, f a2 b2)].

    It “lifts” a binary function so that it is applied {e component-wise} to two
    pairs. The name mirrors [List.map2] / [Option.map2].

    {[
      assert (map2 ( + ) (1, 2) (10, 20) = (11, 22))
    ]} *)

val swap : 'a * 'b -> 'b * 'a
(** [swap (x, y)] returns [(y, x)].

    {[
      assert (swap (1, "a") = ("a", 1))
    ]} *)

val iter : ('a -> unit) -> 'a * 'a -> unit
(** [iter f (x, y)] is equivalent to [f x; f y]. Useful for side effects.

    {[
      let r = ref 0 in
      iter (fun x -> r := !r + x) (3, 4);
      assert (!r = 7)
    ]} *)

val fold : ('acc -> 'a -> 'acc) -> 'a * 'a -> 'acc -> 'acc
(** [fold f (x, y) acc] returns [f (f acc x) y].

    It threads an accumulator through the two elements from left to right.

    {[
      let sum = fold (fun acc x -> acc + x) (3, 4) 0 in
      assert (sum = 7)
    ]} *)

val to_list : 'a * 'a -> 'a list
(** [to_list (x, y)] is [[x; y]]. Handy for quick interoperability with
    list-based APIs or for testing.

    {[
      assert (to_list (1, 2) = [ 1; 2 ])
    ]} *)

val of_list_exn : 'a list -> 'a * 'a
(** [of_list_exn lst] converts a list of length {e exactly two} to a pair.

    - Returns the pair if [lst] is [[x; y]].

    @raise Invalid_argument
      - if the list is empty
      - if the list is a singleton
      - if the list is longer than two.

    {[
      assert (of_list_exn [ 1; 2 ] = (1, 2))
    ]} *)

val of_list : 'a list -> ('a * 'a) option
(** [of_list lst] is [Some (x, y)] when [lst] is [[x; y]], and [None] for any
    other length. A safe, option-returning variant of [of_list_exn].

    {[
      assert (of_list [ 1; 2 ] = Some (1, 2))
    ]} *)

val curry : ('a * 'b -> 'c) -> 'a -> 'b -> 'c
(** [curry f x y] calls [f] with the pair [(x, y)]. It converts a
    {e tuple-taking} function into the usual curried style.

    {[
      let add_pair (x, y) = x + y in
      let add = curry add_pair in
      assert (add 3 4 = 7)
    ]} *)

val uncurry : ('a -> 'b -> 'c) -> 'a * 'b -> 'c
(** [uncurry f (x, y)] calls [f x y]. It converts a curried two-argument
    function into one that accepts a pair.

    {[
      let add x y = x + y in
      let add_pair = uncurry add in
      assert (add_pair (3, 4) = 7)
    ]} *)

val zip : 'a * 'b -> 'c * 'd -> ('a * 'c) * ('b * 'd)
(** [zip (a1, b1) (a2, b2)] groups the first components together and the second
    components together: it returns [((a1, a2), (b1, b2))].

    {[
      assert (zip (1, "one") (2, "two") = ((1, 2), ("one", "two")))
    ]} *)

val unzip : ('a * 'c) * ('b * 'd) -> ('a * 'b) * ('c * 'd)
(** [unzip ((a1, a2), (b1, b2))] performs the inverse of [zip], returning
    [((a1, b1), (a2, b2))].

    {[
      assert (unzip ((1, 2), ("one", "two")) = ((1, "one"), (2, "two")))
    ]} *)
