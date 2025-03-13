package.path = package.path .. ";./?/init.lua"
_G.utils = require("utils")

local day01 = require("day01")

utils.time(day01.part1, 1, 1)
utils.time(day01.part2, 1, 2)
