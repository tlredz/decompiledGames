local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Effect)
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local RockRipple = require(script.Parent.Modules.RockRipple)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
require(script.Parent.Modules.SwirlsC)

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randPointHalfCircle(p)
	local v = p * math.sqrt((math.random()))
	local v2 = 3.141592653589793 * math.random()
	return (Vector3.new(math.cos(v2) * v, math.sin(v2) * v, 0))
end

local function randPointHalfCylinder(p, p2, p3, p4)
	local v = randPointHalfCircle(p3) -- equivalent call inferred; original call site unknown
	return p + CFrame.lookAt(createVector(0, 0, 0), p2):VectorToWorldSpace(v) + p2 * p4 * math.random()
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

local function showTeleportParticles(p, instance, p2, p3, p4)
	local rotation = p3.Rotation
	local position = instance.HumanoidRootPart.Position
	local cFrame = instance.HumanoidRootPart.CFrame
	local model = Instance.new("Model")
	model.Name = "CharacterClone"
	local clones = {}

	for _, child in ipairs(instance:GetChildren()) do
		local v2 = v[child.Name]

		if not v2 then
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

		clone.Transparency = 0.4
		clone.Material = Enum.Material.Neon
		clone.Color = Util.WrapColor3Constructor(Color3.new(1, 0.360784, 0.168627), p, "LeopardFruitVFXColor")
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone:ClearAllChildren()

		if v2 == 1 then
			local clone2 = script.TeleportLines1:Clone()
			Util.SetParentOverrideWithColor(clone2, clone, p, "LeopardFruitVFXColor")
			clone2:Emit(clone2:GetAttribute("EmitCount"))
			local clone3 = script.TeleportLines2:Clone()
			Util.SetParentOverrideWithColor(clone3, clone, p, "LeopardFruitVFXColor")
			clone3:Emit(clone3:GetAttribute("EmitCount"))
			local clone4 = script.Flames:Clone()
			Util.SetParentOverrideWithColor(clone4, clone, p, "LeopardFruitVFXColor")
			emitAll(clone4)
		end

		table.insert(clones, clone)
		clone.CFrame = cFrame:toWorldSpace(rotation * cFrame:toObjectSpace(clone.CFrame))
		clone.CFrame = clone.CFrame - clone.Position + p2 + (clone.Position - position)
		Util.SetParentOverrideWithColor(clone, model, p, "LeopardFruitVFXColor")
	end

	Util.SetParentOverrideWithColor(model, _WorldOrigin, p, "LeopardFruitVFXColor")

	if p4 ~= false then
	end

	heartbeatLoopFor2(0.35, function(_, _, p5)
		local transparency = 0.7 + 0.3 * p5

		for _, v3 in ipairs(clones) do
			v3.Transparency = transparency
			v3.Position = p2 + (v3.Position - p2) * 1.02
			v3.Size *= 1.02
		end
	end, function()
		task.wait(0.5)
		model:Destroy()
	end)
end

function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v2 = modelScale2 == nil and 1 or modelScale2
	local v3 = p or folder:GetPivot().Position
	local v4 = modelScale / v2

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local v5 = part.CFrame - position
		local v6 = position - v3
		part.Size *= Vector3.new(v4, v4, v4)
		part.CFrame = v5 + v3 + v6 * v4
	end

	folder:SetAttribute("ModelScale", modelScale)
end

require(script.Parent:WaitForChild("Modules"):WaitForChild("GroundCrack"))
local _ = { "rbxassetid://9921859745" }
local _ = { "rbxassetid://9929703731" }
require(script.Parent:WaitForChild("Modules").WindBall)

