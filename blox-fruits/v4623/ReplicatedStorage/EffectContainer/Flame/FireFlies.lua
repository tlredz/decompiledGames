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
local fireFlies = FX:WaitForChild("FlameEffects").FireFlies
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local scaleParticle = Util.ScaleParticle

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(p, p2)
	return p * p2
end

local v = {
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v2 = p2 + (p3 - p2) * p
	local v3 = p3 + (p4 - p3) * p
	local v4 = p4 + (p5 - p4) * p
	local v5 = v2 + (v3 - v2) * p
	return v5 + (v3 + (v4 - v3) * p - v5) * p
end

local function timeScaleParticle(child, p)
	child.Drag *= p
	child.Speed = NumberRange.new(child.Speed.Min * p, child.Speed.Max * p)
	child.Lifetime = NumberRange.new(child.Lifetime.Min / p, child.Lifetime.Max / p)
	child.Rate *= p
	child.RotSpeed = NumberRange.new(child.RotSpeed.Min * p, child.RotSpeed.Max * p)
	child.Acceleration *= p ^ 2
end

for _, emitter in ipairs(fireFlies.Ball:GetDescendants()) do
	if not emitter:IsA("ParticleEmitter") then
		continue
	end

	scaleParticle({
		Emitter = emitter,
		Scale = 2.75,
		Time = 0
	})
	emitter.Rate *= 2
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
	local fliesForIfNoImpact = data.fliesForIfNoImpact
	local v2 = data.impactTime - Workspace:GetServerTimeNow() + 0.01
	local impactPos = data.impactPos
	local startPosition = data.StartPosition
	local endPosition = data.EndPosition
	local willImpact = data.willImpact

	if (startPosition - Workspace.CurrentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	local effect = createEffect(CFrame.lookAt(startPosition, endPosition), fireFlies.Ball) -- equivalent call inferred; original call site unknown
	effect.Name = "FireflyBall"
	effect.Parent = _WorldOrigin
	Util.Sound:Play("Mera_FireFlies_Launch", startPosition)
	task.wait()
	destroyAfter(effect, v2 + 0.5)
	task.delay(v2, function()
		effect.Transparency = 1

		for _, child in pairs(effect.Particles:GetChildren()) do
			child.Enabled = false
		end
	end)
	local magnitude = (startPosition - endPosition).Magnitude
	local v3 = (startPosition - endPosition) / 2
	local position = CFrame.new(CFrame.new(startPosition) * (v3 / -1.5)).Position
	local position2 = CFrame.new(CFrame.new(endPosition) * (v3 / 1.5)).Position
	local v4 = magnitude / 5
	local v5 = position + Vector3.new(math.random(-v4, v4), math.random(0, v4 / 2), math.random(-v4, v4))
	local v6 = position2 + Vector3.new(math.random(-v4, v4), math.random(0, v4 / 2), math.random(-v4, v4))
	heartbeatLoopFor2(v2, function(p)
		local v7 = p / fliesForIfNoImpact
		local v8 = cubicBezier(v7, startPosition, v5, v6, endPosition)
		effect.CFrame = CFrame.lookAt(v8, endPosition)
	end)

	if willImpact == false then
		return
	end

	task.wait(v2)

	if (impactPos - Workspace.CurrentCamera.CFrame.Position).Magnitude < 75 then
		Util.CameraShaker:ShakeOnce(6, 10, 0.01, 0.35)
		local clone = fireFlies.FIREFLIEBLUR:Clone()
		clone.Parent = game.Lighting
		TweenService:Create(clone, v[2], {
			Size = 8
		}):Play()
		destroyAfter(clone, 1)
	end

	local effect2 = createEffect(CFrame.new(impactPos), fireFlies.Explosion) -- equivalent call inferred; original call site unknown
	effect2.Parent = _WorldOrigin
	local playbackSpeed = math.clamp((impactPos - startPosition).Magnitude / 350, 0, 1) + 0.5
	local play = Util.Sound:Play("Mera_FireFlies_Explosion", impactPos)
	play.PlaybackSpeed = playbackSpeed

	for _, child in ipairs(effect2.Particles:GetChildren()) do
		local lifetime = child.Lifetime
		child.Lifetime = NumberRange.new(lifetime.Min * 0.66, lifetime.Max * 0.66)
		timeScaleParticle(child, playbackSpeed)
		scaleParticle({
			Emitter = child,
			Scale = 7,
			Time = 0
		})
		child.ZOffset += 1
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local raycastResult = Workspace:Raycast(
		endPosition + createVector(0, 4, 0),
		createVector(-0, -14, -0),
		raycastParams
	)

	if raycastResult then
		local effect3 = createEffect(
			CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
			fireFlies.Scar
		) -- equivalent call inferred; original call site unknown
		effect3.Size *= 0.75

		for _, child in ipairs(effect3:GetChildren()) do
			TweenService:Create(child, v[1], {
				Transparency = 1
			}):Play()
		end

		destroyAfter(effect3, 1)
	end

	destroyAfter(effect2, 1.25)
end