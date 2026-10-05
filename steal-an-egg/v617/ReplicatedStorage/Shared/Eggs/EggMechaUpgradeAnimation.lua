local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local Shake = require(ReplicatedStorage.Client.Shake)
local EggActionMovement = require(script.Parent.EggActionMovement)
local EggEnergyOrbField = require(script.Parent.EggEnergyOrbField)
local EggRenderer = require(script.Parent.EggRenderer)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
local emitTree = VFX.EmitTree
local Log = require(ReplicatedStorage.Packages.Log)
local PlayVFX = require(ReplicatedStorage.UserGenerated.VFX.PlayVFX)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local t = require(ReplicatedStorage.Packages.t)
local VisibleBounds = require(ReplicatedStorage.Shared.Utils.VisibleBounds)
local v = { "AssetAnimation", "Part" }
local color = Color3.fromRGB(80, 190, 220)
local v2 = Log.new()
local transient = Workspace:FindFirstChild("Transient") or Workspace
local random = Random.new()

local function applyShake(p, cframe: CFrame, p2: number, spin: number)
	EggActionMovement.SetPivot(
		p,
		cframe * CFrame.new(
			random:NextNumber(-1, 1) * 0.55 * p2,
			random:NextNumber(-1, 1) * 0.55 * p2,
			random:NextNumber(-1, 1) * 0.55 * p2
		) * CFrame.Angles(0, math.rad(spin), 0) * CFrame.Angles(
			math.rad(random:NextNumber(-1, 1) * 24 * p2),
			0,
			(math.rad(random:NextNumber(-1, 1) * 24 * p2))
		)
	)
end

local function playNamedSound(childName: string, p)
	local sounds = ReplicatedStorage.Assets:FindFirstChild("Sounds")
	local sound = sounds and sounds:FindFirstChild(childName)

	if sound == nil or not sound:IsA("Sound") then
		v2:AtWarning():Log((`Missing ReplicatedStorage.Assets.Sounds.{childName}; sound skipped`))
	else
		Audio.Play(sound, p)
	end
end

local function findParticleAsset(items)
	local particles = ReplicatedStorage.Assets:FindFirstChild("Particles")

	for _, childName in items do
		if particles == nil then
			return nil
		else
			particles = particles:FindFirstChild(childName)
		end
	end

	return particles
end

