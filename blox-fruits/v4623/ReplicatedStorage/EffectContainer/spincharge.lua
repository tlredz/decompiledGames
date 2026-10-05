workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local tag = p.tag
	local char = p.char

	while tag.Parent ~= nil and tag:IsDescendantOf(workspace) do
		wait()
		local clone = script.SmokeRing:Clone()
		clone.Parent = workspace._WorldOrigin
		clone.Size = clone.Size * math.random(50, 200) / 100
		clone.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(
			math.random(-2, 2),
			math.random(-3, 3),
			math.random(-2, 2)
		) * CFrame.Angles(0, math.random(-360, 360), 0)
		local tween = TweenService:Create(clone, TweenInfo.new(0.23, Enum.EasingStyle.Quad), {
			CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 10, 0),
			Size = clone.Size * 1.25,
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end
end