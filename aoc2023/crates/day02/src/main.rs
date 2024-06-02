fn main() {
    let a_test_lines: Vec<String> = include_str!("test-a.txt")
        .lines()
        .map(|l| l.chars().collect())
        .collect();

    // println!("Day 01 part a test: {}", solve_a(a_test_lines));
    solve_a(a_test_lines);
}

fn solve_a(lines: Vec<String>) {
    println!("{:?}", lines)
}
