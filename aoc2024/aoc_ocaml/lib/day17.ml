open Util
module String = Batteries.String

(*
|  index  | value |  op   | description
+---------+-------+-------+---------------------------------------------
|    0    |   0   |  adv  | A = A / (2 ^ arg)
|    1    |   1   |  bxl  | B = B xor literal
|    2    |   2   |  bst  | B = arg mod 8
|    3    |   3   |  jnz  | if A = 0 then nothing. ptr = literal_arg and do not inc ptr
|    4    |   A   |  bxc  | B = B xor C. arg is ignored.
|    5    |   B   |  out  | result = (arg mod 8) :: result
|    6    |   C   |  bdv  | B = A / (2 ^ arg)
|    7    |      |  cdv  | C = A / (2 ^ arg)
*)

let prefix_equal l1 l2 =
  let rec check l1 l2 =
    match (l1, l2) with
    | [], _ -> true
    | _, [] -> false
    | a :: l1, b :: l2 -> if a = b then check l1 l2 else false
  in
  check l1 l2

module Cpu = struct
  type t = {
    ops : int array;
    reg : int array;
    mutable ptr : int;
    mutable out : int list;
  }

  let of_string s =
    let reg, ops = s |> String.split ~by:"\n\n" in

    let ops =
      ops
      |> String.lchop ~n:9
      |> String.split_on_char ','
      |> List.map int_of_string
      |> Array.of_list
    in

    let reg =
      let chop_to_int s = s |> String.lchop ~n:12 |> int_of_string in
      match reg |> String.split_on_char '\n' |> List.map chop_to_int with
      | [ a; b; c ] -> [| 0; 1; 2; 3; a; b; c |]
      | _ -> assert false
    in

    { ptr = 0; ops; reg; out = [] }

  (* helper for testing *)
  let make ops reg = { ptr = 0; ops; reg; out = [] }

  (* getters *)
  let get_a self = self.reg.(4)
  let get_b self = self.reg.(5)
  let get_c self = self.reg.(6)

  (* setters *)
  let set_a self v = self.reg.(4) <- v
  let set_b self v = self.reg.(5) <- v
  let set_c self v = self.reg.(6) <- v

  (** increment the value in the [A] register. Used in part2 *)
  let inc_a self = self.reg.(4) <- get_a self + 1

  (* pointer fns *)
  let set_ptr self idx = self.ptr <- idx
  let inc_ptr self = self.ptr <- self.ptr + 2

  (* dbg printer *)
  let show self =
    let module String = Base.String in
    Printf.printf "----------------------------------------------------\n";
    self.out
    |> List.rev
    |> List.map string_of_int
    |> String.concat ~sep:","
    |> Printf.printf "out: %s\n\n";

    Printf.printf "A: %d\n" (get_a self);
    Printf.printf "B: %d\n" (get_b self);
    Printf.printf "C: %d\n" (get_c self);

    let ops_strs = self.ops |> Array.map string_of_int in
    let ops_line = String.concat ~sep:"," (Array.to_list ops_strs) in
    Printf.printf "%s\n" ops_line;

    if
      Array.length self.ops > 0
      && self.ptr >= 0
      && self.ptr < Array.length self.ops
    then
      let offset =
        let rec calculate_offset i o =
          if i >= self.ptr then o
          else calculate_offset (i + 1) (o + String.length ops_strs.(i) + 1)
        in
        calculate_offset 0 0
      in
      String.make offset ' ' |> Printf.printf "%s^\n"
    else Printf.printf "(invalid ptr: %d)\n" self.ptr

  (* ops *)
  let adv self =
    let argi = self.ops.(self.ptr + 1) in
    let arg = self.reg.(argi) in
    set_a self (get_a self / pow 2 arg);
    inc_ptr self

  let bxl self =
    let arg = self.ops.(self.ptr + 1) in
    set_b self (get_b self lxor arg);
    inc_ptr self

  let bst self =
    let argi = self.ops.(self.ptr + 1) in
    let arg = self.reg.(argi) in
    set_b self (arg mod 8);
    inc_ptr self

  let jnz self =
    if get_a self = 0 then inc_ptr self
    else set_ptr self self.ops.(self.ptr + 1)

  let bxc self =
    set_b self (get_b self lxor get_c self);
    inc_ptr self

  let out self =
    self.out <- self.out @ [ self.reg.(self.ops.(self.ptr + 1)) mod 8 ];
    inc_ptr self

  let bdv self =
    set_b self (get_a self / pow 2 self.reg.(self.ops.(self.ptr + 1)));
    inc_ptr self

  let cdv self =
    set_c self (get_a self / pow 2 self.reg.(self.ops.(self.ptr + 1)));
    inc_ptr self

  exception Halt
  exception Done

  let step self =
    try [| adv; bxl; bst; jnz; bxc; out; bdv; cdv |].(self.ops.(self.ptr)) self
    with _ -> raise Halt

  let reset self a b c =
    set_a self a;
    set_b self b;
    set_c self c;
    self.ptr <- 0;
    self.out <- []

  let run self =
    let rec loop () =
      step self;
      loop ()
    in

    try loop () with Halt -> self

  let answer self = self.out |> List.map string_of_int |> String.concat ","

  let int_answer self =
    self.out |> List.map string_of_int |> String.concat "" |> int_of_string

  let find_quine self =
    let a, b, c = (get_a self, get_b self, get_c self) in
    let goal = Array.to_list self.ops in

    let rec loop offset =
      let rec run_with_check () =
        step self;

        if self.out = goal then raise Done;
        if not (prefix_equal self.out goal) then raise Halt;
        run_with_check ()
      in

      try run_with_check () with
      | Done -> offset + a - 1
      | Halt ->
          reset self (a + offset) b c;
          loop (offset + 1)
    in

    loop 1
