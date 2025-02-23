package.path = package.path .. ";./?/init.lua"

local utils = require("utils")
local day01 = require("day01")

utils.time_fn(day01.part1)
utils.time_fn(day01.part2)
