local createVector = vector.create
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
local lightKick = FX:WaitForChild("LightEffects").LightKick
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local scaleParticle = Util.ScaleParticle

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(p, p2)
	return p * p2
end

local v = {
	TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {
	_WorldOrigin,
	Workspace.CurrentCamera,
	Workspace.Characters,
	Workspace.Enemies
}
return function(data)
	local origin = data.origin
	local laserImpactPos = data.laserImpactPos
	local speedOfBeam = data.speedOfBeam
	local v2 = (laserImpactPos - origin).Magnitude / speedOfBeam

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local effect = createEffect(CFrame.new(), lightKick.Beam) -- equivalent call inferred; original call site unknown
	heartbeatLoopFor2(v2, function(p, p2, p3)
		local v3 = origin + (laserImpactPos - origin) * p3
		effect.Size = Vector3.new(effect.Size.X, (origin - v3).Magnitude, effect.Size.Z)
		effect.CFrame = CFrame.lookAt(origin, v3) * CFrame.new(0, 0, -((v3 - origin).Magnitude / 2)) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
	end, function()
		local laserImpactPos2 = laserImpactPos
		effect.Size = Vector3.new(effect.Size.X, (origin - laserImpactPos2).Magnitude, effect.Size.Z)
		effect.CFrame = CFrame.lookAt(origin, laserImpactPos2) * CFrame.new(
			0,
			0,
			-((laserImpactPos2 - origin).Magnitude / 2)
		) * CFrame.Angles(1.5707963267948966, 0, 0)
		TweenService:Create(effect, v[5], {
			Size = Vector3.new(0, effect.Size.Y, 0)
		}):Play()
	end)
	destroyAfter(effect, v2 + 0.31)
	task.spawn(function()
		for i = 3.5, 1.5, -1 do
			local effect2 = createEffect(
				CFrame.new(origin, laserImpactPos) * CFrame.new(0, 0, -((laserImpactPos - origin).Magnitude / i)) * CFrame.Angles(
					0,
					1.57,
					1.57
				),
				lightKick.Shockwave2
			) -- equivalent call inferred; original call site unknown
			TweenService:Create(effect2, v[4], {
				CFrame = effect2.CFrame * CFrame.new(0, 8.5, 0),
				Size = Vector3.new(effect2.Size.X * 2 * (i / 2.5), 0, effect2.Size.Z * 2 * (i / 2.5)),
				Transparency = 1
			}):Play()
			destroyAfter(effect2, 0.5)
			task.wait(v2 * 0.25)
		end
	end)
	Util.Sound:Play("Pika_LightKick", origin, data.soundRadius, data.soundPitch)
	task.wait(v2)
	local raycastResult = Workspace:Raycast(origin, (laserImpactPos - origin) * 1.1, raycastParams)
	local effect2 = createEffect(CFrame.new(laserImpactPos), lightKick.eff) -- equivalent call inferred; original call site unknown
	destroyAfter(effect2, 1.55)

	for i, child in ipairs(effect2.Attachment:GetChildren()) do
		if child.Name == "smoke" or child.Name == "Rocks" then
			if raycastResult then
				if child.Name ~= "Rocks" then
					child.Color = ColorSequence.new(raycastResult.Instance.Color)
				end

				child:Emit(child:GetAttribute("EmitCount"))
			end
		else
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	Util.Sound:Play("Pika_LightKickExplosion", laserImpactPos, _, 1.5)

	for i = 1, 2 do
		local effect3 = createEffect(effect2.CFrame * CFrame.new(0, 3, 0), lightKick.Shockwave) -- equivalent call inferred; original call site unknown
		destroyAfter(effect3, 0.5)

		if i == 1 then
			TweenService:Create(effect3, v[5], {
				CFrame = effect3.CFrame * CFrame.new(0, -2, 0),
				Size = Vector3.new(effect3.Size.X * 2.5, 0, effect3.Size.Z * 2.5),
				Transparency = 1
			}):Play()
		else
			effect3.CFrame *= CFrame.new(0, 9, 0)
			TweenService:Create(effect3, v[5], {
				CFrame = effect3.CFrame * CFrame.new(0, -2, 0),
				Size = Vector3.new(effect3.Size.X * 1.75, 0, effect3.Size.Z * 1.75),
				Transparency = 1
			}):Play()
		end
	end

	if raycastResult then
		local effect3 = createEffect(
			CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
			lightKick.Scar
		) -- equivalent call inferred; original call site unknown
		destroyAfter(effect3, 1.25)

		for i, child in ipairs(effect3:GetChildren()) do
			TweenService:Create(child, v[3], {
				Transparency = 1
			}):Play()
		end
	end
end