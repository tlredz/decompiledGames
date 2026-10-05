local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local BackpackVisibilityController = require(ReplicatedStorage.Modules.Client.Player.BackpackVisibilityController)
local v = Component.new({
	Tag = "ToggleBackpackVisibleOnShow"
})
local count = 0

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("GuiObject") then
		return
	end

	count += 1
	local formatted = `ToggleBackpackVisibleOnShow_{count}`
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		BackpackVisibilityController.SetVisibility(not instance.Visible, formatted)
	end))
	self._Janitor:Add(function()
		BackpackVisibilityController.SetVisibility(true, formatted)
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v