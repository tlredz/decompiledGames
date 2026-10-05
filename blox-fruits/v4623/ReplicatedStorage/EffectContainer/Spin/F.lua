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
	local root = p.Root
	local holding = p.Holding

	if not root or (root.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 2000 then
		return
	end

	local v = Util.Sound:Play("SpinningWithWindLoop", root)

	while root and root:IsDescendantOf(workspace) and holding and holding.Value and holding:IsDescendantOf(workspace) do
		local clone = script.SpinWind:Clone()
		clone.Size *= 0.25
		clone.CFrame = root.CFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.Angles(
			0,
			0,
			1.5707963267948966 + (math.random() - 0.5) * 0.2
		)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.15 + math.random() * 0.07, Enum.EasingStyle.Circular),
			{
				Size = clone.Size * (2.5 + math.random() * 1.25) * 2.5,
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.Angles(3.141592653589793, 0, 0)
			}
		)
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		wait()
	end

	Util.Sound:FadeOut(v, 0.3)
end