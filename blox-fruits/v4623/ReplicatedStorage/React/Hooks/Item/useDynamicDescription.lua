local Players = game:GetService("Players")
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useHasTag = require(game.ReplicatedStorage.React.Hooks.Instance.useHasTag)
return function(p: number?, data)
	local v = useMatch(p)
	local v2 = useHasTag("ForceDragonChoiceEast", Players.LocalPlayer)
	local v3 = useHasTag("ForceDragonChoice2East", Players.LocalPlayer)
	local v4 = useHasTag("ForceDragonChoiceWest", Players.LocalPlayer)
	local v5 = useHasTag("ForceDragonChoice2West", Players.LocalPlayer)

	if not v then
		return nil
	end

	if table.find(v.Inventory.Brackets, "Fish") and data and data.Type == "Fish" then
		local weight = data.Weight
		local v6 = {}
		local modifiers = data.Modifiers

		if modifiers and #modifiers > 0 then
			table.insert(v6, (`<{table.concat(modifiers, ", ")}>`))
		end

		if weight then
			local v7 = math.floor(tonumber(weight) * 100) / 100
			table.insert(v6, "Weight")
			table.insert(v6, (`{v7 or "???"}kg`))
		end

		return table.concat(v6, "\n")
	elseif table.find(v.Inventory.Brackets, "DragonToken") and data and data.Type == "DragonToken" then
		if not Players.LocalPlayer then
			return nil
		end

		if v2 or v3 then
			return "Guaranteed Dragon (East) on first use. Redeems a random mythical fruit (includes Dragon)!"
		end

		if v4 or v5 then
			return "Guaranteed Dragon (West) on first use. Redeems a random mythical fruit (includes Dragon)!"
		end
	end

	return nil
end