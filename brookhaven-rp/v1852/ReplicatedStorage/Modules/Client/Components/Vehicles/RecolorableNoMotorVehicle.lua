local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "RecolorableNoMotorVehicle"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local playerFromCharacter = Players:GetPlayerFromCharacter(self.Instance.Parent)

	if not playerFromCharacter then
		local playerObject = self.Instance:WaitForChild("PlayerObject", 10)

		if playerObject then
			playerFromCharacter = playerObject.Value
		end
	end

	self._isOwner = playerFromCharacter == Players.LocalPlayer
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v