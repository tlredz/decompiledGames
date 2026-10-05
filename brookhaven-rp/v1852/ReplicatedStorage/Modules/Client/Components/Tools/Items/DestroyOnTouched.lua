local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "DestroyOnTouched"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Touched:Connect(function(otherPart)
		if otherPart and not (Players.LocalPlayer.Character and otherPart:IsDescendantOf(Players.LocalPlayer.Character)) then
			Debris:AddItem(self.Instance, 0)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v