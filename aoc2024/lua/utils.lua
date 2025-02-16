local M = {}

function M.script_path()
	return debug.getinfo(2, "S").source:sub(2):match("(.*/)")
end

return M
