local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local WrapsConfig = require(ReplicatedStorage.Modules.Shared.DB.Vehicles.WrapsConfig)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
local v = Component.new({
	Tag = "VehicleWrapsUI"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._vehicleJanitor = self._Janitor:Add(Janitor.new())
	self._activeOwnedVehicles = {}
end

function v:Start()
	self._Janitor:Add(VehicleController.OnPlayerStartedDriving:Connect(function()
		self:TrackVehicle(VehicleController.GetCurrentDrivingVehicleModel())
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDriving:Connect(function()
		self:StopTrackingVehicle()
	end))
	self._Janitor:Add(VehicleController.OnPlayerStartedDrivingLegacy:Connect(function()
		self:TrackVehicle(VehicleController.GetCurrentDrivingVehicleModel())
	end))
	self._Janitor:Add(VehicleController.OnPlayerStoppedDrivingLegacy:Connect(function()
		self:StopTrackingVehicle()
	end))
	self:SetupUI()
end

function v:SetupUI()
	local template = self.Instance:WaitForChild("Template")

	for k, v2 in WrapsConfig.GetConfig() do
		local v3 = self._Janitor:Add(template:Clone())
		v3.Name = k
		v3.Icon.Image = `rbxassetid://{v2.DecalId}`
		v3.DisplayName.TextLabel.Text = v2.DisplayName
		v3.LayoutOrder = v2.LayoutOrder
		v3.Parent = self.Instance
		local v4 = k
		self._Janitor:Add(v3.Activated:Connect(function()
			Remotes.fireServer("ApplyWrapToActiveVehicle", v4)
		end))
	end

	template.Visible = false
	self.Instance.CanvasSize = UDim2.fromOffset(0, self.Instance.UIGridLayout.AbsoluteContentSize.Y)
end

function v:TrackDecalPart(instance)
	if not instance:HasTag("VehicleWrapPart") then
		return
	end

	self:UpdateSelected(instance:GetAttribute("Wrap"))
	self._vehicleJanitor:Add(instance:GetAttributeChangedSignal("Wrap"):Connect(function()
		self:UpdateSelected(instance:GetAttribute("Wrap"))
	end))
end

function v:TrackVehicle(ancestor)
	self._vehicleJanitor:Cleanup()
	local tagged = CollectionService:GetTagged("VehicleWrapPart")

	for _, v2 in tagged do
		if v2:IsDescendantOf(ancestor) then
			self:TrackDecalPart(v2)
		end
	end

	self._vehicleJanitor:Add(CollectionService:GetInstanceAddedSignal("VehicleWrapPart"):Connect(function(instance)
		if instance:IsDescendantOf(ancestor) then
			self:TrackDecalPart(instance)
		end
	end))
end

function v:StopTrackingVehicle()
	self:UpdateSelected("Default")
	self._vehicleJanitor:Cleanup()
end

function v:UpdateSelected(p2: string)
	for _, guiObject in self.Instance:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		if guiObject.Name == p2 and p2 ~= "Default" then
			guiObject:AddTag("Checked")
		else
			guiObject:RemoveTag("Checked")
		end
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v