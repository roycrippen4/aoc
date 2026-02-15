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

/// Counts the number of character instances in a given string
#[macro_export]
macro_rules! count_char {
    ($input: expr, $delim: expr) => {{
        let bytes = $input.as_bytes();
        #[allow(clippy::char_lit_as_u8)]
        let delim_byte = $delim as u8;

        let mut i = 0;
        let mut count: usize = 0;

        while i < bytes.len() {
            if bytes[i] == delim_byte {
                count += 1;
            }
            i += 1;
        }
        count
    }};
}

#[macro_export]
macro_rules! split_str {
    (const $input:expr, $delimiter:expr) => {{
        const N: usize = $crate::count_char!($input, $delimiter) + 1;
        let bytes = $input.as_bytes();
        let mut result = [""; N];
        let mut index: usize = 0;
        let mut start: usize = 0;
        let mut pos: usize = 0;
        #[allow(clippy::char_lit_as_u8)]
        let delim = $delimiter as u8;

        while pos < bytes.len() {
            if bytes[pos] == delim {
                result[index] = &$input[start..pos];
                start = pos + 1;
                index += 1;
            }
            pos += 1;
        }
        result[index] = &$input[start..];
        result
    }};

    ($input:literal, $delimiter:expr) => {{
        const N: usize = $crate::count_char!($input, $delimiter) + 1;
        let bytes = $input.as_bytes();
        let mut result = [""; N];
        let mut index: usize = 0;
        let mut start: usize = 0;
        let mut pos: usize = 0;
        #[allow(clippy::char_lit_as_u8)]
        let delim = $delimiter as u8;

        while pos < bytes.len() {
            if bytes[pos] == delim {
                result[index] = &$input[start..pos];
                start = pos + 1;
                index += 1;
            }
            pos += 1;
        }
        result[index] = &$input[start..];
        result
    }};

    ($input:expr, $delimiter:expr) => {{
        let input_str: &str = $input;
        let mut result = Vec::new();
        let mut start: usize = 0;
        let bytes = input_str.as_bytes();
        #[allow(clippy::char_lit_as_u8)]
        let delim = $delimiter as u8;

        for pos in 0..bytes.len() {
            if bytes[pos] == delim {
                result.push(&input_str[start..pos]);
                start = pos + 1;
            }
        }
        result.push(&input_str[start..]);
        result
    }};
}

/// Counts the number of lines in a given input &str
#[macro_export]
macro_rules! line_count {
    ($str: expr) => {
        $crate::count_char!($str, b'\n')
    };
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
    fn test_split() {
        // match a const to either an array or a vec based on `const <expr>` presence
        const INPUT: &str = "a|b|c";
        assert_eq!(["a", "b", "c"], split_str!(const INPUT, '|'));
        assert_eq!(vec!["a", "b", "c"], split_str!(const INPUT, '|'));
        assert_eq!(vec!["a", "b", "c"], split_str!(INPUT, '|'));

        // match a literal with `const` keyword
        assert_eq!(["a", "b", "c"], split_str!(const "a|b|c", '|'));
        assert_eq!(vec!["a", "b", "c"], split_str!(const "a|b|c", '|'));

        // match a literal without `const` keyword
        assert_eq!(["a", "b", "c"], split_str!("a|b|c", '|'));
        assert_eq!(vec!["a", "b", "c"], split_str!("a|b|c", '|'));
    }

    #[test]
    fn test_rgb() {
        println!("{}", rgb!("Red 255", 255, 0, 0));
        println!("{}", rgb!("Red 200", 200, 0, 0));
        println!("{}", rgb!("gray", 100, 100, 100));
        println!("{}", rgb!("orange", 255, 140, 0));
    }

    #[test]
    fn test_split_to_array() {
        let result = split_str!("foo|bar|baz", '|');
        let expected = ["foo", "bar", "baz"];

        assert_eq!(result, expected, "Results do not match");
    }
}
