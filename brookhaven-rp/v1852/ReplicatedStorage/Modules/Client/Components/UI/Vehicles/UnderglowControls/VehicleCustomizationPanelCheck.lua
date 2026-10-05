local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local VehicleUIImprovementABTest = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleUIImprovementABTest)
local v = Component.new({
	Tag = "VehicleCustomizationPanelCheck"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	for _, objectValue in self.Instance:GetChildren() do
		if not (objectValue:IsA("ObjectValue") and objectValue.Value and objectValue.Name == "Panel") then
			continue
		end

		local value = objectValue.Value
		self.Instance.Visible = false
		self._Janitor:Add(value:GetPropertyChangedSignal("Visible"):Connect(function()
			if VehicleUIImprovementABTest.IsEnabled() then
				self.Instance.Visible = false
			else
				self.Instance.Visible = value.Visible
			end
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v