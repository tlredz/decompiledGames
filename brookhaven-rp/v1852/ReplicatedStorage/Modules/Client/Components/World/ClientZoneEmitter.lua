local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "ClientZoneEmitter"
})
require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:Construct()
	self._Janitor = Janitor.new()
	self.PlayerEntered = Signal.new()
	self._Janitor:Add(self.PlayerEntered)
	self.PlayerLeft = Signal.new()
	self._Janitor:Add(self.PlayerLeft)
	self.playerInZone = false
end

function v:Start()
	self._Janitor:Add(self.PlayerEntered:Connect(function()
		if self.playerInZone then
			while task.wait(0.5) and self.playerInZone and self.Instance and self.Instance.Parent do
				local character = Players.LocalPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					break
				end

				local touchingParts = humanoidRootPart:GetTouchingParts()

				if not table.find(touchingParts, self.Instance) then
					break
				end
			end

			if self and self.PlayerLeft and self.playerInZone then
				self.playerInZone = false
				self.PlayerLeft:Fire()
			end
		end
	end))
	self._Janitor:Add(self.Instance.Touched:Connect(function(otherPart)
		if not (otherPart.Parent and otherPart.Parent:IsA("Model")) then
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(otherPart.Parent)

		if not playerFromCharacter or playerFromCharacter ~= Players.LocalPlayer then
			return
		end

		if not self.playerInZone then
			self.playerInZone = true
			self.PlayerEntered:Fire()
		end
	end))
end

function v:Stop()
	self.playerInZone = false
	self._Janitor:Destroy()
end

return v