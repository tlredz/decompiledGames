local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local parent = script.Parent
local parent2 = parent.Parent.Parent
local header = parent2:WaitForChild("Header")
local restockButton = header:WaitForChild("RestockButton")
local closeButton = header:WaitForChild("CloseButton")
parent.Selectable = false
local WireHeader
local v = nil
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function LastInputWasGamepad()
	local lastInputType = UserInputService:GetLastInputType()
	return lastInputType == Enum.UserInputType.Gamepad1 or lastInputType == Enum.UserInputType.Gamepad2 or lastInputType == Enum.UserInputType.Gamepad3 or lastInputType == Enum.UserInputType.Gamepad4
end

local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v3 = {
	Size = UDim2.new(0.963, 0, 0.548, 0)
}
local v4 = {
	Size = UDim2.new(0.963, 0, 0.379, 0)
}
local v5 = {
	GroupTransparency = 0
}
local v6 = {
	GroupTransparency = 1
}
local v7 = parent:FindFirstChild("BottomSpacer")

if not v7 then
	v7 = Instance.new("Frame")
	v7.Name = "BottomSpacer"
	v7.BackgroundTransparency = 1
	v7.BorderSizePixel = 0
	v7.Active = false
	v7.Selectable = false
	v7.Parent = parent
end

v7.LayoutOrder = 1000000
v7.Size = UDim2.new(1, 0, 1 - v3.Size.Y.Scale, 0)
local v8 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelScroll()
	if v8 then
		v8:Cancel()
		v8 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CanvasTopOf(p)
	return p.AbsolutePosition.Y - parent.AbsolutePosition.Y + parent.CanvasPosition.Y
end

local function ScrollToItem(instance, p)
	CancelScroll() -- equivalent call inferred; original call site unknown
	local Y = parent.AbsoluteSize.Y

	if Y <= 0 then
		return
	end

	local v9 = (v3.Size.Y.Scale - v4.Size.Y.Scale) * Y
	local canvasTop = CanvasTopOf(instance) -- equivalent call inferred; original call site unknown
	local v11 = parent.AbsoluteCanvasSize.Y + v9

	if p and p ~= instance and p.Parent then
		v11 -= v9

		if CanvasTopOf(p) < canvasTop then
			canvasTop -= v9
		end
	end

	local v12 = canvasTop + v3.Size.Y.Scale * Y
	local Y2 = parent.CanvasPosition.Y
	local v13 = math.max(v11 - Y, 0)

	if not (canvasTop < Y2 or Y2 + Y < v12) then
		canvasTop = Y2
	end

	local v14 = math.clamp(canvasTop, 0, v13)

	if math.abs(v14 - Y2) < 1 then
		return
	end

	v8 = TweenService:Create(parent, tweenInfo, {
		CanvasPosition = Vector2.new(parent.CanvasPosition.X, v14)
	})
	v8.Completed:Connect(CancelScroll)
	v8:Play()
end

local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v9 = nil
local v10 = 0
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		v10 += 1
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		v10 = math.max(v10 - 1, 0)
	end
end)
UserInputService.WindowFocusReleased:Connect(function()
	v10 = 0
end)

local function PointerHeld()
	return v10 > 0 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

local function SnapToNearestRow(p)
	if v8 or v9 or not p and (v10 > 0 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
		return
	end

	local Y = parent.AbsoluteSize.Y

	if Y <= 0 then
		return
	end

	local Y2 = parent.CanvasPosition.Y
	local v11 = math.max(parent.AbsoluteCanvasSize.Y - Y, 0)
	local v12 = 1e999
	local v13 = nil

	for _, guiObject in parent:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject:FindFirstChild("ProductExpander")) then
			continue
		end

		local canvasTop = CanvasTopOf(guiObject) -- equivalent call inferred; original call site unknown

		if not (canvasTop >= -1 and canvasTop <= v11 + 1) then
			continue
		end

		local v15 = math.abs(canvasTop - Y2)

		if not (v15 < v12) then
			continue
		end

		v13 = math.clamp(canvasTop, 0, v11)
		v12 = v15
	end

	if not v13 or v12 < 2 then
		return
	end

	v9 = TweenService:Create(parent, tweenInfo2, {
		CanvasPosition = Vector2.new(parent.CanvasPosition.X, v13)
	})
	v9.Completed:Connect(function()
		v9 = nil
	end)
	v9:Play()
end

local now = 0
local flag = false

local function RequestSnap()
	now = os.clock()

	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local v11

		repeat
			task.wait(0.05)
			v11 = os.clock() - now
		until v11 >= 0.15 and not (v10 > 0 or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or v8) or v11 >= 1.2

		flag = false
		SnapToNearestRow(v11 >= 1.2)
	end)
end

