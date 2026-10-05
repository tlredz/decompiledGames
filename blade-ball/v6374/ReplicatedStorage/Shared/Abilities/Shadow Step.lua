local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3(ReplicatedStorage2.Misc.LightningBolt)
require3(ReplicatedStorage2.Misc.LightningBolt.LightningSparks)
local v = require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v2 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local ShadowStep = {}
ShadowStep.cooldown = 21
ShadowStep.cooldownReductionPerUpgrade = 2.625
ShadowStep.iconId = "rbxassetid://14021534179"

function ShadowStep.localOwnerActivation(p)
	local v3 = 1.7 + 0.24285714285714285 * p.upgradeLevel

	if RunService:IsClient() then
		TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.25), {
			FieldOfView = 80.5
		})
		task.delay(v3, function()
			TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.25), {
				FieldOfView = 70
			}):Play()
		end)
	end

	return nil
end

function ShadowStep.serverActivationAsync(p)
	local v3 = 1.7 + 0.24285714285714285 * p.upgradeLevel

	for _, descendant in p.character:GetDescendants() do
		if descendant:IsA("Decal") then
			local transparency = descendant.Transparency
			descendant.Transparency = 1
			local v4 = descendant
			task.delay(v3, function()
				v4.Transparency = transparency
			end)
		elseif descendant:IsA("BasePart") then
			local transparency = descendant.Transparency
			descendant.Transparency = 1
			local v4 = descendant
			task.delay(v3, function()
				v4.Transparency = transparency
			end)
		end
	end

	local v4 = v2:SetModifierFor(p.character, "Shadow Step", function(p2: number, _)
		return p2 + (85 + p.upgradeLevel * 10) - 36
	end, v2.Priority.ADD)
	task.delay(v3, v4)
end

function ShadowStep.anyClientActivationAsync(data)
	local v3 = 1.7 + 0.24285714285714285 * data.upgradeLevel
	local color = Color3.new(0, 0, 0)

	if data.upgradeLevel >= 2 then
		color = Color3.new(161, 250, 255)
	end

	task.spawn(function()
		local v4 = workspace:GetServerTimeNow() + v3

		while workspace:GetServerTimeNow() < v4 do
			task.wait(0.15)

			for _, part in data.character:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = part:Clone()
				clone:ClearAllChildren()
				clone.Color = Color3.fromRGB(17, 17, 17)
				clone.Material = Enum.Material.Neon
				clone.Transparency = 0.6
				clone.CanCollide = false
				clone.CanQuery = false
				clone.CanTouch = false
				clone.Anchored = true
				clone.Parent = workspace.Runtime
				Debris:AddItem(clone, 0.75)

				if data.upgradeLevel >= 2 then
					clone.Color = Color3.fromRGB(161, 250, 255)
				end

				task.delay(0.375, function()
					TweenService:Create(clone, TweenInfo.new(0.375, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1,
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end
		end
	end)
	v({
		cframe = data.rootPart.CFrame,
		diameter = 20,
		color = color
	})
	local clone = ReplicatedStorage2.Misc.swooshypart:Clone()
	clone.Parent = data.rootPart
	clone.CFrame = data.rootPart.CFrame
	clone.WeldConstraint.Part1 = data.rootPart
	local particleEmitter = clone.partypart.ParticleEmitter

	if data.upgradeLevel >= 2 then
		particleEmitter.Color = ColorSequence.new(color)
	end

	task.spawn(function()
		for _ = 1, data.upgradeLevel >= 2 and 23 or 15 do
			task.wait(0.2)
			particleEmitter:Emit(10)
		end
	end)
	local swoosh = clone.Swoosh

	if data.upgradeLevel >= 2 then
		swoosh = clone.Flashstep
	end

	swoosh.PlaybackSpeed = 0.9 + math.random() * 0.2
	swoosh:Play()
	Debris:AddItem(clone, 5)
	task.wait(0.8)
	swoosh.PlaybackSpeed = 0.9 + math.random() * 0.2
	swoosh:Play()
end

return ShadowStep