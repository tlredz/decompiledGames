local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = data.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	local speed = data.Speed or 0.3
	local duration = data.Duration or 1
	local clone = script.DoorBorder:Clone()
	clone.Size = createVector(7, 0, 7)
	clone.Transparency = 1
	clone.CFrame = cFrame
	clone.Parent = workspace._WorldOrigin
	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = createVector(10, 0, 10),
		Transparency = 0.85
	}):Play()
	local clone2 = script.DoorFill:Clone()
	clone2.Size = createVector(7, 0, 7)
	clone2.Transparency = 1
	clone2.CFrame = clone.CFrame
	clone2.Parent = workspace._WorldOrigin
	TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = createVector(9, 0, 9),
		Transparency = 0.6
	}):Play()
	local clone3 = script.DoorWall:Clone()
	clone3.Size = createVector(7, 2.5, 7)
	clone3.Transparency = 1
	clone3.CFrame = clone.CFrame
	clone3.Parent = workspace._WorldOrigin
	TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = createVector(10, 2.5, 10),
		Transparency = 0
	}):Play()
	local clones = {}
	spawn(function()
		local lastTime = tick()

		while tick() - lastTime < duration + 0.2 + speed do
			local clone4 = script.DoorFill:Clone()
			clone4.Material = "Neon"
			clone4.Transparency = 0.98
			clone4.Size = clone.Size + createVector(0, 0.15, 0)
			clone4.CFrame = clone.CFrame
			clone4.Parent = workspace._WorldOrigin
			local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone4, tweenInfo, {
				Transparency = 0.92
			}):Play()
			local tween = TweenService:Create(clone4.Mesh, tweenInfo, {
				Scale = createVector(0, 0.15, 0)
			})
			tween.Completed:Connect(function()
				clone4:Destroy()
			end)
			tween:Play()
			table.insert(clones, clone4)
			wait(0.1)
		end
	end)
	wait(0.2)
	TweenService:Create(clone3, TweenInfo.new(speed, Enum.EasingStyle.Back), {
		Size = createVector(10, 0, 10),
		Transparency = 0.85
	}):Play()
	local lastTime = tick()

	while tick() - lastTime < speed do
		local v2 = math.min(1, (tick() - lastTime) / speed)
		clone3.CFrame = clone.CFrame * CFrame.new(-5, 0, 0) * CFrame.Angles(0, 0, v2 * 3.141592653589793 / 2) * CFrame.new(
			5,
			0,
			0
		)
		RunService.RenderStepped:Wait()
	end

	clone3.CFrame = clone.CFrame * CFrame.new(-5, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.new(5, 0, 0)
	wait(duration)
	TweenService:Create(clone3, TweenInfo.new(speed, Enum.EasingStyle.Back), {
		Transparency = 0
	}):Play()
	local lastTime2 = tick()

	while tick() - lastTime2 < speed do
		local v2 = 1 - math.min(1, (tick() - lastTime2) / speed)
		clone3.CFrame = clone.CFrame * CFrame.new(-5, 0, 0) * CFrame.Angles(0, 0, v2 * 3.141592653589793 / 2) * CFrame.new(
			5,
			0,
			0
		)
		RunService.RenderStepped:Wait()
	end

	clone3.CFrame = clone.CFrame
	TweenService:Create(clone3, TweenInfo.new(speed, Enum.EasingStyle.Back), {
		Transparency = 1
	}):Play()
	clone:Destroy()
	clone2:Destroy()

	for _, v2 in pairs(clones) do
		v2:Destroy()
	end

	wait(speed)
	clone3:Destroy()
end