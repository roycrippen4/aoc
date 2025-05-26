open Util
module S = String

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
end

let keys tbl = Hashtbl.to_seq_keys tbl |> List.of_seq

let hashtbl_of_list lst =
  let tbl = Hashtbl.create (List.length lst) in
  List.iter (Tuple.uncurry (Hashtbl.add tbl)) lst;
  tbl

let parse_undefined ls =
  let split_map s = S.split ~by:" -> " s |> Expr.parse_fst in
  ls |> List.map (fun s -> split_map s) |> hashtbl_of_list

let parse_defined ls =
  List.map (S.split ~by:": " >> Tuple.map_snd int_of_string) ls
  |> hashtbl_of_list

let defined, operations =
  read_to_string "/home/roy/dev/aoc/aoc2024/data/day24/data.txt"
  |> S.trim |> S.split ~by:"\n\n" |> Tuple.map S.lines
  |> Tuple.bimap ~f1:parse_defined ~f2:parse_undefined

let zs =
  let aux k v acc = if k.[0] = 'z' then (k, v) :: acc else acc in
  let cmp a b = String.compare (fst a) (fst b) in
  Hashtbl.fold aux operations [] |> List.sort cmp |> List.map snd

let rec define arg =
  match Hashtbl.find_opt defined arg with
  | Some value -> value
  | None ->
      let { lhs; rhs; op } : Expr.t = Hashtbl.find operations arg in
      let result = Op.apply (define lhs) op (define rhs) in
      Hashtbl.add defined arg result;
      result

let solve1 () =
  let eval (e : Expr.t) i =
    let bit = Op.apply (define e.lhs) e.op (define e.rhs) in
    bit * pow 2 i
  in

  let accumulate (i, acc) expr = (succ i, acc + eval expr i) in
  zs |> List.fold_left accumulate (0, 0) |> snd

(* part 2 *)

type wire = X | Y | Z

let n_bits = 46
let x_wire = Array.init n_bits (fun i -> Printf.sprintf "x%02d" i)
let y_wire = Array.init n_bits (fun i -> Printf.sprintf "y%02d" i)
let z_wire = Array.init n_bits (fun i -> Printf.sprintf "z%02d" i)
let make_wire i = function X -> x_wire.(i) | Y -> y_wire.(i) | Z -> z_wire.(i)
let is_ok_xor_cache = Hashtbl.create 128
let is_ok_carry_cache = Hashtbl.create 128
let is_ok_z_cache = Hashtbl.create 64

let check_base_case (expr : Expr.t) =
  (expr.lhs = "x00" && expr.rhs = "y00")
  || (expr.lhs = "y00" && expr.rhs = "x00")

let rec is_ok_xor wire n =
  match Hashtbl.find_opt is_ok_xor_cache (wire, n) with
  | Some res -> res
  | None ->
      let res =
        match Hashtbl.find_opt operations wire with
        | None -> false
        | Some expr when expr.op <> Op.XOR -> false
        | Some expr ->
            let xw = make_wire n X in
            let yw = make_wire n Y in
            (expr.lhs = xw && expr.rhs = yw) || (expr.lhs = yw && expr.rhs = xw)
      in
      Hashtbl.add is_ok_xor_cache (wire, n) res;
      res

and is_ok_carry wire n =
  match Hashtbl.find_opt is_ok_carry_cache (wire, n) with
  | Some res -> res
  | None ->
      let is_ok_direct_carry wire_inner n_inner =
        match Hashtbl.find_opt operations wire_inner with
        | None -> false
        | Some expr when expr.op <> Op.AND -> false
        | Some expr ->
            let xw = make_wire n_inner X in
            let yw = make_wire n_inner Y in
            (expr.lhs = xw && expr.rhs = yw) || (expr.lhs = yw && expr.rhs = xw)
      and is_ok_recarry wire_inner n_inner =
        match Hashtbl.find_opt operations wire_inner with
        | None -> false
        | Some expr when expr.op <> Op.AND -> false
        | Some expr ->
            (is_ok_xor expr.lhs n_inner && is_ok_carry expr.rhs n_inner)
            || (is_ok_xor expr.rhs n_inner && is_ok_carry expr.lhs n_inner)
      in

      let res =
        match Hashtbl.find_opt operations wire with
        | None -> false
        | Some expr when n = 1 && expr.op <> Op.AND -> false
        | Some expr when n = 1 -> check_base_case expr
        | Some expr when expr.op <> Op.OR -> false
        | Some expr ->
            let n_minus_1 = n - 1 in
            is_ok_direct_carry expr.lhs n_minus_1
            && is_ok_recarry expr.rhs n_minus_1
            || is_ok_direct_carry expr.rhs n_minus_1
               && is_ok_recarry expr.lhs n_minus_1
      in
      Hashtbl.add is_ok_carry_cache (wire, n) res;
      res

let is_ok_z wire n =
  match Hashtbl.find_opt is_ok_z_cache (wire, n) with
  | Some res -> res
  | None ->
      let res =
        match Hashtbl.find_opt operations wire with
        | None -> false
        | Some expr when expr.op <> Op.XOR -> false
        | Some expr when n = 0 -> check_base_case expr
        | Some expr ->
            (is_ok_xor expr.lhs n && is_ok_carry expr.rhs n)
            || (is_ok_xor expr.rhs n && is_ok_carry expr.lhs n)
      in
      Hashtbl.add is_ok_z_cache (wire, n) res;
      res

let progress start =
  Hashtbl.clear is_ok_xor_cache;
  Hashtbl.clear is_ok_carry_cache;
  Hashtbl.clear is_ok_z_cache;
  let ok_idx i = not (is_ok_z (make_wire i Z) i) in
  Seq.ints start |> Seq.find ok_idx |> Option.get

let swap_wires a b =
  let v_a = Hashtbl.find operations a in
  let v_b = Hashtbl.find operations b in
  Hashtbl.replace operations a v_b;
  Hashtbl.replace operations b v_a

let get_swaps n_swaps =
  let pairs = keys operations |> combos in

  let rec loop_inner base combos best curr =
    match combos with
    | (a, b) :: rest ->
        let curr' = List.sort String.compare [ a; b ] in
        swap_wires a b;
        let best' = progress best in
        if best' > base then (max best best', curr')
        else (
          swap_wires a b;
          loop_inner base rest best curr')
    | [] -> (best, curr)
  in

  let rec loop swaps n best current =
    if n = 0 then swaps
    else
      let base = progress best in
      let best, curr = loop_inner base pairs best current in
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
