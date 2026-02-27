use std::ops::{Index, IndexMut};

#[allow(unused)]
#[derive(Debug)]
pub struct Stack<T, const N: usize>
where
    T: Copy + Default,
{
    length: usize,
    items: [T; N],
    capacity: usize,
}

impl<T, const N: usize> Default for Stack<T, N>
where
    T: Copy + Default,
{
    fn default() -> Self {
        Self {
            length: Default::default(),
            items: [T::default(); N],
            capacity: Default::default(),
        }
    }
}

// #[test]
// fn foo() {
//     let slice: &[usize] = &vec![1, 2, 3];
// }

#[allow(unused)]
impl<T, const N: usize> Stack<T, N>
where
    T: Copy + Default,
{
    pub fn new() -> Self {
        Self::default()
    }

    pub fn len(&self) -> usize {
        self.length
    }

    pub const fn from_slice(slice: &[T]) -> Self {
        if slice.len() > N || slice.is_empty() {
            panic!("slice length must be smaller than Stacks `N`");
        }

        let mut items = [slice[0]; N];
        let mut i = 0;

        while i < slice.len() {
            items[i] = slice[i];
            i += 1;
        }

        Self {
            capacity: N,
            length: slice.len(),
            items,
        }
    }

    pub fn push(&mut self, item: T) {
        self.items[self.length] = item;
        self.length += 1;
    }

    pub fn push_safe(&mut self, item: T) -> Result<(), ()> {
        if self.length == self.capacity {
            return Err(());
        }
        self.push(item);
        Ok(())
    }

    pub fn pop(&mut self) -> Option<T> {
        if self.length == 0 {
            return None;
        }
        self.length -= 1;
        Some(self.items[self.length])
    }

    pub fn is_empty(&self) -> bool {
        self.length == 0
    }

    pub fn as_slice(&self) -> &[T] {
        unsafe { std::slice::from_raw_parts(self.items.as_ptr(), self.length) }
    }

    pub fn clear(&mut self) {
        self.length = 0;
    }

    pub fn get(&self, i: usize) -> Option<T> {
        if (i >= self.length) {
            return None;
        }
        Some(self.items[i])
    }

    pub fn fill(&mut self, value: T) {
        self.items.fill(value);
    }

    pub fn iter(&self) -> std::slice::Iter<'_, T> {
        self.items[..self.length].iter()
    }

    /// Returns an iterator over mutable references to the elements.
    pub fn iter_mut(&mut self) -> std::slice::IterMut<'_, T> {
        let len = self.length;
        self.items[..len].iter_mut()
    }
}

impl<T, const N: usize> From<[T; N]> for Stack<T, N>
where
    T: Copy + Default,
{
    fn from(array: [T; N]) -> Self {
        Self {
            items: array,
            capacity: N,
            length: N,
        }
    }
}

impl<T, const N: usize> Index<usize> for Stack<T, N>
where
    T: Copy + Default,
{
    type Output = T;

    fn index(&self, index: usize) -> &Self::Output {
        &self.items[index]
    }
}

impl<T, const N: usize> IndexMut<usize> for Stack<T, N>
where
    T: Copy + Default,
{
    fn index_mut(&mut self, index: usize) -> &mut Self::Output {
        &mut self.items[index]
    }
}

impl<'a, T, const N: usize> IntoIterator for &'a Stack<T, N>
where
    T: Copy + Default,
{
    type Item = &'a T;
    type IntoIter = std::slice::Iter<'a, T>;

    fn into_iter(self) -> Self::IntoIter {
        self.iter()
    }
}

impl<'a, T, const N: usize> IntoIterator for &'a mut Stack<T, N>
where
    T: Copy + Default,
{
    type Item = &'a mut T;
    type IntoIter = std::slice::IterMut<'a, T>;

    fn into_iter(self) -> Self::IntoIter {
        self.iter_mut()
    }
}

pub struct StackIter<T, const N: usize>
where
    T: Copy + Default,
{
    stack: Stack<T, N>,
    front: usize,
}

impl<T, const N: usize> Iterator for StackIter<T, N>
where
    T: Copy + Default,
{
    type Item = T;

    fn next(&mut self) -> Option<Self::Item> {
        if self.front < self.stack.length {
            let item = self.stack.items[self.front];
            self.front += 1;
            Some(item)
        } else {
            None
        }
    }

    fn size_hint(&self) -> (usize, Option<usize>) {
        let remaining = self.stack.length - self.front;
        (remaining, Some(remaining))
    }
}

impl<T, const N: usize> DoubleEndedIterator for StackIter<T, N>
where
    T: Copy + Default,
{
    fn next_back(&mut self) -> Option<Self::Item> {
        if self.front < self.stack.length {
            self.stack.length -= 1; // Consume from the back
            Some(self.stack.items[self.stack.length])
        } else {
            None
        }
    }
}

impl<T, const N: usize> ExactSizeIterator for StackIter<T, N> where T: Copy + Default {}

impl<T, const N: usize> IntoIterator for Stack<T, N>
where
    T: Copy + Default,
{
    type Item = T;
    type IntoIter = StackIter<T, N>;

    fn into_iter(self) -> Self::IntoIter {
        StackIter {
            stack: self,
            front: 0,
        }
    }
}