local function tweenBeamTransparency(instance, tweenInfo, p: number)
	if instance:GetAttribute("BeamTransparency") == nil then
		instance:SetAttribute("BeamTransparency", instance.Transparency == NumberSequence.new(1) and 1 or 0)
		instance:SetAttribute("OriginalBeamTransparencyNumberSequence", instance.Transparency)
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance:GetAttribute("BeamTransparency")
	local changedConnection = numberValue.Changed:Connect(function(beamTransparency)
		local numberSequenceKeypoints = {}

		for i, keypoint in ipairs(instance:GetAttribute("OriginalBeamTransparencyNumberSequence").Keypoints) do
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value + (1 - keypoint.Value) * beamTransparency
			)
		end

		instance.Transparency = NumberSequence.new(numberSequenceKeypoints)
		instance:SetAttribute("BeamTransparency", beamTransparency)
	end)
	local v2 = game.TweenService:Create(numberValue, tweenInfo, {
		Value = p
	})
	v2:Play()
	v2.Completed:Once(function()
		changedConnection:Disconnect()
		changedConnection = nil
		numberValue:Destroy()
		numberValue = nil
	end)
end

local function windRibbon(p, cFrame, p2, p3, p4, folder)
	Util.Debris:AddItem(folder, 2)
	folder.Part.Color = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), p, "LeopardFruitVFXColor")
	folder.Part.CFrame = cFrame
	folder.Part.Transparency = 1
	local tween = TweenService:Create(
		folder.Part,
		TweenInfo.new(math.random(1, 2) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = folder.Part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			),
			Size = folder.Part.Size * math.random(6, 8),
			Color = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), p, "LeopardFruitVFXColor"),
			Transparency = 1
		}
	)
	Util.ResizeModel(folder, math.random(p2, p3), folder.Part.Position)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v2 = beam
			task.spawn(function()
				task.wait(0.15)
				tweenBeamTransparency(v2, TweenInfo.new(0.1), 1)
			end)
		end

		local beam = folder.Part.beam1.Beam
		local beam2 = folder.Part.beam2.Beam
		local beam3 = folder.Part.beam3.Beam
		local beam4 = folder.Part.beam4.Beam
		local beam5 = folder.Part.beam5.Beam
		local beam6 = folder.Part.beam6.Beam
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		task.wait(0.05)
		TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end)
	tween.Completed:Connect(function()
		folder:Destroy()
	end)
	Util.SetParentOverrideWithColor(folder, p4, p, "LeopardFruitVFXColor")
	tween:Play()
end

