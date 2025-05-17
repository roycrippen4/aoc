open Util
module S = String

module H = struct
  include Hashtbl

  let of_list lst =
    let tbl = create (List.length lst) in
    List.iter (Tuple.uncurry (add tbl)) lst;
    tbl

  let keys tbl = to_seq_keys tbl |> List.of_seq
end

module Op = struct
  type t = OR | XOR | AND

  let to_string = function OR -> "OR" | XOR -> "XOR" | AND -> "AND"

  let of_string = function
    | "OR" -> OR
    | "XOR" -> XOR
    | "AND" -> AND
    | _ -> assert false

  let apply a op b =
    match op with OR -> a lor b | XOR -> a lxor b | AND -> a land b
end

module Expr = struct
  type t = { lhs : string; rhs : string; op : Op.t }

  let to_string { lhs; rhs; op } =
    Printf.sprintf "%s %s %s" lhs (Op.to_string op) rhs

  let of_list = function
    | [ lhs; op; rhs ] -> { lhs; op = Op.of_string op; rhs }
    | _ -> assert false

  let of_string s = S.split_on_char ' ' s |> of_list
  let parse_fst tup = Tuple.map_fst of_string tup |> Tuple.swap
  let to_list expr = List.sort compare [ expr.lhs; expr.rhs ]
end

let parse_undefined ls =
  let split_map s = S.split ~by:" -> " s |> Expr.parse_fst in
  ls |> List.map (fun s -> split_map s) |> H.of_list

let parse_defined ls =
  List.map (S.split ~by:": " >> Tuple.map_snd int_of_string) ls |> H.of_list

let defined, operations =
  read_to_string "/home/roy/dev/aoc/aoc2024/data/day24/data.txt"
  |> S.trim |> S.split ~by:"\n\n" |> Tuple.map S.lines
  |> Tuple.bimap ~f1:parse_defined ~f2:parse_undefined

let zs =
  let aux k v acc = if k.[0] = 'z' then (k, v) :: acc else acc in
  let cmp a b = String.compare (fst a) (fst b) in
  H.fold aux operations [] |> List.sort cmp |> List.map snd

let rec define arg =
  match H.find_opt defined arg with
  | Some value -> value
  | None ->
      let { lhs; rhs; op } : Expr.t = H.find operations arg in
      let result = Op.apply (define lhs) op (define rhs) in
      H.add defined arg result;
      result

let solve1 () =
  let eval (e : Expr.t) i =
    let bit = Op.apply (define e.lhs) e.op (define e.rhs) in
    bit * pow 2 i
  in

  let accumulate (i, acc) (expr : Expr.t) = (succ i, acc + eval expr i) in
  zs |> List.fold_left accumulate (0, 0) |> snd

(* part 2 *)

let make_wire c n = Printf.sprintf "%c%02d" c n
let make_wires n = [ make_wire 'x' n; make_wire 'y' n ]

let is_ok_xor wire n =
  match H.find_opt operations wire with
  | None -> false
  | Some expr when expr.op <> Op.XOR -> false
  | Some expr -> Expr.to_list expr = make_wires n

let rec is_ok_carry wire n =
  let is_ok_direct_carry wire n =
    match H.find_opt operations wire with
    | None -> false
    | Some expr when expr.op <> Op.AND -> false
    | Some expr -> Expr.to_list expr = make_wires n
  in

  let is_ok_recarry wire n =
    match H.find_opt operations wire with
    | None -> false
    | Some expr when expr.op <> Op.AND -> false
    | Some expr ->
        (is_ok_xor expr.lhs n && is_ok_carry expr.rhs n)
        || (is_ok_xor expr.rhs n && is_ok_carry expr.lhs n)
  in

  match H.find_opt operations wire with
  | None -> false
  | Some expr when n = 1 && expr.op <> Op.AND -> false
  | Some expr when n = 1 -> Expr.to_list expr = [ "x00"; "y00" ]
  | Some expr when expr.op <> Op.OR -> false
  | Some expr ->
      let n = n - 1 in
      (is_ok_direct_carry expr.lhs n && is_ok_recarry expr.rhs n)
      || (is_ok_direct_carry expr.rhs n && is_ok_recarry expr.lhs n)

let is_ok_z wire n =
  match H.find_opt operations wire with
  | None -> false
  | Some expr when expr.op <> Op.XOR -> false
  | Some expr when n = 0 -> Expr.to_list expr = [ "x00"; "y00" ]
  | Some expr ->
      (is_ok_xor expr.lhs n && is_ok_carry expr.rhs n)
      || (is_ok_xor expr.rhs n && is_ok_carry expr.lhs n)

let progress start =
  let ok_idx i = not (is_ok_z (make_wire 'z' i) i) in
  Seq.ints start |> Seq.find ok_idx |> Option.get

let swap_wires a b =
  let v_a = Hashtbl.find operations a in
  let v_b = Hashtbl.find operations b in
  Hashtbl.replace operations a v_b;
  Hashtbl.replace operations b v_a

let get_swaps n_swaps =
  let exception Break of int * string list in
  let wires = H.keys operations in

  let rec loop_inner baseline combos best current =
    match combos with
    | (a, b) :: rest ->
        let curr = List.sort String.compare [ a; b ] in
        swap_wires a b;
        let local_best = progress best in
        if local_best > baseline then raise (Break (max best local_best, curr));
        swap_wires a b;
        loop_inner baseline rest best curr (* curr becomes new current *)
    | [] -> (best, current)
  in

  let rec loop swaps n best current =
    if n = 0 then swaps
    else
      let baseline = progress best in
      let cs = combos wires in
      let best, curr =
        try loop_inner baseline cs best current with Break (b, c) -> (b, c)
      in
      loop (curr :: swaps) (pred n) best curr
  in

  loop [] n_swaps 0 [ ""; "" ]
  |> List.flatten
  |> List.sort_uniq String.compare
  |> String.concat ","

let solve2 () =
  get_swaps 4 |> String.fold_left (fun acc c -> acc + int_of_char c) 0

(* exports *)

let part1 () = validate solve1 42883464055378 "24" One
let part2 () = validate solve2 2625 "24" Two
let solution : solution = { part1; part2 }

(* tests *)
