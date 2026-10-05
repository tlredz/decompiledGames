local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
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

local function putValueAsValueObject(instance, name: string, p, value: number, p2)
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
	local instance2 = instance:FindFirstChild(name)

	if instance2 == nil then
		instance2 = Instance.new(v2[typeof(p)])
		instance2.Name = name
		Util.SetParentOverrideWithColor(instance2, instance, p2, "KitsuneFruitVFXColor")
	end

	instance2.Value = p
	rescheduleDestruction(instance2, value or 60)
	return instance2
end

local function getValueOfValueObject(instance, childName: string)
	local child = instance:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	return child.Value
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { Workspace._WorldOrigin, Workspace.Characters, Workspace.Enemies }

local function snapProjectileToFinalPos(p, p2)
	p.CFrame = p.CFrame.Rotation + p2
end

local function shouldStopProjectile(instance)
	return instance:GetAttribute("ProjectileActive") ~= true and instance:GetAttribute("ImpactPos") ~= nil and instance:GetAttribute("DisabledInterp") < 0.9999
end

local function cameraShakeAt(vector2: Vector3, value: number, value2: number, value3: number, value4: number, value5: number)
	local v = value2 or 8
	local v2 = value3 or 14
	local v3 = value4 or 0.2
	local v4 = value5 or 0.7

	if (value or 100) > (Workspace.CurrentCamera.CFrame.Position - vector2).Magnitude then
		Util.CameraShaker:ShakeOnce(v, v2, v3, v4)
	end
end

local function haltUntilCondition(callback, value: number?)
	local v = value or 14
	local bindableEvent = Instance.new("BindableEvent")
	task.delay(v, bindableEvent.Fire, bindableEvent)
	local connection = nil
	connection = heartbeatLoopFor2(v, function()
		local success, result = pcall(callback)

		if success and result then
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		elseif not success then
			print("haltUntilCondition: Error in predicate function: ", result)
			bindableEvent:Fire()
			connection:Disconnect()
			connection = nil
		end
	end)
	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
end

local function alignCFrameWithPlane(rotation: CFrame, vector2: Vector3)
	local v = { rotation.RightVector, rotation.UpVector, rotation.LookVector }
	local v2 = -1e999
	local vector3 = nil

	for _, vector4 in ipairs(v) do
		local dot = vector4:Dot(vector2)

		if not (v2 < math.abs(dot)) then
			continue
		end

		v2 = math.abs(dot)
		vector3 = math.sign(dot) * vector4
	end

	local cross = vector3:Cross(vector2)
	local v3 = math.acos((math.clamp(v2, -1, 1)))

	if cross.Magnitude < 0.0001 then
		return rotation.Rotation
	end

	return CFrame.fromAxisAngle(cross, v3) * rotation.Rotation
end

local function snapPointToPlane(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local unit = vector3.Unit
	local X = unit.X
	local Y = unit.Y
	local Z = unit.Z
	local X2 = vector2.X
	local Z2 = vector2.Z
	local dot = vector4:Dot(unit)
	local v

	if math.abs(Y) < 0.1 then
		v = vector2.Y
	else
		v = (dot - X2 * X - Z2 * Z) / Y
	end

	return (Vector3.new(X2, v, Z2))
end

local function alignWithGround(folder, raycastResult: RaycastResult)
	local v = not raycastResult and createVector(0, 1, 0) or raycastResult.Normal

	if typeof(folder) == "CFrame" then
		local position = folder.Position
		local rotation = folder.Rotation
		local position2

		if raycastResult then
			position2 = raycastResult.Position
		else
			position2 = position
		end

		local unit = v.Unit
		local X = unit.X
		local Y = unit.Y
		local Z = unit.Z
		local X2 = position.X
		local Z2 = position.Z
		local dot = position2:Dot(unit)
		local v2

		if math.abs(Y) < 0.1 then
			v2 = position.Y
		else
			v2 = (dot - X2 * X - Z2 * Z) / Y
		end

		local vector2 = Vector3.new(X2, v2, Z2)
		local v3 = vector2 + v * (position.Y - vector2.Y)
		return alignCFrameWithPlane(rotation, v) + v3
	else
		if typeof(folder) == "Instance" and folder:IsA("BasePart") then
			local position = folder.CFrame.Position
			local rotation = folder.CFrame.Rotation
			local position2

			if raycastResult then
				position2 = raycastResult.Position
			else
				position2 = position
			end

			local unit = v.Unit
			local X = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X2 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v2

			if math.abs(Y) < 0.1 then
				v2 = position.Y
			else
				v2 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v2, Z2)
			local v3 = vector2 + v * (position.Y - vector2.Y)
			folder.CFrame = alignCFrameWithPlane(rotation, v) + v3
		else
			if typeof(folder) ~= "Instance" or not folder:IsA("Model") then
				warn("alignWithGround: Failed to align with ground for object of type " .. typeof(folder))
				return
			end

			local pivot = folder:GetPivot()
			local position = pivot.Position
			local rotation = pivot.Rotation
			local position2

			if raycastResult then
				position2 = raycastResult.Position
			else
				position2 = position
			end

			local unit = v.Unit
			local X = unit.X
			local Y = unit.Y
			local Z = unit.Z
			local X2 = position.X
			local Z2 = position.Z
			local dot = position2:Dot(unit)
			local v2

			if math.abs(Y) < 0.1 then
				v2 = position.Y
			else
				v2 = (dot - X2 * X - Z2 * Z) / Y
			end

			local vector2 = Vector3.new(X2, v2, Z2)
			local v3 = vector2 + v * (position.Y - vector2.Y)
			folder:PivotTo(alignCFrameWithPlane(rotation, v) + v3)
		end

		for _, emitter in ipairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.LockedToPart = true
			end
		end
	end
