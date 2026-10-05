local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fDashParticles = FX:WaitForChild("TigerEffects").FDashParticles
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function ScaleAttachmentsAndEmittersWithin(folder, p: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= p
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, p)
		end
	end
end

local function insertSoundInto(p, p2)
	local clone = fDashParticles[p2]:Clone()
	return (Util.UtilSoundWrapper.Play(clone, p))
end

local v = {
	RightFoot = 0,
	RightLowerLeg = 1,
	RightUpperLeg = 1,
	LeftFoot = 0,
	LeftLowerLeg = 1,
	LeftUpperLeg = 1,
	UpperTorso = 1,
	LowerTorso = 1,
	Head = 1,
	LeftUpperArm = 1,
	LeftLowerArm = 1,
	LeftHand = 0,
	RightUpperArm = 1,
	RightLowerArm = 1,
	RightHand = 0
}
local v2 = {
	Belt = 0,
	Body = 1,
	Eyes = 0,
	["Pants + Bandages"] = 1
}

local function showUntransformedTeleportParticles(instance, p, p2)
	local rotation = p2.Rotation
	local position = instance.HumanoidRootPart.Position
	local cFrame = instance.HumanoidRootPart.CFrame
	local model = Instance.new("Model")
	model.Name = "CharacterClone"
	local clones = {}

	for _, child in ipairs(instance:GetChildren()) do
		local v3 = v[child.Name]

		if not v3 then
			continue
		end

		local clone = child:Clone()

		if clone.ClassName == "MeshPart" then
			clone.TextureID = ""
		end

		local face = clone.Name == "Head" and clone:FindFirstChild("face")

		if face then
			face:Destroy()
		end

		clone.Transparency = 0.7
		clone.Color = Color3.new(0, 0, 0)
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone:ClearAllChildren()

		if v3 == 1 then
			local clone2 = script.TeleportLines1:Clone()
			clone2.Parent = clone
			clone2:Emit(clone2:GetAttribute("EmitCount"))
			local clone3 = script.TeleportLines2:Clone()
			clone3.Parent = clone
			clone3:Emit(clone3:GetAttribute("EmitCount"))
		end

		table.insert(clones, clone)
		clone.CFrame = cFrame:toWorldSpace(rotation * cFrame:toObjectSpace(clone.CFrame))
		clone.CFrame = clone.CFrame - clone.Position + p + (clone.Position - position)
		clone.Parent = model
	end

	model.Parent = _WorldOrigin
	heartbeatLoopFor2(0.35, function(_, _, p3)
		local transparency = 0.7 + 0.3 * p3

		for _, v4 in ipairs(clones) do
			v4.Transparency = transparency
			v4.Position = p + (v4.Position - p) * 1.02
			v4.Size *= 1.02
		end
	end, function()
		task.wait(0.5)
		model:Destroy()
	end)
end

