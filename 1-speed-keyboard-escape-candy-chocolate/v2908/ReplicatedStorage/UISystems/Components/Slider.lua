local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Slider = {}
Slider.__index = Slider
local sliderTemplate = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Settings"):WaitForChild("SliderTemplate")

-- equivalent calls inferred from this helper; original call sites unknown
local function isActivationInput(p)
	return p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch
end

local function isMovementInput(p)
	return p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Touch
end

function Slider.Hydrate(instance, options)
	local v = options or {}
	local sliderFrame = instance:FindFirstChild("SliderFrame")
	local sliderContainer = sliderFrame and sliderFrame:FindFirstChild("SliderContainer")
	assert(sliderContainer, "[Slider] SliderFrame/SliderContainer introuvable dans " .. instance:GetFullName())
	local canvasGroup = sliderContainer:FindFirstChild("CanvasGroup")
	local ratioFrame = canvasGroup and canvasGroup:FindFirstChild("RatioFrame")
	local sliderKnob = sliderContainer:FindFirstChild("SliderKnob")
	local settingLabel = instance:FindFirstChild("SettingLabel")
	local valueFrame = instance:FindFirstChild("ValueFrame")
	local valueTextBox = valueFrame and valueFrame:FindFirstChild("ValueTextBox")
	local object = setmetatable({
		Instance = instance,
		_container = sliderContainer,
		_fill = ratioFrame,
		_knob = sliderKnob,
		_textBox = valueTextBox,
		_label = settingLabel,
		_min = v.min or 0,
		_max = v.max or 1,
		_step = v.step,
		_suffix = v.suffix,
		_onChanged = v.onChanged,
		_format = v.format,
		_parse = v.parse,
		_dragging = false,
		_ownsInstance = false,
		_connections = {}
	}, Slider)
	object._value = object:_snap(v.initial or object._min)

	if settingLabel and v.label then
		settingLabel.Text = v.label
	end

	local function beginDrag(p)
		if not isActivationInput(p) then
			return
		end

		object._dragging = true
		object:_setFromX(p.Position.X, false)
	end

	table.insert(object._connections, sliderFrame.InputBegan:Connect(beginDrag))

	if sliderKnob and sliderKnob:IsA("GuiObject") then
		table.insert(object._connections, sliderKnob.InputBegan:Connect(beginDrag))
	end

	table.insert(object._connections, UserInputService.InputChanged:Connect(function(input)
		if object._dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			object:_setFromX(input.Position.X, false)
		end
	end))
	table.insert(object._connections, UserInputService.InputEnded:Connect(function(input)
		if object._dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			object._dragging = false
			object:_setFromX(input.Position.X, true)
		end
	end))

	if valueTextBox and valueTextBox:IsA("TextBox") then
		table.insert(object._connections, valueTextBox.FocusLost:Connect(function()
			local _parseText = object:_parseText(valueTextBox.Text)

			if _parseText then
				object._value = object:_snap(_parseText)
				object:_refresh()

				if object._onChanged then
					object._onChanged(object._value, true)
				end
			else
				object:_refresh()
			end
		end))
	end

	object:_refresh()
	return object
end

function Slider.Create(options)
	local v = options or {}
	local clone = sliderTemplate:Clone()
	clone.Name = v.name or v.label or sliderTemplate.Name
	clone.Visible = true
	local hydrate = Slider.Hydrate(clone, v)
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

function Slider:_snap(value: number)
	if self._step and self._step > 0 then
		value = self._min + math.floor((value - self._min) / self._step + 0.5) * self._step
	end

	return (math.clamp(value, self._min, self._max))
end

function Slider:_frac()
	local v = self._max - self._min
	return v > 0 and (self._value - self._min) / v or 0
end

function Slider:_formatValue()
	if self._format then
		return self._format(self._value)
	end

	return string.format("%g%s", math.round(self._value * 100) / 100, self._suffix or "")
end

function Slider:_parseText(value: string)
	if self._parse then
		return self._parse(value)
	end

	local v = tonumber((value:gsub("[^%d%.,%-]", ""):gsub(",", ".")))
	return v or nil
end

function Slider:_setFromX(p: number, flag: boolean)
	local X = self._container.AbsolutePosition.X
	local v = math.max(self._container.AbsoluteSize.X, 1)
	local v2 = math.clamp((p - X) / v, 0, 1)
	local _snap = self:_snap(self._min + v2 * (self._max - self._min))
	local v3 = math.abs(_snap - self._value) > 0.0001
	self._value = _snap

	if v3 then
		self:_refresh()
	end

	if (v3 or flag) and self._onChanged then
		self._onChanged(_snap, flag)
	end
end

function Slider:_refresh()
	local _frac = self:_frac()

	if self._fill then
		self._fill.Size = UDim2.fromScale(_frac, 1)
	end

	if self._knob then
		self._knob.Position = UDim2.fromScale(_frac, 0.5)
	end

	if self._textBox and not self._textBox:IsFocused() then
		self._textBox.Text = self:_formatValue()
	end
end

function Slider:Set(p: number, flag: boolean?)
	local _snap = self:_snap(p)

	if math.abs(_snap - self._value) <= 0.0001 then
		return
	end

	self._value = _snap
	self:_refresh()

	if not flag and self._onChanged then
		self._onChanged(_snap, true)
	end
end

function Slider:Get()
	return self._value
end

function Slider:SetLabel(text: string)
	if self._label then
		self._label.Text = text
	end
end

function Slider:Destroy()
	self._dragging = false

	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)

	if self._ownsInstance then
		self.Instance:Destroy()
	end
end

return Slider