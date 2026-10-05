local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local Projectile = require(ReplicatedStorage.Classes.Projectile)
require(ReplicatedStorage.UserGenerated.VFX.Emit)
local PlaySFX = require(ReplicatedStorage.UserGenerated.SFX.PlaySFX)
local PlayVFX = require(ReplicatedStorage.UserGenerated.VFX.PlayVFX)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
require(ReplicatedStorage.UserGenerated.Lang.Finally)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local sounds = script:WaitForChild("Sounds")
local particles = script:WaitForChild("Particles")
local projectile = script:WaitForChild("Models"):WaitForChild("Projectile")
Random.new()
local frozen = table.freeze({
	Speed = FastFlags.Replicated("LaserGun.Speed", Asserts.FinitePositive, 100),
	Radius = FastFlags.Replicated("LaserGun.Radius", Asserts.FiniteNonNegative, 0),
	Gravity = vector.create(0, 0, 0),
	MaxAge = FastFlags.Replicated("LaserGun.MaxAge", Asserts.FinitePositive, 5),
	TrackingRadius = FastFlags.Replicated("LaserGun.TrackingRadius", Asserts.Optional(Asserts.FiniteNonNegative), 3),
	TrackingFalloff = FastFlags.Replicated(
		"LaserGun.TrackingFalloff",
		Asserts.Optional(Asserts.FiniteNonNegative),
		0.005
	),
	TrackingResponse = FastFlags.Replicated(
		"LaserGun.TrackingResponse",
		Asserts.Optional(Asserts.FiniteNonNegative),
		10
	),
	MaxBounces = FastFlags.Replicated("LaserGun.MaxBounces", Asserts.IntegerNonNegative, 8),
	Cooldown = FastFlags.Replicated("LaserGun.Cooldown", Asserts.FiniteNonNegative, 2.2),
	ImpulseForce = FastFlags.Replicated("LaserGun.ImpulseForce", Asserts.FiniteNonNegative, 1200),
	StunDuration = FastFlags.Replicated("LaserGun.StunDuration", Asserts.FiniteNonNegative, 1.8)
})

local function ComputeImpulseForce(p)
	local v = ((p.Attributes.Bounces or 1) - 1) * 0.25 + 1
	return frozen.ImpulseForce:Get() * v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ComputeStunDuration(player)
	local v = ((player.Attributes.Bounces or 1) - 1) * 0.25 + 1
	return frozen.StunDuration:Get() * v
end

local function RandomizePitch(p, p2: number)
	p.PlaybackSpeed *= 1 - p2 + p2 * 2 * math.random()
	return p
end

local v = {}

local function ImpactCharacter(p: string, player)
	if not player.HitPart then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local primaryPart = character.PrimaryPart

	if not primaryPart then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or v[p] then
		return
	end

	v[p] = true
	local _ = player.Attributes.Bounces or 0
	PlayVFX(primaryPart, primaryPart.CFrame, particles:WaitForChild("ImpactCharacter"):Clone())
	local cFrame = primaryPart.CFrame
	local clone = sounds:WaitForChild("ImpactCharacter"):Clone()
	clone.PlaybackSpeed *= 0.9 + 0.2 * math.random()
	PlaySFX(primaryPart, cFrame, clone)
	local cFrame2 = primaryPart.CFrame
	local clone2 = sounds:WaitForChild("FireFaded5s"):Clone()
	clone2.PlaybackSpeed *= 0.9 + 0.2 * math.random()
	PlaySFX(primaryPart, cFrame2, clone2)
	local v4 = humanoid.HipHeight + 0.5 * primaryPart.Size.Y
	local v5 = primaryPart.CFrame * CFrame.new(0, -v4, 0)
	local attachment = Instance.new("Attachment")
	attachment.CFrame = primaryPart.CFrame:ToObjectSpace(v5)

	for _, child in ipairs(particles:WaitForChild("Smoke1"):GetChildren()) do
		local clone_2 = child:Clone()
		clone_2.Parent = attachment
	end

	attachment.Parent = primaryPart
	local attachment2 = Instance.new("Attachment")

	for _, child in ipairs(particles:WaitForChild("Smoke2"):GetChildren()) do
		local clone_3 = child:Clone()
		clone_3.Parent = attachment2
	end

	attachment2.Parent = primaryPart
	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	highlight.Name = "BurnEffect"
	highlight.FillColor = Color3.fromRGB(0, 0, 0)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = character
	local computeStunDuration = ComputeStunDuration(player) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		FillTransparency = 0
	})
	tween:Play()
	tween.Completed:Wait()
	task.wait(computeStunDuration - 1)

	for _, emitter in ipairs(attachment:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Debris:AddItem(attachment, 5)

	for _, emitter in ipairs(attachment2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	Debris:AddItem(attachment2, 5)
	local tween2 = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		FillTransparency = 1
	})
	tween2:Play()
	tween2.Completed:Wait()
	highlight:Destroy()
	v[p] = nil