return function(data)
	local player = data.player
	local root = data.Root or data.hrp
	local origin = data.origin or data.Origin or root and root.Position
	local fireDir = data.fireDir
	local forwardCylinderRadius = data.forwardCylinderRadius
	local forwardCylinderLength = data.forwardCylinderLength
	local endsAfter = data.endsAfter
	local transformedRig = data.transformedRig
	local transformed = data.transformed
	local _ = data.fury
	local v2 = origin + createVector(0, 4, 0)

	if root == nil or root.Parent == nil or (v2 - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if transformed == false then
		task.wait()
		local tigerUnCReleaseLoop = Util.Anims:Get(root.Parent, "TigerUn_CReleaseLoop")
		tigerUnCReleaseLoop.Looped = true
		tigerUnCReleaseLoop:Play()
		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.Size = createVector(5, 5, 5)
		part.Parent = _WorldOrigin
		Util.Debris:AddItem(part, endsAfter + 0.2)
		task.spawn(function()
			while part:IsDescendantOf(Workspace) do
				if root:IsDescendantOf(Workspace) then
					part.CFrame = CFrame.new(root.Parent.UpperTorso.Position) * (root.CFrame - root.CFrame.Position)
					task.wait()
				else
					part:Destroy()
					break
				end
			end
		end)
		Util.Sound:Play("TigerFt_C_ReleaseFlameStabs_01", root)
		local cFrame = root.CFrame
		local v3 = 0.05 * forwardCylinderLength
		local v4 = randPointHalfCircle(forwardCylinderRadius) -- equivalent call inferred; original call site unknown
		local v6 = CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) + v2 + CFrame.lookAt(createVector(0, 0, 0), fireDir):VectorToWorldSpace(v4) + fireDir * v3
		local v7 = math.floor(endsAfter * 0.9 * 15)
		local v8 = 1 / (v7 + 1)
		local v9 = 0
		heartbeatLoopFor2(endsAfter * 0.9, function(_, _, p)
			if not (v9 <= p and p < v8) then
				v9 = v8
				v8 += 1 / (v7 + 1)
				local v10 = p * forwardCylinderLength
				local v11 = randPointHalfCircle(forwardCylinderRadius) -- equivalent call inferred; original call site unknown
				cFrame = v6
				v6 = CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) + v2 + CFrame.lookAt(createVector(0, 0, 0), fireDir):VectorToWorldSpace(v11) + fireDir * v10
				local clone = FX:WaitForChild("TigerEffects").C_Untrans.TPSlash:Clone()
				clone.CFrame = root.CFrame * CFrame.new(
					math.random(-10, 10),
					math.random(-10, 10),
					math.random(-10, 10)
				) * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone, 1.5)
				emitAll(clone)
				local ray = Util.Ray
				local v12 = root.Position + createVector(0, 2, 0)
				local v13 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
				local v14, v15, _ = ray(v12, createVector(-0, -120, -0), v13, false)

				if v14 ~= nil then
					local cframe = CFrame.new(v15) or data.impactCF
					local clone2 = FX:WaitForChild("TigerEffects").C_Untrans.TPSlashGround:Clone()
					clone2.CFrame = cframe * CFrame.new(math.random(-15, 15), 0, math.random(-15, 15)) * CFrame.Angles(
						0,
						math.rad((math.random(-360, 360))),
						0
					)
					Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "LeopardFruitVFXColor")
					emitAll(clone2)
					Util.Debris:AddItem(clone2, 3.5)
					clone2.FloorPushSmoke.Color = ColorSequence.new(v14.Color)
				end

				if (cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
					Util.CameraShaker:ShakeOnce(3, 3, 0.01, 0.1)
				end
			end

			local _ = createVector(0, 10, 0) * math.abs(-1 + (2 * ((p - v9) / (v8 - v9)) + 1) % 2)
		end, function()
			heartbeatLoopFor2(endsAfter * 0.1, function(_, _, _) end, function() end)
		end)
		task.spawn(function()
			task.wait(0.7)
		end)
		task.delay(endsAfter, function()
			tigerUnCReleaseLoop:Stop()
			Util.Anims:Get(root.Parent, "TigerUn_CSlam"):Play()

			if not transformedRig then
				local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone = FX2:WaitForChild("TigerEffects").C_Untrans.RHand.emit:Clone()
				Util.SetParentOverrideWithColor(clone, root.Parent.RightHand, player, "LeopardFruitVFXColor")
				emitAll(clone)
				task.wait(data.timeUntilFinalBlast)
				clone:Destroy()
			end
		end)

		if root.Anchored == false then
			local position = root.Position
			local connection = nil
			connection = heartbeatLoopFor2(endsAfter, function(_, _, p)
				local v10 = p * forwardCylinderLength
				local cFrame2 = CFrame.lookAt(v2, v2 + fireDir) * CFrame.new(0, 0, -v10)
				local ray, _, _ = Util.Ray(
					position,
					cFrame2.Position - position,
					{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
					false
				)

				if ray == nil then
					root.CFrame = cFrame2
					position = cFrame2.Position
				else
					connection:Disconnect()
					connection = nil
				end
			end)
			task.delay(endsAfter, function()
				local position2 = root.Position
				local position3 = root.Position
				local connection2 = nil
				local timeUntilFinalBlast = data.timeUntilFinalBlast
				local clone = FX:WaitForChild("TigerEffects").C_Untrans.HRP.Punch:Clone()
				Util.SetParentOverrideWithColor(clone, part, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone, 2.5)
				emitAll(clone)
				connection2 = heartbeatLoopFor2(timeUntilFinalBlast, function(_, _, p)
					local cFrame2

					if p < 0.75 then
						local v11 = (p / 0.75) ^ 0.5
						cFrame2 = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -p * 45) * CFrame.Angles(
							-1.0995574287564276 * v11,
							0,
							0
						) + Vector3.new(0, 45 * v11 * (2 - v11), 0)
					else
						local v11 = (p - 0.75) / 0.25
						cFrame2 = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -p * 45) * CFrame.Angles(
							-1.7278759594743864,
							0,
							0
						) + Vector3.new(0, 45 * (1 - v11), 0)
					end

					local ray, _, _ = Util.Ray(
						position3,
						cFrame2.Position - position3,
						{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
						false
					)

					if ray == nil then
						root.CFrame = cFrame2
						position3 = cFrame2.Position
					else
						connection2:Disconnect()
						connection2 = nil
					end
				end, function()
					local cFrame2 = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -45)
					local ray, _, _ = Util.Ray(
						position3,
						cFrame2.Position - position3,
						{ Workspace.Characters, Workspace.Enemies, _WorldOrigin },
						false
					)

					if ray == nil then
						root.CFrame = cFrame2
						position3 = cFrame2.Position
					else
						connection2:Disconnect()
						connection2 = nil
					end
				end)
			end)
		end

		task.wait(endsAfter + data.timeUntilFinalBlast)
		local position = root.Position
		Util.Sound:Play("TigerFt_C_Explosion_03", position)
		task.spawn(function()
			if (v2 - Workspace.CurrentCamera.CFrame.Position).Magnitude < 310 then
				task.wait(0.05)
				Util.CameraShaker:ShakeOnce(12, 16, 0.05, 1, createVector(1, 1, 1), createVector(1, 1, 1))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				Util.SetParentOverrideWithColor(colorCorrectionEffect, game.Lighting, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(colorCorrectionEffect, 1.5)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 193, 131),
							player,
							"LeopardFruitVFXColor"
						),
						Brightness = -0.6,
						Saturation = 0.7
					}
				):Play()
				task.spawn(function()
					task.wait(0.02)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 193, 131),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 1.6,
							Saturation = 0.7
						}
					):Play()
					task.wait(0.01)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 255, 255),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0,
							Saturation = 0
						}
					):Play()
				end)
				task.spawn(function()
					TweenService:Create(
						Workspace.Camera,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 90
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						Workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					task.wait(0.1532)
					local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
					depthOfFieldEffect:AddTag("FastModeDepthOfField")
					depthOfFieldEffect.FarIntensity = 0.5
					depthOfFieldEffect.FocusDistance = 54.82
					depthOfFieldEffect.InFocusRadius = 50
					depthOfFieldEffect.NearIntensity = 0.2
					Util.SetParentOverrideWithColor(depthOfFieldEffect, game.Lighting, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(depthOfFieldEffect, 1.5)
					TweenService:Create(
						depthOfFieldEffect,
						TweenInfo.new(0.733, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
						{
							FarIntensity = 0,
							FocusDistance = 0,
							InFocusRadius = 0,
							NearIntensity = 0
						}
					):Play()
				end)
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Name = "LeopardZBloom"
				bloomEffect.Intensity = 4
				bloomEffect.Threshold = 0.4
				bloomEffect.Size = 64
				Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "LeopardFruitVFXColor")
				heartbeatLoopFor2(0.2, function(_, _, p)
					bloomEffect.Intensity = 4 - 4 * p
					bloomEffect.Threshold = 0.4 + 0.6 * p
					bloomEffect.Size = 64 - 64 * p
				end, function()
					bloomEffect:Destroy()
				end)
			end
		end)
		local clone = FX:WaitForChild("TigerEffects").C_Untrans.CSlamLift:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -4, 0)
		clone.Orientation = createVector(0, 0, 0)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 3.5)
		task.spawn(function()
			task.wait(0.085)

			for i = 1, 4 do
				local v10 = i
				task.spawn(function()
					if 20 % v10 ~= 0 then
						local v11 = CFrame.new(root.Position) * CFrame.new(0, 0, -math.random(5, 14)) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						)
						task.spawn(function()
							local cframe = CFrame.new(v11.p)
							local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
							windRibbon(
								player,
								cframe,
								3.5,
								5,
								_WorldOrigin,
								FX2:WaitForChild("TigerEffects").WINDRIBBONS.Ribbon:Clone()
							)
							local cframe2 = CFrame.new(v11.p)
							local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
							windRibbon(
								player,
								cframe2,
								5,
								9.7,
								_WorldOrigin,
								FX3:WaitForChild("TigerEffects").WINDRIBBONS.RibbonFire2:Clone()
							)
						end)
					end
				end)
			end
		end)
		local ray = Util.Ray
		local v10 = root.Position + createVector(0, 2, 0)
		local v11 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
		local v12, v13, v14 = ray(v10, createVector(-0, -40, -0), v11, false)

		if v12 ~= nil then
			local cframe = CFrame.new(v13) or data.impactCF
			local clone2 = FX:WaitForChild("TigerEffects").C_Untrans.CSlamFloor:Clone()
			clone2.CFrame = cframe
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "LeopardFruitVFXColor")
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 4.5)
			task.spawn(function()
				local part2 = Instance.new("Part")
				part2.Name = "BAMPROCK"
				part2.CanTouch = false
				part2.CanQuery = false
				part2.CanCollide = false
				part2.Anchored = true
				RockRipple.createRippleEffect(part2, v13, 5, 5, 4, 3)
			end)
			local v15 = CFrame.new(v13, v13 + v14) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local random = Random.new()

			for i = 1, 30 do
				local v16 = 6.283185307179586 * (i / 30)
				local v17 = Rock2.new({
					Type = "Ground",
					FadeOut = { 0.25, 0.5 },
					FadeIn = { 0.25, 0.5 },
					Lifetime = { 1, 2.5 },
					Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
					Scale = { 2.5, 5 }
				})

				if random:NextInteger(1, 20) % 4 == 0 then
					local unit = Vector3.new(
						math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
						random:NextNumber(0, 1) * 1.25,
						math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
					).Unit
					v17.Type = "Flying"
					v17:Spawn(v15 * CFrame.Angles(0, v16, 0) * CFrame.new(0, 0, -22.5))
					v17:Eject({
						Velocity = Util.Misc.Physics.Velocity(
							Vector3.new(),
							unit * random:NextNumber(20, 80),
							Vector3.new(0, -Workspace.Gravity * random:NextNumber(0.25, 1), 0),
							0.25 + random:NextNumber(0, 2)
						),
						AngularVelocity = Vector3.new(
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1)
						) * 2 * 3.141592653589793 * (1 / v17.Scale)
					})
				else
					v17:Spawn(v15 * CFrame.Angles(0, v16, 0) * CFrame.new(0, 0, -22.5))
					v17:TweenShift((v15 * CFrame.Angles(0, v16, 0)).LookVector * 10 * random:NextNumber(1, 2), 0.25)
				end
			end

			clone.CFrame = clone2.CFrame
			local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
			local groundSpike = FX2:WaitForChild("TigerEffects").C_Untrans.GroundSpike

			for i = 0, 17 do
				local number = random:NextNumber(i * 2 * 3.141592653589793 / 18, (i + 1) * 2 * 3.141592653589793 / 18)
				local v16 = math.random()
				local v17 = 18 + 16 * v16
				local clone3 = groundSpike:Clone()
				local v18 = 1.2 + 0.7 * v16
				ScaleModel(clone3, v18)
				local v19 = cframe * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v17) * CFrame.Angles(
					-math.rad(20 + 25 * v16),
					0,
					0
				) * CFrame.new(0, -22 * v18, 0)
				clone3:PivotTo(v19)
				Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone3, 6)
				task.delay(random:NextNumber(0.4, 0.6), function()
					heartbeatLoopFor2(1.8, function(p, p2, p3)
						clone3.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(255 * (1 - p3), 97 * (1 - p3), 44),
							player,
							"LeopardFruitVFXColor"
						)
					end, function()
						clone3.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(0, 0, 0),
							player,
							"LeopardFruitVFXColor"
						)
					end)
				end)
				local v21 = clone3
				task.delay(random:NextNumber(0, 0.03), function()
					heartbeatLoopFor2(0.2, function(p, p2, p3)
						v21:PivotTo(v19 * CFrame.new(0, 22 * v18 * p3, 0))
					end)
				end)
				local v24 = clone3
				task.spawn(function()
					task.wait(2.3)
					task.delay(random:NextNumber(0.4, 0.8), function()
						TweenService:Create(
							v24.PrimaryPart,
							TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{
								CFrame = v24.PrimaryPart.CFrame * CFrame.new(0, -42, 0)
							}
						):Play()
					end)
				end)
			end
		end
	end
end