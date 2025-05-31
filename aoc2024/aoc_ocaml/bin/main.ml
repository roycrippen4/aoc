open Lib

let () =
  [
    day01.part1;
    day01.part2;
    day02.part1;
    day02.part2;
    day03.part1;
    day03.part2;
    day04.part1;
    day04.part2;
    day05.part1;
    day05.part2;
    day06.part1;
    day06.part2;
    day07.part1;
    day07.part2;
    day08.part1;
    day08.part2;
    day09.part1;
    day09.part2;
    day10.part1;
    day10.part2;
    day11.part1;
    day11.part2;
    day12.part1;
    day12.part2;
    day13.part1;
    day13.part2;
    day14.part1;
    day14.part2;
    day15.part1;
    day15.part2;
    day16.part1;
    day16.part2;
    day17.part1;
    day17.part2;
    day18.part1;
    day18.part2;
    day19.part1;
    day19.part2;
    day20.part1;
    day20.part2;
    day21.part1;
    day21.part2;
    day22.part1;
    day22.part2;
    day23.part1;
    day23.part2;
    day24.part1;
    day24.part2;
    day25.part1;
    day25.part2;
  ]
  |> List.fold_left (fun acc fn -> acc +. fn ()) 0.
  |> Util.pp_time
  |> Printf.printf "Total time: %s\n"
