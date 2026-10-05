local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local lightningBolt3 = Util.LightningBolt3
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(player)
	local character = player.Character
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")

	if (primaryPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	if not player.NoSound then
		task.spawn(function()
			local scale = player.Scale or 3.5
			local position = primaryPart.Position
			local sound2 = player.Sound
			local v = sound:Play("Ope.Explosion.ElectricLoop", primaryPart.Position, 20 * scale)
			sound:Play("Ope.Explosion.Flare", position, 20 * scale)

			if sound2 then
				sound:Play(sound2, position, 20 * scale)
			else
				sound:Play("Ope.Explosion.Lightning", position, 20 * scale)
			end

			wait(1)
			sound:FadeOut(v, 1)
		end)
	end

	local clone = FX:WaitForChild("Koko")["Injection Shot"].Aim:Clone()
	clone.Attachment["1"]:Destroy()
	clone.CFrame = CFrame.new(primaryPart.Position)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = primaryPart
	weldConstraint.Parent = clone

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		Util.Misc.ScaleParticle(emitter, 0.75)
		emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * 0.75, emitter.Lifetime.Max * 0.75)
		emitter.Rate *= 2
	end

	clone.Parent = _WorldOrigin
	destroyAfter(clone, 5)
	local tween = TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(0.4), {
		Brightness = 3,
		Range = 10
	})
	tween:Play()
	tween:Destroy()
	local clone2 = FX:WaitForChild("Koko")["Injection Shot"].HitEffects:Clone()
	clone2.Anchored = true
	clone2.CFrame = primaryPart.CFrame
	local v = 0

	for _, emitter in pairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Emit(emitter:GetAttribute("EmitCount"))
		v = math.max(v, emitter.Lifetime.Max)
	end

	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, v + 0.5)
	task.delay(0.25, function()
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end)
	local random = Random.new()
	task.spawn(function()
		for _ = 1, 5 do
			local v2 = {
				WorldPosition = primaryPart.Position,
				WorldAxis = createVector(0, 1, 0)
			}
			local v3 = {
				WorldPosition = primaryPart.CFrame * CFrame.Angles(random:NextNumber(-1, 1) * 3.141592653589793, 0, 0) * Vector3.new(
					0,
					0,
					-random:NextNumber(5, 20)
				),
				WorldAxis = createVector(0, 0, 0)
			}
			local v4 = lightningBolt3.new(v2, v3, 6)
			v4.PulseSpeed = 5.5
			v4.Frequency = 5
			v4.PulseLength = 1
			v4.FadeLength = 0.25
			v4.MinRadius = 10
			v4.MaxRadius = 15
			v4.Thickness = random:NextNumber(0.5, 2)
			v4.Color = ColorSequence.new(Color3.fromRGB(128, 187, 219), Color3.fromRGB(128, 187, 219))
			task.wait(0.1)
		end
	end)
	task.wait(1)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	local tween2 = TweenService:Create(clone.Attachment.PointLight, TweenInfo.new(0.2), {
		Brightness = 0,
		Range = 0
	})
	tween2:Play()
	tween2:Destroy()
	task.wait(1)
	clone:Destroy()
end