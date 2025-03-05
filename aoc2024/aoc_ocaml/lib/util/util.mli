type solution = Solution.solution
type part = Solution.part

val ( /.. ) : int -> int -> int list
val ( /..= ) : int -> int -> int list
val destructure_list_pair : 'a list -> 'a * 'a
val map_tuple : ('a -> 'b) -> 'a * 'a -> 'b * 'b
val pp_int_list : int list -> unit
val pp_int_list_list : int list list -> unit
val pp_string_list : string list -> unit
val pp_string_list_list : string list list -> unit
val read_to_lines : string -> string list
val read_to_string : string -> string
val slice : string -> int -> int -> string
val split_to_int : char -> string -> int list
val split_to_string : char -> string -> string list
val validate : (unit -> int) -> int -> string -> part -> float
val windows : int -> 'a list -> 'a list list
