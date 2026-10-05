local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleControlsTestController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleControlsTestController)
local Component = require(ReplicatedStorage.Packages.Component)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleControlsSetting"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.scope = Fusion.scoped(Fusion)
	self._Janitor:Add(function()
		Fusion.doCleanup(self.scope)
	end)
end

function v:Start()
	local greenCheckMark = self.Instance:WaitForChild("GreenCheckMark")
	self.scope:Hydrate(self.Instance)({
		Visible = VehicleControlsTestController.IsSettingVisibleValue()
	})
	self.scope:Hydrate(greenCheckMark)({
		Visible = VehicleControlsTestController.IsEnabledValue()
	})
	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		VehicleControlsTestController.SetEnabled(not Fusion.peek(VehicleControlsTestController.IsEnabledValue()))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v