local function setEmittersEnabled(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function createHostPart(name: string, cFrame: CFrame, p: number)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.CFrame = cFrame
	part.Parent = transient
	Debris:AddItem(part, p)
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attachToEgg(p, instance)
	local primaryPart = instance.PrimaryPart

	if primaryPart == nil then
		return
	end

	local visibleBounds = VisibleBounds(instance)
	p.CFrame = primaryPart.CFrame:ToObjectSpace(CFrame.new(visibleBounds.Position))
	p.Parent = primaryPart
end

local function createChargeParticles(instance)
	local particleAsset = findParticleAsset(v)

	if particleAsset == nil then
		v2:AtWarning():Log((`Missing ReplicatedStorage.Assets.Particles.{table.concat(v, ".")}; charge VFX skipped`))
		return nil
	end

	local emit = particleAsset:FindFirstChild("Emit")
	local enable = particleAsset:FindFirstChild("Enable")

	if emit == nil or not emit:IsA("Attachment") then
		v2:AtWarning():Log("Charge VFX is missing its Emit attachment")
		return nil
	end

	if enable == nil or not enable:IsA("Attachment") then
		v2:AtWarning():Log("Charge VFX is missing its Enable attachment")
		return nil
	end

	local v3 = {
		Emit = emit:Clone(),
		Enable = enable:Clone()
	}
	attachToEgg(v3.Emit, instance) -- equivalent call inferred; original call site unknown
	attachToEgg(v3.Enable, instance) -- equivalent call inferred; original call site unknown
	setEmittersEnabled(v3.Enable, true)
	return v3
end

local function detachParticles(chargeParticles, position: Vector3)
	local cframe = CFrame.new(position)
	local part = Instance.new("Part")
	part.Name = "MechaUpgradeParticleKeeper"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.CFrame = cframe
	part.Parent = transient
	Debris:AddItem(part, 8)
	chargeParticles.Emit.CFrame = CFrame.new()
	chargeParticles.Emit.Parent = part
	chargeParticles.Enable.CFrame = CFrame.new()
	chargeParticles.Enable.Parent = part
	return part
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseParticles(chargeParticles)
	setEmittersEnabled(chargeParticles.Enable, false)
	Debris:AddItem(chargeParticles.Emit, 8)
	Debris:AddItem(chargeParticles.Enable, 8)
end

local function emitImpactVfx(cFrame: CFrame)
	local particleAsset = findParticleAsset({ "HitGroundAttach" })

	if particleAsset == nil then
		v2:AtWarning():Log("Missing ReplicatedStorage.Assets.Particles.HitGroundAttach; impact VFX skipped")
		return
	end

	local part = Instance.new("Part")
	part.Name = "MechaUpgradeImpactVFX"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(0.1, 0.1, 0.1)
	part.CFrame = cFrame
	part.Parent = transient
	Debris:AddItem(part, 10)
	local clone = particleAsset:Clone()

	if not TryCall(PlayVFX, part, cFrame, clone) then
		clone:Destroy()
	end
end

local function playChargeLift(instance, pivot: CFrame, cframe: CFrame, vector2: Vector3, object, p)
	local total = 0

	while total < 5 do
		local v3 = RunService.Heartbeat:Wait()
		total += v3

		if instance.Parent == nil then
			return false
		end

		local v4 = math.min(total / 5, 1)
		local v5 = math.min(v4 / 0.62, 1)
		local lerped = pivot:Lerp(cframe, TweenService:GetValue(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
		local value = TweenService:GetValue(v5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
		p.Spin += 216 * v3
		applyShake(instance, lerped, value, p.Spin)
		object:Step(lerped.Position + vector2, v4, v3)
	end

	return true
end

local function playShakeSettle(p, cframe: CFrame, p2)
	local spin = p2.Spin
	local v3 = math.ceil(spin / 360) * 360
	local total = 0

	while total < 0.5 do
		total += RunService.Heartbeat:Wait()

		if p.Parent == nil then
			return
		end

		local v4 = math.min(total / 0.5, 1)
		local value = TweenService:GetValue(v4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		p2.Spin = spin + (v3 - spin) * value
		applyShake(p, cframe, 1 - v4, p2.Spin)
	end

	EggActionMovement.SetPivot(p, cframe)
end

local function playDrop(p, cframe: CFrame, pivot: CFrame, fn)
	local total = 0
	local v3 = false

	while total < 0.26 do
		local v4 = RunService.Heartbeat:Wait()
		total += v4

		if p.Parent == nil then
			return
		end

		if not v3 and total + v4 * 1 >= 0.26 then
			fn()
			v3 = true
		end

		local value = TweenService:GetValue(math.min(total / 0.26, 1), Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		EggActionMovement.SetPivot(p, cframe:Lerp(pivot, value))
	end

	EggActionMovement.SetPivot(p, pivot)

	if not v3 then
		fn()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function triggerImpact(cframe: CFrame, flag: boolean)
	emitImpactVfx(cframe)

	if flag then
		Shake.Play({
			Seconds = 0.45,
			Magnitude = 1.6
		})
	end

	playNamedSound("MechaHatch", cframe)
end

local function playSettle(instance, pivot: CFrame)
	local scale = instance:GetScale()
	local total = 0

	while total < 0.22 do
		total += RunService.Heartbeat:Wait()

		if instance.Parent == nil then
			return
		end

		local v3 = math.min(total / 0.22, 1)
		local v4 = (1 - v3) * (1 - v3)
		local v5 = math.abs((math.sin(6.283185307179586 * v3))) * 0.9 * v4
		EggActionMovement.SetPivot(instance, pivot * CFrame.new(0, v5, 0))
		instance:ScaleTo(scale * (0.88 + 0.12 * TweenService:GetValue(
			v3,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)))
	end

	if instance.Parent ~= nil then
		instance:ScaleTo(scale)
		EggActionMovement.SetPivot(instance, pivot)
	end
end

return {
	Play = function(p: number, instance, callback)
		t.strict(t.number)(p)
		t.strict(t.instanceIsA("Model"))(instance)
		t.strict(t.callback)(callback)
		EggRenderer.DisableCollisions(instance)
		local pivot = instance:GetPivot()
		local v3 = pivot * CFrame.new(0, 7, 0)
		local v4, v5 = VisibleBounds(instance)
		local v6 = v4.Position - pivot.Position
		local cframe = CFrame.new(v4.Position - createVector(0, 1, 0) * (v5.Y * 0.5))
		local v7 = p == Players.LocalPlayer.UserId
		playNamedSound("MechaShake", pivot)
		local chargeParticles = createChargeParticles(instance)
		local v8 = EggEnergyOrbField.new(transient, color)
		local v9 = {
			Spin = 0
		}

		if playChargeLift(instance, pivot, v3, v6, v8, v9) then
			v8:Absorb(v3.Position + v6, 0.6, function(p2: number)
				if instance.Parent == nil then
					return
				end

				v9.Spin += p2 * 216
				applyShake(instance, v3, 1, v9.Spin)
			end)
		else
			v8:Destroy()
		end

		local v10

		if chargeParticles ~= nil then
			v10 = detachParticles(chargeParticles, v3.Position + v6)
		end

		local v11 = callback()

		if v11 == nil then
			v2:AtWarning():Log("Mecha upgrade swap did not produce a replacement egg model")
		else
			EggRenderer.DisableCollisions(v11)
			applyShake(v11, v3, 1, v9.Spin)

			if chargeParticles ~= nil and v10 ~= nil then
				attachToEgg(chargeParticles.Emit, v11) -- equivalent call inferred; original call site unknown
				attachToEgg(chargeParticles.Enable, v11) -- equivalent call inferred; original call site unknown
				v10:Destroy()
				emitTree(chargeParticles.Emit)
			end

			playShakeSettle(v11, v3, v9)
			playDrop(v11, v3, pivot, function()
				triggerImpact(cframe, v7) -- equivalent call inferred; original call site unknown
			end)
			playSettle(v11, pivot)
		end

		if chargeParticles ~= nil then
			releaseParticles(chargeParticles) -- equivalent call inferred; original call site unknown
		end
	end
}