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
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local _ = Util.ScaleParticle

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

local function speedMultiplyTweens(list, speed)
	local tweenInfos = {}

	for i, v2 in ipairs(list) do
		tweenInfos[i] = TweenInfo.new(
			v2.Time / speed,
			v2.EasingStyle,
			v2.EasingDirection,
			v2.RepeatCount,
			v2.Reverses,
			v2.DelayTime
		)
	end

	return tweenInfos
end

local function createEffect(cFrame, instance, value)
	local clone = instance:Clone()
	clone.CFrame = cFrame
	local v2 = value or 1

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Size *= v2
		elseif descendant:IsA("ParticleEmitter") then
			Util.Misc.ScaleParticle(descendant, v2)
		elseif descendant:IsA("Beam") then
			descendant.Width0 *= v2
			descendant.Width1 *= v2
		elseif descendant:IsA("Attachment") then
			descendant.Position *= v2
		end
	end

	return clone
end

local effect = createEffect(CFrame.new(0, 9000000000, 0), lightKick.eff, 2)
local effect2 = createEffect(CFrame.new(0, 9000000000, 0), lightKick.Shockwave, 2)
local effect3 = createEffect(CFrame.new(0, 9000000000, 0), lightKick.Scar, 2)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {
	_WorldOrigin,
	Workspace.CurrentCamera,
	Workspace.Characters,
	Workspace.Enemies
}
return function(data)
	local cFrame = data.CFrame
	local _ = data.Scale
	local speed = data.Speed
	local currentCamera = Workspace.CurrentCamera

	if (cFrame.p - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local v2 = speedMultiplyTweens(v, speed)
	local raycastResult = Workspace:Raycast(
		cFrame.Position + createVector(0, 5, 0),
		createVector(0, -10, 0),
		raycastParams
	)
	local clone = effect:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 1.55)

	for _, child in ipairs(clone.Attachment:GetChildren()) do
		if not ((child.Name == "smoke" or child.Name == "Rocks") and raycastResult) then
			continue
		end

		Util.Misc.ScaleParticle(child, 0.5)

		if child.Name ~= "Rocks" then
			child.Color = ColorSequence.new(raycastResult.Instance.Color)
		end

		child:Emit(child:GetAttribute("EmitCount") * (data.Nerf or 1))
	end

	if not data.IgnoreSound then
		Util.Sound:Play("Pika_LightKickExplosion", cFrame.p, nil, 1 + 1 / speed * 0.5)
	end

	for i = 1, 2 do
		local clone2 = effect2:Clone()
		clone2.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.new(0, 3, 0)
		clone2.Size *= createVector(1, 0.5, 1)
		clone2.Parent = _WorldOrigin
		clone2.Color = Color3.new(1, 1, 0)
		destroyAfter(clone2, 0.5)

		if i == 1 then
			TweenService:Create(clone2, v2[5], {
				CFrame = clone2.CFrame * CFrame.new(0, -2, 0),
				Size = Vector3.new(clone2.Size.X * 3, 0, clone2.Size.Z * 3),
				Transparency = 1,
				Color = Color3.new(1, 1, 1)
			}):Play()
		else
			clone2.CFrame *= CFrame.new(0, 9, 0)
			TweenService:Create(clone2, v2[5], {
				CFrame = clone2.CFrame * CFrame.new(0, -2, 0),
				Size = Vector3.new(clone2.Size.X * 1.75, 0, clone2.Size.Z * 1.75),
				Transparency = 1
			}):Play()
		end
	end

	if raycastResult then
		local v3 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		local clone2 = effect3:Clone()
		clone2.CFrame = v3 * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		clone2.Parent = _WorldOrigin
		destroyAfter(clone2, 1.25)

		for _, child in ipairs(clone2:GetChildren()) do
			TweenService:Create(child, v2[3], {
				Transparency = 1
			}):Play()
		end
	end

	if (Workspace.CurrentCamera.CFrame.Position - cFrame.p).Magnitude < 50 then
		Util.CameraShaker:ShakeOnce(9, 10, 0.01, 0.2)
		local clone2 = lightKick.Blur:Clone()
		clone2.Parent = game.Lighting
		TweenService:Create(clone2, v2[2], {
			Size = 9
		}):Play()
		destroyAfter(clone2, 1)
	end
end