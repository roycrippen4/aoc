use crate::data;

#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
struct PrizeTarget {
    x: usize,
    y: usize,
}

impl From<&str> for PrizeTarget {
    fn from(s: &str) -> Self {
        let s = s.strip_prefix("Prize: X=").unwrap();
        let (x_str, y_str) = s.split_once(", Y=").unwrap();
        let x = x_str.parse().unwrap();
        let y = y_str.parse().unwrap();
        Self { x, y }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
struct Button {
    x: usize,
    y: usize,
    cost: usize,
}

impl From<&str> for Button {
    fn from(s: &str) -> Self {
        let (left, right) = s.split_at(9);
        let cost = match left.chars().nth(7).unwrap() {
            'A' => 3,
            'B' => 1,
            _ => unreachable!(),
        };
        let x: usize = right.get(3..=4).unwrap().parse().unwrap();
        let y: usize = right.get(9..=10).unwrap().parse().unwrap();
        Self { x, y, cost }
    }
}

fn is_positive_integer(v: f64) -> bool {
    v.is_sign_positive() && v.fract().eq(&0.0)
}

fn parse_machine(s: &str) -> (Button, Button, PrizeTarget) {
    let parts = s.trim().split('\n').collect::<Vec<_>>();
    assert_eq!(parts.len(), 3, "{s} has more than 3 parts!");
    (
        Button::from(parts[0]),
        Button::from(parts[1]),
        PrizeTarget::from(parts[2]),
    )
}

fn parse_input(s: &str) -> Vec<(Button, Button, PrizeTarget)> {
    s.split("\n\n").map(parse_machine).collect()
}

// I honestly have no idea how/why this works.
// It got into linear algebra theory I don't really understand.
// I got the equations from ChatGPT; I only translated the math notation into rust code.
fn get_cheapest((a, b, p): (Button, Button, PrizeTarget)) -> usize {
    let determinant = (a.x * b.y) as isize - (a.y * b.x) as isize;

    if determinant != 0 {
        let pxby = (p.x * b.y) as f64;
        let bxpy = (b.x * p.y) as f64;
        let i = (pxby - bxpy) / determinant as f64;

        if !is_positive_integer(i) {
            return 0;
        }

        let axpy = (a.x * p.y) as f64;
        let pxay = (p.x * a.y) as f64;
        let j = (axpy - pxay) / determinant as f64;

        if !is_positive_integer(j) {
            return 0;
        }

        return (i as usize * a.cost) + (j as usize * b.cost);
    }

    0
}

fn evaluate(data: &str) -> usize {
    parse_input(data).into_iter().map(get_cheapest).sum()
}

pub fn solve() -> usize {
    evaluate(data!())
}

#[cfg(test)]
mod test {
    use crate::{
        example,
        util::{Day::Day13, Part::Part1, validate},
    };

    use super::{Button, PrizeTarget, evaluate, get_cheapest, parse_machine, solve};

    #[test]
    fn test_solve() {
        validate(solve, 29436, Day13(Part1));
    }

    #[test]
    fn test_evaluate() {
        assert_eq!(evaluate(example!()), 480);
    }

    #[test]
    fn test_get_cheapest() {
        let text = "Button A: X+94, Y+34\nButton B: X+22, Y+67\nPrize: X=8400, Y=5400";
        let machine = parse_machine(text);
        assert_eq!(280, get_cheapest(machine));

        let text = "Button A: X+17, Y+86\nButton B: X+84, Y+37\nPrize: X=7870, Y=6450";
        let machine = parse_machine(text);
        assert_eq!(200, get_cheapest(machine));
    }

    #[test]
    fn test_parse_machine() {
        let text = "Button A: X+94, Y+34\nButton B: X+22, Y+67\nPrize: X=8400, Y=5400";
        let expected_a = Button {
            x: 94,
            y: 34,
            cost: 3,
        };
        let expected_b = Button {
            x: 22,
            y: 67,
            cost: 1,
        };
        let expected_prize = PrizeTarget { x: 8400, y: 5400 };
        let (a, b, prize) = parse_machine(text);
        assert_eq!(a, expected_a);
        assert_eq!(b, expected_b);
        assert_eq!(prize, expected_prize);
    }

    #[test]
    fn test_button_from_str() {
        let b = Button::from("Button A: X+94, Y+34");
        assert_eq!(b.cost, 3);
        assert_eq!(b.x, 94);
        assert_eq!(b.y, 34);

        let b = Button::from("Button B: X+22, Y+67");
        assert_eq!(b.cost, 1);
        assert_eq!(b.x, 22);
        assert_eq!(b.y, 67);
    }

    #[test]
    fn test_prize_target_from_str() {
        let p = PrizeTarget::from("Prize: X=8400, Y=5400");
        assert_eq!(p.x, 8400);
        assert_eq!(p.y, 5400);
    }
}
