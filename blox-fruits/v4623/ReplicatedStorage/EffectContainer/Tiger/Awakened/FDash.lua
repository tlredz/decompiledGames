local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fDashParticles = FX:WaitForChild("TigerEffects").F_Awak.FDashParticles
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

			if clone:FindFirstChild("VFX") then
				clone.VFX:Destroy()
			end

			clone.PrimaryPart.Anchored = true
			clone:PivotTo(worldSpace)
			clone.Parent = model
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

				local clone2 = script.TeleportLines1:Clone()
				clone2.Parent = child
				clone2:Emit(clone2:GetAttribute("EmitCount"))
				local clone3 = script.TeleportLines2:Clone()
				clone3.Parent = child
				clone3:Emit(clone3:GetAttribute("EmitCount"))
				local clone4 = script.Shards:Clone()
				clone4.Parent = child
				clone4:Emit(clone4:GetAttribute("EmitCount"))
				local clone5 = script.Fire:Clone()
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
					local clone5 = script.Shards:Clone()
					clone5.Parent = clone2
					clone5:Emit(clone5:GetAttribute("EmitCount"))
					local clone6 = script.Fire:Clone()
					clone6.Parent = clone2
					clone6:Emit(clone6:GetAttribute("EmitCount"))
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
				if os.clock() - now > 0.03333333333333333 then
					local transparency = 0.6 + 0.4 * p

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

					for _, v8 in v5 do
						v8:Emit(v8:GetAttribute("EmitCount"))
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

local function rockspawn(p, instance, p2, duration, size, p4, p5)
	local part = Instance.new("Part")
	local ray = Util.Ray
	local v3 = instance.Position + createVector(0, 2, 0)
	local v4 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v5, v6, _ = ray(v3, createVector(-0, -20, -0), v4, false)

	if v5 ~= nil then
		task.spawn(function()
			local v7 = CFrame.new(v6) * instance.CFrame.Rotation
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Material = v5.Material
			part.Color = v5.Color
			part.CFrame = v7 * CFrame.new(0, -p2, 0) * CFrame.Angles(
				math.rad((math.random(-25, 25))),
				math.rad((math.random(-25, 25))),
				(math.rad((math.random(p4, p5))))
			)
			Util.SetParentOverrideWithColor(part, _WorldOrigin, p, "LeopardFruitVFXColor")
			Util.Debris:AddItem(part, duration + 1)
			TweenService:Create(part, TweenInfo.new(0.1), {
				CFrame = part.CFrame * CFrame.new(0, p2, 0),
				Size = size
			}):Play()
			task.wait(duration)
			TweenService:Create(part, TweenInfo.new(0.3), {
				CFrame = part.CFrame * CFrame.new(0, -p2, 0),
				Size = createVector(0, 0, 0)
			}):Play()
		end)
	end
end

return function(data)
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
			clone7.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Floor["FootIK.R"]["Foot2.R"]
			emitAll(clone5.EmitFX)
			emitAll(clone4.EmitFX)
			emitAll(clone7.EmitFX)
			emitAll(clone6.EmitFX)
			task.spawn(function()
				local now = tick()

				while true do
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

					if holding:IsDescendantOf(Workspace) and holding.Value then
						continue
					end

					if v3 then
						Util.Sound:FadeOut(v3, 0.2)
					end

					break
				end
			end)

			repeat
				task.wait()
			until not (holding.Value and holding)

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
		local flag = false
		task.delay(timeUntilReachedEndPoint, function()
			flag = true
		end)
		task.wait()
		local folder = Instance.new("Folder", Workspace._WorldOrigin)
		Util.Debris:AddItem(folder, 15)
		local v3 = {}

		for _, effect in pairs(data.transformedRig.VFX:GetDescendants()) do
			if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) and effect.Enabled) then
				continue
			end

			if effect:IsA("ParticleEmitter") then
				effect:Clear()
			end

			effect:SetAttribute("WasEnabled", true)
			effect.Enabled = false
			v3[effect] = true
		end

		local CharacterTransparency = require(game.ReplicatedStorage.CharacterTransparency)
		local v4 = CharacterTransparency:AddStack(hrp.Parent, "TigerFInvis", 2)
		task.delay(timeUntilReachedEndPoint, function()
			v4:Destroy()

			for k, _ in pairs(v3) do
				k.Enabled = true
				k:SetAttribute("WasEnabled", nil)
			end
		end)
		local forwardCylinderLength = data.forwardCylinderLength
		local distTravelledForward = data.distTravelledForward
		local v5 = victimExists ~= true and 10 or math.clamp(
			math.ceil(distTravelledForward / forwardCylinderLength * 10),
			1,
			10
		)
		local v6 = 2 * random:NextInteger(0, 1) - 1
		local v7 = {}

		for i = 1, v5 - 1 do
			local v8 = (0.4 + 0.6 * math.random()) * forwardCylinderRadius
			v7[i] = CFrame.lookAt(origin, origin + fireDir):PointToWorldSpace((Vector3.new(
				v8 * v6,
				0,
				-forwardCylinderLength * i / 10
			)))
			v6 *= -1
		end

		v7[v5] = endPoint
		local position = hrp.Position
		local v8 = 1
		local v9 = v7[v8]
		local v10 = showTeleportParticles(hrp.Parent, hrp.CFrame.Position, hrp.CFrame.Rotation, transformedRig)
		heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
			if flag then
				return
			end

			local v11 = math.clamp(math.ceil(p * #v7), 1, 10)

			if v8 ~= v11 then
				v8 = v11
				position = v9
				v9 = v7[v8]
				local cframe = CFrame.lookAt(position, position + 2 * (v9 - position))
				showTeleportParticles(hrp.Parent, cframe.Position, cframe.Rotation, transformedRig, v10)
				local clone = FX:WaitForChild("TigerEffects").F_Awak.FDashParticles:Clone()
				clone.CFrame = cframe
				Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
				destroyAfter(clone, 2)
				Util.Sound:Play("BF_TigerFt_AWK_F_TeleportFlicker_0" .. tostring(math.random(1, 2)), hrp)
				emitAll(clone)
			end
		end)
		local position2 = hrp.Position
		local position3 = hrp.Position
		local v11 = 1
		local v12 = v7[v11]
		local connection = nil
		connection = heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
			if flag then
				connection:Disconnect()
				connection = nil
			else
				local v13 = math.clamp(math.ceil(p * #v7), 1, 10)

				if v11 ~= v13 then
					v11 = v13
					position3 = v12
					v12 = v7[v11]
				end

				local v14 = position3 + (v12 - position3) * (p - (v11 - 1) / #v7) * #v7
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
				if not victimExists then
					hrp.CFrame = cframe
					position2 = cframe.Position
				end
			else
				connection:Disconnect()
				connection = nil
				flag = true
			end
		end)
	end
end