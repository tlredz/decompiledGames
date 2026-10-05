local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local parent = script.Parent
local v = nil
local v2 = false
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v3 = {
	Size = UDim2.new(0.963, 0, 0.596, 0)
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
local v7 = nil
local changedConnection = nil
local numberValue = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelScroll()
	if v7 then
		v7:Cancel()
		v7 = nil
	end

	if changedConnection then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	if numberValue then
		numberValue:Destroy()
		numberValue = nil
	end
end

local function ScrollToItem(instance)
	CancelScroll() -- equivalent call inferred; original call site unknown
	numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local Y = parent.CanvasPosition.Y
	v7 = TweenService:Create(numberValue, tweenInfo, {
		Value = 1
	})
	changedConnection = numberValue.Changed:Connect(function(p)
		local v9 = Y + (math.max(0, instance.AbsolutePosition.Y - parent.AbsolutePosition.Y + parent.CanvasPosition.Y) - Y) * p
		parent.CanvasPosition = Vector2.new(0, v9)
	end)
	v7.Completed:Connect(function()
		CancelScroll() -- equivalent call inferred; original call site unknown
	end)
	v7:Play()
end

local v8 = { "CashPayment", "RobuxPayment" }
local v9 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelTween(p)
	local v10 = v9[p]

	if v10 then
		v10:Cancel()
		v9[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayTween(p, p2)
	CancelTween(p) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(p, tweenInfo, p2)
	v9[p] = tween
	tween:Play()
	return tween
end

local function ToggleItem(instance, p, p2)
	local activePayment = instance:GetAttribute("ActivePayment") or "CashPayment"
	instance:SetAttribute("PaymentShown", p == true)

	if p then
		PlayTween(instance, v3) -- equivalent call inferred; original call site unknown

		for _, childName in v8 do
			local child = instance:FindFirstChild(childName)

			if not child then
				continue
			end

			if childName == activePayment then
				child.Visible = true
				CancelTween(child) -- equivalent call inferred; original call site unknown
				local tween = TweenService:Create(child, tweenInfo, v5)
				v9[child] = tween
				tween:Play()
			else
				CancelTween(child) -- equivalent call inferred; original call site unknown
				child.Visible = false
				child.GroupTransparency = 1
			end
		end

		if not p2 then
			ScrollToItem(instance)
		end
	else
		PlayTween(instance, v4) -- equivalent call inferred; original call site unknown

		for _, childName in v8 do
			local child = instance:FindFirstChild(childName)

			if not child then
				continue
			end

			local v12 = child
			;(PlayTween(child, v6)).Completed:Once(function()
				if instance:GetAttribute("PaymentShown") ~= true then
					v12.Visible = false
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
			if v then
				ToggleItem(v, false)
			end

			v = instance
			ToggleItem(instance, true)
		end
	end

	local v10 = nil
	local vector = nil
	local now = 0
	local v11 = false
	productExpander.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Toggle()
		elseif input.UserInputType == Enum.UserInputType.Touch then
			v10 = input
			vector = Vector2.new(input.Position.X, input.Position.Y)
			now = os.clock()
			v11 = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == v10 and vector and (Vector2.new(input.Position.X, input.Position.Y) - vector).Magnitude > 16 then
			v11 = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input ~= v10 then
			return
		end

		local v12 = not v11 and os.clock() - now <= 0.5
		v10 = nil
		vector = nil
		v11 = false

		if not v12 then
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
end

for _, v10 in ipairs(CollectionService:GetTagged("ShopItem")) do
	SetupItem(v10)
end

CollectionService:GetInstanceAddedSignal("ShopItem"):Connect(SetupItem)