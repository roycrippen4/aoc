---@param r integer
---@param g integer
---@param b integer
local function validate(r, g, b)
	assert(r >= 0 and r <= 255, "Invalid argument `r`. `" .. r .. "` is out of bounds")
	assert(g >= 0 and g <= 255, "Invalid argument `g`. `" .. g .. "` is out of bounds")
	assert(b >= 0 and b <= 255, "Invalid argument `b`. `" .. b .. "` is out of bounds")
end

---Colorize string `s` via `r`, `g`, `b` values
---@param s string
---@param r integer
---@param g integer
---@param b integer
function string.rgb(s, r, g, b)
	validate(r, g, b)
	return string.format("\x1b[38;2;%d;%d;%dm%s\x1b[0m", r, g, b, s)
end
