use day05::parse_data;

#[allow(unused)]
fn main() {
    let (seeds, maps) = parse_data(false);
    let a_result = solve_a(&seeds, &maps);
    let b_result = solve_b(&seeds, &maps);
    // println!("{}", a_result);
}

fn solve_a(seeds: &[usize], maps: &[Vec<Vec<usize>>]) -> usize {
    let mut seeds = seeds.to_owned();

    maps.iter().for_each(|mapping| {
        let mut trans_map: Vec<usize> = vec![];

        seeds.iter().for_each(|&seed| {
            let relative_map: Vec<&Vec<usize>> = mapping
                .iter()
                .filter(|&m| seed > m[1] && seed < m[1] + m[2])
                .collect();

            match !relative_map.is_empty() {
                true => trans_map.push(seed - relative_map[0][1] + relative_map[0][0]),
                false => trans_map.push(seed),
            }
        });

        seeds = trans_map;
    });

    *seeds.iter().min().unwrap()
}

#[allow(unused)]
fn solve_b(seeds: &[usize], maps: &[Vec<Vec<usize>>]) -> usize {
    let seeds: Vec<Vec<usize>> = seeds.chunks(2).map(|c| c.to_vec()).collect();
    todo!()
}

pub fn two_sum(nums: Vec<i32>, target: i32) -> Vec<i32> {
    for i in 0..nums.len() {
        for j in i + 1..nums.len() {
            if (nums[i] + nums[j]) == target {
                return vec![i as i32, j as i32];
            }
        }
    }

    vec![0, 0]
}

#[test]
fn test_two_sum() {
    let nums1: Vec<i32> = vec![2, 7, 11, 15];
    let target1: i32 = 9;
    assert_eq!(two_sum(nums1, target1), vec![0, 1]);

    let nums3: Vec<i32> = vec![3, 3];
    let target3: i32 = 6;
    assert_eq!(two_sum(nums3, target3), vec![0, 1]);
}
