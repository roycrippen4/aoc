use std::{iter, str::FromStr};

pub trait StringMethods {
    fn create_pad(len: usize, ch: char) -> String;
    fn to_char_vec(&self) -> Vec<char>;
    fn pad_start(&self, n: usize, c: char) -> String;
    fn pad_end(&self, n: usize, c: char) -> String;
    fn pad(&self, n: usize, c: char) -> String;
    fn into_padded(s: &str) -> String;
    fn to_row<F: FromStr>(&self) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug;
}

impl StringMethods for String {
    fn create_pad(len: usize, ch: char) -> String {
        iter::repeat(ch).take(len).collect::<String>()
    }

    fn to_char_vec(&self) -> Vec<char> {
        self.chars().collect::<Vec<_>>()
    }

    fn pad_start(&self, n: usize, ch: char) -> String {
        let mut s = self.clone();
        let mut n = n;
        while n != 0 {
            s.insert(0, ch);
            n -= 1;
        }
        s
    }

    fn into_padded(s: &str) -> String {
        s.pad(4, '.')
    }

    fn pad_end(&self, n: usize, ch: char) -> String {
        let mut s = self.clone();
        let mut n = n;
        while n != 0 {
            s.insert(self.len(), ch);
            n -= 1;
        }
        s
    }

    fn pad(&self, n: usize, ch: char) -> String {
        self.pad_start(n, ch).pad_end(n, ch)
    }

    /// Trims whitespace, splits the string at `pat`, filters out empty entries, and parses via
    /// `FromStr`
    fn to_row<F: FromStr>(&self) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug,
    {
        self.trim()
            .split("")
            .filter(|s| !s.trim().is_empty())
            .map(|s| s.to_string().parse().expect("Failed to parse"))
            .collect()
    }
}

impl StringMethods for &str {
    fn into_padded(s: &str) -> String {
        s.pad(4, '.')
    }

    fn create_pad(len: usize, ch: char) -> String {
        iter::repeat(ch).take(len).collect::<String>()
    }

    fn to_char_vec(&self) -> Vec<char> {
        self.to_string().to_char_vec()
    }

    fn pad_start(&self, n: usize, c: char) -> String {
        self.to_string().pad_start(n, c)
    }

    fn pad_end(&self, n: usize, c: char) -> String {
        self.to_string().pad_end(n, c)
    }

    fn pad(&self, n: usize, c: char) -> String {
        self.to_string().pad(n, c)
    }

    fn to_row<F: FromStr>(&self) -> Vec<F>
    where
        <F as FromStr>::Err: std::fmt::Debug,
    {
        self.to_string().to_row()
    }
}

#[cfg(test)]
mod test {
    use super::StringMethods;
    #[test]
    fn test_pad_start() {
        let result = "string".to_string().pad_start(3, '.');
        let expected = "...string";
        assert_eq!(expected, result)
    }

    #[test]
    fn test_pad_end() {
        let result = "string".to_string().pad_end(3, '.');
        let expected = "string...";
        assert_eq!(expected, result)
    }

    #[test]
    fn test_pad() {
        let result = "string".to_string().pad(3, '.');
        let expected = "...string...";
        assert_eq!(expected, result)
    }

    #[test]
    fn test_to_char_vec() {
        let string = "string".to_string();
        let expected = ['s', 't', 'r', 'i', 'n', 'g'];
        assert_eq!(string.to_char_vec(), expected)
    }
}
