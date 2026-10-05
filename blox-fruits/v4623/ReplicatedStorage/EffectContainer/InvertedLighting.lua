workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local time = p.Time

	for _ = 1, p.Count do
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Contrast = -1
		colorCorrectionEffect.Parent = game.Lighting
		local TweenService = game:GetService("TweenService")
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(time), {
			Contrast = 0
		}):Play()
		Util.Debris:AddItem(colorCorrectionEffect, time + 1)
	end
end