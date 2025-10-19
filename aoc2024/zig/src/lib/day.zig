/// An enum representing days for Advent of Code problems (1-25).
/// Each variant corresponds to a day number in the challenge.
pub const Day = enum {
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    ten,
    eleven,
    twelve,
    thirteen,
    fourteen,
    fifteen,
    sixteen,
    seventeen,
    eighteen,
    nineteen,
    twenty,
    twenty_one,
    twenty_two,
    twenty_three,
    twenty_four,
    twenty_five,

    /// Converts the Day enum variant to a formatted string.
    /// Returns a string in the format "Day XX" where XX is a zero-padded two-digit number.
    /// Example: Day.two becomes "Day 02", Day.twenty_five becomes "Day 25"
    pub fn toString(self: Day) []const u8 {
        return switch (self) {
            .one => "Day 01",
            .two => "Day 02",
            .three => "Day 03",
            .four => "Day 04",
            .five => "Day 05",
            .six => "Day 06",
            .seven => "Day 07",
            .eight => "Day 08",
            .nine => "Day 09",
            .ten => "Day 10",
            .eleven => "Day 11",
            .twelve => "Day 12",
            .thirteen => "Day 13",
            .fourteen => "Day 14",
            .fifteen => "Day 15",
            .sixteen => "Day 16",
            .seventeen => "Day 17",
            .eighteen => "Day 18",
            .nineteen => "Day 19",
            .twenty => "Day 20",
            .twenty_one => "Day 21",
            .twenty_two => "Day 22",
            .twenty_three => "Day 23",
            .twenty_four => "Day 24",
            .twenty_five => "Day 25",
        };
    }
};
