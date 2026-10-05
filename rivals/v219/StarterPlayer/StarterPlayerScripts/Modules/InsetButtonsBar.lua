local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local InsetBarButton = require(script:WaitForChild("InsetBarButton"))
local insetButtonsBar = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("InsetButtonsBar")
local InsetButtonsBar = {}
InsetButtonsBar.__index = InsetButtonsBar

function InsetButtonsBar.new(background_transparency, background_color, visual_color, is_mirrored)
	local self = setmetatable({}, InsetButtonsBar)
	self.OpenedChanged = Signal.new()
	self.Frame = insetButtonsBar:Clone()
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.IsOpen = nil
	self.Buttons = {}
	self._background_transparency = background_transparency
	self._background_color = background_color
	self._visual_color = visual_color
	self._is_mirrored = is_mirrored
	self._num_buttons_visible_while_closed = 1
	self:_Init()
	return self
end

function InsetButtonsBar:IsWithin(p, p2)
	local visible = self.Frame.Visible

	if visible then
		if self:GetNumVisibleButtons() > 0 then
			visible = UILibrary:IsWithinBounds(p, p2, self.Frame.AbsolutePosition, self.Frame.AbsoluteSize)
		else
			visible = false
		end
	end

	return visible
end

function InsetButtonsBar:GetVisualColor()
	return self._visual_color
end

function InsetButtonsBar:GetBackgroundColor()
	return self._background_color
end

function InsetButtonsBar:GetNumVisibleButtons()
	local count = 0

	for _, button in pairs(self.Buttons) do
		if button.Frame.Visible then
			count += 1
		end
	end

	return count
end

function InsetButtonsBar:SetMirrored(is_mirrored)
	if is_mirrored == self._is_mirrored then
		return
	end

	self._is_mirrored = is_mirrored
	self:_UpdateMirrored()
end

function InsetButtonsBar:Toggle(isOpen, _)
	if isOpen == nil then
		isOpen = not self.IsOpen
	end

	self.IsOpen = isOpen
	self.OpenedChanged:Fire(self.IsOpen)
end

function InsetButtonsBar:SetClosedButtonsVisible(num_buttons_visible_while_closed)
	self._num_buttons_visible_while_closed = num_buttons_visible_while_closed
	self.OpenedChanged:Fire(self.IsOpen)
end

function InsetButtonsBar:CreateButton(p, p2, p3, p4, p5, p6)
	local v = InsetBarButton.new(p2, p3, p4, p5, p6, self._visual_color, self._is_mirrored)
	v.Frame.LayoutOrder = p * (self._is_mirrored and -1 or 1)
	v.Frame.Parent = self.Container
	v.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:Toggle(self.IsOpen)
	end)
	v.Entered:Connect(function()
		for k, button in pairs(self.Buttons) do
			if k == p2 then
				continue
			end

			button:PlayBubbleEffect(nil)
			button:Leave()
		end
	end)
	self.Buttons[v.Name] = v
	return v
end

function InsetButtonsBar:RemoveButton(p)
	local button = self.Buttons[p]

	if not button then
		return
	end

	self.Buttons[p] = nil
	button:Destroy()
	self:Toggle(self.IsOpen)
end

function InsetButtonsBar:Destroy()
	for _, button in pairs(self.Buttons) do
		button:Destroy()
	end

	self.Frame:Destroy()
	self.OpenedChanged:Destroy()
end

function InsetButtonsBar:_UpdateMirrored()
	self.Container.AnchorPoint = self._is_mirrored and Vector2.new(1, 0) or Vector2.new(0, 0)
	self.Container.Position = self._is_mirrored and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
	self.Layout.HorizontalAlignment = self._is_mirrored and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left

	for _, button in pairs(self.Buttons) do
		button.Frame.LayoutOrder = math.abs(button.Frame.LayoutOrder) * (self._is_mirrored and -1 or 1)
		button:SetMirrored(self._is_mirrored)
	end
end

function InsetButtonsBar:_LeaveButtons()
	for _, button in pairs(self.Buttons) do
		button:Leave()
	end
end

function InsetButtonsBar:_UpdateSize()
	local uDim = self.IsOpen and UDim2.new(self:GetNumVisibleButtons(), 0, 1, 0) or UDim2.new(
		self._num_buttons_visible_while_closed,
		0,
		1,
		0
	)

	if self.Frame:IsDescendantOf(Players) then
		self.Frame:TweenSize(uDim, "Out", "Quint", 0.25, true)
	else
		self.Frame.Size = uDim
	end
end

function InsetButtonsBar:_Setup()
	self.Frame.BackgroundTransparency = self._background_transparency
	self.Frame.BackgroundColor3 = self._background_color
	self.Frame:AddTag("CoreGuiBackground")
end

function InsetButtonsBar:_Init()
	self.OpenedChanged:Connect(function()
		self:_UpdateSize()
		self:_LeaveButtons()
	end)
	self:_Setup()
	self:_UpdateSize()
	self:_UpdateMirrored()
	self:Toggle(false)
end

return InsetButtonsBar