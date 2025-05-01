module type OrderedType = sig
  type t

  val compare : t -> t -> int
end

module Make (Ord : OrderedType) = struct
  type t = { mutable data : Ord.t array; mutable size : int }

  let create () = { data = [||]; size = 0 }
  let length h = h.size
  let is_empty h = h.size = 0
  let parent i = (i - 1) lsr 1
  let left i = (i lsl 1) + 1

  let swap a i j =
    let tmp = a.(i) in
    a.(i) <- a.(j);
    a.(j) <- tmp

  let ensure_capacity h =
    if h.size = Array.length h.data then (
      let new_cap = if h.size = 0 then 4 else h.size * 2 in
      let a = Array.make new_cap h.data.(0) in
      Array.blit h.data 0 a 0 h.size;
      h.data <- a)

  let rec sift_up a i =
    if i <> 0 then
      let p = parent i in
      if Ord.compare a.(p) a.(i) < 0 then (
        swap a i p;
        sift_up a p)

  let rec sift_down a size i =
    let l = left i in
    if l < size then
      let r = l + 1 in
      let max_i = if r < size && Ord.compare a.(r) a.(l) > 0 then r else l in
      if Ord.compare a.(i) a.(max_i) < 0 then (
        swap a i max_i;
        sift_down a size max_i)

  let push h v =
    if h.size = 0 then (
      h.data <- [| v |];
      h.size <- 1)
    else (
      ensure_capacity h;
      h.data.(h.size) <- v;
      sift_up h.data h.size;
      h.size <- h.size + 1)

  let peek h = if h.size = 0 then None else Some h.data.(0)

  let pop h =
    if h.size = 0 then None
    else
      let v = h.data.(0) in
      h.size <- h.size - 1;
      h.data.(0) <- h.data.(h.size);
      sift_down h.data h.size 0;
      Some v

  let of_list lst =
    let h = create () in
    List.iter (push h) lst;
    h
end
