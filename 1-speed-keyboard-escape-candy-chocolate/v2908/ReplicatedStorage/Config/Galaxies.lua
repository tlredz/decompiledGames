local modulesByINDEX = {}
local Galaxies = {}

for _, moduleScript in ipairs(script:GetChildren()) do
	local module = require(moduleScript)
	modulesByINDEX[module.INDEX] = module
end

function Galaxies.get(p: number)
	return modulesByINDEX[p]
end

function Galaxies.getOrdered()
	local result = {}

	for _, v in pairs(modulesByINDEX) do
		table.insert(result, v)
	end

	table.sort(result, function(a, b)
		return a.INDEX < b.INDEX
	end)
	return result
end

return Galaxies