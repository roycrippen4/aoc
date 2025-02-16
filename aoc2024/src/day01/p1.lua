local example_path = "/home/roy/dev/aoc/aoc2024/src/day01/data/example.txt"
local input_path = "/home/roy/dev/aoc/aoc2024/src/day01/data/data.txt"

local ffi = require("ffi")
ffi.cdef([[
typedef long time_t;
typedef long suseconds_t;

struct timeval {
  time_t tv_sec; /* seconds */
  suseconds_t tv_usec; /* microseconds */
};

int gettimeofday(struct timeval *tv, void *tz);
]])

local tv = ffi.new("struct timeval")
local function now()
	ffi.C.gettimeofday(tv, nil)
	return tonumber(tv.tv_sec) * 1000000 + tonumber(tv.tv_usec)
end

---Reads text from an absolute path into a string array by line
---@param path string
---@return string[]
local function readlines(path)
	local lines = {}

	for line in io.lines(path) do
		lines[#lines + 1] = line
	end

	return lines
end

---Splits the input data into a left and right side
---@param lines string[]
---@return number[], number[]
local function split_lists(lines)
	local left = {}
	local right = {}

	for i, line in ipairs(lines) do
		local matcher = line:gmatch("%d+")
		left[i] = tonumber(matcher(), 10)
		right[i] = tonumber(matcher(), 10)
	end

	return left, right
end

---@param start_time integer
---@return string
local function format_time(start_time)
	local elapsed_us = now() - start_time
	local time_display

	if elapsed_us >= 1000000 then
		time_display = string.format("%.2fs", elapsed_us / 1000000)
	elseif elapsed_us >= 1000 then
		time_display = string.format("%.2fms", elapsed_us / 1000)
	else
		time_display = string.format("%dµs", elapsed_us)
	end

	return time_display
end

---@param example boolean
---@param expected integer
local function solve(example, expected)
	local start_time = now()
	local path = example and example_path or input_path
	local lines = readlines(path)
	local left, right = split_lists(lines)
	assert(#left == #right)

	table.sort(left)
	table.sort(right)

	local distance = 0
	for i = 1, #left do
		distance = distance + math.abs(left[i] - right[i])
	end

	assert(distance == expected)
	local time = "(solved in " .. format_time(start_time) .. ")"
	print("Answer: " .. distance, time)
end

solve(true, 11)
solve(false, 1506483)
