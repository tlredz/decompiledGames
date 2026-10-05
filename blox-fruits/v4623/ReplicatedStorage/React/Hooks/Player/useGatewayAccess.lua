local Players = game:GetService("Players")
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local CONSTANTS = require(game.ReplicatedStorage.Controllers.IslandController.WorldTeleporter.CONSTANTS)
return function()
	local v = useAttribute(Players.LocalPlayer, CONSTANTS.UNLOCKED_ATTR_KEY)
	local v2 = useMockState("GatewayAccess", true)

	if v2 then
		return v2:get()
	end

	if type(v) == "boolean" then
		return v
	end

	return nil
end