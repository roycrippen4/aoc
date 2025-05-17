open Util
module S = String

module H = struct
  include Hashtbl

  let of_list lst =
    let tbl = create (List.length lst) in
    List.iter (Tuple.uncurry (add tbl)) lst;
    tbl
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

type instruction = { a : string; b : string; op : Op.t }

module Instruction = struct
  type t = instruction

  let to_string { a; b; op } = Printf.sprintf "%s %s %s" a (Op.to_string op) b

  let of_list = function
    | [ a; op; b ] -> { a; op = Op.of_string op; b }
    | _ -> assert false

  let of_string s = S.split_on_char ' ' s |> of_list
  let parse_fst tup = Tuple.map_fst of_string tup |> Tuple.swap
end

(** [bfw XOR mjb -> z00] where [z00] is the value derived from computing
    [bfw XOR mjb] *)
module Expr = struct
  type t = string * Instruction.t

  let of_string =
    S.split ~by:" -> " >> Tuple.swap >> Tuple.map_snd Instruction.of_string

  let to_string (label, instruction) =
    Printf.printf "%s = %s\n" label (Instruction.to_string instruction)
end

let partition_zs = function
  | a, b when a.[0] <> 'z' -> Either.Left (a, b)
  | a, b -> Either.Right (a, b)

let cmp = fun a b -> S.compare (fst a) (fst b)
let get_zs = fun z -> List.sort cmp z |> List.map snd

let parse_undefined ls =
  let split_map s = S.split ~by:" -> " s |> Instruction.parse_fst in

  ls
  |> List.partition_map (fun s -> split_map s |> partition_zs)
  |> Tuple.bimap ~f1:H.of_list ~f2:get_zs

let parse_defined ls =
  List.map (S.split ~by:": " >> Tuple.map_snd int_of_string) ls |> H.of_list

let defined, (undefined, zs) =
  read_to_string "/home/roy/dev/aoc/aoc2024/data/day24/example.txt"
  |> S.trim |> S.split ~by:"\n\n" |> Tuple.map S.lines
  |> Tuple.bimap ~f1:parse_defined ~f2:parse_undefined

(*

// Defined
x00 = 1
x01 = 0
x02 = 1
x03 = 1
x04 = 0
y00 = 1
y01 = 1
y02 = 1
y03 = 1
y04 = 1

(key, (arg1, op, arg2))

// Definable
djm = y00 AND y03
pbm = y01 AND x02
tnw = y02 OR  x01
psh = y03 OR  y00
nrd = y03 OR  x01
fgs = y04 OR  y02
fst = x00 OR  x03
vdt = x03 OR  x00
ntg = x00 XOR y04
ffh = x03 XOR y03
kjc = x04 AND y00

// 2nd order Definable
qhw = djm OR  pbm
kpj = pbm OR  djm
mjb = ntg XOR fgs
bfw = vdt OR  tnw
bqk = ffh OR  nrd
frj = tnw OR  fst
hwm = nrd AND vdt
rvg = kjc AND fst
kwq = ntg OR  kjc
tgd = psh XOR fgs
wpb = nrd XOR fgs
gnj = tnw OR  pbm

// 3rd order Definable
z00 = bfw XOR mjb
z01 = tgd XOR rvg
z02 = gnj AND wpb
z03 = hwm AND bqk
z04 = frj XOR qhw
z05 = kwq OR  kpj
z06 = bfw OR  bqk
z07 = bqk OR  frj
z08 = bqk OR  frj
z09 = qhw XOR tgd
z10 = bfw AND frj
z11 = gnj AND tgd
z12 = tgd XOR rvg
*)

let rec define arg =
  let open Hashtbl in
  let eval a b op =
    let result = Op.apply a op b in
    add defined arg result;
    remove undefined arg;
    result
  in

  try find defined arg
  with Not_found -> (
    let { a; b; op } = find undefined arg in

    match (find_opt defined a, find_opt defined b) with
    | Some a', Some b' -> eval a' b' op
    | Some a', None -> eval a' (define b) op
    | None, Some b' -> eval (define a) b' op
    | None, None -> eval (define a) (define b) op)

let solve1 () =
  let eval { a; b; op } = Op.apply (define a) op (define b) in
  let result = zs |> List.rev_map eval in

  result |> List.iter (fun v -> Printf.printf "%d" v);
  print_endline "";
  42

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 42 "24" One
let part2 () = validate solve2 42 "24" Two
let solution : solution = { part1; part2 }

(* tests *)
