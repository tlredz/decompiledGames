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
local jewelsOfLight = FX:WaitForChild("LightEffects").JewelsOfLight
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
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
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true),
	TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
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

for _, child in ipairs(jewelsOfLight.eff.Attachment:GetChildren()) do
	child.ZOffset += 4
	scaleParticle({
		Emitter = child,
		Time = 0,
		Scale = 1.5
	})
end

jewelsOfLight.Ball.PointLight.Range *= 2
return function(data)
	local projectileVelocity = data.projectileVelocity
	local origin = data.origin
	local impactPos = data.impactPos
	local willImpact = data.willImpact
	local fliesForMax = data.fliesForMax
	local currentCamera = Workspace.CurrentCamera
	local magnitude = projectileVelocity.Magnitude

	if (origin - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local effect = createEffect(CFrame.lookAt(origin, impactPos) * CFrame.Angles(1.57, 0, 0), jewelsOfLight.Ball) -- equivalent call inferred; original call site unknown
	destroyAfter(effect, fliesForMax)
	Util.Sound:Play("PIKA_JewelsShot", effect)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
	bodyVelocity.Velocity = projectileVelocity
	bodyVelocity.Parent = effect
	local cFrame = effect.CFrame

	if willImpact == false then
		return
	end

	local v3 = (impactPos - origin).Magnitude / magnitude
	task.wait(v3)
	effect.Position = impactPos
	effect.Anchored = true
	effect.Transparency = 1
	effect:ClearAllChildren()
	Util.Sound:Play("PIKA_JewelExplosion", impactPos)
	local lookVector = CFrame.new(cFrame.Position, impactPos).LookVector
	local raycastResult = Workspace:Raycast(effect.Position - lookVector * 10, lookVector * 100, raycastParams)
	local effect2 = createEffect(CFrame.new(effect.Position) * CFrame.new(0, 1.5, 0), jewelsOfLight.eff) -- equivalent call inferred; original call site unknown
	destroyAfter(effect2, 1.55)

	for _, child in ipairs(effect2.Attachment:GetChildren()) do
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

	TweenService:Create(effect2.PointLight, v[3], {
		Range = 0,
		Brightness = 0
	}):Play()
end