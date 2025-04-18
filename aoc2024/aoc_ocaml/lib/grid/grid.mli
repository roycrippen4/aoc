(** {2 Grids aka two-dimensional arrays}

    Following conventions in mathematics, grids are considered rows first. Thus
    in the following, [height] refers to the first dimension and [width] to the
    second dimension.

    {v
             0   1       j      width-1
           +---+---+---+---+---+--+
        0  |   |   |   |   |   |  |
           +---+---+---+---+---+--+
        1  |   |   |   |   |   |  |
           +---+---+---+---+---+--+
        i  |   |   |   | X |   |  |
           +---+---+---+---+---+--+
  height-1 |   |   |   |   |   |  |
           +---+---+---+---+---+--+
    v}

    Following OCaml conventions, indices are 0-based.

    For the width to be well-defined, some of the following functions assume a
    positive number of rows (and, to be consistent, a positive number of
    columns). *)

type 'a t = 'a array array
type 'a tl = 'a list list

type 'a entry = int * int * 'a
(** An entry is an ordered triplet or [(x, y, 'a)], where [x] is the column, [y]
    is the row and ['a] is the value. Rows and columns are 0-based. *)

type position = int * int
(** A position is an ordered pair [(x, y)], where [x] is the column and [y] is
    the row. Rows and columns are 0-based. *)

val height : 'a t -> int
(** Returns the number of rows. *)

val width : 'a t -> int
(** Returns the number of columns. *)

val size : 'a t -> int * int
(** both height and width, in that order *)

val make : int -> int -> 'a -> 'a t
(** [make h w v] returns a new grid with height [h] and width [w], where all
    values are equal to [v]. Raises [Invalid_argument] if [h<1] or [w<1].

    For [h>=1] and [w>=1], this is equivalent to [Array.make_matrix h w v]. *)

val init : int -> int -> (position -> 'a) -> 'a t
(** [init h w f] returns a new grid with height [h] and width [w], where the
    value at position [p] is [f p]. Raises [Invalid_argument] if [h<1] or [w<1].
*)

val copy : 'a t -> 'a t
(** [copy g] returns a new grid that contains the same elements as [g] *)

val get : 'a t -> position -> 'a
(** [get g p] returns the value at position [p]. Raises [Invalid_argument] if
    the position is out of bounds. *)

val get_opt : 'a t -> position -> 'a option
(** [get_opt g p] returns [Some] value at position [p]. Returns [None] if the
    position is out of bounds. *)

val entry : 'a t -> position -> 'a entry
val entry_opt : 'a t -> position -> 'a entry option

val set : 'a t -> position -> 'a -> unit
(** [set g p v] sets the value at position [p], with [v]. Raises
    [Invalid_argument] if the position is out of bounds. *)

val set_opt : 'a t -> position -> 'a -> unit option
(** [set g p v] sets the value at position [p], with [v]. Returns [Some unit] if
    the value at [p] is updated. Otherwise returns [None] *)

val inside : 'a t -> position -> bool
(** [inside g p] indicates whether position [p] is a legal position in [g] *)

val north : position -> position
(** the position above in the grid *)

val north_west : position -> position
(** the position above left in the grid *)

val west : position -> position
(** the position to the left in the grid *)

val south_west : position -> position
(** the position below left in the grid *)

val south : position -> position
(** the position below in the grid *)

val south_east : position -> position
(** the position below right in the grid *)

val east : position -> position
(** the position to the right in the grid *)

val north_east : position -> position
(** the position above right in the grid *)

(** the eight ways to move on the grid *)
type direction =
  | N  (** North *)
  | NW  (** Northwest *)
  | W  (** West *)
  | SW  (** Southwest *)
  | S  (** South *)
  | SE  (** Southeast *)
  | E  (** East *)
  | NE  (** Northeast *)

val string_of_direction : direction -> string

val move : direction -> position -> position
(** move a position in a given direction *)

val rotate_left : 'a t -> 'a t
(** [rotate_left g] returns a new grid that is the left rotation of [g] *)

val rotate_right : 'a t -> 'a t
(** [rotate_right g] returns a new grid that is the right rotation of [g] *)

val map : ('a entry -> 'b) -> 'a t -> 'b t
(** [map f g] returns a fresh grid, with the size of the grid [g] and where the
    value at position [p] is given by [f p (get g p)] *)

(** {e The following functions that iterate or fold over the neighbors of [p]
       all begin by calling [f] on the cell north of [p] and rotate clockwise.}
*)

val iter4 : (position -> 'a -> unit) -> 'a t -> position -> unit
(** [iter4 f g p] applies function [f] on the four neighbors of position [p]
    (provided they exist) *)

val iter8 : (position -> 'a -> unit) -> 'a t -> position -> unit
(** [iter8 f g p] applies function [f] on the eight neighbors of position [p]
    (provided they exist) *)

val fold4 : (position -> 'a -> 'acc -> 'acc) -> 'a t -> position -> 'acc -> 'acc
(** [fold4 f g p] folds function [f] on the four neighbors of position [p]
    (provided they exist) *)

(** [fold8 f g p] folds function [f] on the eight neighbors of position [p]
    (provided they exist) *)

val fold8 : (position -> 'a -> 'acc -> 'acc) -> 'a t -> position -> 'acc -> 'acc
(** {e [iter] and [fold] both begin at the top left of the grid and move left to
       right in each row from top to bottom.} *)

val flatten : 'a t -> 'a array
val enumerate : 'a t -> 'a entry t

val iter : (position -> 'a -> unit) -> 'a t -> unit
(** [iter f g] applies function [f] at each position of the grid [g] *)

val fold : ('acc -> 'a entry -> 'acc) -> 'acc -> 'a t -> 'acc
(** [fold f g] folds function [f] over each position of [g] *)

val filter : (position -> 'a -> bool) -> 'a t -> position list
(** [filter f g] Returns the positions of elements that satisfy the predicate
    [f] over each element of [g] *)

val find : (position -> 'a -> bool) -> 'a t -> position
(** [find f g] returns a position in [g] where [f] holds, or raises [Not_found]
    if there is none *)

val find_opt : (position -> 'a -> bool) -> 'a t -> position option
(** [find f g] returns [Some] position in [g] where [f] holds, or returns [None]
*)

val print :
  ?bol:(Format.formatter -> int -> unit) ->
  ?eol:(Format.formatter -> int -> unit) ->
  ?sep:(Format.formatter -> position -> unit) ->
  (Format.formatter -> position -> 'a -> unit) ->
  Format.formatter ->
  'a t ->
  unit
(** [print pp fmt g] prints the grid [g] on formatter [fmt], using function [pp]
    to print each element.

    Function [bol] is called at the beginning of each line, and is passed the
    line number. The default function does nothing.

    Function [eol] is called at the end of each line, and is passed the line
    number. The default function calls [Format.pp_print_newline].

    Function [sep] is printed between two consecutive element on a given row
    (and is passed the position of the left one). The default function does
    nothing. *)

val print_chars : Format.formatter -> char t -> unit
(** prints a grid of characters using [Format.pp_print_char] Example:
    [Format.printf "%a" print_chars g;] *)

val read : in_channel -> char t
(** [read c] reads a grid of characters from the input channel [c]. Raises
    [Invalid_argument] if the lines do not have the same length, or there is no
    line at all. *)

val from_file : string -> char t
(** [read path] creates an input channel [c] from filepath [p] and reads a grid
    of characters from [c]. Raises [Invalid_argument] if the lines do not have
    the same length, or there is no line at all. *)

val of_string : string -> char t
(** [grid_of_string s] reads a grid of characters from [s]. Raises
    [Invalid_argument] if the lines do not have the same length, or there is no
    line at all. *)

val to_list : 'a t -> 'a tl
(** [to_list g] converts a ['a array array] to a ['a list list] *)

val of_list : 'a tl -> 'a t
(** [to_list g] converts a ['a list list] to a ['a array array] *)

val neighbor4_values : 'a t -> position -> 'a option list
(** [neighbor4_values g] Get the values of all orthoganal neighbors from a given
    point [p] if neighbor [n] is in bounds. A neighbor is [None] if it is out of
    bounds. Order of the list starts at [N] and rotates clockwise. *)

val neighbor4_coords : position -> position list
(** [neighbor4_coords g] Get the coordinates of all orthoganal neighbors from a
    given point [p] regardless if neighbor [n] is in bounds. Order of the list
    starts at [N] and rotates clockwise. *)

val neighbor4_entries : 'a t -> position -> 'a entry option list
(** [neighbor4_values g] Get the coordinates and values of all orthoganal
    neighbors from a given point [p] if neighbor [n] is in bounds. A neighbor is
    [None] if it is out of bounds. Order of the list starts at [N] and rotates
    clockwise. *)

val neighbor8_values : 'a t -> position -> 'a option list
(** [neighbor8_values g] returns the values of all neighbors from a given point
    [p]. A neighbor is [None] if it is out of bounds. Order of the list starts
    at [N] and rotates clockwise. *)

val neighbor8_coords : position -> position list
(** [neighbor8_coords g] Get the coordinates of all neighbors from a given point
    [p] regardless if neighbor [n] is in bounds. Order of the list starts at [N]
    and rotates clockwise. *)

val neighbor8_entries : 'a t -> position -> 'a entry option list
(** [neighbor8_entries g] Get the coordinates and values of all neighbors from a
    given point [p] if neighbor [n] is in bounds. A neighbor is [None] if it is
    out of bounds. Order of the list starts at [N] and rotates clockwise. *)