local function showTeleportParticles(parent, position, rotation, transformedRig, list)
	if list then
		local cFrame = parent.HumanoidRootPart.CFrame
		table.insert(
			list,
			{ cFrame:toWorldSpace(rotation * cFrame:toObjectSpace(transformedRig.PrimaryPart.CFrame)), false }
		)
	else
		local rotation2 = rotation.Rotation
		local position2 = parent.HumanoidRootPart.Position
		local cFrame = parent.HumanoidRootPart.CFrame
		local clones = {}
		local model = Instance.new("Model")
		model.Name = "CharacterClone"
		Util.Debris:AddItem(model, 5)
		local v3 = false
		local v4 = {}
		local v5 = {}
		local clone = nil

		if transformedRig then
			clone = transformedRig:Clone()
			clone.VFX:Destroy()
			clone.Name = "TigerClone"
			clone.AnimationController.Animator:Destroy()
			local transformsByName = {}

			for _, bone in ipairs(transformedRig.RootPart:GetDescendants()) do
				if bone:IsA("Bone") then
					transformsByName[bone.Name] = bone.Transform
				end
			end

			for _, bone in ipairs(clone.RootPart:GetDescendants()) do
				if bone:IsA("Bone") then
					bone.Transform = transformsByName[bone.Name]
				end
			end

			local worldSpace = cFrame:toWorldSpace(rotation2 * cFrame:toObjectSpace(clone.PrimaryPart.CFrame))
			clone.PrimaryPart.Anchored = true
			clone:PivotTo(worldSpace)
			table.insert(v4, { worldSpace, false })
			v3 = clone

			for _, child in pairs(clone:GetChildren()) do
				local v6 = v2[child.Name]

				if not v6 then
					continue
				end

				local surfaceAppearance = child:FindFirstChildWhichIsA("SurfaceAppearance")

				if surfaceAppearance then
					surfaceAppearance:Destroy()
				end

				child.Transparency = 0.7
				child.Color = Color3.new(0, 0, 0)

				if v6 ~= 1 then
					continue
				end

				local clone2 = script.trans.TeleportLines1:Clone()
				clone2.Parent = child
				clone2:Emit(clone2:GetAttribute("EmitCount"))
				local clone3 = script.trans.TeleportLines2:Clone()
				clone3.Parent = child
				clone3:Emit(clone3:GetAttribute("EmitCount"))
				local clone4 = script.trans.Shards:Clone()
				clone4.Parent = child
				clone4:Emit(clone4:GetAttribute("EmitCount"))
				local clone5 = script.trans.Fire:Clone()
				clone5.Parent = child
				clone5:Emit(clone5:GetAttribute("EmitCount"))
				v5 = {
					clone2,
					clone3,
					clone4,
					clone5
				}

				for _, v7 in v5 do
					v7.LockedToPart = false
				end
			end

			clone.Parent = model
		else
			for _, child in ipairs(parent:GetChildren()) do
				local v6 = v[child.Name]

				if not v6 then
					continue
				end

				local clone2 = child:Clone()

				if clone2.ClassName == "MeshPart" then
					clone2.TextureID = ""
				end

				local face = clone2.Name == "Head" and clone2:FindFirstChild("face")

				if face then
					face:Destroy()
				end

				clone2.Transparency = 0.7
				clone2.Color = Color3.new(0, 0, 0)
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.CanTouch = false
				clone2.CanQuery = false
				clone2:ClearAllChildren()

				if v6 == 1 then
					local clone3 = script.TeleportLines1:Clone()
					clone3.Parent = clone2
					clone3:Emit(clone3:GetAttribute("EmitCount"))
					local clone4 = script.TeleportLines2:Clone()
					clone4.Parent = clone2
					clone4:Emit(clone4:GetAttribute("EmitCount"))
				end

				table.insert(clones, clone2)
				clone2.CFrame = cFrame:toWorldSpace(rotation2 * cFrame:toObjectSpace(clone2.CFrame))
				clone2.CFrame = clone2.CFrame - clone2.Position + position + (clone2.Position - position2)
				clone2.Parent = model
			end
		end

		model.Parent = _WorldOrigin
		local children = v3 and v3:GetChildren()
		local v6 = 0
		local v7 = 0
		local now = 0
		heartbeatLoopFor2(0.35 + (v3 and 0.25 or 0), function(_, _, p)
			if v3 then
				local transparency = 0.6 + 0.4 * p

				if os.clock() - now > 0.03333333333333333 then
					for _, part in pairs(children) do
						if not (part:IsA("MeshPart") and part.Color == Color3.new(0, 0, 0)) then
							continue
						end

						part.Transparency = transparency
					end

					now = os.clock()
				end

				v6 = (v6 + 1) % #v4
				v6 += 1

				if v6 ~= v7 then
					clone:PivotTo(v4[v6][1])
				end

				v7 = v6

				if v4[v6] and v4[v6][2] == false then
					v4[v6][2] = true

					for _, v9 in v5 do
						v9:Emit(v9:GetAttribute("EmitCount"))
					end
				end
			else
				local transparency = 0.7 + 0.3 * p

				for _, v9 in ipairs(clones) do
					v9.Transparency = transparency
				end
			end
		end, function()
			task.wait(0.5)
			model:Destroy()
		end)
		return v4
	end
end

