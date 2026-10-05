game:GetService("Debris")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local modules = script.Modules
local Flipbook = require(modules.Flipbook)
local Maid = require(modules.Maid)
local BoatTween = require(game.ReplicatedStorage.library.BoatTween)
local thrown = workspace:WaitForChild("Thrown")
local SphereAnimData = require(script:WaitForChild("SphereAnimData"))
Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getUpdateSignal()
	if RunService:IsRunning() then
		return RunService.Heartbeat
	end

	return RunService.RenderStepped
end

local function collectBones(folder)
	local bonesByName = {}

	for _, bone in ipairs(folder:GetDescendants()) do
		if bone:IsA("Bone") then
			bonesByName[bone.Name] = bone
		end
	end

	return bonesByName
end

local linear = Enum.PoseEasingStyle.Linear
local easingDirection2 = Enum.PoseEasingDirection.In

local function buildFrames(p)
	local bones = p.bones
	local clone = {}
	local result = {}

	for _, keyframe in ipairs(p.keyframes) do
		clone = table.clone(clone)

		for _, v2 in ipairs(keyframe.identity) do
			clone[bones[v2]] = {
				CFrame = CFrame.identity,
				EasingStyle = linear,
				EasingDirection = easingDirection2
			}
		end

		for k, v2 in pairs(keyframe.translation) do
			clone[bones[k]] = {
				CFrame = CFrame.new(v2[1], v2[2], v2[3]),
				EasingStyle = linear,
				EasingDirection = easingDirection2
			}
		end

		for k, v2 in pairs(keyframe.full) do
			clone[bones[k]] = {
				CFrame = CFrame.new(
					v2[1],
					v2[2],
					v2[3],
					v2[4],
					v2[5],
					v2[6],
					v2[7],
					v2[8],
					v2[9],
					v2[10],
					v2[11],
					v2[12]
				),
				EasingStyle = linear,
				EasingDirection = easingDirection2
			}
		end

		for k, v2 in pairs(keyframe.easing) do
			local v3 = clone[bones[k]]

			if not v3 then
				continue
			end

			v3.EasingStyle = Enum.PoseEasingStyle[v2[1]]
			v3.EasingDirection = Enum.PoseEasingDirection[v2[2]]
		end

		table.insert(result, {
			Name = keyframe.name,
			Time = keyframe.time,
			Poses = clone
		})
	end

	return result
end

local function easeAlpha(value: number, easingStyle, easingDirection)
	local v2 = math.clamp(value, 0, 1)
	local v3 = easingStyle or Enum.EasingStyle.Linear
	local v4 = easingDirection or Enum.EasingDirection.InOut

	if v3 == Enum.EasingStyle.Linear then
		return v2
	end

	if v3 == Enum.EasingStyle.Sine then
		if v4 == Enum.EasingDirection.In then
			return 1 - math.cos(v2 * 3.141592653589793 / 2)
		end

		if v4 == Enum.EasingDirection.Out then
			return (math.sin(v2 * 3.141592653589793 / 2))
		end

		return -(math.cos(3.141592653589793 * v2) - 1) / 2
	elseif v3 == Enum.EasingStyle.Quad then
		if v4 == Enum.EasingDirection.In then
			return v2 * v2
		end

		if v4 == Enum.EasingDirection.Out then
			return 1 - (1 - v2) * (1 - v2)
		end

		if v2 < 0.5 then
			return v2 * 2 * v2
		end

		return 1 - (v2 * -2 + 2) ^ 2 / 2
	else
		if v3 ~= Enum.EasingStyle.Cubic then
			return v2
		end

		if v4 == Enum.EasingDirection.In then
			return v2 ^ 3
		end

		if v4 == Enum.EasingDirection.Out then
			return 1 - (1 - v2) ^ 3
		end

		if v2 < 0.5 then
			return v2 ^ 3 * 4
		end

		return 1 - (v2 * -2 + 2) ^ 3 / 2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleCFrameTranslation(cframe: CFrame, p: number)
	local v2 = cframe.X * p
	local v3 = cframe.Y * p
	local v4 = cframe.Z * p
	local _, _, _, v5, v6, v7, v8, v9, v10, v11, v12, v13 = cframe:GetComponents()
	return CFrame.new(v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13)
end

