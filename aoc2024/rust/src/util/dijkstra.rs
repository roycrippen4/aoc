use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap};
use std::fmt::Debug;

use super::{Grid, Point};

pub trait Walkable<T: Copy + Debug> {
    /// The type used to measure distance/weight (e.g., i32, f32, u64).
    /// Only requires Copy and Debug. Does **NOT** require Ord or Add
    /// because this trait manually defines how to do those things.
    type Cost: Copy + Debug;

    /// The cost at the starting position (the neutral element).
    /// Typically 0.
    fn zero() -> Self::Cost;

    /// Adds two costs together.
    /// `cost_a` is usually the accumulated path, `cost_b` is the step cost.
    fn add(cost_a: Self::Cost, cost_b: Self::Cost) -> Self::Cost;

    /// Defines the Total Order for the priority queue.
    ///
    /// Note: This allows using floats (f32) which are not normally Ord,
    /// provided you handle NaNs in this implementation.
    fn cmp(cost_a: &Self::Cost, cost_b: &Self::Cost) -> Ordering;

    /// Determines if a cell can be entered.
    fn passable(t: T) -> bool;

    /// Calculates the cost to step onto a specific cell.
    fn cost_of(t: T) -> Self::Cost;
}

struct Node<W, T>
where
    W: Walkable<T>,
    T: Copy + Debug,
{
    cost: W::Cost,
    pos: Point,
}

impl<W, T> PartialEq for Node<W, T>
where
    W: Walkable<T>,
    T: Copy + Debug,
{
    fn eq(&self, other: &Self) -> bool {
        W::cmp(&self.cost, &other.cost) == Ordering::Equal
    }
}

impl<W: Walkable<T>, T: Copy + Debug> Eq for Node<W, T> {}

impl<W, T> PartialOrd for Node<W, T>
where
    W: Walkable<T>,
    T: Copy + Debug,
{
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl<W, T> Ord for Node<W, T>
where
    W: Walkable<T>,
    T: Copy + Debug,
{
    fn cmp(&self, other: &Self) -> Ordering {
        W::cmp(&other.cost, &self.cost)
    }
}

type PrevMap = HashMap<Point, Point>;
fn reconstruct(point: Point, previous: &mut PrevMap) -> Vec<Point> {
    let mut acc = vec![];
    let mut current_point = point;

    loop {
        acc.push(current_point);

        match previous.get(&current_point) {
            Some(previous) => current_point = *previous,
            None => break,
        }
    }

    acc
}

pub fn walk<W, T>(grid: &Grid<T>, start: Point, end: Point) -> Option<Vec<Point>>
where
    W: Walkable<T>,
    T: Copy + Debug,
{
    let is_accessible = |p| grid.inside(p) && W::passable(*grid.get(p).unwrap());
    let can_start = is_accessible(start);
    let can_end = is_accessible(end);

    if !(can_start && can_end) {
        return None;
    }

    let mut distance: HashMap<Point, W::Cost> = HashMap::new();
    let mut previous: PrevMap = HashMap::new();
    let mut priority_q: BinaryHeap<Node<W, T>> = BinaryHeap::new();

    distance.insert(start, W::zero());
    priority_q.push(Node {
        cost: W::zero(),
        pos: start,
    });

    while let Some(Node { cost, pos }) = priority_q.pop() {
        if pos == end {
            return Some(reconstruct(pos, &mut previous));
        }

        let is_stale = match distance.get(&pos) {
            Some(best) => W::cmp(&cost, best) == Ordering::Greater,
            None => true,
        };

        if is_stale {
            continue;
        }

        for nbor in grid.nbor4(pos).into_iter().flatten() {
            let nbor: Point = nbor.into();

            let cell = match grid.get(nbor) {
                Some(cell) if W::passable(*cell) => *cell,
                _ => continue,
            };

            let new_cost = W::add(cost, W::cost_of(cell));
            let is_improvement = match distance.get(&nbor) {
                Some(best_cost) => W::cmp(&new_cost, best_cost) == Ordering::Less,
                None => true,
            };

            if is_improvement {
                distance.insert(nbor, new_cost);
                previous.insert(nbor, pos);

                priority_q.push(Node {
                    cost: new_cost,
                    pos: nbor,
                });
            }
        }
    }

    None
}
