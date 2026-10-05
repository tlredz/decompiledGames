local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local packages = ReplicatedStorage.packages
local Signal = require(packages.Signal)
local Trove = require(packages.Trove)
local components = script.Components
local dropdown = script.Dropdown
local buttonSelected = script.ButtonSelected
local button = components.Button
local separator = components.Separator
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
local folder = Instance.new("Folder")
folder.Name = "Cache"
folder.Parent = script

-- equivalent calls inferred from this helper; original call sites unknown
local function sizeWithY(p, _targetY: number)
	local X = p.Size.X
	return UDim2.new(X.Scale, X.Offset, 0, _targetY)
end

local DropdownController = {}
DropdownController.__index = DropdownController

function DropdownController:_refreshSize()
	local Y = self._layout.AbsoluteContentSize.Y
	self._targetY = math.min(Y, 123)
	local frame = self.Frame
	local canvasSize

	if Y > 123 then
		canvasSize = UDim2.new(0, 0, 0, Y)
	else
		canvasSize = UDim2.new(0, 0, 0, 0)
	end

	frame.CanvasSize = canvasSize

	if self._shown then
		local frame2 = self.Frame
		frame2.Size = sizeWithY(self.Frame, self._targetY)
	end
end

function DropdownController:_position()
	local currentCamera = workspace.CurrentCamera
	local viewportSize

	if currentCamera then
		viewportSize = currentCamera.ViewportSize
	else
		viewportSize = Vector2.new(1920, 1080)
	end

	local absolutePosition = self._parent.AbsolutePosition
	local absoluteSize = self._parent.AbsoluteSize
	local X = self.Frame.AbsoluteSize.X
	local _targetY = self._targetY
	local uDim = UDim.new(1, 0)
	local v = 0
	local uDim2 = UDim.new(0, 0)
	local v2

	if absolutePosition.Y + absoluteSize.Y + _targetY > viewportSize.Y then
		uDim = UDim.new(0, 0)
		v2 = 1
	else
		v2 = 0
	end

	if absolutePosition.X + X > viewportSize.X then
		uDim2 = UDim.new(1, 0)
		v = 1
	end

	local uIPadding = self._parent:FindFirstChildWhichIsA("UIPadding")

	if uIPadding then
		if v == 0 then
			uDim2 -= uIPadding.PaddingLeft
		else
			uDim2 += uIPadding.PaddingRight
		end

		if v2 == 0 then
			uDim += uIPadding.PaddingBottom
		else
			uDim -= uIPadding.PaddingTop
		end
	end

	local v3

	if v2 == 0 then
		v3 = uDim + UDim.new(0, 5)
	else
		v3 = uDim - UDim.new(0, 5)
	end

	self.Frame.AnchorPoint = Vector2.new(v, v2)
	self.Frame.Position = UDim2.new(uDim2, v3)
end

function DropdownController:_scrollIntoView(p2)
	local frame = self.Frame
	local Y = frame.AbsoluteWindowSize.Y
	local v = p2.AbsolutePosition.Y - frame.AbsolutePosition.Y + frame.CanvasPosition.Y
	local v2 = v + p2.AbsoluteSize.Y
	local Y2 = frame.CanvasPosition.Y

	if v < Y2 then
		frame.CanvasPosition = Vector2.new(0, v)
	elseif Y2 + Y < v2 then
		frame.CanvasPosition = Vector2.new(0, v2 - Y)
	end
end

