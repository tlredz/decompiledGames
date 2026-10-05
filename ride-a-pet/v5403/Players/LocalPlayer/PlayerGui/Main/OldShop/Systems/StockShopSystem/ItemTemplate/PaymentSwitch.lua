local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local parent = script.Parent
local cashPayment = parent:WaitForChild("CashPayment")
local robuxPayment = parent:WaitForChild("RobuxPayment")
local robuxOptions = cashPayment:WaitForChild("RobuxOptions")
local cashOptions = robuxPayment:WaitForChild("CashOptions")
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
	v2.Visible = false
	v2.GroupTransparency = 1
	v.GroupTransparency = 1
	v.Visible = true
	TweenService:Create(v, tweenInfo, {
		GroupTransparency = 0
	}):Play()
end

if parent:GetAttribute("ActivePayment") == nil then
	parent:SetAttribute("ActivePayment", "CashPayment")
end

robuxOptions.Activated:Connect(function()
	SwitchTo("RobuxPayment")
end)
cashOptions.Activated:Connect(function()
	SwitchTo("CashPayment")
end)