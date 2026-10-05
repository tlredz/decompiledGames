local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local HUDButtonSelectionTracker = require(ReplicatedStorage.Modules.Client.UI.HUDButtonSelectionTracker)
local v = Component.new({
	Tag = "HUDButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:IsInstanceClickable()
	return self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton")
end

function v:Start()
	if not self:IsInstanceClickable() then
		return
	end

	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		HUDButtonSelectionTracker.SetLastClickedButton(instance)
	end))
end

function v:Stop()
	if self:IsInstanceClickable() then
		HUDButtonSelectionTracker.ClearIfMatches(self.Instance)
	end

	self._Janitor:Destroy()
end

return v