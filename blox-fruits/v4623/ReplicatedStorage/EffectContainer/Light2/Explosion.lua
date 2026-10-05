local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local yataMirror = FX:WaitForChild("LightEffects").YataMirror
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
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
	TweenInfo.new(0.1, Enum.EasingStyle.Sine),
	TweenInfo.new(0.15, Enum.EasingStyle.Sine),
	TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true)
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

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(cFrame, instance, p)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	return clone
end

local _ = Util.VignetteService
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {
	_WorldOrigin,
	Workspace.CurrentCamera,
	Workspace.Characters,
	Workspace.Enemies
}
local rocksModule = Util.RocksModule

local function ScaleParticle(child, scale)
	local keypoints = child.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * scale,
			keypoint.Envelope * scale
		)
	end

	child.Size = NumberSequence.new(numberSequenceKeypoints)
	child.Speed = NumberRange.new(child.Speed.Min * scale, child.Speed.Max * scale)
	child.Acceleration *= scale
end

return function(data)
	local cFrame = data.CFrame
	local speed = data.Speed or 1
	local scale = data.Scale or data.ScaleMultiplier or data.ScaleMult or 1
	local v2 = speedMultiplyTweens(v, speed)
	local raycastResult = Workspace:Raycast(
		cFrame.Position + createVector(0, 5, 0),
		createVector(0, -10, 0),
		raycastParams
	)

	if (Workspace.CurrentCamera.CFrame.Position - cFrame.p).Magnitude < 300 + 100 * scale then
		if (Workspace.CurrentCamera.CFrame.Position - cFrame.p).Magnitude < 160 * scale then
			Util.CameraShaker:ShakeOnce(15, 10, 0.01, 0.7)
			local clone = yataMirror.ColorCorrection:Clone()
			clone.Parent = game.Lighting
			destroyAfter(clone, 1)
			TweenService:Create(clone, v2[4], {
				Brightness = 0,
				TintColor = Color3.new(1, 1, 1)
			}):Play()
			local clone2 = yataMirror.Blur:Clone()
			clone2.Parent = game.Lighting
			TweenService:Create(clone2, v2[5], {
				Size = 10
			}):Play()
			destroyAfter(clone2, 1)
		end

		local v3 = sound:Play("Pika_LightKickExplosion", cFrame.p, nil, 0.75)
		task.delay(1, function()
			sound:FadeOut(v3, 0.5)
		end)
		local effect = createEffect(cFrame, yataMirror.eff) -- equivalent call inferred; original call site unknown
		destroyAfter(effect, 2.5)

		for _, child in ipairs(effect.Attachment:GetChildren()) do
			if child.Name == "smoke" or child.Name == "Rocks" then
				if raycastResult then
					if child.Name ~= "Rocks" then
						child.Color = ColorSequence.new(raycastResult.Instance.Color)
					end

					ScaleParticle(child, scale)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			else
				ScaleParticle(child, scale)
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end

		if raycastResult then
			local v4 = sound:Play("GroundSmash", cFrame.p, nil, 0.75)
			task.delay(0.5, function()
				sound:FadeOut(v4, 0.5)
			end)
			local effect2 = createEffect(
				CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
				yataMirror.Scar
			) -- equivalent call inferred; original call site unknown
			effect2.Size *= 1.25 * scale

			for _, child in ipairs(effect2:GetChildren()) do
				TweenService:Create(child, v2[3], {
					Transparency = 1
				}):Play()
			end

			destroyAfter(effect2, 1.26)
			rocksModule.Ground(
				raycastResult.Position,
				40 * scale,
				createVector(5, 7, 5) * scale,
				{ Workspace.Map },
				8 * scale,
				false,
				1,
				true
			)
		end
	end
end