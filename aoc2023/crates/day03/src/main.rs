fn main() {
    #[allow(unused)]
    let test_txt: Vec<&str> = include_str!("test.txt").lines().collect();
    #[allow(unused)]
    let input_txt: Vec<&str> = include_str!("input.txt").lines().collect();

    // println!("Day 01 part a test: {}", solve_a(test_txt.clone())); // 8
    // println!("Day 01 part b test: {}", solve_b(test_txt)); // 2286
    // println!("Day 01 part a: {}", solve_a(input_txt.clone())); // 2265
    // println!("Day 01 part b: {}", solve_b(input_txt)); // 64097
}
