type solution = Solution.solution
type part = Solution.part

val map_tuple : ('a -> 'b) -> 'a * 'a -> 'b * 'b
val read_to_lines : string -> string list
val read_to_string : string -> string
val split_to_string : char -> string -> string list
val split_to_int : char -> string -> int list
val validate : (unit -> int) -> int -> string -> part -> float
val windows : int -> 'a list -> 'a list list
val ( /.. ) : int -> int -> int list
val ( /..= ) : int -> int -> int list