local function rockspawn(clone, p, duration, vector2, p2, p3)
	local part = Instance.new("Part")
	local ray = Util.Ray
	local v3 = clone.Position + createVector(0, 2, 0)
	local v4 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v5, v6, _ = ray(v3, createVector(-0, -20, -0), v4, false)

	if v5 ~= nil then
		task.spawn(function()
			local v7 = CFrame.new(v6) * clone.CFrame.Rotation
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Material = v5.Material
			part.Color = v5.Color
			part.CFrame = v7 * CFrame.new(0, -p, 0) * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-25, 25))),
				(math.rad((math.random(p2, p3))))
			)
			part.Parent = _WorldOrigin
			Util.Debris:AddItem(part, duration + 1)
			TweenService:Create(part, TweenInfo.new(0.1), {
				CFrame = part.CFrame * CFrame.new(0, p, 0),
				Size = vector2
			}):Play()
			task.wait(duration)
			TweenService:Create(part, TweenInfo.new(0.3), {
				CFrame = part.CFrame * CFrame.new(0, -p, 0),
				Size = createVector(0, 0, 0)
			}):Play()
		end)
	end
end

require(script.Parent:WaitForChild("Modules").ImpactBall)
return function(data)
	local DISTANCE_THRESHOLD = 180
	local player = data.player
	local hrp = data.hrp
	local origin = data.origin
	local fireDir = data.fireDir
	local forwardCylinderRadius = data.forwardCylinderRadius
	local timeUntilReachedEndPoint = data.timeUntilReachedEndPoint
	local victimExists = data.victimExists
	local endPoint = data.endPoint
	local transformedRig = data.transformedRig
	local transformed = data.transformed
	local _ = data.fury

	if hrp == nil or hrp.Parent == nil or (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	local folder = Instance.new("Folder", Workspace._WorldOrigin)
	Util.Debris:AddItem(folder, 15)

	if data.Holding then
		local holding = data.Holding

		if transformed then
			local v3 = Util.Sound:Play("BF_TigerFt_TFM_X_HeldGround_01", hrp)
			local tigerRig = hrp.Parent.TigerRig:FindFirstChild("TigerRig")
			local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone = FX2:WaitForChild("TigerEffects").F_Trans.Holding.eyeL:Clone()
			Util.SetParentOverrideWithColor(clone, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone.RigidConstraint.Attachment0 = clone.Attachment
			clone.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head["Eye.L"]
			local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone2 = FX3:WaitForChild("TigerEffects").F_Trans.Holding.eyeR:Clone()
			Util.SetParentOverrideWithColor(clone2, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone2.RigidConstraint.Attachment0 = clone2.Attachment
			clone2.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head["Eye.R"]
			local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone3 = FX4:WaitForChild("TigerEffects").F_Trans.Holding.Torso:Clone()
			Util.SetParentOverrideWithColor(clone3, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone3.RigidConstraint.Attachment0 = clone3.Attachment
			clone3.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3
			local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone4 = FX5:WaitForChild("TigerEffects").F_Trans.Holding.LHand:Clone()
			Util.SetParentOverrideWithColor(clone4, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone4.RigidConstraint.Attachment0 = clone4.Attachment
			clone4.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.L"]["HandIK.L"]["Hand.L"]["Middle.L"]
			local FX6 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone5 = FX6:WaitForChild("TigerEffects").F_Trans.Holding.RHand:Clone()
			Util.SetParentOverrideWithColor(clone5, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone5.RigidConstraint.Attachment0 = clone5.Attachment
			clone5.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]["Middle.R"]
			local FX7 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone6 = FX7:WaitForChild("TigerEffects").F_Trans.Holding.LFoot:Clone()
			Util.SetParentOverrideWithColor(clone6, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone6.RigidConstraint.Attachment0 = clone6.Attachment
			clone6.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Floor["FootIK.L"]["Foot2.L"]
			local FX8 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone7 = FX8:WaitForChild("TigerEffects").F_Trans.Holding.RFoot:Clone()
			Util.SetParentOverrideWithColor(clone7, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone7.RigidConstraint.Attachment0 = clone7.Attachment
			emitAll(clone5.EmitFX)
			emitAll(clone4.EmitFX)
			emitAll(clone7.EmitFX)
			emitAll(clone6.EmitFX)
			task.spawn(function()
				local now = tick()

				repeat
					task.wait()

					if now < tick() then
						now = tick() + 0.07

						if hrp.Parent == game.Players.LocalPlayer.Character then
							Util.CameraShaker:ShakeOnce(
								2,
								4,
								0.05,
								0.14,
								createVector(0.2, 0.2, 0.2),
								createVector(0.2, 0.2, 0.2)
							)
						end
					end
				until not (holding:IsDescendantOf(Workspace) and holding.Value)
			end)

			repeat
				task.wait()
			until not (holding.Value and holding)

			if v3 then
				Util.Sound:FadeOut(v3, 0.2)
			end

			task.delay(0.1, function()
				clone4:Destroy()
				clone5:Destroy()
				clone6:Destroy()
				clone7:Destroy()
				clone3:Destroy()
				clone:Destroy()
				clone2:Destroy()
			end)
		end
	else
		local _ = player == localPlayer and hrp.Anchored == false
		task.wait()
		local CharacterTransparency = require(game.ReplicatedStorage.CharacterTransparency)
		local v3 = CharacterTransparency:AddStack(hrp.Parent, "TigerFInvis", 2)
		task.delay(timeUntilReachedEndPoint, function()
			v3:Destroy()
		end)
		local forwardCylinderLength = data.forwardCylinderLength
		local distTravelledForward = data.distTravelledForward
		local v4 = transformedRig and 10 or 4
		local v5 = {}
		local v6

		if victimExists == true then
			v6 = math.clamp(math.ceil(distTravelledForward / forwardCylinderLength * v4), 1, v4)
		else
			v6 = v4
		end

		local v7 = 2 * random:NextInteger(0, 1) - 1

		for i = 1, v6 - 1 do
			local v8 = (0.4 + 0.6 * math.random()) * forwardCylinderRadius
			v5[i] = CFrame.lookAt(origin, origin + fireDir):PointToWorldSpace((Vector3.new(
				v8 * v7,
				0,
				-forwardCylinderLength * i / v4
			)))
			v7 *= -1
		end

		v5[v6] = endPoint
		local position = hrp.Position
		local v8 = 1
		local v9 = v5[v8]
		local v10 = showTeleportParticles(hrp.Parent, hrp.CFrame.Position, hrp.CFrame.Rotation, transformedRig)
		Util.Sound:Play("TigerFt_F_Teleport_Dash_0" .. tostring(math.random(1, 3)), hrp.Position)
		local flag = false

		if transformed then
			heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
				if flag then
					return
				end

				local v11 = math.clamp(math.ceil(p * #v5), 1, v4)

				if v8 ~= v11 then
					v8 = v11
					position = v9
					v9 = v5[v8]
					local cframe = CFrame.lookAt(position, position + 2 * (v9 - position))
					showTeleportParticles(hrp.Parent, cframe.Position, cframe.Rotation, transformedRig, v10)
					local clone = FX:WaitForChild("TigerEffects").F_Trans.FDashParticles:Clone()
					clone.CFrame = cframe
					Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
					destroyAfter(clone, 2)
					Util.Sound:Play("TigerFt_F_Teleport_Dash_0" .. tostring(math.random(1, 3)), hrp.Position)
					emitAll(clone)
				end
			end)
		else
			heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
				local v11 = math.clamp(math.ceil(p * #v5), 1, v4)

				if v8 ~= v11 then
					v8 = v11
					position = v9
					v9 = v5[v8]
					local cframe = CFrame.lookAt(position, position + 2 * (v9 - position))
					showTeleportParticles(hrp.Parent, cframe.Position, cframe.Rotation, transformedRig)
					local clone = FX:WaitForChild("TigerEffects").FDashParticlesOld:Clone()
					clone.CFrame = cframe
					clone.Parent = folder
					destroyAfter(clone, 2)
					Util.Sound:Play("TigerFt_F_Teleport_Dash_0" .. tostring(math.random(1, 3)), hrp.Position)

					if transformedRig then
						clone.TeleportLines1.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
						clone.TeleportLines2.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
						clone.TeleportLines3.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))

						for _, child in ipairs(clone.AttachmentEmitters:GetChildren()) do
							child.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
						end
					end

					clone.TeleportLines1:Emit(clone.TeleportLines1:GetAttribute("EmitCount"))
					clone.TeleportLines2:Emit(clone.TeleportLines2:GetAttribute("EmitCount"))
					clone.TeleportLines3:Emit(clone.TeleportLines3:GetAttribute("EmitCount"))

					for _, child in ipairs(clone.AttachmentEmitters:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end
			end)
		end

		local position2 = hrp.Position
		local position3 = hrp.Position
		local v11 = 1
		local v12 = v5[v11]
		local connection = nil
		connection = heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
			local v13 = math.clamp(math.ceil(p * #v5), 1, v4)

			if v11 ~= v13 then
				v11 = v13
				position3 = v12
				v12 = v5[v11]
			end

			local v14 = position3 + (v12 - position3) * (p - (v11 - 1) / #v5) * #v5
			local cframe = CFrame.lookAt(v14, position3 + 2 * (v12 - position3))
			local ray, _, _ = Util.Ray(
				position2,
				cframe.Position - position2,
				{ Workspace.Characters, Workspace.Enemies, folder },
				false
			)

			if ray == nil then
				hrp.CFrame = cframe
				position2 = cframe.Position
			else
				connection:Disconnect()
				connection = nil
				flag = true
			end
		end, function()
			local cframe = CFrame.lookAt(endPoint, endPoint + fireDir)
			local ray, _, _ = Util.Ray(
				position2,
				cframe.Position - position2,
				{ Workspace.Characters, Workspace.Enemies, folder },
				false
			)

			if ray == nil then
				hrp.CFrame = cframe
				position2 = cframe.Position
			else
				connection:Disconnect()
				connection = nil
				flag = true
			end
		end)
		task.delay(timeUntilReachedEndPoint, function()
			if victimExists and transformedRig then
			end
		end)
		task.wait(timeUntilReachedEndPoint)

		if victimExists == false then
			return
		end

		task.spawn(function()
			if hrp.Parent == game.Players.LocalPlayer.Character then
				task.wait(transformedRig and 0.768 or 0.778)
				Workspace.CurrentCamera.FieldOfView = 70
				task.wait()
				Workspace.CurrentCamera.FieldOfView = 70
			end
		end)

		if data.werewolf then
			fireDir = -fireDir

			local function cflerp(object, p, p2)
				return object:lerp(p, p2)
			end

			if game.Players.LocalPlayer.Character and hrp.Parent == game.Players.LocalPlayer.Character then
				local cframe = CFrame.lookAt(hrp.Position, hrp.Position + fireDir)
				hrp.CFrame = cframe
				local currentCamera = Workspace.CurrentCamera
				local cFrame = currentCamera.CFrame
				local _ = cFrame.p - hrp.Position
				local orientation, _, _ = (cFrame - cFrame.p):ToOrientation()
				local _, v13, v14 = cframe:ToOrientation()
				RunService:BindToRenderStep("darkDaggerTeleportCam", Enum.RenderPriority.Camera.Value + 1, function()
					if currentCamera then
						currentCamera.CFrame = currentCamera.CFrame:lerp(
							CFrame.new(cframe.p) * CFrame.fromOrientation(orientation, v13, v14),
							0.15
						)
					else
						RunService:UnbindFromRenderStep("darkDaggerTeleportCam")
					end

					RunService.RenderStepped:Wait()
				end)
				task.spawn(function()
					wait(0.778)
					RunService:UnbindFromRenderStep("darkDaggerTeleportCam")
				end)
			end
		end

		Util.Sound:Play("TigerFt_F_GrabCharge_01", hrp.Position)

		if transformed == false then
			if (endPoint - Workspace.CurrentCamera.CFrame.Position).Magnitude < 150 then
				Util.CameraShaker:ShakeOnce(6, 6, 0.01, 0.4)
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Name = "LeopardCBloom"
				bloomEffect.Intensity = 4
				bloomEffect.Threshold = 0.4
				bloomEffect.Size = 64
				Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "LeopardFruitVFXColor")
				heartbeatLoopFor2(0.4, function(_, _, p)
					bloomEffect.Intensity = 4 - 4 * p
					bloomEffect.Threshold = 0.4 + 0.6 * p
					bloomEffect.Size = 64 - 64 * p
				end, function()
					bloomEffect:Destroy()
				end)
			end

			local clone = FX:WaitForChild("TigerEffects").ImpactBall:Clone()
			clone.CFrame = CFrame.lookAt(endPoint, endPoint + fireDir)
			Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone, 3)
			task.wait(0.015)
			local clone2 = FX:WaitForChild("TigerEffects").F_Untrans.FKickFire:Clone()
			clone2.PrimaryPart.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fireDir)
			Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone2, 3.5)
			local contact = clone2.Contact
			local explosion = clone2.Explosion
			local _ = clone2.FlyBlast
			local pressure = clone2.Pressure
			local flyBlast = clone2.FlyBlast
			emitAll(contact)

			if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
				Util.CameraShaker:ShakeOnce(6, 6, 0.01, 0.25)
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Name = "LeopardZBloom"
				bloomEffect.Intensity = 1.7
				bloomEffect.Threshold = 0.4
				bloomEffect.Size = 12
				Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "LeopardFruitVFXColor")
				heartbeatLoopFor2(0.2, function(_, _, p)
					bloomEffect.Intensity = 4 - 4 * p
					bloomEffect.Threshold = 0.4 + 0.6 * p
					bloomEffect.Size = 64 - 64 * p
				end, function()
					bloomEffect:Destroy()
				end)
			end

			task.wait(0.033)
			task.spawn(function()
				local WAIT_INTERVAL = 0.075
				TweenService:Create(
					pressure.Light,
					TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 6,
						Range = 18
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					pressure.Light,
					TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 8,
						Range = 14
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					pressure.Light,
					TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 6,
						Range = 18
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					pressure.Light,
					TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 8,
						Range = 14
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					pressure.Light,
					TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 6,
						Range = 18
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					pressure.Light,
					TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 8,
						Range = 14
					}
				):Play()
				task.wait(WAIT_INTERVAL)
				TweenService:Create(
					pressure.Light,
					TweenInfo.new(0.075, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 0,
						Range = 0
					}
				):Play()
			end)

			if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < DISTANCE_THRESHOLD then
				TweenService:Create(
					Workspace.Camera,
					TweenInfo.new(0.535, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 40
					}
				):Play()
				task.spawn(function()
					for _ = 1, 13 do
						Util.CameraShaker:ShakeOnce(
							3,
							3,
							0.05,
							0.2,
							createVector(0.3, 0.3, 0.3),
							createVector(0.5, 0.5, 0.5)
						)
						task.wait(0.045)
					end
				end)
			end

			task.spawn(function()
				for _ = 1, 17 do
					emitAll(pressure)
					task.wait(0.025)
				end
			end)
			task.wait(0.6)

			if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < DISTANCE_THRESHOLD then
				Util.CameraShaker:ShakeOnce(12, 10, 0.05, 1.2, createVector(1, 1, 1), createVector(1, 1, 1))
				task.spawn(function()
					if hrp.Parent == game.Players.LocalPlayer.Character then
						task.spawn(function()
							TweenService:Create(
								Workspace.Camera,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									FieldOfView = 107
								}
							):Play()
							task.wait(0.1)
							TweenService:Create(
								Workspace.Camera,
								TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									FieldOfView = 70
								}
							):Play()
						end)
						task.spawn(function()
							local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
							Util.SetParentOverrideWithColor(
								colorCorrectionEffect,
								game.Lighting,
								player,
								"LeopardFruitVFXColor"
							)
							Util.Debris:AddItem(colorCorrectionEffect, 0.3)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 91, 26),
										player,
										"LeopardFruitVFXColor"
									),
									Brightness = -2,
									Saturation = -1,
									Contrast = 8
								}
							):Play()
							task.wait(0.03)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 166, 93),
										player,
										"LeopardFruitVFXColor"
									),
									Brightness = 0.4,
									Saturation = 0,
									Contrast = 1
								}
							):Play()
							task.wait(0.05)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 255, 255),
										player,
										"LeopardFruitVFXColor"
									),
									Brightness = 0,
									Saturation = 0,
									Contrast = 0
								}
							):Play()
						end)
					end
				end)
				TweenService:Create(
					Workspace.Camera,
					TweenInfo.new(0.045, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()
				task.wait(0.045)
				TweenService:Create(
					Workspace.Camera,
					TweenInfo.new(0.185, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end

			emitAll(explosion)
			local ray, _, _ = Util.Ray(
				hrp.Position,
				createVector(-0, -1, -0) * (hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 3),
				{ Workspace.Characters, Workspace.Enemies },
				false
			)

			if ray then
				local clone3 = FX:WaitForChild("TigerEffects").F_Untrans.RockMover:Clone()
				task.spawn(function()
					local v13 = fireDir
					local v14 = hrp.Position + v13 * 0.1
					local rayMap, v15, v16 = Util.RayMap(v14, createVector(0, -10, 0))

					if rayMap then
						local _ = v16 * 0.1
						CFrame.lookAt(hrp.Position, hrp.Position + fireDir)
						clone3.CFrame = Util.Misc.AlignCFrame(CFrame.new(v15, v15 + v13), v16)
						Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(clone3, 1.5)
					end
				end)
				task.spawn(function()
					task.wait(0.1)
					local clone4 = FX:WaitForChild("TigerEffects").F_Untrans.RockMover:Clone()
					clone4.CFrame = clone3.CFrame * CFrame.new(-13, -2, -8)
					Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone4, 1.5)
					local clone5 = FX:WaitForChild("TigerEffects").F_Untrans.RockMover:Clone()
					clone5.CFrame = clone3.CFrame * CFrame.new(13, -2, -7)
					Util.SetParentOverrideWithColor(clone5, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone4, 1.5)
					TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = clone3.CFrame * CFrame.new(-35, 0, -79)
					}):Play()
					TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = clone3.CFrame * CFrame.new(35, 0, -79)
					}):Play()
					task.spawn(function()
						for _ = 1, 15 do
							rockspawn(
								clone4,
								2,
								1.3,
								Vector3.new(
									random:NextNumber(7, 9.75),
									random:NextNumber(4.8, 5.6),
									random:NextNumber(7, 9)
								),
								32,
								38
							)
							rockspawn(
								clone5,
								2,
								1.3,
								Vector3.new(
									random:NextNumber(7, 9.75),
									random:NextNumber(4.8, 5.6),
									random:NextNumber(7, 9)
								),
								32,
								38
							)
							task.wait(0.0125)
						end
					end)
				end)
			end

			task.wait(0.085)
			Util.Sound:Play("TigerFt_FSkill_Explode_03", hrp.Position)
			emitAll(flyBlast)
		elseif transformed == true then
			if (endPoint - Workspace.CurrentCamera.CFrame.Position).Magnitude < 150 then
				Util.CameraShaker:ShakeOnce(15, 15, 0.01, 0.7)
			end

			CFrame.lookAt(hrp.Position, hrp.Position + fireDir)
			local clone = FX:WaitForChild("TigerEffects").ImpactBall:Clone()
			clone.CFrame = CFrame.lookAt(endPoint, endPoint + fireDir)
			Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone, 3)
			task.wait(0.015)
			local clone2 = FX:WaitForChild("TigerEffects").F_Trans.FTKickFire:Clone()
			local primaryPart = clone2.PrimaryPart
			primaryPart.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + fireDir) * CFrame.new(-1.165, 0.45, -7.437)
			Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone2, 3.2)
			local _ = clone2.Contact
			local explosion = clone2.Explosion
			local _ = clone2.FlyBlast
			local _ = clone2.Pressure
			local flyBlast = clone2.FlyBlast
			local legFireKick = clone2.LegFireKick
			local tigerRig = hrp.Parent.TigerRig:FindFirstChild("TigerRig")
			Util.Anims:Get(tigerRig, "TigerTransformed_FSuccess"):Play()
			emitAll(legFireKick)
			Util.Sound:Play("BF_TigerFt_TFM_F_GrabCharge_0" .. tostring(math.random(1, 4)), hrp)

			if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < DISTANCE_THRESHOLD then
				TweenService:Create(
					Workspace.Camera,
					TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						FieldOfView = 40
					}
				):Play()
				task.spawn(function()
					for _ = 1, 16 do
						Util.CameraShaker:ShakeOnce(
							5,
							5,
							0.05,
							0.25,
							createVector(0.3, 0.3, 0.3),
							createVector(0.5, 0.5, 0.5)
						)
						task.wait(0.045)
					end
				end)
			end

			task.wait(0.753)

			if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < DISTANCE_THRESHOLD then
				Util.CameraShaker:ShakeOnce(12, 13, 0.05, 0.8, createVector(1, 1, 1), createVector(1, 1, 1))
				task.spawn(function()
					if hrp.Parent == game.Players.LocalPlayer.Character then
						task.spawn(function()
							TweenService:Create(
								Workspace.Camera,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									FieldOfView = 107
								}
							):Play()
							task.wait(0.1)
							TweenService:Create(
								Workspace.Camera,
								TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									FieldOfView = 70
								}
							):Play()
						end)
						task.spawn(function()
							local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
							Util.SetParentOverrideWithColor(
								colorCorrectionEffect,
								game.Lighting,
								player,
								"LeopardFruitVFXColor"
							)
							Util.Debris:AddItem(colorCorrectionEffect, 0.3)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.03, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 91, 26),
										player,
										"LeopardFruitVFXColor"
									),
									Brightness = -2,
									Saturation = -1,
									Contrast = 8
								}
							):Play()
							task.wait(0.03)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 166, 93),
										player,
										"LeopardFruitVFXColor"
									),
									Brightness = 0.8,
									Saturation = 0,
									Contrast = 1
								}
							):Play()
							task.wait(0.05)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									TintColor = Util.WrapColor3ConstructorForTintColor(
										Color3.fromRGB(255, 255, 255),
										player,
										"LeopardFruitVFXColor"
									),
									Brightness = 0,
									Saturation = 0,
									Contrast = 0
								}
							):Play()
						end)
					end
				end)
				TweenService:Create(
					Workspace.Camera,
					TweenInfo.new(0.045, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()
				task.wait(0.045)
				TweenService:Create(
					Workspace.Camera,
					TweenInfo.new(0.185, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end

			Util.Sound:Play("BF_TigerFt_TFM_F_GrabExplode_0" .. tostring(math.random(1, 3)), hrp)
			emitAll(flyBlast)
			emitAll(explosion)
			local ray, _, _ = Util.Ray(
				hrp.Position,
				createVector(-0, -1, -0) * (hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 3),
				{ Workspace.Characters, Workspace.Enemies },
				false
			)

			if ray then
				local clone3 = FX:WaitForChild("TigerEffects").F_Untrans.RockMover:Clone()
				task.spawn(function()
					local lookVector = CFrame.lookAt(hrp.Position, hrp.Position + fireDir).LookVector
					local v13 = hrp.Position + lookVector * 0.1
					local rayMap, v14, v15 = Util.RayMap(v13, createVector(0, -10, 0))

					if rayMap then
						local _ = v15 * 0.1
						local _ = hrp.CFrame
						clone3.CFrame = Util.Misc.AlignCFrame(CFrame.new(v14, v14 + lookVector), v15)
						Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(clone3, 1.5)
					end
				end)
				task.spawn(function()
					task.wait(0.1)
					local clone4 = FX:WaitForChild("TigerEffects").F_Untrans.RockMover:Clone()
					clone4.CFrame = clone3.CFrame * CFrame.new(-11, -2, -7)
					Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone4, 1.5)
					local clone5 = FX:WaitForChild("TigerEffects").F_Untrans.RockMover:Clone()
					clone5.CFrame = clone3.CFrame * CFrame.new(11, -2, -7)
					Util.SetParentOverrideWithColor(clone5, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone4, 1.5)
					TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = clone3.CFrame * CFrame.new(-39, 0, -95)
					}):Play()
					TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = clone3.CFrame * CFrame.new(39, 0, -95)
					}):Play()
					task.spawn(function()
						for _ = 1, 15 do
							rockspawn(
								clone4,
								2,
								1.3,
								Vector3.new(
									random:NextNumber(9, 11.75),
									random:NextNumber(4.8, 5.6),
									random:NextNumber(9, 11)
								),
								32,
								38
							)
							rockspawn(
								clone5,
								2,
								1.3,
								Vector3.new(
									random:NextNumber(9, 11.75),
									random:NextNumber(4.8, 5.6),
									random:NextNumber(9, 11)
								),
								32,
								38
							)
							task.wait(0.0125)
						end
					end)
				end)
			end
		end
	end
end