local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function Destroy(instance, duration)
	task.delay(duration, function()
		instance:Destroy()
	end)
end

local function SpawnRing(data, p, p2)
	if _G.FastMode then
		return
	end

	for i = 1, p do
		local part = Instance.new("Part")
		part.Size = createVector(0, 0, 0)
		TweenService:Create(part, TweenInfo.new(0.2), {
			Size = createVector(4, 4, 4),
			Orientation = Vector3.new(math.random(1, 360), math.random(1, 360), math.random(1, 360))
		}):Play()
		part.CanCollide = false
		part.Anchored = true
		local v = 360 / p * i
		local v2 = math.cos((math.rad(v))) * p2 + data.X
		local v3 = math.sin((math.rad(v))) * p2 + data.Z
		part.Position = Vector3.new(v2, data.Y, v3)
		part.Color = Color3.fromRGB(127, 142, 100)
		local v4 = part.Position + createVector(0, 5, 0)
		local ray = Util.Ray
		local v5 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v6, position = ray(v4, createVector(0, -15, 0), v5)
		part.Material = v6.Material
		part.Color = v6.Color
		part.Position = position
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

local LightningBolt = require(game.ReplicatedStorage.Util.LightningBolt)
return function(p)
	local humanoidRootPart = p.Player.Character.HumanoidRootPart

	if (workspace.CurrentCamera.CFrame.p - humanoidRootPart.CFrame.p).Magnitude < 600 then
		local clone = FX:WaitForChild("Electro").LightningFan:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, -0.6981317007977318, 0))
		Util.Debris:AddItem(clone, 8)
		clone.Parent = workspace._WorldOrigin
		local count = 0

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
				local v = effect
				task.delay(1.7, function()
					v.Enabled = false
				end)
			end

			if not effect:IsA("Beam") then
				continue
			end

			count += 1
			local width0 = effect.Width0
			local width1 = effect.Width1
			effect.Width0 = 0
			effect.Width1 = 0
			local tween = TweenService:Create(
				effect,
				TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Width0 = width0,
					Width1 = width1
				}
			)
			local v = effect
			tween.Completed:Connect(function()
				TweenService:Create(v, TweenInfo.new(1.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
			tween:Play()

			if count % 3 ~= 0 then
				continue
			end

			local v2 = effect
			task.spawn(function()
				for i = 1, 11 do
					local v3 = LightningBolt.new(v2.Parent.Main1, v2.Parent.Main2, 0, 0, 6, Color3.new(0.4, 0.8, 1))
					v3.PulseLength = 0.8
					v3.PulseSpeed = 8
					v3.Width = 1
					task.wait(0.15)
				end
			end)
		end

		coroutine.wrap(function()
			local model = Instance.new("Model", _WorldOrigin)

			for _ = 1, 11 do
				local clone2 = FX:WaitForChild("Electro").Banana:Clone()
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
				Util.Debris:AddItem(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Size = createVector(16, 0.3, 50),
					CFrame = clone2.CFrame * CFrame.new(20, 0, 0),
					Transparency = 1
				}):Play()
				clone2.Parent = model
				task.wait(0.15)
			end

			Util.Debris:AddItem(model, 0.5)
		end)()
	end
end