end

local function playAnimationOnPlayer(p, p2, p3: string)
	if localPlayer ~= p2 then
		return nil
	end

	local v = Util.Anims:Get(p, p3)
	v:Play()
	return v
end

local _WorldOrigin = Workspace._WorldOrigin
local lampSkill2 = FX:WaitForChild("DogHouse").RedZCharge.LampSkill2
return function(data)
	local player = data.player
	local holding = data.holding
	local hrp = data.hrp
	local v = 2 / (data.maxChargeTime or 1)

	if (hrp.Position - Workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
		return
	end

	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "KitsuneFruitVFXColor")
	Util.Debris:AddItem(folder, 30)
	local cFrame = hrp.CFrame
	Util.Sound:Play("KitsuneMutation_Beam_TapActivate_06", hrp)
	local boolValue = Instance.new("BoolValue")
	boolValue.Value = true
	task.spawn(function()
		while holding and holding:IsDescendantOf(Workspace) and holding.Value do
			task.wait()
		end

		boolValue.Value = false
	end)
	local clone = lampSkill2.Phase1.OrbMain:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "KitsuneFruitVFXColor")
	local weld = clone.Weld
	weld.Part0 = hrp
	local v2 = true
	local orbFolder = lampSkill2.Phase1.OrbFolder
	local count = #orbFolder:GetChildren()
	local _ = clone.CFrame
	local total = -40
	local cframe = CFrame.new(0, 10, 0)
	local cframe2 = CFrame.new(0, 5, 0)
	local v3 = false
	task.spawn(function()
		for _ = 1, 9 do
			local clone2 = orbFolder["Orb" .. math.random(1, count)]:Clone()
			clone2.CFrame = clone.CFrame
			Util.SetParentOverrideWithColor(clone2, clone, player, "KitsuneFruitVFXColor")

			for _, effect in pairs(clone2:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
					continue
				end

				if effect:GetAttribute("EMIT") then
					effect:Emit(effect:GetAttribute("EmitCount"))
				else
					local v5 = effect
					task.spawn(function()
						task.wait(0.1)
						v5.Enabled = true
					end)
				end
			end

			local v5 = CFrame.Angles(0, 0, (math.rad(total))) * cframe
			local weld2 = clone2.Weld
			weld2.Part0 = clone
			weld2.C0 = weld2.Part0.CFrame:ToObjectSpace(weld2.Part1.CFrame) * v5
			total += 40

			if not v3 then
				local lastTime = os.clock()

				while os.clock() - lastTime < 0.05 / v and not v3 do
					task.wait()
				end
			end

			local folder2 = clone2
			task.spawn(function()
				while not v3 do
					task.wait()
				end

				for i, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			local weld2 = part.Weld
			local clone2 = lampSkill2.Phase1.Orb:Clone()
			clone2.CFrame = part.CFrame
			Util.SetParentOverrideWithColor(clone2, clone, player, "KitsuneFruitVFXColor")
			clone2.Weld.Part0 = part.Weld.Part0
			local C0 = weld2.C0 * cframe2
			clone2.Weld.C0 = weld2.C0

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = true
				end
			end

			part:Destroy()
			TweenService:Create(clone2.Weld, TweenInfo.new(0.1 / v), {
				C0 = C0
			}):Play()

			if not v3 then
				local lastTime = os.clock()

				while os.clock() - lastTime < 0.15 / v and not v3 do
					task.wait()
				end
			end

			local folder2 = clone2
			task.spawn(function()
				while not v3 do
					task.wait()
				end

				for i, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end)
		end

		v2 = false
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 5
	Util.SetParentOverrideWithColor(numberValue, folder, player, "KitsuneFruitVFXColor")
	TweenService:Create(numberValue, TweenInfo.new(1 / v), {
		Value = 50
	}):Play()
	local v4 = Util.Sound:Play("KitsuneMutation_Beam_HoldCharge_01", hrp)
	TweenService:Create(v4, TweenInfo.new(0.2), {
		Volume = 1
	}):Play()

	while true do
		local tween = TweenService:Create(
			weld,
			TweenInfo.new(0.1 / v, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				C0 = weld.Part0.CFrame:ToObjectSpace(weld.Part1.CFrame) * CFrame.Angles(
					0,
					0,
					(math.rad(numberValue.Value))
				)
			}
		)
		tween:Play()
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.1 / v do
			if boolValue.Value == false then
				tween:Pause()
				break
			else
				task.wait()
			end
		end

		if boolValue.Value ~= false then
			continue
		end

		if v4 then
			Util.Sound:FadeOut(v4, 0.1)
		end

		v3 = true
		Util.Debris:AddItem(folder, 7)
		break
	end
end