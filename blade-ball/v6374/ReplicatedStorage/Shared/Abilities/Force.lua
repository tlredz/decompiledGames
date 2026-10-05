local createVector = vector.create
require(script.Parent._Types)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(ReplicatedStorage.Misc.LightningBolt)
require(ReplicatedStorage.Misc.LightningBolt.LightningSparks)
require(ReplicatedStorage.Misc.LightningBolt.LightningExplosion)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function shockwave(rootPart, p, value, color, p2, p3, p4)
	local clone = ReplicatedStorage.Misc.Wave:Clone()
	clone.Parent = workspace.Runtime

	if p3 then
		clone.Transparency = 1
		clone.Size = Vector3.new(p, 0.25, p)
	else
		clone.Size = createVector(0.01, 0.5, 0.01)
	end

	if p2 then
		clone.CFrame = rootPart.CFrame
	else
		clone.CFrame = rootPart.CFrame * CFrame.Angles(1.51, 0, 0)
	end

	if p4 then
		clone.CFrame *= CFrame.new(0, -2.5, 0)
	end

	if color then
		clone.Color = color
	end

	local vector2 = Vector3.new(p, 0.5, p)
	local v = value or 0.3
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = p3 and createVector(0.01, 0.25, 0.01) or vector2
		}
	)
	local tween2 = TweenService:Create(
		clone,
		TweenInfo.new(v / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1
		}
	)

	if p3 then
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0), {
			Transparency = 0
		}):Play()
	end

	tween:Play()
	Debris:AddItem(clone, v)
	task.spawn(function()
		task.wait(v / 2)
		tween2:Play()
	end)
end

local function maybeFling(instance, p)
	local _ = 200 + 100 * p.upgradeLevel
	local total = 50

	if p.upgradeLevel >= 1 then
		total += 10
	end

	if p.upgradeLevel >= 2 then
		total += 5
	end

	local v = instance:GetPivot().Position - p.character:GetPivot().Position

	if total < v.Magnitude then
		return
	end

	local bodyVelocity = Instance.new("BodyVelocity")
	Debris:AddItem(bodyVelocity, 0.5)
	bodyVelocity.Name = "ForcePush"
	bodyVelocity.MaxForce = createVector(20000, 20000, 20000)
	bodyVelocity.Parent = instance:FindFirstChild("HumanoidRootPart")
	local v2 = 160 + 30 * p.upgradeLevel - v.Magnitude / 2
	bodyVelocity.Velocity = v.Unit * v2
	TweenService:Create(
		bodyVelocity,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
		{
			Velocity = createVector(0, 0, 0)
		}
	):Play()
end

local Force = {}
Force.cooldown = 7
Force.cooldownReductionPerUpgrade = 1.5
Force.iconId = "rbxassetid://15311827388"

function Force.canBeUsed(_)
	return true
end

function Force.localOwnerActivation(_) end

function Force.anyClientActivationAsync(data)
	local function activate(p: number)
		local clone = nil

		if data.upgradeLevel == 0 then
			clone = ReplicatedStorage.Misc.forcePart:Clone()
			shockwave(data.rootPart, 80, 0.4, Color3.new(0, 0.45098, 1), true)
		elseif data.upgradeLevel == 1 then
			clone = ReplicatedStorage.Misc.forcePart2:Clone()
			shockwave(data.rootPart, 90, 0.4, Color3.new(0, 0.45098, 1), true)
		elseif data.upgradeLevel == 2 then
			clone = ReplicatedStorage.Misc.forcePart3:Clone()
			shockwave(data.rootPart, 100, 0.4, Color3.new(1, 0, 0), true)
		end

		clone.Parent = data.rootPart
		clone.Position = data.rootPart.Position
		clone.hit.PlaybackSpeed -= p
		clone.hit:Play()

		for _, emitter in clone.At2:GetChildren() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local name = tonumber(emitter.Name)

			if name then
				emitter:Emit(name)
			end
		end

		Debris:AddItem(clone, 2)
	end

	task.spawn(function()
		activate(0)
		task.wait(0.5)
		activate(0.5)
		task.wait(0.5)
		activate(1)
	end)

	if data.character ~= localPlayer.Character then
		maybeFling(localPlayer.Character, data)
	end
end

function Force.serverActivationAsync(p)
	for _, model in workspace.Alive:GetChildren() do
		if not (model:IsA("Model") and model ~= p.character and Players:GetPlayerFromCharacter(model) == nil) then
			continue
		end

		maybeFling(model, p)
	end
end

return Force