local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSavePicker"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._showJanitor = self._Janitor:Add(Janitor.new())
	self._selectedIndex = 1
	self._options = {}
	self._callback = nil
end

local function findVehicleByUuid(uuid: string)
	local vehicles = Workspace:FindFirstChild("Vehicles")

	if vehicles == nil then
		return nil
	end

	for _, model in vehicles:GetChildren() do
		if model:IsA("Model") and model:GetAttribute("VehicleUuid") == uuid then
			return model
		end
	end

	return nil
end

local function getOrCreateSelectedStroke(guiObject)
	local selectedStroke = guiObject:FindFirstChild("SelectedStroke")

	if selectedStroke ~= nil and selectedStroke:IsA("UIStroke") then
		return selectedStroke
	end

	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "SelectedStroke"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Thickness = 3
	uIStroke.Color = Color3.fromRGB(255, 255, 255)
	uIStroke.Parent = guiObject
	return uIStroke
end

function v:_updateWorldHighlight()
	self._showJanitor:Remove("WorldHighlight")
	local _option = self._options[self._selectedIndex]

	if _option == nil then
		return
	end

	local vehicleByUuid = findVehicleByUuid(_option.uuid)

	if vehicleByUuid == nil then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "VehicleSavePickerHighlight"
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.8
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = vehicleByUuid
	highlight.Parent = vehicleByUuid
	self._showJanitor:Add(highlight, "Destroy", "WorldHighlight")
end

function v:_setSelected(selectedIndex: number)
	self._selectedIndex = selectedIndex
	local slots = self.Instance:FindFirstChild("Slots")

	if slots ~= nil then
		for i = 1, 3 do
			local guiObject = slots:FindFirstChild("Slot" .. i)

			if not (guiObject ~= nil and guiObject:IsA("GuiObject")) then
				continue
			end

			local selectedStroke = getOrCreateSelectedStroke(guiObject)
			selectedStroke.Enabled = i == selectedIndex
		end
	end

	self:_updateWorldHighlight()
end

function v:Show(options, callback)
	self._showJanitor:Cleanup()
	self._callback = callback
	self._options = options
	self._selectedIndex = 1
	local slots = self.Instance:WaitForChild("Slots")

	for i = 1, 3 do
		local button = slots:FindFirstChild("Slot" .. i)

		if button == nil then
			continue
		end

		local option = options[i]
		button.Visible = option ~= nil

		if option == nil then
			continue
		end

		local icon = button:FindFirstChild("Icon")

		if icon ~= nil and icon:IsA("ImageLabel") then
			icon.Image = option.icon
		end

		if not button:IsA("GuiButton") then
			continue
		end

		local v2 = i
		self._showJanitor:Add(button.Activated:Connect(function()
			self:_setSelected(v2)
		end))
	end

	self:_setSelected(1)
	self.Instance.Visible = true
end

function v:Hide()
	self.Instance.Visible = false
	self._showJanitor:Cleanup()
end

function v:Start()
	local confirm = self.Instance:WaitForChild("Confirm")
	local cancel = self.Instance:WaitForChild("Cancel")
	self._Janitor:Add(confirm.Activated:Connect(function()
		local _callback = self._callback
		local _option = self._options[self._selectedIndex]
		self:Hide()

		if _callback == nil then
			return
		end

		local v2

		if _option ~= nil then
			v2 = _option.uuid
		end

		_callback(v2)
	end))
	self._Janitor:Add(cancel.Activated:Connect(function()
		local _callback = self._callback
		self:Hide()

		if _callback ~= nil then
			_callback(nil)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v