local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
require(script.Parent.Types)
local v = {
	create = function()
		local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui") or Players.LocalPlayer:WaitForChild(
			"PlayerGui",
			5
		)
		local popups = playerGui and (playerGui:FindFirstChild("Popups") or playerGui:WaitForChild("Popups", 5))

		if not (popups and popups:IsA("ScreenGui")) then
			return nil, "PlayerGui.Popups is unavailable"
		end

		local lookoutBlackTransitionUI = popups:FindFirstChild("LookoutBlackTransitionUI")

		if lookoutBlackTransitionUI then
			lookoutBlackTransitionUI:Destroy()
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "LookoutBlackTransitionUI"
		screenGui.DisplayOrder = 1000
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		screenGui.Parent = popups
		local frame = Instance.new("Frame")
		frame.Name = "LookoutBlackTransition"
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Position = UDim2.fromScale(0, 0)
		frame.Size = UDim2.fromScale(1, 1)
		frame.Visible = true
		frame.ZIndex = 1000
		frame.Parent = screenGui
		return {
			Gui = screenGui,
			Frame = frame,
			Tween = nil
		}, nil
	end,
	destroy = function(state)
		if state.Tween then
			state.Tween:Cancel()
			state.Tween = nil
		end

		state.Gui:Destroy()
	end
}

local function fade(state, p, backgroundTransparency: number, duration: number)
	if state.Tween then
		state.Tween:Cancel()
	end

	local tween = TweenService:Create(
		state.Frame,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			BackgroundTransparency = backgroundTransparency
		}
	)
	state.Tween = tween
	tween:Play()
	local v2 = p.wait(duration)

	if v2 and state.Frame.Parent then
		state.Frame.BackgroundTransparency = backgroundTransparency
	end

	if state.Tween == tween then
		state.Tween = nil
	end

	return v2
end

function v.fadeToBlack(p, p2, p3: number)
	return (fade(p, p2, 0, p3))
end

function v.fadeFromBlack(p, p2, p3: number)
	return (fade(p, p2, 1, p3))
end

return table.freeze(v)