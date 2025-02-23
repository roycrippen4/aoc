local utils = require("utils")

local M = {}

---@return integer, integer
function M.solve()
	local lines = utils.get_input(1)
	local left, right = require("day01.lib").split_lists(lines)
	assert(#left == #right)

	table.sort(left)
	table.sort(right)

	local distance = 0
	for i = 1, #left do
		distance = distance + math.abs(left[i] - right[i])
	end

	return distance, 23126924
end

return M
