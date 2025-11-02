/// An enum representing days for Advent of Code problems (1-25).
/// Each variant corresponds to a day number in the challenge.
pub const Day = enum {
    @"01",
    @"02",
    @"03",
    @"04",
    @"05",
    @"06",
    @"07",
    @"08",
    @"09",
    @"10",
    @"11",
    @"12",
    @"13",
    @"14",
    @"15",
    @"16",
    @"17",
    @"18",
    @"19",
    @"20",
    @"21",
    @"22",
    @"23",
    @"24",
    @"25",

    /// Converts the Day enum variant to a formatted string.
    /// Returns a string in the format "Day XX" where XX is a zero-padded two-digit number.
    /// Example: Day.two becomes "Day 02", Day.twenty_five becomes "Day 25"
    pub fn toString(self: Day) []const u8 {
        return switch (self) {
            .@"01" => "Day 01",
            .@"02" => "Day 02",
            .@"03" => "Day 03",
            .@"04" => "Day 04",
            .@"05" => "Day 05",
            .@"06" => "Day 06",
            .@"07" => "Day 07",
            .@"08" => "Day 08",
            .@"09" => "Day 09",
            .@"10" => "Day 10",
            .@"11" => "Day 11",
            .@"12" => "Day 12",
            .@"13" => "Day 13",
            .@"14" => "Day 14",
            .@"15" => "Day 15",
            .@"16" => "Day 16",
            .@"17" => "Day 17",
            .@"18" => "Day 18",
            .@"19" => "Day 19",
            .@"20" => "Day 20",
            .@"21" => "Day 21",
            .@"22" => "Day 22",
            .@"23" => "Day 23",
            .@"24" => "Day 24",
            .@"25" => "Day 25",
        };
    }
};
