local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local parent = script.Parent
local cashPayment = parent:WaitForChild("CashPayment")
local robuxPayment = parent:WaitForChild("RobuxPayment")
local robuxOptions = cashPayment:WaitForChild("Frame"):WaitForChild("RobuxOptions")
local cashOptions = robuxPayment:WaitForChild("Frame"):WaitForChild("CashOptions")
local click = SoundService:WaitForChild("SFX"):FindFirstChild("Click")
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function SwitchTo(activePayment)
	if parent:GetAttribute("ActivePayment") == activePayment then
		return
	end

	parent:SetAttribute("ActivePayment", activePayment)

	if click then
		click:Play()
	end

	if parent:GetAttribute("PaymentShown") ~= true then
		return
	end

	local v = activePayment == "RobuxPayment" and robuxPayment or cashPayment
	local v2 = activePayment == "RobuxPayment" and cashPayment or robuxPayment
	local selectedObject = GuiService.SelectedObject
	local v3

	if selectedObject == nil then
		v3 = false
	else
		v3 = selectedObject:IsDescendantOf(v2)
	end

	v2.Visible = false
	v2.GroupTransparency = 1
	v.GroupTransparency = 1
	v.Visible = true
	TweenService:Create(v, tweenInfo, {
		GroupTransparency = 0
	}):Play()

	if v3 then
		local frame = v:FindFirstChild("Frame") or v
		local dollar = frame:FindFirstChild("Dollar") or frame:FindFirstChild("x1")

		if not dollar then
			for _, button in frame:GetChildren() do
				if not (button:IsA("GuiButton") and button.Visible) then
					continue
				end

				dollar = button
				break
			end
		end

		if dollar then
			GuiService.SelectedObject = dollar
		end
	end
end

if parent:GetAttribute("ActivePayment") == nil then
	parent:SetAttribute("ActivePayment", "CashPayment")
end

local function OnPress(object, fn)
	object.Activated:Connect(function()
		fn()
	end)
	object:GetAttributeChangedSignal("GamepadPress"):Connect(function()
		fn()
	end)
end

OnPress(robuxOptions, function()
	SwitchTo("RobuxPayment")
end)
OnPress(cashOptions, function()
	SwitchTo("CashPayment")
end)