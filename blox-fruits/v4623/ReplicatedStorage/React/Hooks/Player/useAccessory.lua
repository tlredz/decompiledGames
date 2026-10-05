local React = require(game.ReplicatedStorage.Packages.React)
local useDynamicAccessories = require(game.ReplicatedStorage.React.Hooks.Player.useDynamicAccessories)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
return function()
	local v = useDynamicAccessories()
	local v2, v3 = React.useMemo(function()
		if v then
			for k, v4 in v do
				if v4.Type == "Super" and v4.Equipped then
					return v4.Name, k
				end
			end
		end

		return nil
	end, { v })
	local v4 = useMatch(v2, "Accessory")

	if v2 and v4 then
		return v4.Index.ItemId, v3
	end

	return nil, nil
end