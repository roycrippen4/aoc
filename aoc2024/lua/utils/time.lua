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
---@param day integer must be 1-25
---@param part integer must be 1 or 2
return function(fn, day, part)
	local start = now()
	local result, expected = fn()
	local time = format_time(start)
	local expected_str = "\n\nExpected: " .. expected .. "\nFound:    " .. result .. "\n"
	assert(result == expected, expected_str)
	print("Day " .. day .. " Part " .. part .. " solved in " .. time)
end
