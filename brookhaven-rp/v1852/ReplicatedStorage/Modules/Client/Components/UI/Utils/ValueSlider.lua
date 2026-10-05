local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "ValueSlider"
})

local function numberAttr(items, attributeName: string, p: number)
	for _, item in items do
		local attribute = item:GetAttribute(attributeName)

		if typeof(attribute) == "number" then
			return attribute
		end
	end

	return p
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnChanged = Signal.new()
	self.OnCommitted = Signal.new()
	self._Janitor:Add(self.OnChanged)
	self._Janitor:Add(self.OnCommitted)
	self._value = 0
end

function v:GetValue()
	return self._value
end

function v:IsDragging()
	return self._dragging == true
end

function v:SetValue(p: number)
	if self._dragging == true then
		return
	end

	self:_apply(p, false, true)
end

function v:_hosts()
	return {
		self.Instance,
		self._detector,
		self._knob,
		self._fill,
		self._track
	}
end

function v:_range()
	local selected = numberAttr(self:_hosts(), "Min", 0)
	local selected2 = numberAttr(self:_hosts(), "Max", 1)

	if selected2 < selected then
		selected2, selected = selected, selected2
	end

	local v4 = numberAttr(self:_hosts(), "Snap", 0)

	if v4 > 0 then
		return selected, selected2, v4
	end

	return selected, selected2, nil
end

function v:_snap(value: number)
	local _range, v2, v3 = self:_range()
	local v4 = math.clamp(value, _range, v2)

	if v3 == nil then
		return v4
	end

	return (math.clamp(math.round(v4 / v3) * v3, _range, v2))
end

function v:_alphaFromValue(p: number)
	local _range, v2 = self:_range()

	if v2 == _range then
		return 0
	end

	return (math.clamp((p - _range) / (v2 - _range), 0, 1))
end

function v:_applyVisual(value: number)
	local v2 = math.clamp(value, 0, 1)
	local _fill = self._fill
	local _knob = self._knob
	local size = _fill.Size

	if self._vertical then
		_fill.Size = UDim2.new(size.X.Scale, size.X.Offset, v2, 0)
		_knob.Position = UDim2.new(_knob.Position.X.Scale, _knob.Position.X.Offset, v2, 0)
	else
		_fill.Size = UDim2.new(v2, 0, size.Y.Scale, size.Y.Offset)
		_knob.Position = UDim2.new(v2, 0, _knob.Position.Y.Scale, _knob.Position.Y.Offset)
	end
end

function v:_apply(p: number, flag: boolean, flag2: boolean?)
	local _snap = self:_snap(p)
	self:_applyVisual(self:_alphaFromValue(_snap))
	local v2 = _snap ~= self._value
	self._value = _snap
	self._ignoreAttr = true
	self.Instance:SetAttribute("Value", _snap)
	self._ignoreAttr = false

	if v2 and flag2 ~= true then
		self.OnChanged:Fire(_snap)
	end

	if flag then
		self.OnCommitted:Fire(_snap)
	end
end

local function isGuiShown(_track)
	local parent = _track

	while parent ~= nil and parent:IsA("GuiObject") do
		if parent.Visible ~= true then
			return false
		end

		parent = parent.Parent
	end

	return _track:IsDescendantOf(game)
end

function v:_endDrag(flag: boolean?)
	local dragging = self._dragging == true
	self._dragging = false

	if self._moveConn then
		self._moveConn:Disconnect()
		self._moveConn = nil
	end

	if self._endConn then
		self._endConn:Disconnect()
		self._endConn = nil
	end

	if flag == true and dragging then
		self.OnCommitted:Fire(self._value)
	end
end

function v:_fromPointer(vector: Vector3, flag: boolean)
	local _track = self._track
	local absoluteSize = _track.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		return
	end

	local v2

	if self._vertical then
		v2 = math.clamp((vector.Y - _track.AbsolutePosition.Y) / absoluteSize.Y, 0, 1)
	else
		v2 = math.clamp((vector.X - _track.AbsolutePosition.X) / absoluteSize.X, 0, 1)
	end

	local _range, v3 = self:_range()
	self:_apply(_range + v2 * (v3 - _range), flag)
end

