open Printf
module H = Hashtbl

let input = Util.read_to_string "../data/day06/data.txt" |> String.trim

module Kind = struct
  type t = Guard | Block | Empty

  let of_char = function
    | '^' -> Guard
    | '.' -> Empty
    | '#' -> Block
    | _ -> raise Not_found
end

module Direction = struct
  type t = N | S | E | W

  let rotate = function N -> E | E -> S | S -> W | W -> N

  let next x y = function
    | N -> (x, y - 1)
    | S -> (x, y + 1)
    | E -> (x + 1, y)
    | W -> (x - 1, y)
end

module PosSet = Set.Make (struct
  type t = int * int

  let compare = compare
end)

type g = (int * int, Kind.t) H.t

let create_grid s =
  let grid : g = H.create (String.length s) in
  let x = ref 0 in
  let y = ref 0 in
  let guard = ref (-1, -1, Direction.S) in

  let process_char c =
    match c with
    | '\n' ->
        incr y;
        x := 0
    | '^' ->
        H.add grid (!x, !y) Empty;
        guard := (!x, !y, N);
        incr x
    | _ ->
        H.add grid (!x, !y) (Kind.of_char c);
        incr x
  in

  String.iter process_char s;
  (grid, !guard)

let grid, guard_start = create_grid input
let gx, gy, _ = guard_start

let rec step (x, y, d) =
  let dx, dy = Direction.next x y d in
  match H.find_opt grid (dx, dy) with
  | None -> None
  | Some Empty -> Some (dx, dy, d)
  | Some Block -> step (x, y, Direction.rotate d)
  | _ -> assert false

let guard_path =
  let rec go guard acc =
    match guard with
    | None -> acc
    | Some (x, y, d) ->
        let next_g = step (x, y, d) in
        go next_g (PosSet.add (x, y) acc)
  in
  go (Some guard_start) PosSet.empty

let solve1 () = PosSet.cardinal guard_path

(* part 2 *)

module Q = Core.Deque

module Cell = struct
  type t = {
    mutable walk_id : int;
    mutable blocked : bool;
    mutable north : bool;
    mutable south : bool;
    mutable east : bool;
    mutable west : bool;
  }

  let default () =
    {
      walk_id = 0;
      blocked = false;
      north = false;
      south = false;
      east = false;
      west = false;
    }

  let maybe_reset cell curr_walk =
    if cell.walk_id = curr_walk then ()
    else (
      cell.walk_id <- curr_walk;
      cell.north <- false;
      cell.south <- false;
      cell.east <- false;
      cell.west <- false)
end

type cells = Cell.t Grid.t
type path_step = { y : int; x : int; direction : Direction.t }
type pos = { mutable y : int; mutable x : int }
type result = Go | Out | Loop
type 'a set = ('a, unit) H.t

let direction = ref Direction.N
let loop_count = ref 0
let tested : string set = H.create 4000

(* *)

let grid = Grid.of_string input
let width = Grid.width grid
let height = Grid.height grid
let cur = { y = 0; x = 0 }

(* *)

let ( .%{} ) arr (x, y) = arr.(y).(x)
let ( .%{}<- ) arr (x, y) v = arr.(y).(x) <- v

let process_input () : cells * pos =
  let open Array in
  let map = init height (fun _ -> init width (fun _ -> Cell.default ())) in

  let rec rows pos = function
    | y when y >= height -> (map, pos)
    | y -> rows (cols pos y 0) (y + 1)
  and cols pos y = function
    | x when x >= width -> pos
    | x -> (
        match grid.%{x, y} with
        | '#' ->
            map.%{x, y}.blocked <- true;
            cols pos y (x + 1)
        | '.' -> cols pos y (x + 1)
        | _ -> cols { y; x } y (x + 1))
  in

  rows { y = 0; x = 0 } 0

exception Return of result

let walk_north (map : cells) curr_walk : result =
  let rec loop () =
    if cur.y - 1 < 0 then raise (Return Out);
    cur.y <- cur.y - 1;

    let next = map.(cur.y).(cur.x) in
    if not next.blocked then loop ()
    else (
      cur.y <- cur.y + 1;
      let current = map.(cur.y).(cur.x) in
      Cell.maybe_reset current curr_walk;

      if current.north then raise (Return Loop);
      current.north <- true;
      direction := Direction.E;

      raise (Return Go))
  in
  try loop () with Return r -> r

