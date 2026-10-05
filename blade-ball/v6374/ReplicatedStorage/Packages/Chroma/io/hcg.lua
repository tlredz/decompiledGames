local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2hcg = require(script:WaitForChild("rgb2hcg"))
local utils = require(script.Parent.Parent:WaitForChild("utils"))
local unpack2 = utils.unpack

function Color:hcg()
	return rgb2hcg(self._rgb)
end

function chroma.hcg(...)
	local v = table.pack(...)
	v[v.n + 1] = "hcg"
	return Color.new(unpack(v, 1, v.n + 1))
end

local format = input.format
format.hcg = require(script:WaitForChild("hcg2rgb"))
table.insert(input.autodetect, {
	p = 19,
	test = function(...)
		local v = unpack2(table.pack(...), "hcg")

		if type(v) == "table" and #v == 3 then
			return "hcg"
		end

		return nil
	end
})
return nil