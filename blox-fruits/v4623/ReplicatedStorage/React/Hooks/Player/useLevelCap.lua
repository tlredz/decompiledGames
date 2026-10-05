local Players = game:GetService("Players")
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local CONSTANTS = require(game.ReplicatedStorage.Util.LevelCap.CONSTANTS)
return function()
	local v = useAttribute(Players.LocalPlayer, CONSTANTS.LEVEL_CAP.ATTR_KEY)
	local v2 = useMockState("LevelCap", 2800)

	if v2 then
		return v2:get()
	end

	if type(v) == "number" then
		return v
	end

	return CONSTANTS.LEVEL_CAP.BASE
end