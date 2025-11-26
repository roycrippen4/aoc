/// Gets the example data as a &str
#[macro_export]
macro_rules! example {
    () => {
        include_str!("data/example.txt")
    };
}

/// Gets the input data as a &str
#[macro_export]
macro_rules! data {
    () => {
        include_str!("data/data.txt")
    };
}

#[macro_export]
macro_rules! line_count {
    ($str: expr) => {{
        let input = $str.as_bytes();
        let mut i = 0;
        let mut count: usize = 0;

        while i < input.len() {
            if input[i] == b'\n' {
                count += 1;
            }

            i += 1;
        }

        count
    }};
}

/// Colors string `s` fg color with `r`, `g`, `b` values using ansci escape codes.
/// `r`, `g`, and `b` values range from 0 to 255;
///
/// # Example
/// ```
/// use aoc2024::rgb;
///
/// println!("{}", rgb!("Red 255", 255, 0, 0));
/// println!("{}", rgb!("Red 200", 200, 0, 0));
/// println!("{}", rgb!("gray", 100, 100, 100));
/// println!("{}", rgb!("orange", 255, 140, 0));
/// ```
#[macro_export]
macro_rules! rgb {
    ($s:expr, $r:expr, $g:expr, $b:expr) => {
        format!("\x1b[38;2;{};{};{}m{}\x1b[0m", $r, $g, $b, $s)
    };
}
#[cfg(test)]
mod test {
    #[test]
    fn test_rgb() {
        println!("{}", rgb!("Red 255", 255, 0, 0));
        println!("{}", rgb!("Red 200", 200, 0, 0));
        println!("{}", rgb!("gray", 100, 100, 100));
        println!("{}", rgb!("orange", 255, 140, 0));
    }
}
