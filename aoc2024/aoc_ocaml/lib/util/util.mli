type solution = Solution.solution
type part = Solution.part

val map_tuple : ('a -> 'b) -> 'a * 'a -> 'b * 'b
val read_to_lines : string -> string list
val read_to_string : string -> string
val split : char -> string -> string list
val validate : (unit -> int) -> int -> string -> part -> float
