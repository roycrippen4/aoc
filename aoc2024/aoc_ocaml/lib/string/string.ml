include String

let rec char_list_mem l (c : char) =
  match l with [] -> false | hd :: tl -> Char.equal hd c || char_list_mem tl c

let split_gen str ~on =
  let is_delim =
    match on with
    | `char c' -> fun c -> Char.equal c c'
    | `char_list l -> fun c -> char_list_mem l c
  in
  let len = length str in
  let rec loop acc last_pos pos =
    if pos = -1 then sub str 0 last_pos :: acc
    else if is_delim str.[pos] then
      let pos1 = pos + 1 in
      let sub_str = sub str pos1 (last_pos - pos1) in
      loop (sub_str :: acc) pos (pos - 1)
    else loop acc last_pos (pos - 1)
  in
  loop [] len (len - 1)

let split_on_chars str ~on:chars = split_gen str ~on:(`char_list chars)

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

let split_once str ~by:sep =
  let p = find str sep in
  let len = length sep in
  let slen = length str in
  (sub str 0 p, sub str (p + len) (slen - p - len))

let implode chars = List.to_seq chars |> of_seq

let split_at str ~idx =
  let rec loop left right pos = function
    | [] -> (implode (List.rev left), implode (List.rev right))
    | char :: rest ->
        if pos >= idx then loop left (char :: right) (succ pos) rest
        else loop (char :: left) right (succ pos) rest
  in

  let len = length str in
  if idx >= len then (str, "")
  else if idx < 0 then ("", str)
  else loop [] [] 0 (explode str)

let%test _ =
  let s = "Per Martin-Löf" in
  let first, last = split_at s ~idx:3 in
  first = "Per" && last = " Martin-Löf"

let split_whitespace str : string list =
  let is_whitespace = function
    | ' ' | '\t' | '\r' | '\n' -> true
    | _ -> false
  in

  let len = String.length str in

  let rec skip_from idx : int =
    if idx >= len then idx
    else if is_whitespace str.[idx] then skip_from (idx + 1)
    else idx
  in

  let rec find_word_end idx : int =
    if idx >= len then idx
    else if not (is_whitespace str.[idx]) then find_word_end (idx + 1)
    else idx
  in

  let rec loop i strs : string list =
    let word_start = skip_from i in
    if word_start >= len then List.rev strs
    else
      let word_end = find_word_end word_start in
      let word = sub str word_start (word_end - word_start) in
      loop word_end (word :: strs)
  in

  if len = 0 then [] else loop 0 []

let%test _ =
  split_whitespace "hello world foo bar" = [ "hello"; "world"; "foo"; "bar" ]

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
