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

	local clone = script.ThinRing:Clone()
	clone.CFrame = root.CFrame
	clone.Size = createVector(0, 26, 0)
	clone.Parent = workspace._WorldOrigin
	local tween = TweenService:Create(clone, TweenInfo.new(0.25), {
		Size = createVector(39, 0, 39),
		Transparency = 1
	})
	tween.Completed:Connect(function()
		clone:Destroy()
	end)
	tween:Play()

	for i = 1, 4 do
		local clone2 = script.SpinWind:Clone()
		clone2.Color = i <= 2 and Color3.new() or Color3.new(1, 1, 1)
		clone2.Transparency = 0.5 - math.random() * 0.2
		clone2.Size = clone2.Size * 0.1 * (0.5 + math.random())
		clone2.CFrame = root.CFrame * CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		clone2.Parent = workspace._WorldOrigin
		local tween2 = TweenService:Create(
			clone2,
			TweenInfo.new(0.5 + math.random() * 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Size = clone2.Size * 20 * (2 + math.random() * 2),
				Transparency = 1
			}
		)
		tween2.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween2:Play()

		for _ = 1, math.random(2, 3) do
			local clone3 = script.SpinSpike:Clone()
			clone3.Color = math.random() < 0.5 and Color3.new() or Color3.new(1, 1, 1)
			clone3.CFrame = root.CFrame * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			) * CFrame.new(0, 0, 5)
			clone3.Parent = workspace._WorldOrigin
			local tween3 = TweenService:Create(
				clone3,
				TweenInfo.new(0.25 + math.random() * 0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 0, 0),
					CFrame = clone3.CFrame * CFrame.new(0, 0, math.random(15, 30))
				}
			)
			tween3.Completed:Connect(function()
				clone3:Destroy()
			end)
			tween3:Play()
		end
	end
end