type 'a t = 'a option = None | Some of 'a

let and_ opt_b = function Some _ -> opt_b | None -> None
let and_then f = function Some v -> f v | None -> None
let expect msg = function Some v -> v | None -> failwith msg
let is_none_or f = function Some v -> f v | None -> true
let is_some_and f = function Some v -> f v | None -> false
let map_or default f = function Some v -> f v | None -> default
let ok_or err = function Some v -> Ok v | None -> Error err
let ok_or_else err = function Some v -> Ok v | None -> err ()
let or_ alt = function Some v -> v | None -> alt
let or_else f = function Some v -> v | None -> f ()
let unwrap = function Some v -> v | None -> invalid_arg "option is None"
let unwrap_or default = function Some v -> v | None -> default
let unwrap_or_else f = function Some v -> v | None -> f ()
let filter p = function Some v -> if p v then Some v else None | None -> None
let none = None
let some v = Some v
let value o ~default = match o with Some v -> v | None -> default
let get = function Some v -> v | None -> invalid_arg "option is None"
let bind o f = match o with None -> None | Some v -> f v
let join = function Some o -> o | None -> None
let map ~f o = match o with None -> None | Some v -> Some (f v)
let fold ~none ~some = function Some v -> some v | None -> none
let iter f = function Some v -> f v | None -> ()
let is_none = function None -> true | Some _ -> false
let is_some = function None -> false | Some _ -> true

let equal eq o0 o1 =
  match (o0, o1) with
  | Some v0, Some v1 -> eq v0 v1
  | None, None -> true
  | _ -> false

let compare cmp o0 o1 =
  match (o0, o1) with
  | Some v0, Some v1 -> cmp v0 v1
  | None, None -> 0
  | None, Some _ -> -1
  | Some _, None -> 1

let to_result ~none = function None -> Error none | Some v -> Ok v
let to_list = function None -> [] | Some v -> [ v ]
let to_seq = function None -> Seq.empty | Some v -> Seq.return v

(* operators *)
let ( >>| ) t f = map ~f t

(* applicative *)
let ( *> ) a b = match (a, b) with Some _, Some y -> Some y | _ -> None
let ( <* ) a b = match (a, b) with Some x, Some _ -> Some x | _ -> None

let ( <*> ) f_opt x_opt =
  match (f_opt, x_opt) with Some f, Some x -> Some (f x) | _ -> None
