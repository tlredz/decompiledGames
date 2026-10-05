local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local FX = require(game.ReplicatedStorage.FX)
local death = FX:WaitForChild("Pain").Death

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { map }
local v = { TweenInfo.new(0.135, Enum.EasingStyle.Sine, Enum.EasingDirection.In) }

local function createEffect(cFrame, instance, p, p2, p3)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, p2 or _WorldOrigin, p3, "PainFruitVFXColor")
	return clone
end

local v2 = {
	"LeftLowerArm",
	"RightLowerArm",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftLowerLeg",
	"RightLowerLeg",
	"LeftUpperLeg",
	"RightUpperLeg",
	"RightHand",
	"LeftHand",
	"LeftFoot",
	"RightFoot",
	"UpperTorso",
	"LowerTorso",
	"Head"
}
return function(player)
	local character = player.Character
	local _ = character.Humanoid
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local head = character:FindFirstChild("Head")

	if not head or character ~= game.Players.LocalPlayer.Character and (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 750 then
		return
	end

	local _DeathOverride = character:GetAttribute("_DeathOverride")

	if _DeathOverride and typeof(_DeathOverride) == "string" and _DeathOverride ~= "" then
		Effect.new(_DeathOverride):play({
			Character = character
		})
		return
	end

	local random = Random.new()
	Sound:Play("DeathSound", head)
	local children = character:GetChildren()
	local player2 = player.Player
	local cFrame = humanoidRootPart.CFrame * CFrame.Angles(-1.57, 1.57, 0)
	local clone = death.eff:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "PainFruitVFXColor")
	Debris:AddItem(clone, 2)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		ScaleParticle({
			Emitter = emitter,
			Scale = humanoidRootPart.Size.Z,
			Time = 0,
			EasingStyle = Enum.EasingStyle.Linear,
			EasingDirection = Enum.EasingDirection.Out
		})
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end

	for _, v4 in pairs(children) do
		if not table.find(v2, v4.Name) then
			continue
		end

		local clone2 = death.Glow:Clone()

		if humanoidRootPart.Size.Z < 0.9 or humanoidRootPart.Size.Z > 1.1 then
			ScaleParticle({
				Emitter = clone2,
				Scale = humanoidRootPart.Size.Z,
				Time = 0,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})
		end

		Util.SetParentOverrideWithColor(clone, v4, player2, "PainFruitVFXColor")
		clone2:Emit(clone2:GetAttribute("EmitCount"))
	end

	for _, part in pairs(children) do
		if not part:IsA("BasePart") then
			continue
		end

		for _, descendant in pairs(part:GetDescendants()) do
			if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
				continue
			end

			descendant.Enabled = false
		end
	end

	local clone2 = WrapHighlight(death.Highlight):Clone()
	Util.SetParentOverrideWithColor(clone, clone2, player2, "PainFruitVFXColor")
	clone2.Adornee = character
	TweenService:Create(clone2, v[1], {
		FillTransparency = 0
	}):Play()
	task.wait(0.4)

	for _, v4 in pairs(children) do
		if not table.find(v2, v4.Name) then
			continue
		end

		local number = random:NextNumber(1, 2.5)

		for _, emitter in pairs(death:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone3 = emitter:Clone()
			ScaleParticle({
				Emitter = clone3,
				Scale = humanoidRootPart.Size.Z,
				Time = 0,
				EasingStyle = Enum.EasingStyle.Linear,
				EasingDirection = Enum.EasingDirection.Out
			})

			if clone3.Name ~= "square" then
				local lifetime = clone3.Lifetime
				clone3.Lifetime = NumberRange.new(lifetime.Min * number, lifetime.Max * number)
			end

			Util.SetParentOverrideWithColor(clone, v4, player2, "PainFruitVFXColor")
			clone3:Emit(clone3:GetAttribute("EmitCount"))
		end
	end

	clone2:Destroy()

	for _, descendant in pairs(character:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("MeshPart") or descendant:IsA("Part") or descendant:IsA("Decal")) then
			continue
		end

		descendant.Transparency = 1
	end
end