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
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 700 then
		return
	end

	for i = 1, 2 do
		local clone = script.ThinRing:Clone()
		clone.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(i / 7 + 0.2, Enum.EasingStyle.Quad), {
			Size = createVector(16, 0, 16) * (i + 1),
			CFrame = clone.CFrame + clone.CFrame.UpVector * (i * 12),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end

	for i = 1, 10 do
		local clone = script.SpinWind:Clone()
		clone.Transparency = 0.4 - math.random() * 0.3
		clone.Color = math.random() < 0.4 and Color3.new() or Color3.new(1, 1, 1)
		clone.Size *= 0.1
		clone.CFrame = cFrame * CFrame.new(0, 0, -i ^ 1.25 * 3) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			0,
			0
		)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.3 + math.random() * 0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Size = clone.Size * 6 * (i / 10 * 1.5 + 1) * (5 + math.random() * 1.5),
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.Angles(3.141592653589793, 0, 0)
			}
		)
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()

		for _ = 1, 2 do
			local clone2 = script.SpinSpike:Clone()
			clone2.CFrame = cFrame * CFrame.new(0, 0, -i ^ 1.25 * 3) * CFrame.Angles(
				(math.random() - 0.5) * 0.66,
				(math.random() - 0.5) * 0.66,
				(math.random() - 0.5) * 0.66
			) * CFrame.new(math.random(-3, -3), math.random(-3, 3), 0)
			clone2.Parent = workspace._WorldOrigin
			local tween2 = TweenService:Create(
				clone2,
				TweenInfo.new(0.15 + math.random() * 0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 0, 5),
					Transparency = 1,
					CFrame = clone2.CFrame * CFrame.new(0, 0, 50)
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