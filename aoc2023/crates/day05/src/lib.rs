pub fn process(s: &str) -> Vec<usize> {
    s.split_whitespace()
        .filter_map(|s| s.parse().ok())
        .collect()
}

pub fn parse_data(test: bool) -> (Vec<usize>, Vec<Vec<Vec<usize>>>) {
    let input_data = match test {
        true => include_str!("../data/test.txt").to_string(),
        false => include_str!("../data/input.txt").to_string(),
    };

    let split_input = input_data.split("\n\n").collect::<Vec<&str>>();
    let mut map_groups: Vec<Vec<Vec<usize>>> = vec![];

    let seeds: Vec<usize> = process(split_input[0]);

    (1..split_input.len()).for_each(|i| {
        let mut maps: Vec<Vec<usize>> = vec![];
        let ungrouped: Vec<usize> = process(split_input[i]);

        for chunk in ungrouped.chunks(3) {
            maps.push(chunk.to_vec());
        }

        map_groups.push(maps);
    });

    (seeds, map_groups)
}