end

local function HandleHit(instance, data)
	local serverTimeNow = workspace:GetServerTimeNow()
	local bounces = (instance.Attributes.Bounces or 0) + 1
	instance.Attributes.Bounces = bounces
	local instance2 = data.Instance
	local position = data.Position
	local normal = data.Normal
	local linearVelocity = instance.LinearVelocity
	local linearVelocity2 = linearVelocity - 2 * linearVelocity:Dot(normal) * normal

	if instance.TrackingFalloff then
		instance.TrackingFalloff /= 2
	end

	if instance.TrackingResponse then
		instance.TrackingResponse *= 2
	end

	instance.LinearVelocity = linearVelocity2
	instance.MaxAge = instance.Age + frozen.MaxAge:Get()
	local cframe = CFrame.lookAlong(position + normal * 0.001, linearVelocity2)
	local v4 = {
		Timestamp = serverTimeNow,
		CFrame = instance.CFrame,
		LinearVelocity = instance.LinearVelocity,
		Age = instance.Age,
		HitPart = instance2,
		HitNormal = normal,
		HitPosition = position,
		HitEnding = data.Ending,
		HitAlpha = data.Alpha,
		HitSize = instance2.Size,
		HitCFrame = instance2.CFrame,
		Attributes = table.clone(instance.Attributes)
	}
	local model = instance2:FindFirstAncestorOfClass("Model")

	if model and model.PrimaryPart and model:FindFirstChildOfClass("Humanoid") then
		v4.Character = model
	end

	table.insert(instance.Impacts, table.freeze(v4))

	if v4.Character then
		instance:Destroy()

		if instance.Model then
			task.spawn(function() end)
			task.spawn(ImpactCharacter, instance.Id, v4)
		end
	elseif bounces <= frozen.MaxBounces:Get() then
		if instance.Model then
			task.spawn(function()
				PlayVFX(instance2, cframe, particles:WaitForChild("ImpactBounce"):Clone())
				local clone = sounds:WaitForChild("ImpactBounce"):Clone()
				clone.PlaybackSpeed *= 0.9 + 0.2 * math.random()
				PlaySFX(instance2, cframe, clone)
			end)
		end
	else
		instance:Destroy()

		if instance.Model then
			task.spawn(function()
				PlayVFX(instance2, cframe, particles:WaitForChild("ImpactFinal"):Clone())
				local clone = sounds:WaitForChild("ImpactFinal"):Clone()
				clone.PlaybackSpeed *= 0.9 + 0.2 * math.random()
				PlaySFX(instance2, cframe, clone)
			end)
		end
	end
end

local function GetSourceInfo(model)
	if not (model and model:IsA("Model")) then
		return nil
	end

	local tool = model:FindFirstChildOfClass("Tool")

	if not tool or tool.Name ~= "Laser Gun" then
		return nil
	end

	local handle = tool:FindFirstChild("Handle")

	if not (handle and handle:IsA("BasePart")) then
		return nil
	end

	local muzzle = handle:FindFirstChild("Muzzle")

	if muzzle and muzzle:IsA("Attachment") then
		return {
			Character = model,
			Tool = tool,
			Handle = handle,
			Muzzle = muzzle
		}
	end

	return nil
end

