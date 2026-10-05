local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.LightningBolt2
local _ = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(data)
	local timeToHit = data.TimeToHit
	local timeAtHit = data.TimeAtHit
	local startPosition = data.StartPosition
	local stopPosition = data.StopPosition
	local part = data.Part
	local size = data.Size
	local v = timeAtHit - timeToHit
	local _ = Workspace:GetServerTimeNow() - v
	local v2 = timeAtHit - Workspace:GetServerTimeNow()
	local clone = script.Missile:Clone()
	clone.CFrame = CFrame.new(startPosition) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.Parent = Workspace._WorldOrigin
	Util.Debris:AddItem(clone, v2 + 2)
	part.Color = Color3.fromRGB(255, 51, 0)
	task.delay(0.2, function()
		part.Color = Color3.fromRGB(57, 54, 50)
	end)
	task.delay(v2 * 0.2, function()
		local ray = Util.Ray
		local v3 = stopPosition + createVector(0, 5, 0)
		local v4 = { Workspace.Characters, Workspace.Enemies }
		local _, v5, _ = ray(v3, createVector(0, -10, 0), v4)
		local part2 = Instance.new("Part")
		part2.CanTouch = false
		part2.Anchored = true
		part2.CanCollide = false
		part2.Transparency = 1
		part2.Material = "Neon"
		part2.Color = Color3.new(1, 0.33, 0)
		part2.Shape = "Cylinder"
		part2.Size = createVector(0.25, 0, 0)
		part2.CFrame = CFrame.new(v5) * CFrame.Angles(0, 0, 1.5707963267948966)
		part2.Parent = Workspace._WorldOrigin
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(part2, TweenInfo.new(v2 * 0.8, Enum.EasingStyle.Linear), {
			Transparency = 0.8,
			Size = Vector3.new(0.25, size * 2, size * 2)
		})
		tween.Completed:Connect(function()
			part2:Destroy()
		end)
		tween:Play()
	end)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(clone, TweenInfo.new(v2, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(stopPosition) * CFrame.Angles(-1.5707963267948966, 0, 0)
	}):Play()
	task.wait(v2)
	clone.Transparency = 1
	clone.Smoke:Destroy()
	local v3 = tostring(math.random(1, 4))
	local Sound = require(game.ReplicatedStorage.Util.Sound)
	Sound:Play("MissileRocket" .. v3, clone)
	local part2 = Instance.new("Part")
	part2.CFrame = CFrame.new(stopPosition)
	part2.Size = Vector3.new(size * 2, size * 2, size * 2)
	part2.Material = Enum.Material.Neon
	part2.Color = Color3.fromRGB(255, 0, 0)
	part2.Transparency = 0.8
	part2.Anchored = true
	part2.CanCollide = false
	part2.Shape = Enum.PartType.Ball
	part2.Parent = Workspace._WorldOrigin
	task.wait(0.15)
	part2:Destroy()
end