local function getModelScale(model)
	if model:IsA("Model") and model.PrimaryPart then
		local success, result = pcall(function()
			return model:GetScale()
		end)

		if success and type(result) == "number" and result > 0 then
			return result
		end
	end

	return 1
end

local function createKeyframePreviewPlayer(model, SphereAnimData2, value: number?, animscaler2)
	local bonesByName = collectBones(model)
	local frames = buildFrames(SphereAnimData2)
	local updateSignal = getUpdateSignal() -- equivalent call inferred; original call site unknown
	local v3 = {
		_conn = nil,
		_playing = false,
		_speed = 1,
		_looped = false,
		_length = 0,
		_frames = frames,
		_bonesByName = bonesByName,
		_originalTransforms = {},
		_animScale = value or 1
	}

	for _, v4 in pairs(bonesByName) do
		v3._originalTransforms[v4] = v4.Transform
	end

	if #frames > 0 then
		v3._length = frames[#frames].Time
	end

	local function getCombinedScale()
		local v4

		if animscaler2 then
			if model.Name == "center" then
				v4 = 10 * value * animscaler2.Value
			else
				v4 = 20 * value * animscaler2.Value
			end
		elseif model.Name == "center" then
			v4 = 10 * value
		else
			v4 = 20 * value
		end

		return v4 * v3._animScale
	end

	local function applyFramePoses(poses)
		local v4

		if animscaler2 then
			if model.Name == "center" then
				v4 = 10 * value * animscaler2.Value
			else
				v4 = 20 * value * animscaler2.Value
			end
		elseif model.Name == "center" then
			v4 = 10 * value
		else
			v4 = 20 * value
		end

		local v5 = v4 * v3._animScale

		for k, item in pairs(poses) do
			local v6 = bonesByName[k]

			if v6 then
				v6.Transform = scaleCFrameTranslation(item.CFrame, v5)
			end
		end
	end

	local function getSegmentAtTime(p)
		if #frames == 0 then
			return nil, nil, 0
		end

		if #frames == 1 then
			return frames[1], frames[1], 0
		end

		if p <= frames[1].Time then
			return frames[1], frames[2], 0
		end

		for i = 1, #frames - 1 do
			local frame = frames[i]
			local frame2 = frames[i + 1]

			if not (frame.Time <= p and p <= frame2.Time) then
				continue
			end

			local v4 = frame2.Time - frame.Time
			return frame, frame2, not (v4 > 0) and 1 or (p - frame.Time) / v4 or 1
		end

		return frames[#frames], frames[#frames], 1
	end

	local function applyInterpolated(segmentAtTime, p, p2)
		if not (segmentAtTime and p) then
			return
		end

		local v4

		if animscaler2 then
			if model.Name == "center" then
				v4 = 10 * value * animscaler2.Value
			else
				v4 = 20 * value * animscaler2.Value
			end
		elseif model.Name == "center" then
			v4 = 10 * value
		else
			v4 = 20 * value
		end

		local v5 = v4 * v3._animScale
		local poses = segmentAtTime.Poses
		local poses2 = p.Poses

		for k, v6 in pairs(bonesByName) do
			local pos = poses[k]
			local pos2 = poses2[k]

			if not (pos or pos2) then
				continue
			end

			local cFrame = pos and pos.CFrame or CFrame.identity
			local v7

			if pos2 then
				v7 = pos2.CFrame or cFrame
			else
				v7 = cFrame
			end

			v6.Transform = scaleCFrameTranslation(
				cFrame:Lerp(
					v7,
					(easeAlpha(
						p2,
						pos2 and pos2.EasingStyle or Enum.EasingStyle.Linear,
						pos2 and pos2.EasingDirection or Enum.EasingDirection.InOut
					))
				),
				v5
			)
		end
	end

	function v3:SetAnimScale(value2: number)
		self._animScale = value2 or 1
	end

	function v3:Play(flag: boolean?, value2: number?, animScale: number?)
		self:Stop(false)
		self._looped = flag == true
		self._speed = value2 or 1

		if animScale ~= nil then
			self._animScale = animScale
		end

		self._playing = true

		if #self._frames == 0 then
			return
		end

		local total = 0
		applyFramePoses(self._frames[1].Poses)
		self._conn = updateSignal:Connect(function(p)
			if not self._playing then
				return
			end

			total += p * self._speed

			if self._length <= 0 then
				applyFramePoses(self._frames[#self._frames].Poses)
				return
			end

			local v4 = total

			if self._looped then
				v4 %= self._length
			elseif self._length <= v4 then
				applyFramePoses(self._frames[#self._frames].Poses)
				self:Stop(false)
				return
			end

			local segmentAtTime, v5, v6 = getSegmentAtTime(v4)
			applyInterpolated(segmentAtTime, v5, v6)
		end)
	end

	function v3:Stop(flag: boolean?)
		self._playing = false

		if self._conn then
			self._conn:Disconnect()
			self._conn = nil
		end

		if flag ~= false then
			for k, _originalTransform in pairs(self._originalTransforms) do
				if k and k.Parent then
					k.Transform = _originalTransform
				end
			end
		end
	end

	return v3
end

local function easeOutBounce(p)
	if p < 0.36363636363636365 then
		return 7.5625 * p * p
	end

	if p < 0.7272727272727273 then
		local v2 = p - 0.5454545454545454
		return 7.5625 * v2 * v2 + 0.75
	end

	if p < 0.9090909090909091 then
		local v2 = p - 0.8181818181818182
		return 7.5625 * v2 * v2 + 0.9375
	end

	local v2 = p - 0.9545454545454546
	return 7.5625 * v2 * v2 + 0.984375
end

local function easeInBounce(p)
	local v2 = 1 - p
	local v3

	if v2 < 0.36363636363636365 then
		v3 = 7.5625 * v2 * v2
	elseif v2 < 0.7272727272727273 then
		local v4 = v2 - 0.5454545454545454
		v3 = 7.5625 * v4 * v4 + 0.75
	elseif v2 < 0.9090909090909091 then
		local v4 = v2 - 0.8181818181818182
		v3 = 7.5625 * v4 * v4 + 0.9375
	else
		local v4 = v2 - 0.9545454545454546
		v3 = 7.5625 * v4 * v4 + 0.984375
	end

	return 1 - v3
end

local function enableParticles(folder)
	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end
end

local function disableParticles(folder)
	for _, effect in ipairs(folder:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = false
		end
	end
end

local function emitEffects(folder, value, _)
	local v2 = value or 1

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local v3 = descendant
			task.spawn(function()
				local v4 = (v3:GetAttribute("EmitDelay") or 0) * v2
				local emitCount = v3:GetAttribute("EmitCount") or 0
				local emitDuration = v3:GetAttribute("EmitDuration")

				if emitDuration and emitDuration > 0 then
					v3.Enabled = true
					task.wait(emitDuration * v2)
					v3.Enabled = false
				else
					task.wait(v4)
					v3:Emit(emitCount)
				end
			end)
		elseif descendant:IsA("PointLight") and descendant.Name == "SpecialLight" then
			local v3 = descendant
			task.spawn(function()
				v3.Enabled = true
				local brightness = v3:GetAttribute("Brightness") or v3.Brightness
				local range = v3:GetAttribute("Range") or v3.Range
				local v4 = (v3:GetAttribute("Tween") or 0.2) * v2
				TweenService:Create(v3, TweenInfo.new(v4, Enum.EasingStyle.Sine), {
					Brightness = brightness,
					Range = range
				}):Play()
			end)
		elseif descendant:IsA("Beam") then
			local v3 = descendant
			task.spawn(function()
				local v4 = (v3:GetAttribute("EmitDelay") or 0) * v2
				local v5 = (v3:GetAttribute("EmitDuration") or 0.5) * v2
				local time = 0.25 * v2
				local transparency = v3.Transparency
				task.wait(v4)
				v3.Transparency = NumberSequence.new(1)
				v3.Enabled = true
				BoatTween:Create(v3, {
					Time = v5 / 2,
					EasingStyle = "Sine",
					EasingDirection = "In",
					Goal = {
						Transparency = transparency
					}
				}):Play()
				task.delay(v5 / 2, function()
					BoatTween:Create(v3, {
						Time = time,
						EasingStyle = "Sine",
						EasingDirection = "Out",
						Goal = {
							Transparency = NumberSequence.new(1)
						}
					}):Play()
				end)
			end)
		end
	end
end

local function createScaleDriver(object, clone)
	local v2 = object:give(Instance.new("NumberValue"))
	v2.Value = clone:GetScale()
	object:giveTask(v2.Changed:Connect(function()
		clone:ScaleTo(v2.Value)
	end))
	return v2
end

local Effectv2b2 = {}
Effectv2b2.__index = Effectv2b2

function Effectv2b2.Attack(_, p, value, value2, p2)
	local v2 = value or 1
	local v3 = value2 or 1
	local position = p.Position
	local v4 = Maid.new()
	task.delay(15 * v3, function()
		v4:doCleaning()
	end)
	local parent = v4:give(Instance.new("Folder"))
	parent.Name = "Explosion"
	parent.Parent = thrown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function burst(childName, p3, p4)
		task.spawn(function()
			if v3 < 1 then
				return
			end

			local child = script:FindFirstChild(childName)

			if not child then
				return
			end

			for _ = 1, p3 do
				if p4 then
					task.wait(p4 * v3)
				end

				local v6 = v4:give(child:Clone())
				v6.Parent = parent
				v6.CFrame = CFrame.new(position) * CFrame.new(0, 3, 0) * CFrame.fromEulerAnglesXYZ(
					0,
					math.random(-180, 180),
					0
				)
				Flipbook.animate(v6.Decal, false, math.random(40, 90) * v3, 1, false, false)
				local v7 = math.random(5, 10) * 0.1 * v3
				local v8

				if animscaler then
					v8 = math.random(13, 17) * (v2 * 1.1) * animscaler.Value
				else
					v8 = math.random(13, 17) * (v2 * 1.1)
				end

				local tweenInfo = TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(v6.Mesh, tweenInfo, {
					Scale = Vector3.new(v8, v8 / 1.3, v8)
				}):Play()
				TweenService:Create(v6, TweenInfo.new(v7 * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = v6.CFrame * CFrame.fromEulerAnglesXYZ(0, math.random(1000, 2500), 0)
				}):Play()
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function distortionBurst(p3, p4)
		task.spawn(function()
			for _ = 1, p3 do
				if p4 then
					task.wait(p4 * v3)
				end

				task.spawn(function()
					local v6 = v4:give(script.Distortion:Clone())
					v6.Parent = parent
					v6.CFrame = CFrame.new(position)
					local v7 = math.random(20, 25) * v2
					local v8 = math.random(2, 3) * 0.1 * v3
					local time = v8 - v8 / 6
					local time2 = v8 / 6
					local vector = Vector3.new(v7, v7, v7)
					BoatTween:Create(v6, {
						Time = time,
						EasingStyle = "Linear",
						Goal = {
							Size = vector * 5 / 6,
							Transparency = 1
						}
					}):Play()
					task.wait(time)

					if v6.Parent then
						local highlight = v6:FindFirstChildWhichIsA("Highlight")

						if highlight then
							highlight:Destroy()
						end

						v6.Transparency = 0.95
						BoatTween:Create(v6, {
							Time = time2,
							EasingStyle = "Linear",
							Goal = {
								Size = vector,
								Transparency = 1
							}
						}):Play()
					end
				end)
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bubble()
		task.spawn(function()
			local clone = script.Spheres:Clone()
			clone.Parent = parent
			clone.PrimaryPart.CFrame = CFrame.new(position)
			clone:ScaleTo(0.01)
			local v6 = {}
			local keyframePreviewPlayers = {}

			for _, model in ipairs(clone:GetDescendants()) do
				if not model:IsA("Model") or v6[model] or not model:FindFirstChildWhichIsA("Bone", true) then
					continue
				end

				v6[model] = true
				local keyframePreviewPlayer = createKeyframePreviewPlayer(model, SphereAnimData, v2, animscaler)
				keyframePreviewPlayer:Play(true, 2 / v3)
				table.insert(keyframePreviewPlayers, keyframePreviewPlayer)
			end

			local v7 = 1 * v3
			local v8 = 0.3 * v3
			local v9 = 0.3 * v3
			local v10 = v7 - v8 - v9
			local v11 = 2 * v2
			local v12 = v11 * 2
			local scaleDriver = createScaleDriver(v4, clone)
			local lastTime = tick()
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v13 = math.clamp((tick() - lastTime) / v8, 0, 1)
				local v14

				if v13 < 0.36363636363636365 then
					v14 = 7.5625 * v13 * v13
				elseif v13 < 0.7272727272727273 then
					local v15 = v13 - 0.5454545454545454
					v14 = 7.5625 * v15 * v15 + 0.75
				elseif v13 < 0.9090909090909091 then
					local v15 = v13 - 0.8181818181818182
					v14 = 7.5625 * v15 * v15 + 0.9375
				else
					local v15 = v13 - 0.9545454545454546
					v14 = 7.5625 * v15 * v15 + 0.984375
				end

				local v15 = 0.01 + (v11 - 0.01) * v14
				scaleDriver.Value = v15

				for _, v16 in ipairs(keyframePreviewPlayers) do
					v16:SetAnimScale(v15)
				end

				if v13 >= 1 then
					heartbeatConnection:Disconnect()
				end
			end)
			v4:giveTask(heartbeatConnection)
			task.wait(v8)
			scaleDriver.Value = v11

			for _, v13 in ipairs(keyframePreviewPlayers) do
				v13:SetAnimScale(v11)
			end

			task.wait(v10)
			local lastTime2 = tick()
			local heartbeatConnection2 = nil
			heartbeatConnection2 = RunService.Heartbeat:Connect(function()
				local v13 = math.clamp((tick() - lastTime2) / v9, 0, 1)
				local v14 = 1 - v13
				local v15

				if v14 < 0.36363636363636365 then
					v15 = 7.5625 * v14 * v14
				elseif v14 < 0.7272727272727273 then
					local v16 = v14 - 0.5454545454545454
					v15 = 7.5625 * v16 * v16 + 0.75
				elseif v14 < 0.9090909090909091 then
					local v16 = v14 - 0.8181818181818182
					v15 = 7.5625 * v16 * v16 + 0.9375
				else
					local v16 = v14 - 0.9545454545454546
					v15 = 7.5625 * v16 * v16 + 0.984375
				end

				local v16 = 1 - v15
				local v17 = v11 + (v12 - v11) * v16
				scaleDriver.Value = v17

				for _, v18 in ipairs(keyframePreviewPlayers) do
					v18:SetAnimScale(v17)
				end

				if v13 >= 1 then
					heartbeatConnection2:Disconnect()
					disableParticles(clone)

					for _, v18 in ipairs(keyframePreviewPlayers) do
						v18:Stop(true)
					end

					clone:Destroy()
				end
			end)
			v4:giveTask(heartbeatConnection2)
			task.wait(v9)
		end)
	end

	task.spawn(function()
		local folder = v4:give(script.Explosion:Clone())
		folder.Parent = parent
		folder.PrimaryPart.Position = position
		folder:ScaleTo(v2)

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Lifetime = NumberRange.new(descendant.Lifetime.Min * v3, descendant.Lifetime.Max * v3)
			elseif descendant:IsA("PointLight") then
				descendant.Range *= v2
			end
		end

		local folder2 = v4:give(script.Root:Clone())
		folder2.PrimaryPart.Position = position
		folder2:ScaleTo(v2)

		for _, emitter in ipairs(folder2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * v3, emitter.Lifetime.Max * v3)
			end
		end

		burst("Sphere2", 1, nil) -- equivalent call inferred; original call site unknown
		burst("Sphere", 3, nil) -- equivalent call inferred; original call site unknown
		task.delay(1 * v3, function()
			disableParticles(folder2)
		end)
		burst("Sphere2", 10, 0.05) -- equivalent call inferred; original call site unknown
		burst("Sphere", 5, 0.05) -- equivalent call inferred; original call site unknown
		distortionBurst(15, 0.05) -- equivalent call inferred; original call site unknown
		task.spawn(function()
			bubble() -- equivalent call inferred; original call site unknown
			task.wait(1 * v3)

			local function resetLifetimes(folder3)
				for _, emitter in ipairs(folder3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min / v3, emitter.Lifetime.Max / v3)
					end
				end
			end

			resetLifetimes(folder2)
			resetLifetimes(folder)

			while p2.Parent do
				wait()
			end

			burst("Sphere2", 2, nil) -- equivalent call inferred; original call site unknown
			burst("Sphere", 5, nil) -- equivalent call inferred; original call site unknown
		end)
		task.wait(10 * v3)
		v4:doCleaning()
	end)
	return parent
end

setmetatable(Effectv2b2, {
	__index = function(_, p)
		error(("%q is not a valid member of %q"):format(tostring(p), script.Name), 2)
	end
})
return Effectv2b2