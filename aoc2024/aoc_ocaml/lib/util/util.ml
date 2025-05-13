type solution = Solution.solution
type part = Solution.part

let ( /.. ) = Operators.( /.. )
let ( /..= ) = Operators.( /..= )
let ( += ) = Operators.( += )
let ( +=. ) = Operators.( +=. )
let ( *= ) = Operators.( *= )
let ( *=. ) = Operators.( *=. )
let ( -= ) = Operators.( -= )
let ( -=. ) = Operators.( -=. )
let ( /= ) = Operators.( /= )
let ( /=. ) = Operators.( /=. )
let ( %= ) = Operators.( %= )
let ( let* ) = Operators.( let* )
let ( /+ ) = Operators.( /+ )
let ( /- ) = Operators.( /- )
let ( ** ) = Operators.( ** )

(* Function application / Combinatory logic *)
let ( >> ) = Operators.( >> )
let ( % ) = Operators.( % )
let ( <$> ) = Operators.( <$> )
let ( <*> ) = Operators.( <*> )

(* *)

let chars = General.chars
let map_tuple = General.map_tuple
let map_tuple2 = General.map_tuple2
let map2_tuple = General.map2_tuple
let flip = General.flip
let pop = General.pop
let pp_char_list = Fmt.pp_char_list
let pp_char_list_list = Fmt.pp_char_list_list
let pp_int_list = Fmt.pp_int_list
let pp_int_list_list = Fmt.pp_int_list_list
let pp_string_list = Fmt.pp_string_list
let pp_string_list_list = Fmt.pp_string_list_list
let read_to_lines = General.read_to_lines
let read_to_string = General.read_to_string
let slice s start finish = String.sub s start (finish - start)
let split_to_int = General.split_to_int
let split_to_string = General.split_to_string
let validate = Solution.validate
let windows = General.windows
let combos = General.combos
let pairs = General.pairs
let char_of_int2 = General.char_of_int2
let int_of_char2 = General.int_of_char2
let pow = General.pow
let range = Operators.range
let range_i = Operators.range_i
let identity x = x

exception Todo of string

let todo () : 'a = raise (Todo "Not yet implemented")
