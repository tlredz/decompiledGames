local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReplicatedPlayerData = require(game.ReplicatedStorage.Util.ReplicatedPlayerData)
return function()
	local localPlayer

	if RunService:IsRunning() then
		localPlayer = Players.LocalPlayer
	else
		localPlayer = nil
	end

	return React.useMemo(function()
		if localPlayer then
			return ReplicatedPlayerData.read(localPlayer)
		end

		return nil
	end, { localPlayer })
end