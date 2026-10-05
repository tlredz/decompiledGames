local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "Wheelbarrow"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.tool = self.Instance
	local sound = self.Instance:FindFirstChild("Wheel"):FindFirstChild("Sound")
	self._Janitor:Add(self.tool.Equipped:Connect(function()
		sound:AddTag("PlaySoundWhileMoving")
		sound.Volume = 0.5
	end))
	self._Janitor:Add(self.tool.Unequipped:Connect(function()
		sound:RemoveTag("PlaySoundWhileMoving")
		sound.Volume = 0
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v