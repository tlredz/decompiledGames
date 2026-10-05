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
local clipFrame = parent:WaitForChild("ClipFrame")
parent.MouseEnter:Connect(function()
	parent.TextColor3 = Color3.fromRGB(61, 160, 255)
	PlayTween(clipFrame, tweenInfo, {
		Size = UDim2.fromOffset(200, 60)
	})
end)
parent.MouseLeave:Connect(function()
	parent.TextColor3 = Color3.fromRGB(96, 96, 96)
	PlayTween(clipFrame, tweenInfo, {
		Size = UDim2.fromOffset(200, 0)
	})
end)
clipFrame.Size = UDim2.fromOffset(200, 0)