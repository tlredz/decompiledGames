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
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local VLightLaser = require(script.Parent:WaitForChild("VLightLaser"))
local TweenService = game:GetService("TweenService")
local scaleParticle = Util.ScaleParticle

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

local function speedMultiplyTweens(list, speedMult)
	local tweenInfos = {}

	for i, v2 in ipairs(list) do
		tweenInfos[i] = TweenInfo.new(
			v2.Time / speedMult,
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

local vignetteService = Util.VignetteService
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {
	_WorldOrigin,
	Workspace.CurrentCamera,
	Workspace.Characters,
	Workspace.Enemies
}
local rocksModule = Util.RocksModule

local function ScaleParticle(child, impactSizeMult)
	local keypoints = child.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * impactSizeMult,
			keypoint.Envelope * impactSizeMult
		)
	end

	child.Size = NumberSequence.new(numberSequenceKeypoints)
	child.Speed = NumberRange.new(child.Speed.Min * impactSizeMult, child.Speed.Max * impactSizeMult)
	child.Acceleration *= impactSizeMult
end

return function(data)
	local char = data.char
	local root = data.root
	local mousePos = data.mousePos
	local maxDist = data.maxDist
	local impactPos = data.impactPos
	local yataMirrorActive = data.yataMirrorActive
	local speedMult = data.speedMult
	local impactSizeMult = data.impactSizeMult

	if char:FindFirstChildOfClass("Humanoid") == nil or root == nil or (root.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local v2 = speedMultiplyTweens(v, speedMult)
	local v3 = root.Position + (mousePos - root.Position).Unit * math.min(maxDist, (mousePos - root.Position).Magnitude)
	local magnitude = (root.Position - v3).Magnitude
	local cFrame = root.CFrame
	local total = 10
	local v4 = 1
	task.spawn(function()
		for i = 1, magnitude / 25 do
			if yataMirrorActive.Value == false then
				break
			end

			local effect = createEffect(
				root.CFrame * CFrame.new(v4 == 1 and 25 or -25, total, i * -25) * CFrame.Angles(0, 1.57, 0),
				yataMirror.Square,
				"Square" .. i
			) -- equivalent call inferred; original call site unknown
			destroyAfter(effect, 1.2)
			TweenService:Create(effect, v2[1], {
				Size = effect.Size * 3
			}):Play()
			Util.Sound:Play("LightMirrorReflect", effect.Position, _, i * 0.15 + 2.5)

			for i2, child in ipairs(effect.Attachment:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			local effect2 = createEffect(CFrame.new(cFrame.Position, effect.Position), yataMirror.Beam) -- equivalent call inferred; original call site unknown
			local magnitude2 = (effect.Position - cFrame.Position).Magnitude
			destroyAfter(effect2, 1.25)
			TweenService:Create(effect2, v2[2], {
				Size = Vector3.new(1, 1, magnitude2),
				CFrame = CFrame.new(cFrame.Position, effect.Position) * CFrame.new(0, 0, -magnitude2 / 2)
			}):Play()
			task.delay(1, function()
				TweenService:Create(effect, v2[1], {
					Size = effect.Size * 0
				}):Play()
				task.wait(0.1)
				TweenService:Create(effect2, v2[2], {
					Position = effect.Position,
					Size = createVector(1, 1, 0)
				}):Play()
			end)
			local v9 = v4 == 1 and 2 or 1
			local cFrame2 = effect.CFrame
			v4 = v9
			cFrame = cFrame2
			total += 10
			task.wait(0.15 / speedMult)
		end
	end)
	local connection = nil
	connection = heartbeatLoopFor2(5, function(p)
		if yataMirrorActive.Value ~= false and not (p > 2) then
			return
		end

		connection:Disconnect()
		connection = nil
		local laserImpactPos = impactPos.Value
		local cFrame2 = Util.Misc.AlignCFrame(CFrame.new(createVector(0, 0, 0), root.CFrame.LookVector)) + laserImpactPos + createVector(
			0,
			1,
			0
		) * total
		local effect = createEffect(CFrame.new(cFrame.Position, cFrame2.Position), yataMirror.Beam) -- equivalent call inferred; original call site unknown
		local magnitude2 = (cFrame2.Position - cFrame.Position).Magnitude
		destroyAfter(effect, 1.25)
		TweenService:Create(effect, v2[2], {
			Size = Vector3.new(0.75, 0.75, magnitude2),
			CFrame = CFrame.new(cFrame.Position, cFrame2.Position) * CFrame.new(0, 0, -magnitude2 / 2)
		}):Play()
		task.wait(0.15 / speedMult)
		local v6 = cFrame2.p - root.CFrame.p
		local ray, v7 = Util.Ray(root.CFrame.p, v6 + v6.unit, { Workspace.Characters, Workspace.Enemies })

		if ray then
			root.CFrame = CFrame.new(v7 - v6.unit * 3) * (cFrame2 - cFrame2.p)
		else
			root.CFrame = cFrame2
		end

		if char == game.Players.LocalPlayer.Character then
			local yataMirrorKick = Util.Anims:Get(char, "YataMirrorKick1")
			yataMirrorKick:Play()
			yataMirrorKick:AdjustSpeed(0.5 * speedMult)
		end

		local raycastResult = Workspace:Raycast(
			cFrame2.Position + createVector(0, 5, 0),
			Vector3.new(0, -total - 10, 0),
			raycastParams
		)
		task.spawn(function()
			VLightLaser({
				laserImpactPos = laserImpactPos,
				origin = cFrame2.Position,
				speedOfBeam = (laserImpactPos - cFrame2.Position).Magnitude / (0.35 / speedMult),
				soundPitch = 0.5,
				soundRadius = 120
			})
		end)
		task.wait(0.35 / speedMult)

		if (Workspace.CurrentCamera.CFrame.Position - laserImpactPos).Magnitude < 160 then
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

		local effect2 = createEffect(CFrame.new(laserImpactPos), yataMirror.eff) -- equivalent call inferred; original call site unknown
		destroyAfter(effect2, 2.5)

		for i, child in ipairs(effect2.Attachment:GetChildren()) do
			if child.Name == "smoke" or child.Name == "Rocks" then
				if raycastResult then
					if child.Name ~= "Rocks" then
						child.Color = ColorSequence.new(raycastResult.Instance.Color)
					end

					ScaleParticle(child, impactSizeMult)
					child:Emit(child:GetAttribute("EmitCount"))
				end
			else
				ScaleParticle(child, impactSizeMult)
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end

		if raycastResult then
			local effect3 = createEffect(
				CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0),
				yataMirror.Scar
			) -- equivalent call inferred; original call site unknown
			effect3.Size *= 1.25 * impactSizeMult

			for i, child in ipairs(effect3:GetChildren()) do
				TweenService:Create(child, v2[3], {
					Transparency = 1
				}):Play()
			end

			destroyAfter(effect3, 1.26)
			rocksModule.Ground(
				raycastResult.Position,
				40 * impactSizeMult,
				createVector(5, 7, 5) * impactSizeMult,
				{ Workspace.Map },
				8 * impactSizeMult,
				false,
				1,
				true
			)
		end

		task.delay(0.6, function()
			local tween = TweenService:Create(effect, v2[2], {
				Position = cFrame2.Position,
				Size = createVector(1, 1, 0)
			})
			tween:Play()
			tween.Completed:Once(function()
				if effect and effect.Parent ~= nil then
					effect:Destroy()
				end
			end)
		end)
	end)
end