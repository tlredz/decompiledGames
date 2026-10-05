local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local jackpot = script.Parent:GetAttribute("Jackpot")
local speed = script.Parent:GetAttribute("Speed")
local track = script.Parent.Yuuki.Humanoid:LoadAnimation(script.Animation)
track:Play(0, nil, speed)

if jackpot == false then
	track.TimePosition = 7
	task.wait(3 / speed)
	TweenService:Create(script.Parent.Door1, TweenInfo.new(1), {
		Orientation = script.Parent.Door1.Orientation + createVector(0, -90, 0)
	}):Play()
	TweenService:Create(script.Parent.Door2, TweenInfo.new(1), {
		Orientation = script.Parent.Door1.Orientation + createVector(0, 90, 0)
	}):Play()
	task.wait(1 / speed)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.new(0, 0, 0)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = script.Parent
	TweenService:Create(highlight, TweenInfo.new(1 / speed), {
		FillTransparency = 0.5
	}):Play()
end