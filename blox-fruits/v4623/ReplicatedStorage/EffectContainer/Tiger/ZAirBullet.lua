local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local flameFist = FX:WaitForChild("TigerEffects").Z_Untrans.FlameFist
local flameFistTransformed = FX:WaitForChild("TigerEffects").Z_Trans.FlameFistTransformed
local flameFistAwakened = FX:WaitForChild("TigerEffects").Z_Awak.FlameFistAwakened
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

return function(data)
	local player = data.player
	local _ = data.hrp
	local origin = data.origin
	local velocity = data.velocity
	local fliesFor = data.fliesFor
	local _ = data.airBulletSizeMult
	local transformed = data.transformed

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
		Util.CameraShaker:ShakeOnce(3, 3, 0.01, 0.05)
	end

	local folder = Instance.new("Folder", Workspace._WorldOrigin)
	Util.Debris:AddItem(folder, 3.5)

	if transformed == false then
		local clone = flameFist:Clone()
		clone.CFrame = CFrame.lookAt(origin, origin + velocity) * inverse * CFrame.Angles(0, 3.141592653589793, 0)
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 3)
		Util.Sound:Play("TigerFt_Z_Wind_Bullet_Launch_0" .. tostring(math.random(1, 3)), clone)
		emitAll(clone.ShotImpactWind)
		enableAll(clone.EnableFlames)
		task.spawn(function()
			task.wait(0.055)
			clone.AuraWind.Enabled = false
			clone.AuraWind2.Enabled = false
			emitAll(clone.WindBack)

			for _, descendant in pairs(clone.FireTrails:GetDescendants()) do
				descendant.Enabled = true
			end

			task.wait(0.12)
			clone.EmbersBall.Enabled = true
		end)
		destroyAfter(clone, fliesFor + 1)
		task.wait()
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
		local v = velocity.Magnitude * fliesFor / ((1 - 2 ^ (-12 * fliesFor)) / 8.317766166719343)
		local velocity2 = velocity.Unit * v
		bodyVelocity.Velocity = velocity2
		Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "LeopardFruitVFXColor")
		clone.Anchored = false
		heartbeatLoopFor2(fliesFor + 0.5, function(p)
			bodyVelocity.Velocity = velocity2 * 2 ^ (p * -12)
		end)
		local windTrailAttach1 = clone.WindTrailAttach1
		local windTrailAttach2 = clone.WindTrailAttach2
		local v3 = (windTrailAttach1.Position + windTrailAttach2.Position) * 0.5
		heartbeatLoopFor2(fliesFor, function()
			windTrailAttach1.CFrame = CFrame.Angles(0, 0.8, 0) * (windTrailAttach1.CFrame - v3) + v3
			windTrailAttach2.CFrame = CFrame.Angles(0, 0.8, 0) * (windTrailAttach2.CFrame - v3) + v3
		end)
		task.delay(fliesFor - 0.1, function()
			emitAll(clone.IMPACTBAMP)
		end)
		task.wait(fliesFor)
		clone.Transparency = 1
		Util.Sound:Play("TigerFt_Z_Wind_Bullet_Explode_0" .. tostring(math.random(1, 3)), clone)
		enableAll(clone, false)

		for _, trail in pairs(clone:GetDescendants()) do
			if trail:IsA("Trail") then
				trail.Enabled = false
			end
		end
	elseif transformed == true then
		local awakened = data.Awakened
		local clone

		if awakened then
			clone = flameFistAwakened:Clone()
			clone.CFrame = CFrame.lookAt(origin, origin + velocity) * inverse * CFrame.Angles(0, 3.141592653589793, 0)
			Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone, 3)
		else
			clone = nil
		end

		if not clone then
			clone = flameFistTransformed:Clone()
			clone.CFrame = CFrame.lookAt(origin, origin + velocity) * inverse * CFrame.Angles(0, 3.141592653589793, 0)
			Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone, 3)
		end

		if awakened then
			Util.Sound:Play("BF_TigerFt_AWK_Z_FireBullet_0" .. tostring(math.random(1, 4)), clone)
		else
			Util.Sound:Play("BF_TigerFt_TFM_Z_FireBullet_Launch_0" .. tostring(math.random(1, 3)), clone)
		end

		emitAll(clone.ShotImpactWind)
		enableAll(clone.EnableFlames)
		task.spawn(function()
			task.wait(0.037)
			clone.AuraWind.Enabled = false
			clone.AuraWind2.Enabled = false
			enableAll(clone.EnableFlames, true)
			emitAll(clone.WindBack)

			for _, descendant in pairs(clone.FireTrails:GetDescendants()) do
				descendant.Enabled = true
			end
		end)
		destroyAfter(clone, fliesFor + 1)
		task.wait()
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
		local v = velocity.Magnitude * fliesFor / ((1 - 2 ^ (-12 * fliesFor)) / 8.317766166719343)
		local velocity2 = velocity.Unit * v
		bodyVelocity.Velocity = velocity2
		Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "LeopardFruitVFXColor")
		clone.Anchored = false
		heartbeatLoopFor2(fliesFor + 0.5, function(p)
			bodyVelocity.Velocity = velocity2 * 2 ^ (p * -12)
		end)
		local windTrailAttach1 = clone.WindTrailAttach1
		local windTrailAttach2 = clone.WindTrailAttach2
		local v3 = (windTrailAttach1.Position + windTrailAttach2.Position) * 0.5
		heartbeatLoopFor2(fliesFor, function()
			windTrailAttach1.CFrame = CFrame.Angles(0, 0.8, 0) * (windTrailAttach1.CFrame - v3) + v3
			windTrailAttach2.CFrame = CFrame.Angles(0, 0.8, 0) * (windTrailAttach2.CFrame - v3) + v3
		end)
		task.delay(fliesFor - 0.1, function()
			emitAll(clone.IMPACTBAMP)
		end)
		task.wait(fliesFor)
		clone.Transparency = 1

		if awakened then
			Util.Sound:Play("BF_TigerFt_AWK_Z_Explode_0" .. tostring(math.random(1, 3)), clone)
		else
			Util.Sound:Play("BF_TigerFt_TFM_Z_FireBullet_Explode_0" .. tostring(math.random(1, 4)), clone)
		end

		enableAll(clone, false)

		for _, trail in pairs(clone:GetDescendants()) do
			if trail:IsA("Trail") then
				trail.Enabled = false
			end
		end
	end
end