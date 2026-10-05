local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local root = p.Root

	if not root or (root.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
		return
	end

	local v = 0.5 - (masterClock:GetTime() - p.Timestamp)
	local v2 = Util.Sound:Play("SpinningWithWind", root)
	local lastTime = tick()

	while tick() - lastTime < v do
		local clone = script.SpinWind:Clone()
		clone.Transparency = 0.1
		clone.Size = clone.Size * (1 + math.random() * 0.3) * 0.25
		clone.CFrame = root.CFrame * CFrame.Angles(3.141592653589793, 0, 1.5707963267948966) * CFrame.Angles(
			6.283185307179586 * math.random(),
			0,
			0
		)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.16 + math.random() * 0.09), {
			Size = clone.Size * createVector(2, 5, 5) * (1 + math.random() * 0.3),
			CFrame = clone.CFrame + createVector(0, 1.5, 0),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		local clone2 = script.SpinSpike:Clone()
		clone2.Transparency = 0.1
		clone2.Size = clone2.Size * (1 + math.random() * 0.3) * 0.25
		clone2.CFrame = root.CFrame * CFrame.Angles(-1.57, 0, 0) * CFrame.new(0, 0, 3)
		clone2.Parent = workspace._WorldOrigin
		local tween2 = TweenService:Create(
			clone2,
			TweenInfo.new(0.15 + math.random() * 0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Size = createVector(20, 20, 5),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.new(0, 0, -4.5)
			}
		)
		tween2.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween2:Play()
		wait()
	end

	wait()

	for i = 1, 5 do
		local clone = script.SpinWind:Clone()
		clone.Size = clone.Size * (1 + math.random() * i / 10) * 0.35
		clone.CFrame = root.CFrame * CFrame.Angles(3.141592653589793, 0, 1.5707963267948966) * CFrame.Angles(
			6.283185307179586 * math.random(),
			0,
			0
		) + Vector3.new(0, i / 2, 0)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(i / 30 + 0.13, Enum.EasingStyle.Quad), {
			Size = clone.Size * createVector(1, 3, 3) * (1 + math.random() * 0.3) * 1.4,
			CFrame = clone.CFrame * CFrame.Angles(3.141592653589793, math.random() - 0.5, 0),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end

	Util.Sound:FadeOut(v2, 0.3)
end