local TweenService = game:GetService("TweenService")

function PlayTween(p, p2, p3, p4)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()

	if p4 then
		tween.Completed:Wait()
	end
end

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local parent = script.Parent
local clipButton = parent:WaitForChild("ClipButton")
local v = false

local function toggleCredits(p)
	if p == nil then
		p = not v
	end

	v = p
	local parent2 = parent
	local textColor

	if v then
		textColor = Color3.fromRGB(61, 160, 255)
	else
		textColor = Color3.fromRGB(96, 96, 96)
	end

	parent2.TextColor3 = textColor
	PlayTween(clipButton, tweenInfo, {
		Size = UDim2.fromOffset(200, v and 85 or 0)
	})
end

parent.Activated:Connect(function()
	toggleCredits()
end)
clipButton.Activated:Connect(function()
	toggleCredits()
end)
toggleCredits(false)