parent:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(RequestSnap)
local v11 = { "CashPayment", "RobuxPayment" }
local v12 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelTween(p)
	local v13 = v12[p]

	if v13 then
		v13:Cancel()
		v12[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayTween(p, p2)
	CancelTween(p) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(p, tweenInfo, p2)
	v12[p] = tween
	tween:Play()
	return tween
end

local function ToggleItem(instance, p, p2, p3)
	local activePayment = instance:GetAttribute("ActivePayment") or "CashPayment"
	instance:SetAttribute("PaymentShown", p == true)

	if p then
		PlayTween(instance, v3) -- equivalent call inferred; original call site unknown

		for _, childName in v11 do
			local child = instance:FindFirstChild(childName)

			if not child then
				continue
			end

			if childName == activePayment then
				child.Visible = true
				CancelTween(child) -- equivalent call inferred; original call site unknown
				local tween = TweenService:Create(child, tweenInfo, v5)
				v12[child] = tween
				tween:Play()
			else
				CancelTween(child) -- equivalent call inferred; original call site unknown
				child.Visible = false
				child.GroupTransparency = 1
			end
		end

		if not p2 then
			ScrollToItem(instance, p3)
		end
	else
		PlayTween(instance, v4) -- equivalent call inferred; original call site unknown

		for _, childName in v11 do
			local child = instance:FindFirstChild(childName)

			if not child then
				continue
			end

			local v15 = child
			;(PlayTween(child, v6)).Completed:Once(function()
				if instance:GetAttribute("PaymentShown") ~= true then
					v15.Visible = false
				end
			end)
		end
	end
end

local function SetupItem(instance)
	if instance.Parent ~= parent then
		return
	end

	local productExpander = instance:WaitForChild("ProductExpander")
	local cashPayment = instance:WaitForChild("CashPayment")
	local robuxPayment = instance:WaitForChild("RobuxPayment")
	productExpander.AnchorPoint = Vector2.new(productExpander.AnchorPoint.X, 0)
	productExpander.Position = UDim2.new(productExpander.Position.X.Scale, productExpander.Position.X.Offset, 0, 0)
	local scale = v4.Size.Y.Scale

	-- equivalent calls inferred from this helper; original call sites unknown
	local function KeepCardSize()
		local scale2 = instance.Size.Y.Scale

		if scale2 > 0 then
			productExpander.Size = UDim2.new(1, 0, math.min(scale / scale2, 1), 0)
		end
	end

	instance:GetPropertyChangedSignal("Size"):Connect(KeepCardSize)
	instance.Size = v4.Size
	KeepCardSize() -- equivalent call inferred; original call site unknown
	cashPayment.GroupTransparency = 1
	robuxPayment.GroupTransparency = 1
	robuxPayment.Visible = false

	if not v2 then
		v2 = true
		v = instance
		ToggleItem(instance, true, true)
		parent.CanvasPosition = Vector2.new(0, 0)
	end

	local function Toggle()
		game.SoundService.SFX.Click:Play()

		if v == instance then
			ToggleItem(instance, false)
			v = nil
		else
			local v13 = v

			if v13 then
				ToggleItem(v13, false)
			end

			v = instance
			ToggleItem(instance, true, false, v13)
		end
	end

	local v13 = nil
	local vector = nil
	local now2 = 0
	local v14 = false
	productExpander.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Toggle()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			v13 = input
			vector = Vector2.new(input.Position.X, input.Position.Y)
			now2 = os.clock()
			v14 = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == v13 and vector and (Vector2.new(input.Position.X, input.Position.Y) - vector).Magnitude > 16 then
			v14 = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input ~= v13 then
			return
		end

		local v15 = not v14 and os.clock() - now2 <= 0.5
		v13 = nil
		vector = nil
		v14 = false

		if not v15 then
			return
		end

		local vector2 = Vector2.new(input.Position.X, input.Position.Y)
		local absolutePosition = productExpander.AbsolutePosition
		local absoluteSize = productExpander.AbsoluteSize

		if vector2.X < absolutePosition.X or vector2.X > absolutePosition.X + absoluteSize.X or vector2.Y < absolutePosition.Y or vector2.Y > absolutePosition.Y + absoluteSize.Y then
			return
		end

		Toggle()
	end)
	productExpander.SelectionGained:Connect(function()
		if v ~= instance then
			Toggle()
		end
	end)
	productExpander.Activated:Connect(function()
		if LastInputWasGamepad() then
			Toggle()
		end
	end)
	productExpander:GetAttributeChangedSignal("GamepadPress"):Connect(Toggle)
	productExpander.SelectionGained:Connect(function()
		WireHeader()
	end)
end

for _, v13 in ipairs(CollectionService:GetTagged("ShopItem")) do
	SetupItem(v13)
end

CollectionService:GetInstanceAddedSignal("ShopItem"):Connect(SetupItem)

local function FirstRow()
	if v and v.Parent == parent then
		return v
	end

	local layoutOrder = 1e999
	local v13 = nil

	for _, guiObject in parent:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject:FindFirstChild("ProductExpander") and guiObject.LayoutOrder < layoutOrder) then
			continue
		end

		layoutOrder = guiObject.LayoutOrder
		v13 = guiObject
	end

	return v13
end

WireHeader = function()
	local firstRow = FirstRow()
	local productExpander = firstRow and firstRow:FindFirstChild("ProductExpander")

	if not productExpander then
		return
	end

	for _, child in parent:GetChildren() do
		local productExpander2 = child:FindFirstChild("ProductExpander")

		if productExpander2 and productExpander2 ~= productExpander and productExpander2.NextSelectionUp == restockButton then
			productExpander2.NextSelectionUp = nil
		end
	end

	productExpander.NextSelectionUp = restockButton
	restockButton.NextSelectionDown = productExpander
	closeButton.NextSelectionDown = productExpander
	restockButton.NextSelectionRight = closeButton
	closeButton.NextSelectionLeft = restockButton
end

local function FocusFirstRow()
	if GamepadUI.CursorActive() or not UserInputService.GamepadEnabled or not (parent2.Visible and parent.Visible) then
		return
	end

	local firstRow = FirstRow()
	local productExpander = firstRow and firstRow:FindFirstChild("ProductExpander")

	if productExpander and productExpander.Visible then
		WireHeader()
		GuiService.SelectedObject = productExpander
	end
end

parent2:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent2.Visible then
		task.delay(0.1, FocusFirstRow)
	end
end)