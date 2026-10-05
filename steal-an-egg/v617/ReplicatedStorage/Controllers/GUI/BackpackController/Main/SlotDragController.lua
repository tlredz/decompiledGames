local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local SlotDragController = {}
SlotDragController.__index = SlotDragController
local v = nil

local function toGuiPosition(instance, p)
	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")
	local v2

	if screenGui then
		v2 = screenGui.AbsolutePosition
	else
		v2 = Vector2.zero
	end

	return p + v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectAll(list)
	for _, connection in list do
		connection:Disconnect()
	end

	table.clear(list)
end

local function isVisible(parent)
	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("ScreenGui") then
			return parent.Enabled
		else
			parent = parent.Parent
		end
	end

	return false
end

local function inheritedScale(parent)
	local v2 = 1

	while parent and parent:IsA("GuiObject") do
		for _, uIScale in parent:GetChildren() do
			if uIScale:IsA("UIScale") then
				v2 *= uIScale.Scale
			end
		end

		parent = parent.Parent
	end

	return (math.max(v2, 0.001))
end

function SlotDragController.new(parent, options)
	local object = setmetatable({
		Button = parent,
		Options = options,
		Connections = {},
		GestureConnections = {},
		Gesture = nil,
		SuppressActivationUntil = 0,
		DetectorHandledActivation = false,
		Destroyed = false
	}, SlotDragController)
	local uIDragDetector = Instance.new("UIDragDetector")
	uIDragDetector.Name = "SlotDragDetector"
	uIDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane
	uIDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset
	uIDragDetector.Enabled = false
	uIDragDetector.Parent = parent
	object.Detector = uIDragDetector
	table.insert(object.Connections, uIDragDetector.DragStart:Connect(function(p2)
		local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")
		local v3

		if screenGui then
			v3 = screenGui.AbsolutePosition
		else
			v3 = Vector2.zero
		end

		object:_begin(p2 + v3)
	end))
	table.insert(object.Connections, uIDragDetector.DragContinue:Connect(function(p2)
		local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")
		local v3

		if screenGui then
			v3 = screenGui.AbsolutePosition
		else
			v3 = Vector2.zero
		end

		object:_continue(p2 + v3)
	end))
	table.insert(object.Connections, uIDragDetector.DragEnd:Connect(function(p2)
		local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")
		local v3

		if screenGui then
			v3 = screenGui.AbsolutePosition
		else
			v3 = Vector2.zero
		end

		object:_finish(p2 + v3, false)
	end))
	table.insert(object.Connections, parent.InputBegan:Connect(function(input)
		if object.Gesture and object.InputConnection then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonA then
			object.DetectorHandledActivation = false

			if not uIDragDetector.Enabled then
				return
			end

			if object.InputConnection then
				object.InputConnection:Disconnect()
			end

			object.InputConnection = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if input.UserInputState == Enum.UserInputState.Cancel then
					object:Cancel()
				elseif input.UserInputState == Enum.UserInputState.End and object.InputConnection then
					object.InputConnection:Disconnect()
					object.InputConnection = nil
				end
			end)
		end
	end))
	table.insert(object.Connections, parent.Destroying:Connect(function()
		object:Destroy()
	end))
	return object
end

function SlotDragController:SetEnabled(enabled)
	if self.Destroyed then
		return
	end

	if not enabled then
		self:Cancel()
	end

	self.Detector.Enabled = enabled
end

function SlotDragController:IsActivationSuppressed()
	local gesture = self.Gesture

	if os.clock() < self.SuppressActivationUntil then
		return true
	elseif gesture == nil then
		return false
	else
		return gesture.Mode ~= "pending"
	end
end

function SlotDragController:ShouldHandleNativeActivation()
	return self.Gesture == nil and not (self:IsActivationSuppressed() or self.DetectorHandledActivation)
end

function SlotDragController:_begin(p)
	if self.Destroyed or self.Gesture or v or not (self.Detector.Enabled and isVisible(self.Button) and self.Options.CanStart()) then
		return
	end

	self.DetectorHandledActivation = false
	local lastInputType = UserInputService:GetLastInputType()
	local touch = lastInputType == Enum.UserInputType.Touch
	local scrollingFrame

	if touch then
		scrollingFrame = self.Options.ScrollingFrame
	end

	if scrollingFrame and not self.Button:IsDescendantOf(scrollingFrame) then
		scrollingFrame = nil
	end

	local canvasPosition

	if scrollingFrame then
		canvasPosition = scrollingFrame.CanvasPosition
	end

	local scrollingEnabled

	if scrollingFrame then
		scrollingEnabled = scrollingFrame.ScrollingEnabled
	end

	self.Gesture = {
		Mode = "pending",
		StartPosition = p,
		LastPosition = p,
		Touch = touch,
		InputType = lastInputType,
		Scroller = scrollingFrame,
		CanvasPosition = canvasPosition,
		ScrollingEnabled = scrollingEnabled
	}
	v = self

	if scrollingFrame then
		scrollingFrame.ScrollingEnabled = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancel()
		self:Cancel()
	end

	table.insert(self.GestureConnections, UserInputService.WindowFocusReleased:Connect(cancel))
	table.insert(self.GestureConnections, GuiService.MenuOpened:Connect(cancel))
	table.insert(self.GestureConnections, self.Button.AncestryChanged:Connect(cancel))
	local button = self.Button

	while button do
		if button:IsA("GuiObject") then
			table.insert(self.GestureConnections, button:GetPropertyChangedSignal("Visible"):Connect(function()
				if not isVisible(self.Button) then
					cancel() -- equivalent call inferred; original call site unknown
				end
			end))
		elseif button:IsA("ScreenGui") then
			table.insert(self.GestureConnections, button:GetPropertyChangedSignal("Enabled"):Connect(cancel))
			break
		end

		button = button.Parent
	end
