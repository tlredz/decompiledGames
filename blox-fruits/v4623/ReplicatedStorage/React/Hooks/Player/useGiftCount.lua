local Players = game:GetService("Players")
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
return function()
	local selected = useAttribute(Players.LocalPlayer, "GiftCount")
	local v2 = useMockState("GiftCount", 0)

	if v2 then
		selected = v2:get()
	end

	if type(selected) == "number" then
		return selected
	end

	return nil
end