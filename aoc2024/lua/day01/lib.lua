local M = {}

---Splits the input data into a left and right side
---@param lines string[]
---@return number[], number[]
function M.split_lists(lines)
	local left = {}
	local right = {}

	for i, line in ipairs(lines) do
		local matcher = line:gmatch("%d+")
		left[i] = tonumber(matcher(), 10)
		right[i] = tonumber(matcher(), 10)
	end

	return left, right
end

return M
