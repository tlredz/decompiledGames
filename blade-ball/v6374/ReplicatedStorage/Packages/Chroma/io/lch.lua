local collections = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2lch = require(script:WaitForChild("rgb2lch"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local array = collections.Array
local unpack2 = utils.unpack

function Color:lch()
	return rgb2lch(self._rgb)
end

function Color:hcl()
	return array.reverse(rgb2lch(self._rgb))
end

function chroma.lch(...)
	local v = table.pack(...)
	v[v.n + 1] = "lch"
	return Color.new(unpack(v, 1, v.n + 1))
end

function chroma.hcl(...)
	local v = table.pack(...)
	v[v.n + 1] = "hcl"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.lch = require(script:WaitForChild("lch2rgb"))
local format2 = input.format
format2.hcl = require(script:WaitForChild("hcl2rgb"))

for _, v in { "lch", "hcl" } do
	local v2 = v
	table.insert(input.autodetect, {
		p = 24,
		test = function(...)
			local v3 = unpack2(table.pack(...), v2)

			if type(v3) == "table" and #v3 == 3 then
				return v2
			end

			return nil
		end
	})
end

return nil