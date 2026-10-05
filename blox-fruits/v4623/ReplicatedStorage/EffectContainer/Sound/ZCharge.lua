local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt

local function putFolder(parent, name: string)
	local v = parent:FindFirstChild(name)

	if v == nil then
		v = Instance.new("Folder")
		v.Name = name
		v.Parent = parent
	end

	return v
end

local rescheduleDestruction

rescheduleDestruction = function(instance, duration: number, flag: boolean?)
	if (flag == nil or flag) == true or instance:GetAttribute("PrevTimeDestructInitiated") == nil then
		instance:SetAttribute("PrevTimeDestructInitiated", time())
	end

	local destructionDepth = instance:GetAttribute("DestructionDepth") or 0
	instance:SetAttribute("DestructionDepth", destructionDepth + 1)

	if destructionDepth >= 100 then
		instance:Destroy()
		warn("rescheduleDestruction: Maximum re-entrancy depth of 100 exceeded")
	else
		task.delay(duration, function()
			local prevTimeDestructInitiated = instance:GetAttribute("PrevTimeDestructInitiated")

			if duration - (time() - prevTimeDestructInitiated) < 0.2 and instance ~= nil and instance.Parent ~= nil then
				instance:Destroy()
				return
			end

			if instance == nil or instance.Parent == nil then
				return
			end

			rescheduleDestruction(instance, duration, false)
		end)
	end
end

local function putValueAsValueObject(parent, name: string, folder, value: number)
	local v2 = {
		boolean = "BoolValue",
		CFrame = "CFrameValue",
		Color3 = "Color3Value",
		number = "NumberValue",
		Instance = "ObjectValue",
		Ray = "RayValue",
		string = "StringValue",
		Vector3 = "Vector3Value"
	}
	local instance = parent:FindFirstChild(name)

	if instance == nil then
		instance = Instance.new(v2[typeof(folder)])
		instance.Name = name
		instance.Parent = parent
	end

	instance.Value = folder
	rescheduleDestruction(instance, value or 60)
	return instance
end

local function getValueObject(instance, childName)
	return instance:FindFirstChild(childName)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

-- equivalent calls inferred from this helper; original call sites unknown
local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function fireClientProjectile(p, p2, instance, callback, part, p3)
	local fn = p3 == nil and function(_)
		return CFrame.new()
	end or p3

	if part == nil then
		part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(p2, p2, p2) * 2
		part.Transparency = 1
		part.Name = "Projectile"
		part.Parent = _WorldOrigin
		destroyAfter(part, p + 7)
	end

	part.CFrame = CFrame.lookAt(callback(0.001), callback(0.002)) * fn(0.001)
	local bindableEvent = Instance.new("BindableEvent")
	destroyAfter(bindableEvent, 7)
	local v = false
	local connection = nil
	connection = heartbeatLoopFor2(p, function(_, _, p4)
		if instance:GetAttribute("ProjectileActive") == true or instance:GetAttribute("ImpactPos") == nil or not (instance:GetAttribute("DisabledInterp") < 0.9999) then
			part.CFrame = CFrame.lookAt(callback(p4), callback(p4 + 0.01)) * fn(p4)
			return
		end

		connection:Disconnect()
		connection = nil
		snapProjectileToFinalPos(part, instance:GetAttribute("ImpactPos")) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(instance:GetAttribute("ImpactPos"), "Impact")
		v = true
	end, function()
		if v == true then
			return
		end

		snapProjectileToFinalPos(part, callback(1)) -- equivalent call inferred; original call site unknown
		bindableEvent:Fire(callback(1), "NonImpact")
	end)
	return bindableEvent, part, connection
