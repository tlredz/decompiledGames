local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local EstateSurfacingTelemetry = require(ReplicatedStorage.Modules.Client.Houses.ABTests.EstateSurfacingTelemetry)
local HouseViewCamera = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.HouseViewCamera)
local color = Color3.fromRGB(133, 255, 80)
local color2 = Color3.fromRGB(255, 100, 100)
local v = Component.new({
	Tag = "EstatePlotPickerPopup"
})
v.OnDismissed = Signal.new()

function v:Construct()
	self._Janitor = Janitor.new()
	self._plotButtonJanitor = Janitor.new()
	self._occupancyJanitor = Janitor.new()
	self._completedPlotPick = false
	self._shouldRestoreHouseMenuOnDismiss = false
end

function v:setPlotButtonStatus(instance, flag: boolean)
	instance.AutoButtonColor = false
	local statusLabel = instance:FindFirstChild("StatusLabel")

	if statusLabel ~= nil and statusLabel:IsA("TextLabel") then
		statusLabel.Visible = true

		if flag then
			statusLabel.Text = "(Open)"
		else
			statusLabel.Text = "(Occupied)"
		end
	end

	if flag then
		instance.BackgroundColor3 = color
	else
		instance.BackgroundColor3 = color2
	end
end

function v:Start()
	local background = self.Instance:WaitForChild("Background")
	self._titleLabel = background:WaitForChild("TitleBar"):WaitForChild("Title")
	self._plotList = background:WaitForChild("PlotList")
	local close = background:FindFirstChild("Close")

	if close ~= nil and (close:IsA("GuiButton") or close:IsA("ImageButton")) then
		self._Janitor:Add(close.Activated:Connect(function()
			self._shouldRestoreHouseMenuOnDismiss = true
			PanelController.Close("MainGUIHandler", "EstatePlotPickerPopup")
		end))
	end

	local v2 = PanelController.WaitForPanel("MainGUIHandler", "EstatePlotPickerPopup")

	if v2 ~= nil then
		v2:RegisterListener(self, v2.Events.Closing, function(_)
			self._occupancyJanitor:Cleanup()

			if not self._completedPlotPick then
				v.OnDismissed:Fire(self._shouldRestoreHouseMenuOnDismiss)
			end

			self._shouldRestoreHouseMenuOnDismiss = false
		end)
		self._Janitor:Add(function()
			v2:UnregisterListener(self, v2.Events.Closing)
		end, true)
	end

	self._Janitor:Add(PanelController.OnPanelOpened:Connect(function(_: string, p: string)
		if not (p ~= "EstatePlotPickerPopup" and PanelController.IsOpen("MainGUIHandler", "EstatePlotPickerPopup")) then
			return
		end

		self._shouldRestoreHouseMenuOnDismiss = false
		PanelController.Close("MainGUIHandler", "EstatePlotPickerPopup")
	end))
end

function v:bindOccupancyWatchers()
	self._occupancyJanitor:Cleanup()

	for _, button in self._plotList:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local estateRegion = button:GetAttribute("EstateRegion")

		if typeof(estateRegion) ~= "string" then
			continue
		end

		local estateRegionPlotCamera = HouseViewCamera.ResolveEstateRegionPlotCamera(estateRegion)

		if estateRegionPlotCamera == nil then
			continue
		end

		local houseOwned = estateRegionPlotCamera:FindFirstChild("HouseOwned")

		if houseOwned ~= nil and houseOwned:IsA("BoolValue") then
			self._occupancyJanitor:Add(houseOwned:GetPropertyChangedSignal("Value"):Connect(function()
				if not PanelController.IsOpen("MainGUIHandler", "EstatePlotPickerPopup") then
					return
				end

				self:refreshPlotAvailability()
			end))
		end
	end
end

function v:refreshPlotAvailability()
	self._plotButtonJanitor:Cleanup()

	for _, button in self._plotList:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local estateRegion = button:GetAttribute("EstateRegion")

		if typeof(estateRegion) ~= "string" then
			continue
		end

		local estateRegionPlotCamera = HouseViewCamera.ResolveEstateRegionPlotCamera(estateRegion)

		if estateRegionPlotCamera == nil then
			self:setPlotButtonStatus(button, false)
			button.Active = false
			button.Selectable = false
		else
			local houseOwned = estateRegionPlotCamera:FindFirstChild("HouseOwned")
			local v2

			if houseOwned == nil then
				v2 = false
			else
				v2 = houseOwned:IsA("BoolValue") and houseOwned.Value == true
			end

			self:setPlotButtonStatus(button, not v2)
			button.Active = true
			button.Selectable = true
			local v3 = estateRegion
			self._plotButtonJanitor:Add(button.Activated:Connect(function()
				self:onPlotButtonActivated(v3)
			end))
		end
	end
end

function v:onPlotButtonActivated(p: string)
	local estateRegionPlotCamera = HouseViewCamera.ResolveEstateRegionPlotCamera(p)

	if estateRegionPlotCamera == nil then
		self:refreshPlotAvailability()
		return
	end

	local houseOwned = estateRegionPlotCamera:FindFirstChild("HouseOwned")
	local v2

	if houseOwned == nil then
		v2 = false
	else
		v2 = houseOwned:IsA("BoolValue") and houseOwned.Value == true
	end

	if not HouseViewCamera.TeleportPlayerToCameraStatic(estateRegionPlotCamera) then
		return
	end

	self._completedPlotPick = true
	local pendingHouseIdFromAttribute = EstateSurfacingTelemetry.getPendingHouseIdFromAttribute(self.Instance)
	EstateSurfacingTelemetry.sendTeleportPrompt(pendingHouseIdFromAttribute, p, not v2)
	PanelController.Close("MainGUIHandler", "EstatePlotPickerPopup")
end

function v:Open()
	self._completedPlotPick = false
	self._titleLabel.Text = "Choose an Estate Plot to teleport to:"
	PanelController.Open("MainGUIHandler", "EstatePlotPickerPopup")
	self:bindOccupancyWatchers()
	task.defer(function()
		self:refreshPlotAvailability()
	end)
end

function v:Stop()
	self._plotButtonJanitor:Destroy()
	self._occupancyJanitor:Destroy()
	self._Janitor:Destroy()
end

return v