let walk_south (map : cells) curr_walk : result =
  let rec loop () =
    if cur.y + 1 = height then raise (Return Out);
    cur.y <- cur.y + 1;

    let next = map.(cur.y).(cur.x) in
    if not next.blocked then loop ()
    else (
      cur.y <- cur.y - 1;
      let current = map.(cur.y).(cur.x) in
      Cell.maybe_reset current curr_walk;

      if current.south then raise (Return Loop);
      current.south <- true;
      direction := Direction.W;

      raise (Return Go))
  in
  try loop () with Return r -> r

let walk_east (map : cells) curr_walk : result =
  let rec loop () =
    if cur.x + 1 = width then raise (Return Out);
    cur.x <- cur.x + 1;

    let next = map.(cur.y).(cur.x) in
    if not next.blocked then loop ()
    else (
      cur.x <- cur.x - 1;
      let current = map.(cur.y).(cur.x) in
      Cell.maybe_reset current curr_walk;

      if current.east then raise (Return Loop);
      current.east <- true;
      direction := Direction.S;

      raise (Return Go))
  in
  try loop () with Return r -> r

let walk_west (map : cells) curr_walk : result =
  let rec loop () =
    if cur.x - 1 < 0 then raise (Return Out);
    cur.x <- cur.x - 1;

    let next = map.(cur.y).(cur.x) in
    if not next.blocked then loop ()
    else (
      cur.x <- cur.x + 1;
      let current = map.(cur.y).(cur.x) in
      Cell.maybe_reset current curr_walk;

      if current.west then raise (Return Loop);
      current.west <- true;
      direction := Direction.N;

      raise (Return Go))
  in
  try loop () with Return r -> r

let walk_map map { x; y; direction = d } walk count =
  cur.x <- x;
  cur.y <- y;
  direction := d;

  let rec loop acc =
    match
      match !direction with
      | Direction.N -> walk_north map walk
      | Direction.S -> walk_south map walk
      | Direction.E -> walk_east map walk
      | Direction.W -> walk_west map walk
    with
    | Out -> acc
    | Loop -> succ acc
    | _ -> loop acc
  in

  loop count

let walk_maps (map : cells) (path : path_step Q.t) cur : int =
  let make_id x y = sprintf "%d~%d" y x in
  let is_tested (step : path_step) = H.mem tested (make_id step.x step.y) in
  H.replace tested (make_id cur.x cur.y) ();

  let rec loop walk acc =
    let prev = Q.dequeue_front_exn path in

    match Q.peek_front path with
    | None -> acc
    | Some block when is_tested block -> loop walk acc
    | Some block ->
        H.replace tested (make_id block.x block.y) ();
        map.(block.y).(block.x).blocked <- true;

        let count = walk_map map prev walk acc in

        map.(block.y).(block.x).blocked <- false;
        loop (succ walk) count
  in

  loop 0 0

let get_p1_path (map : cells) : path_step Q.t =
  let path = Q.create () in

  let rec loop d =
    Q.enqueue_back path { y = cur.y; x = cur.x; direction = d };

    match d with
    | Direction.N ->
        cur.y <- cur.y - 1;
        if cur.y < 0 then path
        else if map.(cur.y).(cur.x).blocked then (
          cur.y <- cur.y + 1;
          loop E)
        else loop N
    | S ->
        cur.y <- cur.y + 1;
        if cur.y >= height then path
        else if map.(cur.y).(cur.x).blocked then (
          cur.y <- cur.y - 1;
          loop W)
        else loop S
    | E ->
        cur.x <- cur.x + 1;
        if cur.x >= width then path
        else if map.(cur.y).(cur.x).blocked then (
          cur.x <- cur.x - 1;
          loop S)
        else loop E
    | W ->
        cur.x <- cur.x - 1;
        if cur.x < 0 then path
        else if map.(cur.y).(cur.x).blocked then (
          cur.x <- cur.x + 1;
          loop N)
        else loop W
  in

  loop Direction.N

let solve2 () =
  let map, pos = process_input () in

  cur.x <- pos.x;
  cur.y <- pos.y;

  let path = get_p1_path map in
  walk_maps map path pos

(* exports *)

let part1 () = Util.validate solve1 4559 "06" One
let part2 () = Util.validate solve2 1604 "06" Two
let solution : Util.solution = { part1; part2 }
