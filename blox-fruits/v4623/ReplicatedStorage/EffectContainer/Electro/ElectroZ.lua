local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function Destroy(instance, duration)
	task.delay(duration, function()
		instance:Destroy()
	end)
end

local function SpawnRing(position, p, p2)
	if _G.FastMode then
		return
	end

	for i = 1, p do
		local part = Instance.new("Part")
		part.Size = createVector(0, 0, 0)
		TweenService:Create(part, TweenInfo.new(0.2), {
			Size = createVector(2, 2, 2),
			Orientation = Vector3.new(math.random(1, 360), math.random(1, 360), math.random(1, 360))
		}):Play()
		part.CanCollide = false
		part.Anchored = true
		local v = 360 / p * i
		local v2 = math.cos((math.rad(v))) * p2 + position.X
		local v3 = math.sin((math.rad(v))) * p2 + position.Z
		part.Position = Vector3.new(v2, position.Y, v3)
		part.Color = Color3.fromRGB(127, 142, 100)
		local v4 = part.Position + createVector(0, 5, 0)
		local ray = Util.Ray
		local v5 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v6, _ = ray(v4, createVector(0, -15, 0), v5)

		if v6 then
			part.Material = v6.Material
			part.Color = v6.Color
		else
			part.Material = Enum.Material.Concrete
			part.Color = Color3.new(0.34902, 0.345098, 0.337255)
		end

		part.Parent = workspace._WorldOrigin
		task.delay(4, function()
			TweenService:Create(part, TweenInfo.new(2), {
				Size = createVector(0, 0, 0),
				Orientation = Vector3.new(math.random(1, 360), math.random(1, 360), math.random(1, 360))
			}):Play()
			Util.Debris:AddItem(part, 2)
		end)
	end
end

local LightningBolt3 = require(game.ReplicatedStorage.Util.LightningBolt3)
local LightningExplosion = require(game.ReplicatedStorage.Util.LightningBolt3.LightningExplosion)
return function(p)
	local humanoidRootPart = p.Player.Character.HumanoidRootPart
	local pos = p.Pos

	if (workspace.CurrentCamera.CFrame.p - humanoidRootPart.CFrame.p).Magnitude < 600 then
		local clone = FX:WaitForChild("Electro").Z:Clone()
		clone.Position = pos
		clone.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(clone, 3)

		for i = 1, 3 do
			local child = clone:FindFirstChild("MainBeam" .. i)
			local width0 = child.Width0
			local width1 = child.Width1
			child.Width0 = 0
			child.Width1 = 0
			TweenService:Create(
				child,
				TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 0, true),
				{
					Width0 = width0,
					Width1 = width1
				}
			):Play()
		end

		local main3 = clone.Main3
		local main1 = clone.Main1
		LightningExplosion.new(
			main1.WorldPosition,
			0.5,
			0,
			ColorSequence.new(Color3.new(0.333333, 0.788235, 1)),
			Color3.new(0.333333, 0.788235, 1)
		)

		for _, child in pairs(clone.Main1:GetChildren()) do
			child.Enabled = true
		end

		task.delay(0.5, function()
			for _, child in pairs(clone.Main1:GetChildren()) do
				child.Enabled = false
			end
		end)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
		raycastParams.FilterDescendantsInstances = { workspace.Map }
		local raycastResult = workspace:Raycast(clone.Position, createVector(0, -20, 0), raycastParams)

		if raycastResult then
			SpawnRing(raycastResult.Position, 9, 7)

			for _ = 1, 3 do
				local v = LightningBolt3.new(main3, main1, 10)
				v.Color = Color3.new(0.262745, 0.843137, 1)
				v.PulseLength = 0.5
				v.PulseSpeed = 8
				local clone2 = FX:WaitForChild("Electro").Shock:Clone()
				clone2.CFrame = CFrame.new(raycastResult.Position)
				clone2.Parent = workspace._WorldOrigin
				TweenService:Create(clone2, TweenInfo.new(0.3), {
					Size = createVector(40, 1, 40),
					Transparency = 1
				}):Play()
				Util.Debris:AddItem(clone2, 0.3)
				local clone3 = FX:WaitForChild("Electro").Slashes:Clone()
				clone3.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
					0,
					math.rad((math.random(1, 360))),
					0
				)
				clone3.Parent = workspace._WorldOrigin
				TweenService:Create(clone3, TweenInfo.new(0.3), {
					CFrame = clone3.CFrame * CFrame.new(0, 20, 0),
					Transparency = 1
				}):Play()
				Util.Debris:AddItem(clone3, 0.3)
				local v2 = LightningBolt3.new(main3, main1, 5)
				v2.Color = Color3.new(0.262745, 0.843137, 1)
				v2.PulseLength = 0.5
				v2.PulseSpeed = 4
				v2.Thickness = 3
				task.wait(0.1)
			end
		end
	end
end