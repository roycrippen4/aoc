open Format

let pp_int fmt x = fprintf fmt "%d" x
let pp_char fmt c = fprintf fmt "%c" c
let pp_string fmt x = fprintf fmt "%s" x

let _pp_int_list fmt lst =
  pp_open_box fmt 2;
  fprintf fmt "[ @,";

  let rec loop = function
    | [] -> ()
    | [ x ] -> pp_int fmt x
    | x :: xs ->
        fprintf fmt "%d; @," x;
        loop xs
  in
  loop lst;
  fprintf fmt " ]";
  pp_close_box fmt ()

let _pp_string_list fmt lst =
  pp_open_box fmt 2;
  fprintf fmt "[ @,";

  let rec loop = function
    | [] -> ()
    | [ x ] -> pp_string fmt x
    | x :: xs ->
        fprintf fmt "%s; @," x;
        loop xs
  in

  loop lst;
  fprintf fmt " ]";
  pp_close_box fmt ()

let _pp_array pp_elt fmt arr =
  Format.fprintf fmt "[|";
  Array.iteri
    (fun i x ->
      if i > 0 then Format.fprintf fmt "; ";
      pp_elt fmt x)
    arr;
  Format.fprintf fmt "|]"

let pp_int_list lst = printf "%a@." _pp_int_list lst
let pp_int_list_list lst = List.iter pp_int_list lst
let pp_string_list lst = printf "%a@." _pp_string_list lst
let pp_string_list_list lst = List.iter pp_string_list lst
let pp_array pp_elt arr = printf "%a\n" (_pp_array pp_elt) arr
