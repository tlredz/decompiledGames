local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "VehiclePanel"
})
local v2 = false
local v3 = false

function v:DisconnectCallbacks()
	for _, callback in self.callbacks do
		if callback.inputBegan then
			callback.inputBegan:Disconnect()
		end

		if callback.inputEnded then
			callback.inputEnded:Disconnect()
		end

		if callback.mouseButton1Down then
			callback.mouseButton1Down:Disconnect()
		end
	end

	self.callbacks = {}
end

function v:OnPlayerStartedDriving(p: string)
	if not v2 then
		warn("VehicleController not loaded in VehiclePanel")
		return
	end

	if v2.GetVehicleUuidFromInstance(self.vehicle) ~= p then
		return
	end

	self.vehiclePanel = self.Instance
	self.Instance:AddTag("Panel")
	v3.ToggleGroup("HouseControl", false)
	v2.SetVehiclePanel(self)
end

function v:OnPlayerStoppedDriving()
	if v3 then
		v3.Close("MainGUIHandler", "MainAudio")
	end

	self:CloseCurrentOpenPanel()

	if self.vehiclePanel then
		self.Instance:RemoveTag("Panel")

		if v2 then
			v2.SetVehiclePanel(nil)
		end

		self.vehiclePanel = nil
		self:DisconnectCallbacks()
	end
end

function v.RegisterButtonCallback(p, p2, p3, callback, callback2, flag: boolean?)
	if p.callbacks[p3] then
		return
	end

	p.callbacks[p3] = {
		inputBegan = nil,
		inputEnded = nil,
		mouseButton1Down = nil
	}
	p.callbacks[p3].mouseButton1Down = p2.MouseButton1Down:Connect(function()
		callback()

		if callback2 then
			local lastTime = tick()

			while (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(
				Enum.UserInputType.Gamepad1,
				Enum.KeyCode.ButtonA
			)) and tick() - lastTime < 3 do
				task.wait(0.1)
			end

			if tick() - lastTime < 3 then
				callback2()
			end
		end
	end)
	p.callbacks[p3].inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if (flag or not gameProcessed) and input.KeyCode == p3 then
			callback()
		end
	end)

	if callback2 then
		p.callbacks[p3].inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if (flag or not gameProcessed) and input.KeyCode == p3 then
				callback2()
			end
		end)
	end
end

function v:SetCurrentOpenPanel(currentOpenPanel)
	if self.currentOpenPanel == currentOpenPanel and self.currentOpenPanel.Visible then
		self:CloseCurrentOpenPanel()
		return
	end

	self:CloseCurrentOpenPanel()
	self.currentOpenPanel = currentOpenPanel
	v3.Open("MainGUIHandler", currentOpenPanel.Name)
end

function v:CloseCurrentOpenPanel()
	if self.currentOpenPanel and self.currentOpenPanel.Parent and self.currentOpenPanel.Visible then
		v3.Close("MainGUIHandler", self.currentOpenPanel.Name)
	end

	self.currentOpenPanel = nil
end

function v.IsSuspensionButtonHidden(p)
	return p.hideSuspensionButton
end

function v.IsWheelDecalButtonHidden(p)
	return p.hideWheelDecalButton
end

function v:_getCarButtonsFrame()
	local carButtons = self.Instance:FindFirstChild("CarButtons")
	assert(carButtons, (`Tried to get CarButtons frame but not found in VehiclePanel: {self.Instance:GetFullName()}`))
	return carButtons
end

function v:_getCarButtons()
	local _getCarButtonsFrame = self:_getCarButtonsFrame()
	local guiObjects = {}

	for _, guiObject in _getCarButtonsFrame.CarButtonsTop:GetChildren() do
		if guiObject:IsA("GuiObject") then
			table.insert(guiObjects, guiObject)
		end
	end

	for _, guiObject in _getCarButtonsFrame.CarButtonsBottom:GetChildren() do
		if guiObject:IsA("GuiObject") then
			table.insert(guiObjects, guiObject)
		end
	end

	return guiObjects
end

function v:SetVisibleCarButtonTags(items)
	local _getCarButtonsFrame = self:_getCarButtonsFrame()

	if self._carButtonsFilterJanitor == nil then
		self._carButtonsFilterJanitor = self._Janitor:Add(Janitor.new())
	else
		self._carButtonsFilterJanitor:Cleanup()
	end

	if items then
		local v4 = {}

		for _, item in items do
			v4[item] = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hasVisibleTag(guiObject)
			for tag in v4 do
				if guiObject:HasTag(tag) then
					return true
				end
			end

			return false
		end

		self._carButtonVisibilitySnapshot = {}

		local function processContainer(instance)
			local visible = false

			for _, guiObject in instance:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				self._carButtonVisibilitySnapshot[guiObject] = guiObject.Visible
				local visibleTag = hasVisibleTag(guiObject) -- equivalent call inferred; original call site unknown
				guiObject.Visible = visibleTag

				if visibleTag then
					visible = true
				else
					local v6 = guiObject
					self._carButtonsFilterJanitor:Add(guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
						if v6.Visible then
							v6.Visible = false
						end
					end))
				end
			end

			instance.Visible = visible
		end

		processContainer(_getCarButtonsFrame.CarButtonsTop)
		processContainer(_getCarButtonsFrame.CarButtonsBottom)
	else
		if self._carButtonVisibilitySnapshot then
			for k, visible in self._carButtonVisibilitySnapshot do
				if k.Parent then
					k.Visible = visible
				end
			end

			self._carButtonVisibilitySnapshot = nil
		end

		self:SetCarButtonsTopVisible(true)
		self:SetCarButtonsBottomVisible(true)
	end
end

function v:SetBoostDisabled(flag: boolean)
	self.boostDisabled = flag == true

	if self.OnBoostDisabledChanged then
		self.OnBoostDisabledChanged:Fire(self.boostDisabled)
	end
end

function v.IsBoostDisabled(p)
	return p.boostDisabled == true
end

function v:SetCarButtonsTopVisible(visible: boolean)
	local _getCarButtonsFrame = self:_getCarButtonsFrame()
	_getCarButtonsFrame.CarButtonsTop.Visible = visible
end

function v:SetCarButtonsBottomVisible(visible: boolean)
	local _getCarButtonsFrame = self:_getCarButtonsFrame()
	_getCarButtonsFrame.CarButtonsBottom.Visible = visible
end

function v:SetCarButtonsVisible(flag: boolean)
	self:SetCarButtonsTopVisible(flag)
	self:SetCarButtonsBottomVisible(flag)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnBoostDisabledChanged = self._Janitor:Add(Signal.new())
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	v2 = VehicleController
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v3 = PanelController
end

function v:Start()
	self.callbacks = {}
	self._Janitor:Add(v2.OnPlayerStartedDriving:Connect(function(p)
		self.vehicle = v2.GetCurrentDrivingVehicleModel()

		if not self.vehicle then
			return
		end

		self.hideSuspensionButton = self.vehicle:GetAttribute("HideSuspensionButton")
		self.hideWheelDecalButton = self.vehicle:GetAttribute("HideWheelDecalButton")
		self:OnPlayerStartedDriving(p)
	end))
	self._Janitor:Add(v2.OnPlayerStoppedDriving:Connect(function()
		self:SetVisibleCarButtonTags(nil)
		self:SetBoostDisabled(false)
		self:OnPlayerStoppedDriving()
	end))
end

function v:Stop()
	self:DisconnectCallbacks()

	if self._Janitor and self._Janitor.Destroy then
		self._Janitor:Destroy()
	end
end

return v