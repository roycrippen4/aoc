(** Returns [string array] from the file contents located at [filepath] separated by newlines *)
let readlines (filepath : string) : string array =
  In_channel.with_open_text filepath In_channel.input_lines |> Array.of_list

(** Split the string [str] by character [delim] and filter empty results out  *)
let split delim str =
  String.split_on_char delim str |> List.filter (fun s -> s <> "")

(** Appends an new item [a] into list [lst] *)
let append_item lst a = lst @ [ a ]
