local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local module = require("../VFX")
local flag = false
local v = Component.new({
	Tag = LuminescentCavern.Enums.CollectionService.LightingPart,
	Ancestors = { Workspace }
})

function v:Construct()
	local UID = self.Instance:GetAttribute("UID")
	self.Connection = nil
	self.Thread = nil

	if UID == LuminescentCavern.Enums.LightingParts.Entrance then
		self:_ConstructEntrance()
	elseif UID == LuminescentCavern.Enums.LightingParts.ProximityPart then
		self:_ConstructProximityPart()
	end
end

function v.Stop(p)
	if p.Connection then
		p.Connection:Disconnect()
	end

	if p.Thread then
		task.cancel(p.Thread)
	end
end

function v:_ConstructEntrance()
	if self.Connection then
		return
	end

	self.Connection = self.Instance.Touched:Connect(function(otherPart)
		local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

		if not playerFromCharacter or playerFromCharacter ~= Players.LocalPlayer then
			flag = true
			module.SetCavernLightingState(true)
		end
	end)
end

function v:_ConstructProximityPart()
	if self.Thread then
		return
	end

	self.Thread = task.spawn(function()
		while true do
			task.wait(1)

			if not flag then
				continue
			end

			local character = Players.LocalPlayer.Character

			if character then
				if (character.PrimaryPart.Position - self.Instance.Position).magnitude >= 30 then
					flag = false
					module.SetCavernLightingState(false)
				end
			else
				flag = false
				module.SetCavernLightingState(false)
			end
		end
	end)
end

return v