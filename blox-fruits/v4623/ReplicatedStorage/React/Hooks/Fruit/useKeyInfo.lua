local React = require(game.ReplicatedStorage.Packages.React)
local useKeys = require(game.ReplicatedStorage.React.Hooks.Fruit.useKeys)
local useListAsTrueMap = require(game.ReplicatedStorage.React.Hooks.useListAsTrueMap)
local v = {}
return function(value: string?)
	local v3 = useListAsTrueMap((useKeys(false)))
	return React.useMemo(function()
		if not value then
			return nil
		end

		local v4 = v[value]

		if v4 then
			return v4
		end

		local isPermanent = value:find("Permanent ") ~= nil
		local permanent

		if value:find("Permanent ") then
			permanent = value
		else
			permanent = "Permanent " .. value
		end

		local physical = value:gsub("Permanent ", "")

		if not v3[physical] then
			return nil
		end

		local v8 = {
			Key = value,
			Permanent = permanent,
			Physical = physical,
			IsPermanent = isPermanent
		}
		table.freeze(v8)
		v[value] = v8
		return v8
	end, { value, v3 })
end