end

function SlotDragController:_createPreview(p2)
	local button = self.Button
	local screenGui = button:FindFirstAncestorWhichIsA("ScreenGui")

	if not screenGui then
		return false
	end

	local frame = Instance.new("Frame")
	frame.Name = "BackpackDragPreview"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.Active = false
	frame.ZIndex = 100
	frame.Parent = screenGui
	p2.PreviewLayer = frame
	local clone = button:Clone()
	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)

	for _, instance in descendants do
		if instance:IsA("UIDragDetector") or instance:IsA("LuaSourceContainer") then
			instance:Destroy()
		else
			for _, tag in instance:GetTags() do
				instance:RemoveTag(tag)
			end

			if instance:IsA("GuiObject") then
				instance.Active = false
				instance.Selectable = false
				instance.Interactable = false
			end
		end
	end

	for _, child in clone:GetChildren() do
		if not (child:IsA("UIScale") or child:IsA("UIAspectRatioConstraint") or child:IsA("UISizeConstraint")) then
			continue
		end

		child:Destroy()
	end

	local scale = inheritedScale(button)
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = scale
	uIScale.Parent = clone
	clone.Name = "Item"
	clone.AnchorPoint = Vector2.zero
	clone.Position = UDim2.fromOffset(0, 0)
	clone.Size = UDim2.fromOffset(button.AbsoluteSize.X / scale, button.AbsoluteSize.Y / scale)
	clone.AutomaticSize = Enum.AutomaticSize.None
	clone.Rotation = button.AbsoluteRotation
	clone.ZIndex = 100
	clone.Visible = true
	local frame2 = Instance.new("Frame")
	frame2.Name = "Position"
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.fromOffset(0, 0)
	frame2.ZIndex = 100
	frame2.Parent = frame
	clone.Parent = frame2
	p2.PreviewHolder = frame2
	p2.PreviewOrigin = button.AbsolutePosition
	return true
end

function SlotDragController:_continue(lastPosition)
	local gesture = self.Gesture

	if not gesture then
		return
	end

	gesture.LastPosition = lastPosition

	if not (self.Options.CanStart() and isVisible(self.Button)) then
		self:Cancel()
		return
	end

	local v2 = lastPosition - gesture.StartPosition

	if gesture.Mode == "pending" then
		if (gesture.Touch and 12 or 8) > v2.Magnitude then
			return
		end

		if gesture.Scroller and gesture.ScrollingEnabled and math.abs(v2.Y) >= math.abs(v2.X) then
			gesture.Mode = "scrolling"
		else
			gesture.Mode = "dragging"
			self.Options.OnDragStart()

			if self.Gesture ~= gesture then
				return
			end

			if not self:_createPreview(gesture) then
				self:Cancel()
				return
			end
		end
	end

	if gesture.Mode == "scrolling" then
		local scroller = gesture.Scroller
		local v3 = math.max(0, scroller.AbsoluteCanvasSize.Y - scroller.AbsoluteWindowSize.Y)
		scroller.CanvasPosition = Vector2.new(
			gesture.CanvasPosition.X,
			(math.clamp(gesture.CanvasPosition.Y - v2.Y, 0, v3))
		)
	elseif gesture.Mode == "dragging" then
		local v3 = gesture.PreviewOrigin + v2 - gesture.PreviewLayer.AbsolutePosition
		gesture.PreviewHolder.Position = UDim2.fromOffset(v3.X, v3.Y)
	end
end

function SlotDragController:_finish(p, p2)
	local gesture = self.Gesture

	if not gesture then
		return
	end

	local v2 = p2 or not (self.Options.CanStart() and isVisible(self.Button))
	self.Gesture = nil

	if v == self then
		v = nil
	end

	disconnectAll(self.GestureConnections) -- equivalent call inferred; original call site unknown

	if self.InputConnection then
		self.InputConnection:Disconnect()
		self.InputConnection = nil
	end

	if gesture.PreviewLayer then
		gesture.PreviewLayer:Destroy()
	end

	if gesture.Scroller and gesture.Scroller.Parent then
		gesture.Scroller.ScrollingEnabled = gesture.ScrollingEnabled
	end

	if v2 or gesture.Mode ~= "pending" then
		self.SuppressActivationUntil = os.clock() + 0.2
	end

	if gesture.Mode == "dragging" then
		self.Options.OnDragEnd(p, v2)
	elseif gesture.Mode == "pending" and not v2 and self.Options.CanStart() and isVisible(self.Button) then
		local absolutePosition = self.Button.AbsolutePosition
		local v3 = absolutePosition + self.Button.AbsoluteSize

		if p.X >= absolutePosition.X and p.Y >= absolutePosition.Y and p.X <= v3.X and p.Y <= v3.Y then
			self.DetectorHandledActivation = true
			self.Options.OnActivate(gesture.InputType)
		end
	end
end

function SlotDragController:Cancel()
	local gesture = self.Gesture

	if gesture then
		self:_finish(gesture.LastPosition, true)
	end
end

function SlotDragController:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self:Cancel()
	disconnectAll(self.Connections) -- equivalent call inferred; original call site unknown

	if self.InputConnection then
		self.InputConnection:Disconnect()
		self.InputConnection = nil
	end

	self.Detector:Destroy()
end

return SlotDragController