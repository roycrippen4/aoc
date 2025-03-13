require("utils.rgb")

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

M.iter = require("utils.iter")
M.time = require("utils.time")

return M
