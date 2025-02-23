local M = {}

---Print contents of `tbl`, with indentation.
---`indent` sets the initial level of indentation.
---@param tbl table
---@param indent number?
function M.tprint(tbl, indent)
	indent = indent or 0
	for k, v in pairs(tbl) do
		local formatting = ("  "):rep(indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting .. "{")
			M.tprint(v, indent + 1)
			print(("  "):rep(indent) .. "}")
		else
			local value = type(v) == "boolean" and tostring(v) or v
			print(formatting .. tostring(value))
		end
	end
end

---Reads text from an absolute path into a string array by line
---@param path string
---@return string[]
function M.readlines(path)
	local lines = {}

	for line in io.lines(path) do
		lines[#lines + 1] = line
	end

	return lines
end

---@param day number The day of the challenge. 1-25
---@param example boolean? Whether to read the example file
function M.get_input(day, example)
	assert(day >= 1 and day <= 25, "Day must be between 1 and 25")
	local ex = example and "example" or "data"
	return M.readlines(string.format("../data/day%02d/%s.txt", day, ex))
end

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

---@param fn fun(): integer, integer
function M.time_fn(fn)
	local start = now()
	local result, expected = fn()
	local time = format_time(start)
	assert(result == expected, "Expected " .. expected .. " but got " .. result)
	print("Answer: " .. result, "(solved in " .. time .. ")")
end

return M