end

let path = "/home/roy/dev/aoc/aoc2024/data/day17/data.txt"
let input = read_to_string path |> String.trim

(* *)
let ( >>= ) a b = a := !a lsr b
let ( >> ) a b = a lsr b
let ( ^^ ) a b = a lxor b
let ( & ) a b = a land b

let check_digits a digit prog =
  a := !a >> digit * 3;
  let len = Array.length prog in

  let rec loop i =
    if i >= len then true
    else
      let low3 = (!a & 0b111) ^^ 7 in
      let shift = !a >> low3 in
      let low3_xor_shift = low3 ^^ shift in
      let v = (low3_xor_shift ^^ 4) & 0b111 in
      if prog.(i) <> v then false
      else (
        a >>= 3;
        loop (i + 1))
  in
  loop digit

(* part 1 *)
let solve1 () = input |> Cpu.of_string |> Cpu.run |> Cpu.int_answer

(* let example = *)
(*   "Register A: 2024\nRegister B: 0\nRegister C: 0\n\nProgram: 0,3,5,4,3,0" *)

(* part 2 *)
let solve2 () =
  (* input |> Cpu.of_string |> Cpu.find_quine |> Printf.printf "answer: %d\n"; *)
  42

(* exports *)
let part1 () = validate solve1 657457310 "17" One
let part2 () = validate solve2 42 "17" Two
let solution : solution = { part1; part2 }

(* tests *)

let%test _ =
  let reg = [| 0; 1; 2; 3; 0; 0; 9 |] in
  let ops = [| 2; 6 |] in
  let cpu : Cpu.t = { reg; ops; ptr = 0; out = [] } in
  let _ = Cpu.run cpu in
  Cpu.get_a cpu = 0 && Cpu.get_b cpu = 1 && Cpu.get_c cpu = 9

let%test _ =
  let reg = [| 0; 1; 2; 3; 10; 0; 0 |] in
  let ops = [| 5; 0; 5; 1; 5; 4 |] in
  let cpu : Cpu.t = { reg; ops; ptr = 0; out = [] } in
  let _ = Cpu.run cpu in
  cpu.out = [ 2; 1; 0 ]

let%test _ =
  let reg = [| 0; 1; 2; 3; 2024; 0; 0 |] in
  let ops = [| 0; 1; 5; 4; 3; 0 |] in
  let cpu : Cpu.t = { reg; ops; ptr = 0; out = [] } in
  let _ = Cpu.run cpu in
  cpu.out = [ 0; 1; 3; 7; 7; 7; 7; 6; 5; 2; 4 ] && Cpu.get_a cpu = 0

let%test _ =
  let reg = [| 0; 1; 2; 3; 0; 29; 0 |] in
  let cpu : Cpu.t = { reg; ops = [| 1; 7 |]; ptr = 0; out = [] } in
  let _ = Cpu.run cpu in
  cpu.out = [] && Cpu.get_b cpu = 26

let%test _ =
  let reg = [| 0; 1; 2; 3; 0; 2024; 43690 |] in
  let ops = [| 4; 0 |] in
  let cpu : Cpu.t = { reg; ops; ptr = 0; out = [] } in
  let _ = Cpu.run cpu in
  Cpu.get_b cpu = 44354

let%test _ =
  let path = "/home/roy/dev/aoc/aoc2024/data/day17/example.txt" in
  let example = read_to_string path |> String.trim in
  let cpu = Cpu.of_string example in
  let _ = Cpu.run cpu in
  Cpu.answer cpu = "4,6,3,5,6,3,5,2,1,0" && Cpu.int_answer cpu = 4635635210

(* let%test _ = *)
(*   let example = *)
(*     "Register A: 2024\nRegister B: 0\nRegister C: 0\n\nProgram: 0,3,5,4,3,0" *)
(*   in *)
(**)
(*   let cpu = Cpu.of_string example in *)
(*   Cpu.set_a cpu 117440; *)
(*   Cpu.run cpu |> Cpu.show; *)
(*   true *)

let%test _ = prefix_equal [ 1; 2 ] [ 1; 2; 3 ]
let%test _ = prefix_equal [ 1; 2; 3 ] [ 1; 3; 2 ] |> not
let%test _ = prefix_equal [ 1; 2; 3; 4; 5 ] [ 1; 2; 4; 5 ] |> not
let%test _ = prefix_equal [ 1; 2; 3; 4; 5 ] [] |> not
let%test _ = prefix_equal [] [ 1; 2; 3 ]
