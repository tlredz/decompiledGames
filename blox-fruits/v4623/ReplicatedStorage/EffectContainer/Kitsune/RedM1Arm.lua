local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local redM1Arm = FX:WaitForChild("Kitsune").RedM1Arm
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
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
	local v = value or 10
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

local BeamSpline = require(script:WaitForChild("BeamSpline"))

local function createBeamTemplate(flag: boolean, data)
	local clone

	if flag then
		clone = redM1Arm.BeamTemplateTransformed:Clone()
	else
		clone = redM1Arm.BeamTemplate:Clone()
	end

	if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
		clone.Texture = "rbxassetid://89717981979992"
		clone.Color = ColorSequence.new(Color3.fromRGB(132, 121, 255))
	end

	return clone
end

local function createBeamRig(p: number, _WorldOrigin, beamTemplate)
	local clones = table.create(p)
	local hosts = table.create(p)

	for i = 1, p do
		local part = Instance.new("Part")
		part.Name = ("BeamSplineHost_%02d"):format(i)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.Size = createVector(0.2, 0.2, 0.2)
		part.CFrame = CFrame.new(0, -1000000, 0)
		part.Parent = _WorldOrigin
		local attachment = Instance.new("Attachment")
		attachment.Name = "A0"
		attachment.Parent = part
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "A1"
		attachment2.Parent = part
		local clone = beamTemplate:Clone()
		clone.Name = ("BeamSpline_%02d"):format(i)
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		clone.Parent = _WorldOrigin
		clones[i] = clone
		hosts[i] = part
	end

	return {
		beams = clones,
		hosts = hosts
	}
end

local function destroyBeamRig(beamRig)
	for _, beam in ipairs(beamRig.beams) do
		if beam then
			beam:Destroy()
		end
	end

	for _, host in ipairs(beamRig.hosts) do
		if host then
			host:Destroy()
		end
	end
end

