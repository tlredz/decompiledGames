local collections = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local array = collections.Array
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack
local lch2rgb = require(script.Parent:WaitForChild("lch2rgb"))

local function hcl2rgb(...)
	local reversed = array.reverse(unpack2(table.pack({ ... }), "hcl"))
	return lch2rgb(unpack(reversed))
end

return hcl2rgb