include String

let explode s =
  let rec loop i l =
    if i < 0 then l
    else
      (* i >= 0 && i < length s *)
      loop (i - 1) (unsafe_get s i :: l)
  in
  loop (String.length s - 1) []

let to_list = explode

let chop ?(l = 1) ?(r = 1) s =
  if l < 0 then
    invalid_arg
      "String.chop: number of characters to chop on the left is negative";
  if r < 0 then
    invalid_arg
      "String.chop: number of characters to chop on the right is negative";
  let slen = length s in
  if slen < l + r then "" else sub s l (slen - l - r)

let find_from str pos sub =
  let len = length str in
  let sublen = length sub in
  if pos < 0 || pos > len then invalid_arg "String.find_from";
  if sublen = 0 then pos
  else
    let rec find ~str ~sub i =
      if i > len - sublen then raise Not_found
      else
        let rec loop ~str ~sub i j =
          if j = sublen then i
          else if unsafe_get str (i + j) <> unsafe_get sub j then
            find ~str ~sub (i + 1)
          else loop ~str ~sub i (j + 1)
        in
        loop ~str ~sub i 0
    in
    find ~str ~sub pos

let find str sub = find_from str 0 sub

let split str ~by:sep =
  let p = find str sep in
  let len = length sep in
  let slen = length str in
  (sub str 0 p, sub str (p + len) (slen - p - len))

let ends_with str p =
  let el = length p and sl = length str in
  let diff = sl - el in
  if diff < 0 then false
  else
    let rec loop str p diff i =
      if i = el then true
      else if unsafe_get str (diff + i) <> unsafe_get p i then false
      else loop str p diff (i + 1)
    in
    loop str p diff 0

let split_on_string_comp ?(on_empty = [ "" ]) ~by:sep s =
  if s = "" then on_empty
  else if sep = "" then
    invalid_arg "String.split_on_string: empty sep not allowed"
  else
    (* str is not empty *)
    let len = String.length s in
    let seplen = String.length sep in
    let rec loop acc curr =
      if curr = len then List.rev ("" :: acc)
      else
        let i_opt = try Some (find_from s curr sep) with Not_found -> None in
        match i_opt with
        | Some i ->
            let tok = sub s curr (i - curr) in
            let next = i + seplen in
            loop (tok :: acc) next
        | None ->
            let rest = sub s curr (len - curr) in
            List.rev (rest :: acc)
    in
    loop [] 0

let split_on_string ~by str = split_on_string_comp ~by str

let split_on_char sep str =
  if str = "" then [ "" ]
  else
    let rec loop acc ofs limit =
      if ofs < 0 then sub str 0 limit :: acc
      else if unsafe_get str ofs <> sep then loop acc (ofs - 1) limit
      else loop (sub str (ofs + 1) (limit - ofs - 1) :: acc) (ofs - 1) ofs
    in
    let len = length str in
    loop [] (len - 1) len

let lines str = split_on_char '\n' str
