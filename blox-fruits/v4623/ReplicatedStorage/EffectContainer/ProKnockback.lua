workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame
	local width = data.Width or 10
	local length = data.Length or 50
	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 100 + length * 10 < magnitude then
		return
	end

	local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)
	Effect.new("Wind"):replicate({
		CFrame = cFrame * CFrame.new(0, 0, -length / 2),
		Color = Color3.new(1, 1, 1),
		Size = width * 0.75,
		Duration = 1
	})
	local clone = script.Swirl:Clone()
	clone.Size = Vector3.new(width * 1.75, length, width * 1.75)
	clone.CFrame = cFrame * CFrame.new(0, 0, -length / 2) * cframe
	clone.Parent = _WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(length / 10 * 0.06), {
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.Angles(0, 3.142592653589793, 0),
		Size = Vector3.new(width * 0.25, length, width * 0.25)
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()

	for i = 1, length, 10 do
		local v = width * (1.5 - i / length * 1)
		local clone2 = script.Rings:Clone()
		clone2.Size = Vector3.new(v * 0.5, v / 10, v * 0.5)
		clone2.CFrame = cFrame * CFrame.new(0, 0, -i) * cframe
		clone2.Parent = _WorldOrigin
		local tween2 = TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 1,
			Size = Vector3.new(v * 1.5, v / 10, v * 1.5)
		})
		tween2.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween2:Play()
		wait(0.05)
	end
end