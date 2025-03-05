type solution = Solution.solution
type part = Solution.part

let ( /.. ) = General.( /.. )
let ( /..= ) = General.( /..= )
let map_tuple = General.map_tuple
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
let destructure_list_pair = General.destructure_list_pair
