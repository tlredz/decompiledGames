local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Toggle = {}
Toggle.__index = Toggle
local toggleTemplate = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Settings"):WaitForChild("ToggleTemplate")
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(35, 232, 0)
local color2 = Color3.fromRGB(150, 150, 150)

function Toggle.Hydrate(instance, options)
	local v = options or {}
	local container = instance:FindFirstChild("Container")
	local toggleContainer = container and container:FindFirstChild("ToggleContainer")
	local toggler = toggleContainer and toggleContainer:FindFirstChild("Toggler")
	assert(
		toggler and toggler:IsA("GuiButton"),
		"[Toggle] Container/ToggleContainer/Toggler introuvable dans " .. instance:GetFullName()
	)
	local object = setmetatable({
		Instance = instance,
		_toggler = toggler,
		_knob = toggler:FindFirstChild("Knob"),
		_valueLabel = container:FindFirstChild("ValueTextLabel"),
		_label = instance:FindFirstChild("SettingLabel"),
		_enabled = v.initial == true,
		_onChanged = v.onChanged,
		_ownsInstance = false,
		_connections = {}
	}, Toggle)

	if object._label and v.label then
		object._label.Text = v.label
	end

	table.insert(object._connections, toggler.Activated:Connect(function()
		object:Set(not object._enabled)
	end))
	object:_refresh(true)
	return object
end

function Toggle:Create()
	local v = self or {}
	local clone = toggleTemplate:Clone()
	clone.Name = v.name or v.label or toggleTemplate.Name
	clone.Visible = true
	local hydrate = Toggle.Hydrate(clone, v)
	hydrate._ownsInstance = true

	if v.size then
		clone.Size = v.size
	end

	if v.layoutOrder then
		clone.LayoutOrder = v.layoutOrder
	end

	clone.Parent = v.parent
	return hydrate
end

function Toggle:_refresh(flag: boolean?)
	local _enabled = self._enabled

	if self._knob then
		local v = {
			Position = UDim2.fromScale(_enabled and 0.5 or 0, 0),
			BackgroundColor3 = _enabled and color or color2
		}

		if flag then
			self._knob.Position = v.Position
			self._knob.BackgroundColor3 = v.BackgroundColor3
		else
			TweenService:Create(self._knob, tweenInfo, v):Play()
		end
	end

	if self._valueLabel then
		self._valueLabel.Text = _enabled and "On" or "Off"
	end
end

function Toggle:Set(flag: boolean, flag2: boolean?)
	local enabled = flag == true

	if enabled == self._enabled then
		return
	end

	self._enabled = enabled
	self:_refresh(false)

	if not flag2 and self._onChanged then
		self._onChanged(enabled)
	end
end

function Toggle:Get()
	return self._enabled
end

function Toggle:SetLabel(text: string)
	if self._label then
		self._label.Text = text
	end
end

function Toggle:Destroy()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)

	if self._ownsInstance then
		self.Instance:Destroy()
	end
end

return Toggle