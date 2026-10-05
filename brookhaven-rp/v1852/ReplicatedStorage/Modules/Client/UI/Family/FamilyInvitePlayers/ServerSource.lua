local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FamilyController = require(ReplicatedStorage.Modules.Client.UI.Family.FamilyController)
local localPlayer = Players.LocalPlayer
local ServerSource = {}
ServerSource.__index = ServerSource

function ServerSource.new()
	local self = setmetatable({}, ServerSource)
	self._Janitor = Janitor.new()
	self.PlayerAdded = Players.PlayerAdded
	self.PlayerRemoving = Players.PlayerRemoving
	return self
end

function ServerSource:GetPlayers()
	local result = {}

	for _, v in Players:GetPlayers() do
		if v == localPlayer or FamilyController.IsPlayerInFamily(v) then
			continue
		end

		table.insert(result, {
			Name = v.Name,
			UserId = v.UserId,
			DisplayName = v.DisplayName,
			IsOnline = true,
			InServer = true
		})
	end

	table.sort(result, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)
	return result
end

return ServerSource