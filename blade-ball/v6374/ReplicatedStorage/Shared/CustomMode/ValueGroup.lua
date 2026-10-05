local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Freeze)
local ValueGroup = {}

function ValueGroup.new(valueType: string, options)
	local v2 = {
		valueType = valueType,
		options = options or {},
		_calculatedOptions = {}
	}
	table.freeze(v2)
	return (setmetatable(v2, {
		__index = ValueGroup
	}))
end

function ValueGroup:extend(p2)
	local v2 = {
		valueType = self.valueType,
		options = v.List.merge(self.options, p2)
	}
	table.freeze(v2)
	return (setmetatable(v2, p2))
end

function ValueGroup.getOptions(p, p2)
	local result = {}

	for _, option in next, p.options, nil do
		local v2 = option:find("(", nil, true)
		local v3 = option:find(")", nil, true)

		if v2 and v3 then
			local v4 = p2[option:sub(v2, v3)]

			if v4 then
				for _, v5 in next, v4, nil do
					table.insert(result, v5 .. option:sub(v3 + 1))
				end
			else
				table.insert(result, option)
			end
		else
			table.insert(result, option)
		end
	end

	table.freeze(result)
	return result
end

local v2 = {
	Number = ValueGroup.new("Number", { "Ball Speed", "(Player)'s Health", "(Player)'s Speed" }),
	Text = ValueGroup.new("Text", { "(Player)'s Username" }),
	Player = ValueGroup.new("Player")
}
table.freeze(v2)
local v3 = {
	Number = v2.Number,
	Text = v2.Text:extend({ "(Player)'s Team" }),
	Player = v2.Player
}
table.freeze(v3)
local v4 = {
	Number = v3.Number,
	Text = v3.Text,
	Player = v3.Player:extend({ "(Team) Leader" })
}
table.freeze(v4)
ValueGroup.Presets = {
	["Bot Battle"] = v2,
	Classic = v2,
	["2 Teams"] = v3,
	["4 Teams"] = v3,
	["1 vs All"] = v4,
	["2 Teams Leader"] = v4
}
return ValueGroup