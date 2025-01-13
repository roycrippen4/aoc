fn unsafe_index(x: isize) -> usize {
    usize::try_from(x).unwrap()
}

fn partition<T: Copy + PartialOrd>(array: &mut [T]) -> usize {
    let n = array.len();
    let pivot = array[0];
    let mut i = -1;
    let mut j = n as isize;

    loop {
        loop {
            i += 1;
            if array[unsafe_index(i)] >= pivot {
                break;
            }
        }

        loop {
            j -= 1;
            if j < 0 || array[unsafe_index(j)] <= pivot {
                break;
            }
        }

        if i >= j {
            return unsafe_index(j);
        }

        let temp = array[unsafe_index(i)];
        array[unsafe_index(i)] = array[unsafe_index(j)];
        array[unsafe_index(j)] = temp;
    }
}

pub fn quicksort<T: Copy + PartialOrd>(array: &mut [T]) {
    if array.len() <= 1 {
        return;
    }
    let pi = partition(array);
    let (left, right) = array.split_at_mut(pi + 1);
    quicksort(left);
    quicksort(right);
}

#[cfg(test)]
mod test {
    use super::{partition, quicksort};

    #[test]
    fn test_partition() {
        let mut input = [5, 3, 8, 4, 2, 7, 1, 10];
        let expected = [1, 3, 2, 4, 8, 7, 5, 10];
        partition(&mut input);
        assert_eq!(expected, input);

        let mut input = [12, 10, 9, 16, 19, 9];
        let expected = [9, 10, 9, 16, 19, 12];
        partition(&mut input);
        assert_eq!(expected, input);
    }

    #[test]
    fn test_quicksort() {
        let data = generate_test_data();
        for (expected, mut input) in data {
            quicksort(&mut input);
            assert_eq!(input, expected);
        }
    }

    fn generate_test_data() -> Vec<(Vec<isize>, Vec<isize>)> {
        vec![
            (vec![-5, -3, 0, 1, 2, 7, 8], vec![7, -3, 8, 1, 2, -5, 0]),
            (vec![1, 1, 1, 1], vec![1, 1, 1, 1]),
            (vec![1, 2, 3, 4, 5], vec![5, 4, 3, 2, 1]),
            (vec![], vec![]),
            (vec![42], vec![42]),
            (vec![-10, -2, 0, 3, 5], vec![0, -2, 5, 3, -10]),
        ]
    }
}
