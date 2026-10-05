local Players = game:GetService("Players")
local React = require(game.ReplicatedStorage.Packages.React)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useChildren = require(game.ReplicatedStorage.React.Hooks.Instance.useChildren)
local useHolding = require(game.ReplicatedStorage.React.Hooks.Player.useHolding)
return function()
	local v = useHolding()
	local v3 = useChildren((useMatchingChild(Players.LocalPlayer, function(backpack)
		if backpack:IsA("Backpack") then
			return backpack
		end

		return nil
	end)))
	return React.useMemo(function()
		local v4 = {}

		if v then
			v4[v] = true
		end

		if v3 then
			for _, tool in v3 do
				if tool:IsA("Tool") then
					v4[tool] = true
				end
			end
		end

		local result = {}

		for k, _ in pairs(v4) do
			table.insert(result, k)
		end

		table.freeze(result)
		return result
	end, { v, v3 })
end