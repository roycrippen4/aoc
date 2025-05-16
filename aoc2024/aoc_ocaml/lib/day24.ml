open Util

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
end

type instruction = string * Op.t * string

let input = read_to_string "/home/roy/dev/aoc/aoc2024/data/day24/example.txt"

let parse =
  String.trim >> String.split ~by:"\n\n" >> Tuple.map String.lines
  >> Tuple.bimap
       ~f1:
         (List.map (String.split ~by:": " >> Tuple.map_snd int_of_string)
         >> H.of_list)
       ~f2:
         (List.map
            (String.split ~by:" -> "
            >> Tuple.map_fst
                 ( String.split_on_char ' ' >> function
                   | [ arg1; op; arg2 ] -> (arg1, Op.of_string op, arg2)
                   | _ -> raise (Invalid_argument "FUCK") )
            >> Tuple.swap)
         >> H.of_list)

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

let solve1 () = 42

(* part 2 *)

let solve2 () = 42

(* exports *)

let part1 () = validate solve1 42 "24" One
let part2 () = validate solve2 42 "24" Two
let solution : solution = { part1; part2 }

(* tests *)
