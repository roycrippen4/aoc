use std::fs::read_to_string;
use std::io;
use std::path::PathBuf;

pub fn read_file(file_path: PathBuf) -> Result<String, io::Error> {
    read_to_string(file_path)
}