function DropdownController:_cycle(p: number)
	if self._selected then
		local index = table.find(self._order, self._selected)

		if not index then
			return
		end

		local v = math.clamp(index + p, 1, #self._order)

		if v ~= index then
			local v2 = self._order[v]
			self:Select(v2)
			self:_scrollIntoView(self._buttons[v2])
		end
	else
		self:Select(self._order[1])
		self:_scrollIntoView(self._buttons[self._order[1]])
	end
end

function DropdownController:Show()
	if self._shown then
		return
	end

	self._shown = true
	self:_position()
	self:_refreshSize()
	self.Frame.Visible = true

	if self._selected then
		self:_scrollIntoView(self._buttons[self._selected])
	end

	self.Toggled:Fire(true)
	ContextActionService:BindAction("DropdownNav", function(_, p, p2)
		if p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		local keyCode = p2.KeyCode

		if keyCode == Enum.KeyCode.DPadUp then
			self:_cycle(-1)
		elseif keyCode == Enum.KeyCode.DPadDown then
			self:_cycle(1)
		elseif keyCode == Enum.KeyCode.ButtonA then
			if self._selected then
				self.Switched:Fire(self._selected, true)
			end

			self:Hide()
		elseif keyCode == Enum.KeyCode.ButtonB then
			self:Hide()
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonB)
end

function DropdownController:Hide()
	if not self._shown then
		return
	end

	self._shown = false
	self.Frame.Visible = false
	ContextActionService:UnbindAction("DropdownNav")
	self.Toggled:Fire(false)
end

function DropdownController:Toggle()
	if self._shown then
		self:Hide()
	else
		self:Show()
	end
end

function DropdownController:Select(selected: string, flag: boolean?)
	local _button = self._buttons[selected]

	if not _button then
		return
	end

	self._selected = selected
	local _selectedInstance = self._selectedInstance
	local frame = _selectedInstance.Frame
	TweenService:Create(frame, tweenInfo, {
		BackgroundColor3 = _button.BackgroundColor3
	}):Play()
	TweenService:Create(frame.Line, tweenInfo, {
		BackgroundColor3 = _button.BackgroundColor3
	}):Play()
	_selectedInstance.Parent = _button
	self.Switched:Fire(selected, flag)
end

function DropdownController:Deselect()
	self._selected = nil
	self._selectedInstance.Parent = folder
end

function DropdownController:GetSelected()
	return self._selected
end

function DropdownController:_buildTab(data, p: number, flag: boolean)
	local clone = button:Clone()
	clone.Name = data.Name
	clone.LayoutOrder = p * 2
	local label = clone:FindFirstChild("Label")
	label.Text = data.DisplayName or data.Name
	local icon = clone:FindFirstChild("Icon")

	if data.Icon then
		icon.Image = data.Icon
		icon.Visible = true
	else
		icon.Visible = false
	end

	if data.Color then
		clone.BackgroundColor3 = data.Color
	end

	local BG = clone:FindFirstChild("IgnoreList"):FindFirstChild("BG")

	if data.Background then
		BG.Image = data.Background
		BG.Visible = true
	else
		BG.Visible = false
	end

	clone.Parent = self.Frame
	self._buttons[data.Name] = clone
	table.insert(self._order, data.Name)
	self._trove:Connect(clone.Activated, function()
		clone.BackgroundTransparency = 1

		if self._selected == data.Name then
			self:Hide()
		else
			self:Select(data.Name, true)
		end
	end)
	self._trove:Connect(clone.MouseEnter, function()
		if self._selected == data.Name then
			return
		end

		clone.BackgroundTransparency = 0.9
	end)
	self._trove:Connect(clone.MouseLeave, function()
		clone.BackgroundTransparency = 1
	end)

	if not flag then
		local clone2 = separator:Clone()
		clone2.LayoutOrder = p * 2 + 1
		clone2.Parent = self.Frame
	end
end

function DropdownController.new(data)
	local object = setmetatable({}, DropdownController)
	object._trove = Trove.new()
	object._parent = data.Parent
	object._buttons = {}
	object._shown = false
	object._targetY = 0
	object._order = {}
	object.Switched = object._trove:Add(Signal.new())
	object.Toggled = object._trove:Add(Signal.new())
	object._selectedInstance = object._trove:Add(buttonSelected:Clone())
	object._selectedInstance.Parent = folder
	local clone = dropdown:Clone()

	if data.ScaleWithParent and not UserInputService.TouchEnabled then
		local uIPadding = data.Parent:FindFirstChildWhichIsA("UIPadding")
		local uDim

		if uIPadding then
			uDim = uIPadding.PaddingLeft + uIPadding.PaddingRight
		else
			uDim = UDim.new()
		end

		clone.Size = UDim2.new(1 + uDim.Scale, uDim.Offset, 0, 0)
	else
		clone.Size = sizeWithY(clone, 0)
	end

	clone.CanvasSize = UDim2.new(0, 0, 0, 0)
	clone.Visible = false
	object.Frame = object._trove:Add(clone)
	local folder2 = Instance.new("Folder")
	folder2.Name = "DropdownContainer"
	object.Container = folder2
	local uIListLayout = clone:FindFirstChildWhichIsA("UIListLayout")
	assert(uIListLayout, "Dropdown template needs a UIListLayout")
	object._layout = uIListLayout
	local v = #data.Tabs

	for k, tab in data.Tabs do
		object:_buildTab(tab, k, k == v)
	end

	object._trove:Connect(uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		object:_refreshSize()
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isLeftHalf(p: number)
		return p < clone.AbsolutePosition.X + clone.AbsoluteSize.X / 2
	end

	object._trove:Connect(clone.InputChanged, function(p)
		if p.UserInputType == Enum.UserInputType.MouseMovement then
			clone.ScrollingEnabled = not isLeftHalf(p.Position.X)
		elseif p.UserInputType == Enum.UserInputType.MouseWheel and isLeftHalf(p.Position.X) then
			object:_cycle(p.Position.Z > 0 and -1 or 1)
		end
	end)
	clone.Parent = folder2
	folder2.Parent = data.Parent
	object:_refreshSize()

	if data.DefaultTab then
		object:Select(data.DefaultTab)
	end

	return object
end

function DropdownController:Destroy()
	self._trove:Destroy()
end

return DropdownController