end

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 300) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local function TimeScaleParticle(instance, p)
	instance.Drag *= p
	instance.Speed = NumberRange.new(instance.Speed.Min * p, instance.Speed.Max * p)
	instance.Lifetime = NumberRange.new(instance.Lifetime.Min / p, instance.Lifetime.Max / p)
	instance.Rate *= p
	instance.RotSpeed = NumberRange.new(instance.RotSpeed.Min * p, instance.RotSpeed.Max * p)
	instance.Acceleration *= p ^ 2

	if instance:GetAttribute("EmitDelay") then
		instance:SetAttribute("EmitDelay", instance:GetAttribute("EmitDelay") / p)
	end
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local parent = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame
	local v = parent:FindFirstChild("ItemsTableFolder")

	if v == nil then
		v = Instance.new("Folder")
		v.Name = "ItemsTableFolder"
		v.Parent = parent
	end

	local _ = data.origin
	local _ = data.fireDir
	local znoTempo = FX:WaitForChild("SoundEffects").ZnoTempo

	if data.maxTempoActive == true then
		znoTempo = FX:WaitForChild("SoundEffects").ZmaxTempo
	end

	local _ = data.targetPos
	local cframe = CFrame.new(hrp.Position)

	if data.skillHeld == true then
		if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 300 and data.skillHeld == true then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "MusicZChargeFolder"
		folder.Parent = _WorldOrigin
		destroyAfter(folder, 30)
		local _ = znoTempo.projectiles
		local _ = znoTempo.explosion
		local clone = znoTempo.RootAura:Clone()
		local clone2 = znoTempo.MaxAura:Clone()
		clone.CFrame = cframe
		clone.Name = "Aura"
		clone.Parent = folder
		destroyAfter(clone, 30)
		clone2.CFrame = cframe
		clone2.Name = "maxaura"
		clone2.Parent = folder
		destroyAfter(clone2, 30)
		local clone3 = znoTempo.Tornado2:Clone()
		clone3.CFrame = cframe * CFrame.new(0, -3, 0)
		clone3.Parent = folder
		destroyAfter(clone3, 30)
		local descendantsByDescendant = {}
		local weldsByWeld = {}

		for _, weld in pairs(clone3:GetChildren()) do
			local v2 = (weld:IsA("Weld") or weld.Name ~= "SpinA") and 1 or 0.5

			if weld:IsA("Weld") and weld.Name ~= "Weld" then
				weldsByWeld[weld] = weld
				weld.C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * CFrame.Angles(
					0,
					math.rad((math.random(-90, 90))),
					0
				)
			end

			weld:SetAttribute("Tweening", false)

			for _, descendant in pairs(weld:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendantsByDescendant[descendant] = descendant
					descendant.CurveSize0 *= v2
					descendant.CurveSize1 *= v2
					descendant.Width0 *= v2
					descendant.Width1 *= v2
				elseif descendant:IsA("Attachment") then
					descendantsByDescendant[descendant] = descendant
					descendant.Position = Vector3.new(
						descendant.Position.X * v2,
						descendant.Position.Y * v2,
						descendant.Position.Z * v2
					)
				end
			end
		end

		local v2

		if data.maxTempoActive == true then
		end

		v2 = Util.Sound:Play("SoundFruit.Basw.SoundFruitCharge", clone2)
		local lastTime = nil
		local v3 = false
		local connection = nil
		connection = heartbeatLoopFor2(30, function(_, _, _)
			if clone2 and clone2.Parent and clone2:IsDescendantOf(Workspace) then
				for _, v4 in pairs(weldsByWeld) do
					if v4:GetAttribute("Tweening") ~= false then
						continue
					end

					local v5 = v4
					task.spawn(function()
						v5:SetAttribute("Tweening", true)
						local v6 = math.random(100, 150)
						local v7 = math.random(5, 15) / 200
						local tween = TweenService:Create(
							v5,
							TweenInfo.new(v7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								C0 = v5.Part0.CFrame:ToObjectSpace(v5.Part1.CFrame) * CFrame.Angles(0, math.rad(v6), 0)
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v5:SetAttribute("Tweening", false)
					end)
				end

				if lastTime == nil or tick() - lastTime >= 0.35 then
					lastTime = tick()

					if v3 == true then
						v3 = false
						TweenService:Create(
							clone3,
							TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = cframe * CFrame.new(0, -3, 0)
							}
						):Play()
					elseif v3 == false then
						v3 = true
						TweenService:Create(
							clone3,
							TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = cframe * CFrame.new(0, 3, 0)
							}
						):Play()
					end

					for _, instance in pairs(descendantsByDescendant) do
						if instance:IsA("Beam") then
							TweenService:Create(
								instance,
								TweenInfo.new(0.175, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
								{
									CurveSize0 = instance.CurveSize0 * 2,
									CurveSize1 = instance.CurveSize1 * 2,
									Width0 = instance.Width0 * 2,
									Width1 = instance.Width1 * 2
								}
							):Play()
						elseif instance:IsA("Attachment") then
							TweenService:Create(
								instance,
								TweenInfo.new(0.175, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
								{
									Position = Vector3.new(
										instance.Position.X * 2,
										instance.Position.Y * 2,
										instance.Position.Z * 2
									)
								}
							):Play()
						end
					end
				end
			else
				if v2 then
					Util.Sound:FadeOut(v2, 0.1)
					v2 = nil
				end

				connection:Disconnect()
				connection = nil
			end
		end)
		task.delay(30, function()
			if v2 then
				Util.Sound:FadeOut(v2, 0.1)
				v2 = nil
			end
		end)
		putValueAsValueObject(v, string.format("musicZCharge%s", data.EffectID or ""), folder, 30)
	elseif data.skillHeld == false then
		local child = v:FindFirstChild((string.format("musicZCharge%s", data.EffectID or "")))

		if child and child.Value then
			local value = child.Value
			local starter = value:FindFirstChild("starter")

			if starter then
				destroyAfter(starter, 0.1)
			end

			local aura = value:FindFirstChild("Aura")

			if aura then
				local v2 = 0

				for _, emitter in aura:GetDescendants(), nil, nil do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					v2 = math.max(v2, emitter.Lifetime.Max)
					emitter.Enabled = false
				end

				destroyAfter(aura, v2)
			end

			local maxaura = value:FindFirstChild("maxaura")

			if maxaura then
				local v2 = 0

				for _, emitter in maxaura:GetDescendants(), nil, nil do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					v2 = math.max(v2, emitter.Lifetime.Max)
					emitter.Enabled = false
				end

				destroyAfter(maxaura, v2)
			end

			local tornado2 = value:FindFirstChild("Tornado2")

			if tornado2 then
				destroyAfter(tornado2, 0)
			end

			destroyAfter(value, 4)
		end
	end
end