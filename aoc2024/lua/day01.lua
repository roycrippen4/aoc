---Splits the input data into a left and right side
---@param lines string[]
---@return number[], number[]
local function split_lists(lines)
	local left = {}
	local right = {}

	utils.iter(ipairs(lines)):each(function(i, line)
		local matcher = line:gmatch("%d+")
		left[i] = tonumber(matcher(), 10)
		right[i] = tonumber(matcher(), 10)
	end)

	return left, right
end

---@return integer, integer
local function part1()
	local lines = utils.get_input(1)
	local left, right = split_lists(lines)
	assert(#left == #right)

	table.sort(left)
	table.sort(right)

	---@param i integer
	---@param v integer
	---@return integer
	local function accumulate(acc, i, v)
		return acc + math.abs(v - right[i])
	end

	local distance = utils.iter(ipairs(left)):fold(0, accumulate)
	return distance, 1506483
end

---Computes the frequency map for elements in a list
---@param list integer[]
---@return table<integer, integer>
local function frequency_map(list)
	return utils.iter(list):fold({}, function(acc, value)
		if acc[value] then
			return acc
		end

		local function eq(v)
			return value == v
		end

		acc[value] = #(utils.iter(list):filter(eq):totable())

		return acc
	end)
end

-- let solve2 () =
--   let left_map, right_map = parse lines |> map_tuple into_frequency_map in
--   Hashtbl.fold
--     (fun n count acc ->
--       match Hashtbl.find_opt right_map n with
--       | Some count_right -> acc + (n * count * count_right)
--       | None -> acc)
--     left_map 0

---@return integer, integer
local function part2()
	local lines = utils.get_input(1)
	local left, right = split_lists(lines)
	assert(#left == #right)
	local left_map, right_map = frequency_map(left), frequency_map(right)

	local answer = utils.iter(pairs(left_map)):fold(0, function(acc, k, v)
		local count_right = right_map[k]
		if count_right then
			return acc + (k * v * count_right)
		end
		return acc
	end)

	return answer, 23126924
end

return {
	part1 = part1,
	part2 = part2,
}
