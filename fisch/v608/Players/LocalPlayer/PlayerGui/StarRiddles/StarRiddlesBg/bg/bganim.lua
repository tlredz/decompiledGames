local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local color = Color3.fromRGB(244, 180, 255)
local color2 = Color3.fromRGB(183, 176, 255)
local parent = script.Parent
local parent2 = parent.Parent
local now = 0
local random = Random.new()
RunService.RenderStepped:Connect(function()
	if not (parent2.Enabled and parent.Visible) then
		return
	end

	if tick() - now > 0.5 then
		now = tick()
		local clone = script.glow:Clone()
		clone.Position = UDim2.fromScale(random:NextNumber(0, 1), 1)
		clone.Size = UDim2.fromScale(random:NextNumber(0.2, 0.5), random:NextNumber(1, 2))
		clone.ImageTransparency = 1
		clone.ImageColor3 = color:Lerp(color2, random:NextNumber())
		clone.Parent = parent
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
			{
				ImageTransparency = random:NextNumber(0.6, 0.85)
			}
		)
		TweenService:Create(clone, TweenInfo.new(5, Enum.EasingStyle.Linear), {
			Position = clone.Position + UDim2.fromScale(random:NextNumber(-0.2, 0.2), 0)
		}):Play()
		tween.Completed:Once(function()
			tween:Destroy()
			clone:Destroy()
		end)
		tween:Play()
	end
end)