return function(data)
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local clone = redM1Arm.LinesSparks:Clone()
	clone.Parent = hrp
	clone:Emit(clone:GetAttribute("EmitCount"))

	if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
		clone.Color = ColorSequence.new(Color3.fromRGB(73, 11, 161))
	end

	destroyAfter(clone, 2)
	Util.Sound:Play("KitsuneMutation_M1_Tailspin_0" .. tostring(math.random(1, 3)), hrp)
	local arm = redM1Arm:WaitForChild("Arm")

	if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
		if data.Tool.IsTransformed.Value == true then
			arm = redM1Arm:WaitForChild("ArmGalaxyTransformed")
		else
			arm = redM1Arm:WaitForChild("ArmGalaxyUntransformed")
		end
	end

	local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
	local kitsune = hrp.Parent:FindFirstChild("Kitsune")
	local v = kitsune and kitsune:FindFirstChild("Kitsune") and true or false
	local beamTemplate = createBeamTemplate(v, data)

	local function getNewArm()
		local clone2 = arm:Clone()
		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Enabled = true
		local fillColor

		if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
			fillColor = Color3.fromRGB(93, 0, 255)
		else
			fillColor = Color3.fromRGB(255, 102, 102)
		end

		highlight.FillColor = fillColor
		local outlineColor

		if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
			outlineColor = Color3.fromRGB(120, 115, 255)
		else
			outlineColor = Color3.fromRGB(255, 0, 0)
		end

		highlight.OutlineColor = outlineColor
		highlight.OutlineTransparency = 0
		highlight.FillTransparency = v and 1 or 0

		if data.Tool and data.Tool:FindFirstChild("IsGalaxy") and data.Tool:FindFirstChild("IsGalaxy").Value == true then
			highlight.FillTransparency = 1
		end

		highlight.Parent = clone2
		clone2.Parent = _WorldOrigin
		local bone = clone2:WaitForChild("RootPart").Bone
		local bones = {}

		for i = 1, 7 do
			bone = bone["Bone.00" .. tostring(i)]
			table.insert(bones, bone)
		end

		local beamRig = createBeamRig(1, _WorldOrigin, beamTemplate)
		return {
			armModel = clone2,
			orderedBones = bones,
			rootBone = clone2:WaitForChild("RootPart").Bone,
			beamRig = beamRig
		}
	end

	local function setArmBonePositions(p, fn)
		local inverse = CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
		local inverse2 = CFrame.lookAt(createVector(0, 0, 0), createVector(-0, -1, -0)):Inverse()
		local cframe = CFrame.Angles(-0.3490658503988659, 0, 0)
		local count = #p.orderedBones

		for i = 1, count do
			local v2 = fn(i)
			local v3

			if i == count then
				v3 = fn(count) + (fn(count) - fn(count - 1))
			else
				v3 = fn(i + 1)
			end

			if i == 1 then
				p.rootBone.WorldCFrame = CFrame.lookAt(v2, v3) * inverse2 * cframe
			end

			p.orderedBones[i].WorldCFrame = CFrame.lookAt(v2, v3) * inverse
		end
	end

	local function getSpaceCurveLength(callback, value: number?)
		local v2 = value or 50
		local v3 = callback(0)
		local total = 0

		for i = 1, v2 do
			local v4 = callback(i / v2)
			total += (v4 - v3).Magnitude
			v3 = v4
		end

		return total
	end

	local function getTAtArcLength(callback, p: number, value: number?)
		local v2 = value or 80

		if p <= 0 then
			return 0
		end

		local v3 = callback(0)
		local total = 0

		for i = 1, v2 do
			local v4 = i / v2
			local v5 = callback(v4)
			local magnitude = (v5 - v3).Magnitude

			if p <= total + magnitude then
				local v6 = (p - total) / math.max(magnitude, 1e-8)
				local v7 = (i - 1) / v2
				return math.map(v6, 0, 1, v7, v4)
			else
				total += magnitude
				v3 = v5
			end
		end

		return 1
	end

	local function applySpaceCurveToArm(p, fn)
		local count = #p.orderedBones
		local spaceCurveLength = getSpaceCurveLength(fn)
		local v2 = math.clamp(5, 0, spaceCurveLength * 0.499)
		local tAtArcLength = getTAtArcLength(fn, v2)
		local tAtArcLength2 = getTAtArcLength(fn, spaceCurveLength - v2)
		return setArmBonePositions(p, function(p2: number)
			local v3 = 1 - (p2 - 1) / (count - 1)
			return fn((math.map(v3, 0, 1, tAtArcLength, tAtArcLength2)))
		end)
	end

	local function playArmAnimation(newArm, childName: string, items)
		local track = newArm.armModel:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(redM1Arm:WaitForChild(childName))

		if items then
			for k, item in pairs(items) do
				track[k] = item
			end
		end

		track:Play(0)
		return track
	end

	local function getArmAnimationLength(p, childName: string)
		return p.armModel:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(redM1Arm:WaitForChild(childName)).Length
	end

	-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
	local function cubicHermite(p, p2, p3, p4, p5)
		return (2 * p ^ 3 - 3 * p ^ 2 + 1) * p2 + (p ^ 3 - 2 * p ^ 2 + p) * p3 + (-2 * p ^ 3 + 3 * p ^ 2) * p4 + (p ^ 3 - p ^ 2) * p5
	end

	local function slerp(unit: Vector3, unit2: Vector3, p: number)
		local unit3 = unit.Unit
		local unit4 = unit2.Unit
		local dot = unit3:Dot(unit4)

		if dot > 0.9995 then
			return (unit3 + p * (unit4 - unit3)).Unit
		end

		local v2 = math.clamp(dot, -1, 1)
		local v3 = math.acos(v2) * p
		local v4 = math.sin(v3)
		local unit5 = (unit4 - unit3 * v2).Unit

		if v2 < -0.9995 then
			unit5 = CFrame.lookAlong(createVector(0, 0, 0), unit3).RightVector
		end

		return (unit3 * math.cos(v3) + unit5 * v4).Unit
	end

	local armMaxExtendRadius = data.armMaxExtendRadius
	local armExtendTime = data.armExtendTime
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local position = hrp.Position
	local victimHrpsBindableOrTable

	if typeof(data.victimHrpsBindableOrTable) == "table" then
		victimHrpsBindableOrTable = data.victimHrpsBindableOrTable
	else
		victimHrpsBindableOrTable = data.victimHrpsBindableOrTable:Invoke()
	end

	local count = 0

	for _, v5 in ipairs(victimHrpsBindableOrTable) do
		local root = v5.root
		local _ = v5.inRange

		if root == nil then
			return
		end

		if (root.Position - position).Magnitude <= armMaxExtendRadius + 10 then
			count += 1
		end
	end

	local v5 = math.max(count, 3)
	local v6 = {}
	local positions = {}

	for i = 1, v5 do
		local newArm = getNewArm()
		table.insert(v2, newArm)
		local position2 = CFrame.Angles(0, 6.283185307179586 * (i / v5), 0) * createVector(1, 0, 0) * armMaxExtendRadius + position
		local v7 = nil

		for _, v9 in ipairs(victimHrpsBindableOrTable) do
			local root = v9.root
			local _ = v9.inRange

			if root == nil then
				return
			end

			if v6[root] or not ((root.Position - position).Magnitude <= armMaxExtendRadius + 10) then
				continue
			end

			position2 = root.Position
			v6[root] = true
			table.insert(positions, root.Position)
			v7 = v9
			break
		end

		if v7 == nil then
			if count == 1 then
				local v9 = positions[1]

				if v9 and i > 1 then
					position2 = CFrame.Angles(0, (i - 1) * 2 * 3.141592653589793 / 3, 0) * (v9 - position) + position
				end
			elseif count == 2 then
				local v9 = positions[1]
				local v10 = positions[2]

				if v9 and v10 then
					local unit2 = (slerp((v9 - position).Unit, (v10 - position).Unit, 0.5).Unit * createVector(
						1,
						0.01,
						1
					)).Unit

					if unit2 == unit2 and i == 3 then
						position2 = position - unit2 * armMaxExtendRadius
					end
				end
			end
		end

		table.insert(v3, position2)
		local magnitude = (position2 - position).Magnitude

		if v7 then
			playArmAnimation(newArm, "Grab", {
				Looped = true,
				Priority = Enum.AnimationPriority.Action
			})
		else
			playArmAnimation(newArm, "Reach", {
				Looped = true,
				Priority = Enum.AnimationPriority.Idle
			})
		end

		table.insert(v4, function(p: number)
			return position:Lerp(position2, p)
		end)
		task.spawn(function()
			local v11 = armExtendTime * 2
			local v12 = time()
			local steppedConnection = nil
			local RunService = game:GetService("RunService")
			steppedConnection = RunService.Stepped:Connect(function()
				if hrp then
					position = hrp.Position
				end

				local v13 = time() - v12

				if v11 <= v13 then
					steppedConnection:Disconnect()
					return
				end

				local v14 = v13 / armExtendTime
				local v15 = position2 - position
				local v16 = CFrame.Angles(0, 5.026548245743669 * (1 - v14), 0) * v15 + position

				local function fn(p: number)
					local v17 = math.clamp(v14, 0.1, 1)
					local v18 = math.map(p, 0, 1, 0, v17)
					local v19 = position
					local v20 = v16
					local v21 = CFrame.Angles(0, -1.5707963267948966, 0) * (v20 - v19).Unit * 120 * math.clamp(
						math.map(magnitude, 60, 105, 1, 2),
						0.5,
						2
					)
					local v22 = CFrame.Angles(0, 1.5707963267948966, 0) * (v20 - v19).Unit * 120 * math.clamp(
						math.map(magnitude, 60, 105, 1, 2),
						0.5,
						2
					)

					if v14 > 1 then
						local v23 = math.clamp(1 - math.map(v14, 1, 2, 0, 1), 0.2, 1)
						v20 = v19 + (v20 - v19) * v23
						v21 *= v23
						v22 *= v23
					end

					return cubicHermite(v18, v19, v21, v20, v22)
				end

				applySpaceCurveToArm(newArm, fn)

				if newArm.beamRig then
					BeamSpline.drawSpaceCurveWithBeamArray(fn, newArm.beamRig.beams, 20)
				end

				if v14 >= 1 and v7 ~= nil then
					local v17

					if typeof(data.victimHrpsBindableOrTable) == "table" then
						v17 = data.victimHrpsBindableOrTable
					else
						v17 = data.victimHrpsBindableOrTable:Invoke()
					end

					victimHrpsBindableOrTable = v17

					for i2, v18 in ipairs(victimHrpsBindableOrTable) do
						local root = v18.root
						local inRange = v18.inRange

						if root == nil then
							return
						end

						if v7.root ~= root then
							continue
						end

						v7 = v18
						break
					end

					local root = v7.root
					local inRange = v7.inRange

					if not (root ~= nil and v6[root] == true) then
						return
					end

					if inRange == true and root.Anchored == false and newArm.rootBone:FindFirstChild("Mid") then
						root.CFrame = root.CFrame.Rotation + newArm.rootBone.Mid.WorldPosition
					end

					if inRange ~= true then
						v6[root] = nil
					end
				end
			end)
			task.wait(v11 - 0.05)
			newArm.armModel:Destroy()

			if newArm.beamRig then
				destroyBeamRig(newArm.beamRig)
				newArm.beamRig = nil
			end
		end)
	end
end