local function SharedShoot(player, player2, projectile2)
	local v2 = Projectile.new({
		Id = player.Id,
		CreationTime = player.Timestamp,
		Origin = player.Origin,
		LinearVelocity = player.Direction * frozen.Speed:Get(),
		Radius = frozen.Radius:Get(),
		Gravity = frozen.Gravity,
		MaxAge = frozen.MaxAge:Get(),
		TrackingRadius = frozen.TrackingRadius:Get(),
		TrackingFalloff = frozen.TrackingFalloff:Get(),
		TrackingResponse = frozen.TrackingResponse:Get(),
		FilterDescendantsInstances = { player2.Character },
		TemplateModel = projectile2
	})
	v2.Hit:Connect(function(p)
		HandleHit(v2, p)
	end)
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClientShoot(player)
	local sourceInfo = GetSourceInfo(player.Character)

	if not sourceInfo then
		return nil
	end

	task.spawn(function()
		local handle = sourceInfo.Handle
		local worldCFrame = sourceInfo.Muzzle.WorldCFrame
		local clone = sounds:WaitForChild("Fire"):Clone()
		clone.PlaybackSpeed *= 0.9 + 0.2 * math.random()
		PlaySFX(handle, worldCFrame, clone)
		PlayVFX(sourceInfo.Handle, sourceInfo.Muzzle.WorldCFrame, particles:WaitForChild("Fire"):Clone())
		local vertexColor = sourceInfo.Tool.Handle.Mesh.VertexColor
		sourceInfo.Tool.Handle.Mesh.VertexColor = vertexColor * 0.1
		task.delay(frozen.Cooldown:Get(), function()
			sourceInfo.Tool.Handle.Mesh.VertexColor = vertexColor
			local handle2 = sourceInfo.Handle
			local worldCFrame2 = sourceInfo.Muzzle.WorldCFrame
			local clone2 = sounds:WaitForChild("Reload"):Clone()
			clone2.PlaybackSpeed *= 0.9 + 0.2 * math.random()
			PlaySFX(handle2, worldCFrame2, clone2)
		end)
	end)
	return (SharedShoot(player, sourceInfo, projectile))
end

local function ShootLocal()
	local sourceInfo = GetSourceInfo(Players.LocalPlayer.Character)

	if not sourceInfo then
		return
	end

	local position = sourceInfo.Muzzle.WorldCFrame.Position
	local target = Projectile.PickTarget({
		FilterDescendantsInstances = { sourceInfo.Character }
	})
	local serverTimeNow = workspace:GetServerTimeNow()
	local v3 = {
		Id = HttpService:GenerateGUID(false):lower():gsub("%-", ""),
		Character = sourceInfo.Character,
		Origin = position,
		Direction = (target - position).Unit,
		Timestamp = serverTimeNow
	}
	task.spawn(function()
		Net:RemoteEvent("LaserGun_Fire"):FireServer(v3.Id, v3.Origin, v3.Direction, v3.Timestamp)
	end)
	local clientShoot = ClientShoot(v3) -- equivalent call inferred; original call site unknown

	if clientShoot then
		clientShoot.Destroying:Connect(function()
			Net:RemoteEvent("LaserGun_Impact"):FireServer(clientShoot.Id, clientShoot.Impacts)
		end)
	end
end

if RunService:IsClient() then
	task.spawn(function()
		Net:RemoteEvent("LaserGun_Fire").OnClientEvent:Connect(function(player)
			local sourceInfo = GetSourceInfo(player.Character)

			if not sourceInfo then
				return
			end

			task.spawn(function()
				local handle = sourceInfo.Handle
				local worldCFrame = sourceInfo.Muzzle.WorldCFrame
				local clone = sounds:WaitForChild("Fire"):Clone()
				clone.PlaybackSpeed *= 0.9 + 0.2 * math.random()
				PlaySFX(handle, worldCFrame, clone)
				PlayVFX(sourceInfo.Handle, sourceInfo.Muzzle.WorldCFrame, particles:WaitForChild("Fire"):Clone())
				local vertexColor = sourceInfo.Tool.Handle.Mesh.VertexColor
				sourceInfo.Tool.Handle.Mesh.VertexColor = vertexColor * 0.1
				task.delay(frozen.Cooldown:Get(), function()
					sourceInfo.Tool.Handle.Mesh.VertexColor = vertexColor
					local handle2 = sourceInfo.Handle
					local worldCFrame2 = sourceInfo.Muzzle.WorldCFrame
					local clone2 = sounds:WaitForChild("Reload"):Clone()
					clone2.PlaybackSpeed *= 0.9 + 0.2 * math.random()
					PlaySFX(handle2, worldCFrame2, clone2)
				end)
			end)
			SharedShoot(player, sourceInfo, projectile)
		end)
		Net:RemoteEvent("LaserGun_ImpactCharacter").OnClientEvent:Connect(function(p: string, p2)
			ImpactCharacter(p, p2)
		end)
	end)
end

return table.freeze({
	Settings = frozen,
	ShootLocal = ShootLocal,
	GetSourceInfo = GetSourceInfo,
	SharedShoot = SharedShoot,
	ComputeImpulseForce = ComputeImpulseForce,
	ComputeStunDuration = ComputeStunDuration
})