function v:_drag(p)
	if self._dragging then
		return
	end

	local v2 = p.UserInputType == Enum.UserInputType.MouseButton1
	local v3 = p.UserInputType == Enum.UserInputType.Touch
	local v4

	if p.UserInputType == Enum.UserInputType.Gamepad1 then
		v4 = p.KeyCode == Enum.KeyCode.ButtonA
	else
		v4 = false
	end

	if not ((v2 or v3 or v4) and isGuiShown(self._track)) then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pointerPosition(p2)
		if p2.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return p2.Position
		end

		local mouseLocation = UserInputService:GetMouseLocation()
		local guiInset = GuiService:GetGuiInset()
		return (Vector3.new(mouseLocation.X - guiInset.X, mouseLocation.Y - guiInset.Y, 0))
	end

	self._dragging = true
	local v5 = pointerPosition(p) -- equivalent call inferred; original call site unknown
	self:_fromPointer(v5, false)
	self._moveConn = UserInputService.InputChanged:Connect(function(input)
		if not isGuiShown(self._track) then
			self:_endDrag(true)
			return
		end

		local v6

		if input.UserInputType == Enum.UserInputType.MouseMovement or input == p then
			v6 = true
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
			v6 = input.KeyCode == Enum.KeyCode.Thumbstick1
		else
			v6 = false
		end

		if not v6 then
			return
		end

		local vector

		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				local mouseLocation = UserInputService:GetMouseLocation()
				local guiInset = GuiService:GetGuiInset()
				vector = Vector3.new(mouseLocation.X - guiInset.X, mouseLocation.Y - guiInset.Y, 0)
			else
				vector = input.Position
			end
		else
			vector = input.Position
		end

		self:_fromPointer(vector, false)
	end)
	self._endConn = UserInputService.InputEnded:Connect(function(input)
		local v6 = input.UserInputType == p.UserInputType
		local v7

		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			v7 = input.KeyCode == Enum.KeyCode.ButtonA
		else
			v7 = false
		end

		if not (v6 or v7) then
			return
		end

		if v6 and isGuiShown(self._track) then
			local v9 = pointerPosition(input) -- equivalent call inferred; original call site unknown
			self:_fromPointer(v9, false)
		end

		self:_endDrag(true)
	end)
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("UIDragDetector") then
		instance = self.Instance:FindFirstChildWhichIsA("UIDragDetector")
	end

	if instance == nil then
		return
	end

	local parent = instance.Parent
	local parent2 = parent and parent.Parent
	local sliderBar = parent2 and parent2:FindFirstChild("SliderBar")

	if parent == nil or sliderBar == nil or parent2 == nil or not (parent:IsA("GuiObject") and sliderBar:IsA("GuiObject") and parent2:IsA("GuiObject")) then
		return
	end

	self._detector = instance
	self._knob = parent
	self._fill = sliderBar
	self._track = parent2
	self._vertical = instance:GetAttribute("DragAxis") == "Y" or sliderBar:GetAttribute("DragAxis") == "Y"
	instance.Enabled = false
	parent.Active = true
	sliderBar.Active = true
	parent2.Active = true

	if self._vertical then
		sliderBar.AnchorPoint = Vector2.new(sliderBar.AnchorPoint.X, 0)
		sliderBar.Position = UDim2.new(
			sliderBar.Position.X.Scale,
			sliderBar.Position.X.Offset,
			0,
			sliderBar.Position.Y.Offset
		)
		parent.AnchorPoint = Vector2.new(parent.AnchorPoint.X, 0.5)
	else
		sliderBar.AnchorPoint = Vector2.new(0, sliderBar.AnchorPoint.Y)
		sliderBar.Position = UDim2.new(
			0,
			sliderBar.Position.X.Offset,
			sliderBar.Position.Y.Scale,
			sliderBar.Position.Y.Offset
		)
		parent.AnchorPoint = Vector2.new(0.5, parent.AnchorPoint.Y)
	end

	local value = nil

	for _, v3 in self:_hosts() do
		local default = v3:GetAttribute("Default")

		if typeof(default) ~= "number" then
			continue
		end

		value = default
		break
	end

	if typeof(value) ~= "number" then
		value = self.Instance:GetAttribute("Value")
	end

	if typeof(value) ~= "number" then
		value = instance:GetAttribute("Value")
	end

	if typeof(value) ~= "number" then
		local _range, v3 = self:_range()
		local v4

		if self._vertical then
			v4 = sliderBar.Size.Y.Scale
		else
			v4 = sliderBar.Size.X.Scale
		end

		value = _range + math.clamp(v4, 0, 1) * (v3 - _range)
	end

	self:_apply(value, false, true)
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("Value"):Connect(function()
		if self._ignoreAttr or self._dragging then
			return
		end

		local value2 = self.Instance:GetAttribute("Value")

		if typeof(value2) == "number" then
			self:_apply(value2, false, true)
		end
	end))

	local function onInput(p)
		self:_drag(p)
	end

	self._Janitor:Add(parent2.InputBegan:Connect(onInput))
	self._Janitor:Add(sliderBar.InputBegan:Connect(onInput))
	self._Janitor:Add(parent.InputBegan:Connect(onInput))

	while parent2 ~= nil and parent2:IsA("GuiObject") do
		self._Janitor:Add(parent2:GetPropertyChangedSignal("Visible"):Connect(function()
			if self._dragging == true and not isGuiShown(self._track) then
				self:_endDrag(true)
			end
		end))
		parent2 = parent2.Parent
	end
end

function v:Stop()
	self:_endDrag()
	self._Janitor:Destroy()
end

return v