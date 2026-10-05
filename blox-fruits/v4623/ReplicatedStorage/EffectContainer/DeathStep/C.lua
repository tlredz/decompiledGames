local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local legMesh = script.LegMesh
local spiralWind = script.SpiralWind
local curvedRing = script.CurvedRing
local airSlash = script.AirSlash
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(data)
	local HRP = data.HRP
	local holding = data.Holding
	local fire = data.Fire
	local duration = data.Duration or 3

	if (workspace.CurrentCamera.CFrame.p - HRP.Position).Magnitude > 500 then
		return
	end

	local cFrame = HRP.CFrame
	local cframe = CFrame.Angles(-1.5707963267948966, 0, 1.5707963267948966)
	local clone = spiralWind:Clone()
	clone.Size = createVector(8, 8, 9)
	clone.CFrame = cFrame * cframe
	clone.Parent = _WorldOrigin

	if fire then
		clone.Color = Color3.new(1, 0.5, 0)
		clone.Transparency = 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ran()
		return math.random() - 0.5
	end

	local lastTime = tick()
	local lastTime2 = tick()

	while tick() - lastTime < duration do
		local v = tick() - lastTime

		if holding == nil or not holding:IsDescendantOf(workspace) or v > 0.2 and holding.Value == false then
			break
		end

		cFrame = HRP.CFrame
		local clone2 = legMesh:Clone()
		clone2.Size = createVector(2.75, 2.75, 2.75)
		clone2.Color = Color3.new()
		clone2.CFrame = cFrame * CFrame.new(ran() * 4.5, ran() * 2 - 1.5, ran() * 4.5) * CFrame.Angles(
			ran() * 0.75,
			ran() * 0.75,
			ran() * 0.75
		)
		local color

		if fire then
			clone2.Material = "Neon"
			color = Color3.new(1, 0.3 + math.random() * 0.2, 0)
		end

		clone2.Parent = _WorldOrigin
		local v2 = 37.6 + math.random() * 4
		local tween = TweenService:Create(clone2, TweenInfo.new(0.09 + math.random() * 0.04), {
			Size = Vector3.new(0.5, v2, 0.5),
			CFrame = clone2.CFrame * CFrame.new(0, -v2 / 2, 0)
		})
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()

		if color then
			TweenService:Create(
				clone2,
				TweenInfo.new(0.09 + math.random() * 0.04, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Color = color
				}
			):Play()
		end

		local clone3 = curvedRing:Clone()
		clone3.Size = createVector(1.5, 0.3, 1.5)

		if fire then
			clone3.Transparency = 0
			clone3.Color = Color3.new()
		end

		clone3.CFrame = clone2.CFrame
		clone3.Parent = _WorldOrigin
		local v4 = 7 + math.random() * 1.5
		local tween2 = TweenService:Create(
			clone3,
			TweenInfo.new(0.12 + math.random() * 0.04, Enum.EasingStyle.Exponential),
			{
				Size = Vector3.new(v4, 0, v4),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.new(0, -v2 * 0.9, 0)
			}
		)
		tween2.Completed:Connect(function()
			clone3:Destroy()
		end)
		tween2:Play()
		clone.Size = Vector3.new(10, math.sin(v * 20) * 4 + 11, 10)
		clone.CFrame = cFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, v * 40, 0) * cframe

		if fire then
			clone.Color = Color3.new(1, math.sin(v * 30) * 0.04 + 0.4, 0)
		end

		if tick() - lastTime2 > 0.06 then
			lastTime2 = tick()
			Util.Sound:Play("MeleeSwingLoud", cFrame)
		end

		RunService.RenderStepped:Wait()
	end

	clone:Destroy()
	wait(0.1)
	local clone2 = airSlash:Clone()
	clone2.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone2.Size = createVector(6, 60, 60)
	clone2.Color = Color3.new()

	if fire then
		clone2.Color = Color3.new(1, 0.5, 0)
	end

	clone2.Parent = _WorldOrigin
	local tween = TweenService:Create(clone2, TweenInfo.new(0.12), {
		CFrame = clone2.CFrame * CFrame.Angles(-3.1101767270538954, 0, 0)
	})
	tween.Completed:Connect(function()
		clone2:Destroy()
	end)
	TweenService:Create(clone2, TweenInfo.new(0.12, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		Size = createVector(4, 40, 40)
	}):Play()
	tween:Play()
end