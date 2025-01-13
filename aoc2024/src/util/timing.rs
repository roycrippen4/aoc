use std::{
    fmt,
    time::{Duration, Instant},
};

use crate::rgb;

use super::Day;

enum TimeRange {
    Seconds,
    MillisecondsSlow,
    MillisecondsMedium,
    MillisecondsFast,
    Nanoseconds,
}

fn get_time_range(t: &Duration) -> TimeRange {
    if t.as_secs() > 0 {
        TimeRange::Seconds
    } else if t.subsec_millis() > 100 {
        TimeRange::MillisecondsSlow
    } else if t.subsec_millis() > 10 {
        TimeRange::MillisecondsMedium
    } else if t.subsec_millis() > 0 {
        TimeRange::MillisecondsFast
    } else {
        TimeRange::Nanoseconds
    }
}

fn colorize_time(t: &Duration) -> String {
    let range = get_time_range(t);
    match range {
        TimeRange::Nanoseconds => rgb!(format!("{:#?}", t), 0, 255, 0),
        TimeRange::MillisecondsFast => rgb!(format!("{:#?}", t), 127, 210, 0),
        TimeRange::MillisecondsMedium => rgb!(format!("{:#?}", t), 255, 165, 0),
        TimeRange::MillisecondsSlow => rgb!(format!("{:#?}", t), 255, 82, 0),
        TimeRange::Seconds => rgb!(format!("{:#?}", t), 255, 0, 0),
    }
}

pub fn validate<T>(func: impl Fn() -> T, expected: T, day: Day) -> Duration
where
    T: PartialEq,
    T: fmt::Debug,
{
    let start = Instant::now();
    let result = func();
    let total_time = start.elapsed();
    let colored_time = colorize_time(&total_time);
    assert_eq!(expected, result);
    println!("{day} solved in {colored_time}");
    total_time
}

pub fn perf<T>(func: impl Fn() -> T, iterations: usize) {
    let start = Instant::now();
    (0..iterations).for_each(|_| {
        func();
    });
    let colorized_time = colorize_time(&(start.elapsed() / iterations as u32));
    println!("Average: {colorized_time}");
}

#[cfg(test)]
mod test {
    use std::time::Duration;

    use super::colorize_time;

    #[test]
    fn test_colorize_time() {
        println!("time: {}", colorize_time(&Duration::from_secs(1)));
        println!("time: {}", colorize_time(&Duration::from_millis(500)));
        println!("time: {}", colorize_time(&Duration::from_millis(50)));
        println!("time: {}", colorize_time(&Duration::from_millis(5)));
        println!("time: {}", colorize_time(&Duration::from_nanos(500)));
    }
}
