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

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 800 then
		return
	end

	for _ = 1, 6 do
		local clone = script.HeartBig:Clone()
		clone.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Parent = workspace._WorldOrigin
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Size = createVector(60, 2.25, 60),
			CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0) + cFrame.LookVector * 56
		}):Play()
		TweenService:Create(clone.PointLight, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Brightness = 0,
			Range = 60
		}):Play()
		coroutine.wrap(function()
			wait(0.2)
			local tween = TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end)()
		local clone2 = script.HeartSmall:Clone()
		clone2.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone2.Parent = workspace._WorldOrigin
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = createVector(52.5, 2.25, 52.5),
			CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0) + cFrame.LookVector * 56
		}):Play()
		coroutine.wrap(function()
			wait(0.15)
			local tween = TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Transparency = 1
			})
			tween.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween:Play()
		end)()
		wait()
		wait()
	end
end