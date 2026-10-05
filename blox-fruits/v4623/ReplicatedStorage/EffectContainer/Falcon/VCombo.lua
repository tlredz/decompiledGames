local createVector = vector.create
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

	if not root or (root.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	local lastTime = tick()

	while tick() - lastTime < 0.7 do
		local clone = script.SpinWind:Clone()
		clone.Color = math.random() < 0.5 and Color3.new() or Color3.new(1, 1, 1)
		clone.Transparency = 0.3 - math.random() * 0.2
		clone.Size *= 0.1
		clone.CFrame = root.CFrame * CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.16 + math.random() * 0.09, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{
				Size = clone.Size * 20 * (3 + math.random()),
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}
		)
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()

		for _ = 1, 2 do
			local clone2 = script.SpinSpike:Clone()
			clone2.Color = Color3.new(1, 1, 1)
			clone2.CFrame = root.CFrame * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			) * CFrame.new(0, 0, 5)
			clone2.Parent = workspace._WorldOrigin
			local tween2 = TweenService:Create(
				clone2,
				TweenInfo.new(0.13 + math.random() * 0.04, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 0, 0),
					CFrame = clone2.CFrame * CFrame.new(0, 0, 35)
				}
			)
			tween2.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween2:Play()
		end

		wait()
	end
end