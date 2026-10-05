local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
require(script.Parent.Modules.SwirlsX)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local xSpiralGround = FX:WaitForChild("TigerEffects").X_Untrans.XSpiralGround
local _ = FX:WaitForChild("TigerEffects").X_Untrans.Pillar
local pillarAir = FX:WaitForChild("TigerEffects").X_Untrans.PillarAir
local explode = FX:WaitForChild("TigerEffects").X_Untrans.explode
local explode2 = FX:WaitForChild("TigerEffects").X_Trans.explode
local floor = FX:WaitForChild("TigerEffects").X_Untrans.Floor
local stars = FX:WaitForChild("TigerEffects").X_Untrans.Stars
local _ = FX:WaitForChild("TigerEffects").X_Untrans.XEnemyHit
local xSpiral = FX:WaitForChild("TigerEffects").X_Untrans.XSpiral
local xSpiral2 = FX:WaitForChild("TigerEffects").X_Trans.XSpiral
local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
local xSpiralGround2 = FX2:WaitForChild("TigerEffects").X_Trans.XSpiralGround
local _ = FX2:WaitForChild("TigerEffects").X_Trans.Pillar
local _ = FX2:WaitForChild("TigerEffects").X_Trans.Floor
local pillarAir2 = FX2:WaitForChild("TigerEffects").X_Trans.PillarAir
local _ = FX2:WaitForChild("TigerEffects").X_Trans.Stars
local _ = FX2:WaitForChild("TigerEffects").X_Trans.XEnemyHit
local spikeBack = FX2:WaitForChild("TigerEffects").X_Trans.SpikeBack
local _ = FX2:WaitForChild("TigerEffects").X_Trans.flywind
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local NumSeqMap = require(interpolationScheme.Parent:WaitForChild("SequenceMaps"):WaitForChild("NumSeqMap"))

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

local function debrisPart(player, data, p, p2, instance, p3)
	for _ = 1, _G.FastMode and 1 or math.random(1, 2) do
		local v = math.random(20, 40) / 10
		local clone = instance:Clone()
		clone.Material = data.Material
		clone.Transparency = data.Transparency

		if p3 == true then
			clone.Transparency = 1
		end

		clone.Reflectance = data.Reflectance
		clone.Color = data.Color
		clone.Size = Vector3.new(v, v, v)
		clone.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
			math.rad((math.random(-13, 13))),
			math.rad((math.random(-13, 13))),
			(math.rad((math.random(-13, 13))))
		)
		clone.CanCollide = false
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
		clone.Color = data.Color
		clone.Velocity = clone.CFrame.lookVector.Unit * Vector3.new(
			math.random(-356, 399),
			math.random(90, 130),
			math.random(-195, 195)
		)
		clone.RotVelocity = Vector3.new(math.random(-12, 12), math.random(-7, 7), math.random(-12, 12))
		emitAll(clone)
		local tween = TweenService:Create(clone, TweenInfo.new(3.9), {
			Size = createVector(0, 0, 0)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		return clone
	end
end

local function debrisPart2(player, data, p, p2, rockFlyBAMP, p3)
	for _ = 1, _G.FastMode and 1 or math.random(1, 2) do
		local v = math.random(35, 50) / 10
		local clone = rockFlyBAMP:Clone()
		clone.Material = data.Material
		clone.Transparency = data.Transparency

		if p3 == true then
			clone.Transparency = 1
		end

		clone.Reflectance = data.Reflectance
		clone.Color = data.Color
		clone.Size = Vector3.new(v, v, v)
		clone.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
			math.rad((math.random(-13, 13))),
			math.rad((math.random(-13, 13))),
			(math.rad((math.random(-13, 13))))
		)
		clone.CanCollide = false
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
		clone.Color = data.Color
		clone.Velocity = clone.CFrame.lookVector.Unit * Vector3.new(
			math.random(-416, 419),
			math.random(110, 180),
			math.random(-415, 415)
		)
		clone.RotVelocity = Vector3.new(math.random(-12, 12), math.random(-7, 7), math.random(-12, 12))
		emitAll(clone)
		task.spawn(function()
			task.wait(0.75)
			clone.FlamesTrailBlack.Enabled = false
		end)
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(1.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
			{
				Color = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
				Size = createVector(0, 0, 0)
			}
		)
		local v3 = clone
		tween.Completed:Connect(function()
			v3:Destroy()
		end)
		tween:Play()
		return clone
	end
end

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function enableAllErrthang(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			effect.Enabled = enabled
		end
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

local function ScaleAttachmentsAndEmittersWithin(folder, projectileSizeMult: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= projectileSizeMult
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, projectileSizeMult)
		end
	end
end

local function insertSoundInto(p, p2, p3)
	local clone = xSpiralGround[p2]:Clone()

	if p3 then
		clone:SetAttribute("PlaybackSpeed", clone:GetAttribute("PlaybackSpeed") * 0.9)
	end

	return (Util.UtilSoundWrapper.Play(clone, p))
end

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
	local v = game.TweenService:Create(numberValue, tweenInfo, {
		Value = p
	})
	v:Play()
	v.Completed:Once(function()
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
				math.rad((math.random(-50, 50))),
				math.rad((math.random(-50, 50))),
				(math.rad((math.random(-50, 50))))
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

			local v = beam
			task.spawn(function()
				task.wait(0.1)
				tweenBeamTransparency(v, TweenInfo.new(0.1), 1)
			end)
		end

		local beam = folder.Part.beam1.Beam
		local beam2 = folder.Part.beam2.Beam
		local beam3 = folder.Part.beam3.Beam
		local beam4 = folder.Part.beam4.Beam
		local beam5 = folder.Part.beam5.Beam
		local beam6 = folder.Part.beam6.Beam
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 19,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 19,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 10,
			Width1 = 2
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 19,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 19,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 10,
			Width1 = 2
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
	local origin = data.origin
	local HRP = data.HRP
	local projectilePart = data.projectilePart
	local _ = data.rotPerFrame
	local fliesFor = data.fliesFor
	local projectileSizeMult = data.projectileSizeMult
	local transformedRig = data.transformedRig
	local transformed = data.transformed
	local _ = data.fury
	local _ = data.stage

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if projectilePart then
		projectilePart.CanCollide = false
	end

	if data.Holding and data.Holding.Value then
		local holding = data.Holding
		local folder = Instance.new("Folder")
		folder.Parent = Workspace._WorldOrigin

		if transformed then
			if data.Grounded then
				local tigerRig = HRP.Parent.TigerRig:FindFirstChild("TigerRig")
				local v = Util.Sound:Play("BF_TigerFt_TFM_X_HeldGround_01", HRP)
				local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone = FX3:WaitForChild("TigerEffects").X_Trans.Holding.TigerRoot.XGroundHold:Clone()
				Util.SetParentOverrideWithColor(clone, tigerRig.PrimaryPart, player, "LeopardFruitVFXColor")
				local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone2 = FX4:WaitForChild("TigerEffects").X_Trans.Holding.LFoot:Clone()
				Util.SetParentOverrideWithColor(clone2, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
				clone2.RigidConstraint.Attachment0 = clone2.Attachment
				clone2.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Floor:FindFirstChild("FootIK.L")

				if data.wolf then
					clone.Position = createVector(0, -5.5, 0)
				end

				emitAll(clone2.Impact)
				task.spawn(function()
					local now = tick()

					repeat
						task.wait()

						if now < tick() then
							now = tick() + 0.07

							if HRP.Parent == game.Players.LocalPlayer.Character then
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

				if v then
					Util.Sound:FadeOut(v, 0.2)
				end

				task.delay(0.1, function()
					clone:Destroy()
					clone2:Destroy()
				end)
			else
				local tigerRig = HRP.Parent.TigerRig:FindFirstChild("TigerRig")
				local v = Util.Sound:Play("BF_TigerFt_TFM_X_HeldAir_01", HRP)
				local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone = FX3:WaitForChild("TigerEffects").X_Trans.Holding.LFootAir:Clone()
				Util.SetParentOverrideWithColor(clone, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
				clone.RigidConstraint.Attachment0 = clone.Attachment
				clone.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Floor:FindFirstChild("FootIK.L")
				local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone2 = FX4:WaitForChild("TigerEffects").X_Trans.Holding.SpinHold:Clone()
				local root = clone2.Root
				root.RigidConstraint.Attachment0 = root.Attachment
				root.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller
				Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")

				repeat
					task.wait()
				until not (holding.Value and holding)

				if v then
					Util.Sound:FadeOut(v, 0.2)
				end

				task.delay(0.1, function()
					clone:Destroy()
					enableAllErrthang(clone2, false)
					clone2:Destroy()
				end)
			end
		elseif data.Grounded then
			repeat
				task.wait()
			until not (holding.Value and holding)

			task.delay(0.1, function() end)
		else
			local part = Instance.new("Part")
			part.Size = createVector(8, 8, 8)
			part.Transparency = 1
			part.CanCollide = false
			part.Anchored = true
			part.CFrame = HRP.CFrame
			Util.SetParentOverrideWithColor(part, Workspace._WorldOrigin, player, "LeopardFruitVFXColor")

			repeat
				task.wait()
			until not (holding.Value and holding)

			task.delay(1, function()
				part:Destroy()
			end)
		end

		Util.Debris:AddItem(folder, 5)
	else
		if projectilePart == nil or projectilePart.Parent == nil then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = Workspace._WorldOrigin
		Util.Debris:AddItem(folder, 8)

		if transformed == false then
			local ray = Util.Ray
			local v = HRP.Position + createVector(0, 2, 0)
			local v2 = { Workspace.Characters, Workspace.Enemies, folder }
			local v3, _, _ = ray(v, createVector(-0, -15, -0), v2, false)

			if v3 then
				Util.Sound:Play("TigerFt_X_GroundLaunch_02", HRP)
				local v4 = Util.Sound:Play("TigerFt_X_GroundLoop_01", projectilePart)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v4, TweenInfo.new(1), {
					Volume = 1
				}):Play()
				local clone = FX2:WaitForChild("TigerEffects").X_Untrans.PopHrp.Pop:Clone()
				Util.SetParentOverrideWithColor(clone, HRP, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone, 2.5)
				emitAll(clone)
				local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone2 = FX3:WaitForChild("TigerEffects").X_Untrans.SpinKick:Clone()
				clone2.CFrame = HRP.CFrame
				clone2.Orientation += createVector(20, 0, 0)
				Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone2, 2.5)
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
					Orientation = clone2.Orientation + createVector(-130, 0, 0)
				}):Play()

				for _, decal in pairs(clone2:GetDescendants()) do
					if decal:IsA("Decal") then
						TweenService:Create(
							decal,
							TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end
				end

				for _, beam in pairs(clone2:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0
							}
						):Play()
					end
				end

				for _, part in pairs(clone2:GetDescendants()) do
					if part:IsA("Part") then
						TweenService:Create(
							part,
							TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end
				end

				local ray2 = Util.Ray
				local v5 = HRP.Position + createVector(0, 2, 0)
				local v6 = { Workspace.Characters, Workspace.Enemies, folder }
				local v7, v8, _ = ray2(v5, createVector(-0, -16, -0), v6, false)

				if v7 ~= nil then
					local cframe = CFrame.new(v8)
					local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
					local clone3 = FX4:WaitForChild("TigerEffects").X_Untrans.BURNKICK:Clone()
					local _, v9, _ = HRP.CFrame:ToOrientation()
					clone3.CFrame = cframe * CFrame.Angles(0, v9, 0)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone3, 3.5)
					task.spawn(function()
						task.wait(0.15)
						emitAll(clone3)
					end)
				end

				if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
					Util.CameraShaker:ShakeOnce(14, 14, 0.01, 0.25)
					local bloomEffect = Instance.new("BloomEffect")
					bloomEffect.Name = "LeopardZBloom"
					bloomEffect.Intensity = 2
					bloomEffect.Threshold = 0.4
					bloomEffect.Size = 25
					Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "LeopardFruitVFXColor")
					heartbeatLoopFor2(0.2, function(_, _, p)
						bloomEffect.Intensity = 2 - 2 * p
						bloomEffect.Threshold = 0.4 + 0.6 * p
						bloomEffect.Size = 25 - 25 * p
					end, function()
						bloomEffect:Destroy()
					end)
				end

				local clone3 = xSpiralGround:Clone()
				ScaleAttachmentsAndEmittersWithin(clone3, projectileSizeMult)
				clone3.CFrame = projectilePart.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				clone3.CanCollide = false
				task.spawn(function()
					task.wait(0.15)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
				end)
				destroyAfter(clone3, fliesFor + 4)
				emitAll(clone3.Pop)

				if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
					task.spawn(function()
						task.wait(0.15)
						Util.CameraShaker:ShakeOnce(14, 16, 0.01, 0.55)
					end)
				end

				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { Workspace.Map }
				task.spawn(function()
					task.wait(0.25)
					local lastTime = tick()

					while tick() - lastTime < 0.67 do
						task.wait(0.016666666666666666)

						for _ = 1, 2 do
							local raycastResult = Workspace:Raycast(
								Vector3.new(
									clone3.RockPoint.WorldPosition.X,
									clone3.RockPoint.Position.Y + 7.5,
									clone3.RockPoint.WorldPosition.Z
								),
								createVector(0, -15.5, 0),
								raycastParams
							)

							if not raycastResult then
								continue
							end

							local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
							local clone4 = FX4:WaitForChild("TigerEffects").X_Untrans.RockSplint:Clone()
							clone4.CFrame = CFrame.new(raycastResult.Position) * CFrame.new(
								math.random(-150, 150) / 10,
								-5,
								math.random(-70, 70) / 10
							)
							clone4.Size = Vector3.new(
								math.random(110, 138) / 10,
								math.random(14, 20) / 10,
								math.random(110, 132) / 10
							)
							clone4.Parent = folder
							clone4.Material = raycastResult.Material
							clone4.Color = raycastResult.Instance.Color
							TweenService:Create(clone4, TweenInfo.new(0.2), {
								CFrame = clone4.CFrame * CFrame.new(0, math.random(45, 45) / 10, 0) * CFrame.Angles(
									math.rad((math.random(-10, 10))),
									math.rad((math.random(-360, 360))),
									(math.rad((math.random(5, 10))))
								)
							}):Play()
							task.delay(1.5, function()
								local tween = TweenService:Create(clone4, TweenInfo.new(0.5), {
									Position = clone4.Position - createVector(0, 4, 0)
								})
								tween.Completed:Connect(function()
									clone4:Destroy()
								end)
								tween:Play()
							end)
						end
					end
				end)
				task.spawn(function()
					task.wait(0.215)

					for _ = 1, 35 do
						task.wait(0.015)
						local v9 = clone3.Position + createVector(0, 7.5, 0)
						local rayMap, v10, v11 = Util.RayMap(v9, createVector(0, -37.5, 0))

						if rayMap then
							debrisPart(
								player,
								rayMap,
								v10,
								v11,
								FX2:WaitForChild("TigerEffects").X_Untrans.RockFlyBAMP,
								false
							)
						end
					end
				end)
				heartbeatLoopFor2(fliesFor, function()
					clone3.CFrame += -clone3.CFrame.Position + projectilePart.CFrame.Position + createVector(0, 7.6, 0)
				end, function()
					for _, effect in ipairs(clone3:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
							continue
						end

						effect.Enabled = false
					end

					for _, descendant in ipairs(clone3:GetDescendants()) do
						if descendant:IsA("Decal") or descendant:IsA("Texture") then
							descendant.Transparency = 1
						end
					end
				end)
				heartbeatLoopFor2(fliesFor, function()
					local ray3 = Util.Ray
					local v9 = projectilePart.Position + createVector(0, 2, 0)
					local v10 = {
						Workspace.Characters,
						Workspace.Enemies,
						folder,
						projectilePart
					}
					local v11, v12, _ = ray3(v9, createVector(-0, -6, -0), v10, false)

					if v11 == nil and clone3.A0.GroundTrail.Enabled == true then
						clone3.A0.GroundTrail.Enabled = false
						clone3.Aura.Smoke.Enabled = false
						clone3.Aura.FlamesAir.Enabled = true
						clone3.Aura.SmokeAir.Enabled = true
					else
						if v11 ~= nil and clone3.A0.GroundTrail.Enabled == false then
							clone3.A0.GroundTrail.Enabled = true
							clone3.Aura.Smoke.Enabled = true
							clone3.Aura.FlamesAir.Enabled = false
							clone3.Aura.SmokeAir.Enabled = false
						end

						clone3.A0.WorldPosition = clone3.A0.WorldPosition * createVector(1, 0, 1) + (v12.Y + 0.1) * createVector(
							0,
							1,
							0
						)
						clone3.A1.WorldPosition = clone3.A1.WorldPosition * createVector(1, 0, 1) + (v12.Y + 0.1) * createVector(
							0,
							1,
							0
						)
					end
				end)
				local emitters = {}

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end

				local v9 = NumSeqMap.new(script.SizeGraph:GetAttribute("Sequence"), 60)
				local v10 = 1
				local windSwirlWeld2 = clone3.WindSwirlWeld2
				task.spawn(function()
					local function spinWeld()
						for _ = 1, 35 do
							local tween = TweenService:Create(
								windSwirlWeld2,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
								{
									C1 = windSwirlWeld2.C1 * CFrame.Angles(0, -15.707963267948966, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end

					spinWeld()
				end)
				local windSwirlWeld3 = clone3.WindSwirlWeld3
				task.spawn(function()
					local function spinWeld()
						for _ = 1, 35 do
							local tween = TweenService:Create(
								windSwirlWeld3,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
								{
									C1 = windSwirlWeld3.C1 * CFrame.Angles(0, -15.707963267948966, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end

					spinWeld()
				end)
				task.spawn(function()
					task.wait(0.25)
					local clone4 = stars:Clone()
					clone4.CFrame = clone3.CFrame
					Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
					local weldConstraint = Instance.new("WeldConstraint")
					Util.SetParentOverrideWithColor(weldConstraint, clone4, player, "LeopardFruitVFXColor")
					weldConstraint.Part0 = clone3
					weldConstraint.Part1 = clone4

					for _ = 1, 9 do
						emitAll(clone4)
						task.wait(0.1)
					end

					clone4:Destroy()
				end)
				task.spawn(function()
					task.wait(fliesFor - 0.25)
					enableAll(clone3, false)
				end)
				awaitHeartbeatLoopFor(fliesFor, function(_, _, p)
					local v11 = v9:GetValue(p) * 3.5
					local v12 = v11 / v10

					for _, v13 in ipairs(emitters) do
						if not (v13.Name ~= "FlamesTrailDark2" and v13.Name ~= "FlamesTrailDark" and v13.Name ~= "FlamesAir" and v13.Name ~= "SmokeAir") then
							continue
						end

						if not (v13.Name ~= "Smoke" and v13.Name ~= "Flames") then
							continue
						end

						ScaleParticle(v13, v12)
					end

					v10 = v11
				end, function()
					local v11 = v9:GetValue(1) * 3.5 / v10

					for _, v12 in ipairs(emitters) do
						if not (v12.Name ~= "FlamesTrailDark2" and v12.Name ~= "FlamesTrailDark" and v12.Name ~= "FlamesAir" and v12.Name ~= "SmokeAir") then
							continue
						end

						if not (v12.Name ~= "Smoke" and v12.Name ~= "Flames") then
							continue
						end

						ScaleParticle(v12, v11)
					end
				end)
				enableAll(clone3, false)
				clone3.Transparency = 1
				clone3.Anchored = true
				task.spawn(function()
					for _, beam in pairs(clone3:GetDescendants()) do
						if beam:IsA("Beam") then
							beam:Destroy()
						end
					end

					task.wait(2)
					clone3:Destroy()
				end)
				local clone4 = explode:Clone()
				clone4.CFrame = clone3.CFrame * CFrame.new(0, -7, 0) * CFrame.Angles(0.5235987755982988, 0, 0)
				Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
				emitAll(clone4)
				Util.Debris:AddItem(clone4, 3.5)

				if v4 then
					Util.Sound:FadeOut(v4, 0.2)
				end

				Util.Sound:Play("TigerFt_X_Ground_Explosion_01", clone4.Position)
				local clone5 = explode:Clone()
				clone5.CFrame = clone3.CFrame * CFrame.new(0, -7, 0) * CFrame.Angles(-0.5235987755982988, 0, 0)
				Util.SetParentOverrideWithColor(clone5, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone5, 3.5)
				task.spawn(function()
					for _ = 1, 25 do
						local _ = clone4.CFrame * CFrame.Angles(
							-1.4835298641951802,
							3.141592653589793,
							-1.4835298641951802
						)
						local _ = math.random(5, 13) / 5
						local v11 = math.random(20, 60) / 5

						if math.random(2) == 1 then
							v11 *= -1
						end

						local _ = math.random(-22, 21) / 1.5
						coroutine.resume(coroutine.create(function()
							task.wait(math.random(70, 90) / 100)
						end))
					end
				end)
				local clone6 = pillarAir:Clone()
				clone6.CFrame = clone3.CFrame
				Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone6, 3.5)
				local ray3 = Util.Ray
				local v11 = clone3.Position + createVector(0, 2, 0)
				local v12 = { Workspace.Characters, Workspace.Enemies, folder }
				local v13, v14, _ = ray3(v11, createVector(-0, -35, -0), v12, false)

				if v13 ~= nil then
					local cframe = CFrame.new(v14)
					local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
					local clone7 = FX4:WaitForChild("TigerEffects").X_Untrans.BURN:Clone()
					local _, v15, _ = clone3.CFrame:ToOrientation()
					clone7.CFrame = cframe * CFrame.Angles(0, v15, 0)
					Util.SetParentOverrideWithColor(clone7, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone7, 3.5)
					task.spawn(function()
						task.wait(0.15)
					end)
				end
			else
				if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 or (projectilePart == nil or projectilePart.Parent == nil) then
					return
				end

				Util.Sound:Play("TigerFt_X_Air_Launch_01", HRP)
				local v4 = Util.Sound:Play("TigerFt_X_GroundLoop_01", projectilePart)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v4, TweenInfo.new(1), {
					Volume = 1
				}):Play()
				task.spawn(function()
					if HRP.Parent == game.Players.LocalPlayer.Character then
						task.spawn(function()
							task.wait(0.12)
							Util.CameraShaker:ShakeOnce(7, 7, 0.05, 1.4, createVector(1, 1, 1), createVector(1, 1, 1))
							local clone = script.DOF:Clone()
							local Debris = game:GetService("Debris")
							Debris:AddItem(clone, 1)
							Util.SetParentOverrideWithColor(clone, game.Lighting, player, "LeopardFruitVFXColor")
							TweenService:Create(
								clone,
								TweenInfo.new(0.233, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
								{
									FarIntensity = 0,
									FocusDistance = 0,
									InFocusRadius = 0,
									NearIntensity = 0
								}
							):Play()
						end)
					end

					if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
						Util.CameraShaker:ShakeOnce(14, 14, 0.01, 0.25)
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
				local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone = FX3:WaitForChild("TigerEffects").X_Untrans.hrpwind.HitXWindStart:Clone()
				local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone2 = FX4:WaitForChild("TigerEffects").X_Untrans.hrpwind.HitXWind:Clone()
				Util.SetParentOverrideWithColor(clone2, HRP, player, "LeopardFruitVFXColor")
				Util.SetParentOverrideWithColor(clone, HRP, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone2, 2)
				Util.Debris:AddItem(clone, 2)
				local FX5 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone3 = FX5:WaitForChild("TigerEffects").X_Untrans.WindSwirlStart:Clone()
				clone3.CFrame = HRP.CFrame * CFrame.Angles(
					0.017575465567582896,
					1.5707963267948966,
					0.010402162341886203
				)
				Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone3, 2)
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(0.534, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
					{
						Scale = createVector(5, 15, 5.5)
					}
				):Play()
				TweenService:Create(
					clone3.Decal,
					TweenInfo.new(0.217, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Transparency = 0
					}
				):Play()
				task.spawn(function()
					task.wait(0.1)
					emitAll(clone3)
					emitAll(clone)
				end)
				task.spawn(function()
					task.wait(0.1)
					TweenService:Create(clone3, TweenInfo.new(0.234, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						CFrame = clone3.CFrame * CFrame.Angles(0, -2.8797932657906435, 0)
					}):Play()
					task.wait(0.1)
					TweenService:Create(
						clone3.Decal,
						TweenInfo.new(0.233, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.spawn(function()
					task.spawn(function()
						if HRP.Parent == game.Players.LocalPlayer.Character then
							task.spawn(function()
								task.wait(0.12)
								Util.CameraShaker:ShakeOnce(
									9,
									9,
									0.05,
									0.7,
									createVector(1, 1, 1),
									createVector(1, 1, 1)
								)
								local clone4 = script.DOF:Clone()
								local Debris = game:GetService("Debris")
								Debris:AddItem(clone4, 1)
								Util.SetParentOverrideWithColor(clone4, game.Lighting, player, "LeopardFruitVFXColor")
								TweenService:Create(
									clone4,
									TweenInfo.new(0.333, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
									{
										FarIntensity = 0,
										FocusDistance = 0,
										InFocusRadius = 0,
										NearIntensity = 0
									}
								):Play()
								TweenService:Create(
									Workspace.Camera,
									TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
									{
										FieldOfView = 45
									}
								):Play()
								task.wait(0.05)
								TweenService:Create(
									Workspace.Camera,
									TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										FieldOfView = 85
									}
								):Play()
								task.wait(0.05)
								TweenService:Create(
									Workspace.Camera,
									TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
									{
										FieldOfView = 70
									}
								):Play()
							end)
						end

						if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
							Util.CameraShaker:ShakeOnce(14, 14, 0.01, 0.25)
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
					task.wait(0.117)
					local FX6 = require(ReplicatedStorage:WaitForChild("FX"))
					local clone4 = FX6:WaitForChild("TigerEffects").X_Untrans.WindSwirl:Clone()
					clone4.CFrame = HRP.CFrame * CFrame.new(1.007, -0.324, 0.596)
					Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone4, 2)
					TweenService:Create(
						clone4.Mesh,
						TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
						{
							Scale = createVector(10, 12, 11)
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						clone4.Decal,
						TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(clone4, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = clone4.CFrame * CFrame.Angles(0, -3.0823910853621457, 0)
					}):Play()
					task.wait(0.083)
					TweenService:Create(clone4, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = clone4.CFrame * CFrame.Angles(0, 3.765076622279728, 0)
					}):Play()
					task.wait(0.075)
					emitAll(clone2)
				end)
				task.wait(0.25)
				local clone4 = xSpiral:Clone()
				ScaleAttachmentsAndEmittersWithin(clone4, projectileSizeMult)
				clone4.CFrame = projectilePart.CFrame * CFrame.Angles(0, 0, -1.5707963267948966)
				Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
				destroyAfter(clone4, fliesFor + 4)
				local windSwirlWeld2 = clone4.WindSwirlWeld2
				task.spawn(function()
					local function spinWeld()
						for _ = 1, 35 do
							local tween = TweenService:Create(
								windSwirlWeld2,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
								{
									C1 = windSwirlWeld2.C1 * CFrame.Angles(0, 15.707963267948966, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end

					spinWeld()
				end)
				task.spawn(function()
					task.wait(0.35)

					for _, beam in pairs(clone4:GetDescendants()) do
						if beam:IsA("Beam") then
							beam.Enabled = true
						end
					end
				end)
				local clone5 = FX2:WaitForChild("TigerEffects").X_Untrans.hrpwind.HitXWind:Clone()
				Util.SetParentOverrideWithColor(clone5, HRP, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone5, 2.5)
				emitAll(clone5)
				heartbeatLoopFor2(fliesFor, function()
					clone4.CFrame += -clone4.CFrame.Position + projectilePart.CFrame.Position + createVector(0, 6, 0)
				end, function()
					for _, effect in ipairs(clone4:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
							continue
						end

						effect.Enabled = false
					end

					for _, descendant in ipairs(clone4:GetDescendants()) do
						if descendant:IsA("Decal") or descendant:IsA("Texture") then
							descendant.Transparency = 1
						end
					end
				end)
				local emitters = {}

				for _, emitter in ipairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end

				local v5 = NumSeqMap.new(script.SizeGraph:GetAttribute("Sequence"), 60)
				local v6 = 1
				local v7 = false
				awaitHeartbeatLoopFor(fliesFor, function(_, _, p)
					local v8 = v5:GetValue(p) * 3.5
					local v9 = v8 / v6

					for _, v10 in ipairs(emitters) do
						if not (v10.Name ~= "FlamesTrailDark2" and v10.Name ~= "FlamesTrailDark" and v10.Name ~= "FlamesAir" and v10.Name ~= "SmokeAir") then
							continue
						end

						if not (v10.Name ~= "Smoke" and v10.Name ~= "Flames") then
							continue
						end

						ScaleParticle(v10, v9)
					end

					if v9 > 1.1 and v7 == false then
						local clone6 = xSpiralGround.XCharge:Clone()

						if transformedRig then
							clone6:SetAttribute("PlaybackSpeed", clone6:GetAttribute("PlaybackSpeed") * 0.9)
						end

						Util.UtilSoundWrapper.Play(clone6, clone4)
						v7 = true
					end

					v6 = v8
				end, function()
					local v8 = v5:GetValue(1) * 3.5 / v6

					for _, v9 in ipairs(emitters) do
						if not (v9.Name ~= "FlamesTrailDark2" and v9.Name ~= "FlamesTrailDark" and v9.Name ~= "FlamesAir" and v9.Name ~= "SmokeAir") then
							continue
						end

						if not (v9.Name ~= "Smoke" and v9.Name ~= "Flames") then
							continue
						end

						ScaleParticle(v9, v8)
					end
				end)

				if v4 then
					Util.Sound:FadeOut(v4, 0.2)
				end

				task.spawn(function()
					for _, beam in pairs(clone4:GetDescendants()) do
						if beam:IsA("Beam") then
							beam:Destroy()
						end
					end

					task.wait(2)
					clone4:Destroy()
				end)
				local clone6 = pillarAir:Clone()
				clone6.CFrame = clone4.CFrame * CFrame.Angles(0, 0, 1.5707963267948966)
				Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
				Util.Sound:Play("BF_TigerFt_TFM_X_Air_Explosion_01", clone6.Position)
				emitAll(clone6)
				Util.Debris:AddItem(clone6, 3.5)
				task.spawn(function()
					task.wait(0.25)
					local clone7 = FX2:WaitForChild("TigerEffects").WindBall:Clone()
					clone7.Size *= 0.7
					clone7.CFrame = CFrame.new(clone6.Position)
					Util.SetParentOverrideWithColor(clone7, folder, player, "LeopardFruitVFXColor")
				end)

				for _ = 1, 3 do
					task.spawn(function()
						task.wait(0.15)
						local clone7 = FX2:WaitForChild("TigerEffects").X_Untrans.PillarExplosionMesh:Clone()
						clone7.CFrame = clone6.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
						Util.SetParentOverrideWithColor(clone7, folder, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(clone7, 2)
						TweenService:Create(
							clone7,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CFrame = clone7.CFrame * CFrame.new(0, 78, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
							}
						):Play()
						TweenService:Create(
							clone7.Mesh,
							TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Scale = createVector(20.852, 64.222, 20.037)
							}
						):Play()
						TweenService:Create(
							clone7.Decal,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end)
					task.wait(0.075)
				end
			end
		elseif transformed == true then
			local ray = Util.Ray
			local v = HRP.Position + createVector(0, 2, 0)
			local v2 = { Workspace.Characters, Workspace.Enemies, folder }
			local v3, _, _ = ray(v, createVector(-0, -15, -0), v2, false)

			if v3 then
				Util.Sound:Play("BF_TigerFt_TFM_X_GroundLaunch_0" .. tostring(math.random(1, 3)), HRP)
				local v4 = Util.Sound:Play("BF_TigerFt_TFM_X_GroundTravel_01", projectilePart)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v4, TweenInfo.new(1), {
					Volume = 1
				}):Play()
				local clone = FX2:WaitForChild("TigerEffects").X_Untrans.PopHrp.Pop:Clone()
				Util.SetParentOverrideWithColor(clone, HRP, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone, 2.5)
				emitAll(clone)
				local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone2 = FX3:WaitForChild("TigerEffects").X_Trans.SpinKick:Clone()
				clone2.CFrame = HRP.CFrame
				clone2.Orientation += createVector(20, 0, 0)
				Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone2, 2.5)
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
					Orientation = clone2.Orientation + createVector(-130, 0, 0)
				}):Play()

				for _, decal in pairs(clone2:GetDescendants()) do
					if decal:IsA("Decal") then
						TweenService:Create(
							decal,
							TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end
				end

				for _, beam in pairs(clone2:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(
							beam,
							TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0
							}
						):Play()
					end
				end

				for _, part in pairs(clone2:GetDescendants()) do
					if part:IsA("Part") then
						TweenService:Create(
							part,
							TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end
				end

				local ray2 = Util.Ray
				local v5 = HRP.Position + createVector(0, 2, 0)
				local v6 = { Workspace.Characters, Workspace.Enemies, folder }
				local v7, v8, _ = ray2(v5, createVector(-0, -16, -0), v6, false)

				if v7 ~= nil then
					local cframe = CFrame.new(v8)
					local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
					local clone3 = FX4:WaitForChild("TigerEffects").X_Trans.BURNKICK:Clone()
					local _, v9, _ = HRP.CFrame:ToOrientation()
					clone3.CFrame = cframe * CFrame.Angles(0, v9, 0)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone3, 3.5)
					task.spawn(function()
						task.wait(0.15)
						emitAll(clone3)
					end)
				end

				if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 180 then
					task.spawn(function()
						task.wait(0.15)
						TweenService:Create(
							Workspace.Camera,
							TweenInfo.new(0.045, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								FieldOfView = 105
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
						Util.CameraShaker:ShakeOnce(14, 15, 0.01, 0.45)
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
					end)
				end

				local clone3 = xSpiralGround2:Clone()
				ScaleAttachmentsAndEmittersWithin(clone3, projectileSizeMult)
				clone3.CFrame = projectilePart.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				clone3.CanCollide = false
				task.spawn(function()
					task.wait(0.15)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
				end)
				destroyAfter(clone3, fliesFor + 4)
				emitAll(clone3.Pop)
				task.spawn(function()
					task.wait(0.25)

					for _ = 1, 8 do
						task.spawn(function()
							local clone4 = spikeBack:Clone()
							clone4.CFrame = projectilePart.CFrame * CFrame.new(0, 3, -15) * CFrame.Angles(
								math.rad((math.random(-360, -360))),
								1.5707963267948966,
								3.141592653589793
							)
							Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
							Util.Debris:AddItem(clone4, 2)
							TweenService:Create(
								clone4.Mesh,
								TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
								{
									Scale = createVector(0.902, 1.4, 1.4)
								}
							):Play()
							TweenService:Create(
								clone4.Decal,
								TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
								{
									Transparency = 1
								}
							):Play()
						end)
						task.wait(0.05)
					end
				end)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { Workspace.Map }
				task.spawn(function()
					task.wait(0.25)
					local lastTime = tick()

					while tick() - lastTime < 0.67 do
						task.wait(0.016666666666666666)

						for _ = 1, 2 do
							local raycastResult = Workspace:Raycast(
								Vector3.new(
									clone3.RockPoint.WorldPosition.X,
									clone3.RockPoint.Position.Y + 7.5,
									clone3.RockPoint.WorldPosition.Z
								),
								createVector(0, -15.5, 0),
								raycastParams
							)

							if not raycastResult then
								continue
							end

							local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
							local clone4 = FX4:WaitForChild("TigerEffects").X_Untrans.RockSplint:Clone()
							clone4.CFrame = CFrame.new(raycastResult.Position) * CFrame.new(
								math.random(-150, 150) / 10,
								-5,
								math.random(-70, 70) / 10
							)
							clone4.Size = Vector3.new(
								math.random(160, 198) / 10,
								math.random(18, 24) / 10,
								math.random(160, 182) / 10
							)
							clone4.Parent = folder
							clone4.Material = raycastResult.Material
							clone4.Color = raycastResult.Instance.Color
							TweenService:Create(clone4, TweenInfo.new(0.2), {
								CFrame = clone4.CFrame * CFrame.new(0, math.random(45, 45) / 10, 0) * CFrame.Angles(
									math.rad((math.random(-10, 10))),
									math.rad((math.random(-360, 360))),
									(math.rad((math.random(5, 10))))
								)
							}):Play()
							task.delay(1.5, function()
								local tween = TweenService:Create(clone4, TweenInfo.new(0.5), {
									Position = clone4.Position - createVector(0, 4, 0)
								})
								tween.Completed:Connect(function()
									clone4:Destroy()
								end)
								tween:Play()
							end)
						end
					end
				end)
				task.spawn(function()
					task.wait(0.215)

					for _ = 1, 35 do
						task.wait(0.015)
						local v9 = clone3.Position + createVector(0, 7.5, 0)
						local rayMap, v10, v11 = Util.RayMap(v9, createVector(0, -37.5, 0))

						if not rayMap then
							continue
						end

						debrisPart2(
							player,
							rayMap,
							v10,
							v11,
							FX2:WaitForChild("TigerEffects").X_Trans.RockFlyBAMP,
							false
						)
						debrisPart(
							player,
							rayMap,
							v10,
							v11,
							FX2:WaitForChild("TigerEffects").X_Trans.TrailKickBurn,
							true
						)
					end
				end)
				heartbeatLoopFor2(fliesFor, function()
					clone3.CFrame += -clone3.CFrame.Position + projectilePart.CFrame.Position + createVector(0, 7.6, 0)
				end, function()
					for _, effect in ipairs(clone3:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
							continue
						end

						effect.Enabled = false
					end

					for _, descendant in ipairs(clone3:GetDescendants()) do
						if descendant:IsA("Decal") or descendant:IsA("Texture") then
							descendant.Transparency = 1
						end
					end
				end)
				heartbeatLoopFor2(fliesFor, function()
					local ray3 = Util.Ray
					local v9 = projectilePart.Position + createVector(0, 2, 0)
					local v10 = {
						Workspace.Characters,
						Workspace.Enemies,
						folder,
						projectilePart
					}
					local v11, v12, _ = ray3(v9, createVector(-0, -6, -0), v10, false)

					if v11 == nil and clone3.A0.GroundTrail.Enabled == true then
						clone3.A0.GroundTrail.Enabled = false
						clone3.Aura.Smoke.Enabled = false
						clone3.Aura.FlamesAir.Enabled = true
						clone3.Aura.SmokeAir.Enabled = true
					else
						if v11 ~= nil and clone3.A0.GroundTrail.Enabled == false then
							clone3.A0.GroundTrail.Enabled = true
							clone3.Aura.Smoke.Enabled = true
							clone3.Aura.FlamesAir.Enabled = false
							clone3.Aura.SmokeAir.Enabled = false
						end

						clone3.A0.WorldPosition = clone3.A0.WorldPosition * createVector(1, 0, 1) + (v12.Y + 0.1) * createVector(
							0,
							1,
							0
						)
						clone3.A1.WorldPosition = clone3.A1.WorldPosition * createVector(1, 0, 1) + (v12.Y + 0.1) * createVector(
							0,
							1,
							0
						)
					end
				end)
				local emitters = {}

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end

				local v9 = NumSeqMap.new(script.SizeGraph:GetAttribute("Sequence"), 60)
				local v10 = 1
				local windSwirlWeld2 = clone3.WindSwirlWeld2
				task.spawn(function()
					task.wait(0.55)
					emitAll(clone3.before)
					task.wait(0.5245)
					clone3.Stars:Emit(12)
				end)
				task.spawn(function()
					local function spinWeld()
						for _ = 1, 35 do
							local tween = TweenService:Create(
								windSwirlWeld2,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
								{
									C1 = windSwirlWeld2.C1 * CFrame.Angles(0, 15.707963267948966, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end

					spinWeld()
				end)
				local windSwirlWeld3 = clone3.WindSwirlWeld3
				task.spawn(function()
					local function spinWeld()
						for _ = 1, 35 do
							local tween = TweenService:Create(
								windSwirlWeld3,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
								{
									C1 = windSwirlWeld3.C1 * CFrame.Angles(0, 15.707963267948966, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end

					spinWeld()
				end)
				awaitHeartbeatLoopFor(fliesFor, function(_, _, p)
					local v11 = v9:GetValue(p) * 3.5
					local v12 = v11 / v10

					for _, v13 in ipairs(emitters) do
						if not (v13.Name ~= "FlamesTrailDark2" and v13.Name ~= "FlamesTrailBlack" and v13.Name ~= "FlamesTrailDark" and v13.Name ~= "FlamesAir") then
							continue
						end

						if not (v13.Name ~= "SmokeAir" and v13.Name ~= "Smoke" and v13.Name ~= "Flames") then
							continue
						end

						ScaleParticle(v13, v12)
					end

					v10 = v11
				end, function()
					local v11 = v9:GetValue(1) * 3.5 / v10

					for _, v12 in ipairs(emitters) do
						if not (v12.Name ~= "FlamesTrailDark2" and v12.Name ~= "FlamesTrailBlack" and v12.Name ~= "FlamesTrailDark" and v12.Name ~= "FlamesAir") then
							continue
						end

						if not (v12.Name ~= "SmokeAir" and v12.Name ~= "Smoke" and v12.Name ~= "Flames") then
							continue
						end

						ScaleParticle(v12, v11)
					end
				end)
				clone3.Transparency = 1
				clone3.Anchored = true

				if v4 then
					Util.Sound:FadeOut(v4, 0.2)
				end

				task.spawn(function()
					for _, beam in pairs(clone3:GetDescendants()) do
						if beam:IsA("Beam") then
							beam:Destroy()
						end
					end

					task.wait(2)
					clone3:Destroy()
				end)
				local clone4 = explode2:Clone()
				clone4.CFrame = clone3.CFrame * CFrame.new(0, -7, 0) * CFrame.Angles(0.5235987755982988, 0, 0)
				Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
				emitAll(clone4)
				Util.Debris:AddItem(clone4, 3.5)
				Util.Sound:Play("BF_TigerFt_TFM_X_Explode_02", clone4.Position)
				local clone5 = pillarAir:Clone()
				clone5.CFrame = clone3.CFrame
				Util.SetParentOverrideWithColor(clone5, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone5, 3.5)
				local ray3 = Util.Ray
				local v11 = clone3.Position + createVector(0, 2, 0)
				local v12 = { Workspace.Characters, Workspace.Enemies, folder }
				local v13, v14, _ = ray3(v11, createVector(-0, -35, -0), v12, false)

				if v13 ~= nil then
					local cframe = CFrame.new(v14)
					local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
					local clone6 = FX4:WaitForChild("TigerEffects").X_Untrans.BURN:Clone()
					local _, v15, _ = clone3.CFrame:ToOrientation()
					clone6.CFrame = cframe * CFrame.Angles(0, v15, 0)
					Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone6, 3.5)
					task.spawn(function()
						task.wait(0.15)
						emitAll(clone6)
					end)
				end

				task.spawn(function()
					task.wait(0.15)
					local ray4 = Util.Ray
					local v15 = projectilePart.Position + createVector(0, 2, 0)
					local v16 = { Workspace.Characters, Workspace.Enemies, folder }
					local v17, v18, v19 = ray4(v15, createVector(-0, -100, -0), v16, false)

					if v17 then
						local v20 = CFrame.new(v18, v18 + v19) * CFrame.Angles(-1.5707963267948966, 0, 0)
						local random = Random.new()

						for i = 1, 23 do
							local v22 = Rock2.new({
								Type = "Flying",
								FadeOut = { 0.25, 0.5 },
								FadeIn = { 0.25, 0.5 },
								Lifetime = { 1, 2.5 },
								Size = Vector3.new(
									random:NextNumber(1, 2),
									random:NextNumber(1, 2),
									random:NextNumber(1, 2)
								),
								Scale = { 3.8333333333333335, 7.666666666666667 }
							})
							local v23 = Vector3.new(
								math.sin(random:NextNumber(-0.5, 0.5) * 2 * 3.141592653589793) * 0.4,
								random:NextNumber(2.5, 3.95),
								math.cos(random:NextNumber(-0.5, 0.5) * 2 * 3.141592653589793) * 0.4
							).Unit + projectilePart.CFrame.LookVector * 1.75
							v22:Spawn(v20 * CFrame.Angles(0, 6.283185307179586 * (i / 23), 0) * CFrame.new(0, 0, -52.25))
							v22:Eject({
								Velocity = Util.Misc.Physics.Velocity(
									Vector3.new(),
									v23 * random:NextNumber(30.666666666666668, 76.66666666666667),
									Vector3.new(0, -Workspace.Gravity * random:NextNumber(1, 1.56), 0),
									0.25 + random:NextNumber(0, 2)
								),
								AngularVelocity = Vector3.new(
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1)
								) * 2 * 3.141592653589793 * (1 / v22.Scale)
							})
						end
					end
				end)

				if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 5510 then
					task.wait(0.1532)
					Util.CameraShaker:ShakeOnce(18, 15, 0.05, 0.75, createVector(1, 1, 1), createVector(1, 1, 1))
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					Util.SetParentOverrideWithColor(
						colorCorrectionEffect,
						game.Lighting,
						player,
						"LeopardFruitVFXColor"
					)
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
								FieldOfView = 110
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
						depthOfFieldEffect.FarIntensity = 0.3
						depthOfFieldEffect.FocusDistance = 54.82
						depthOfFieldEffect.InFocusRadius = 50
						depthOfFieldEffect.NearIntensity = 0.2
						Util.SetParentOverrideWithColor(
							depthOfFieldEffect,
							game.Lighting,
							player,
							"LeopardFruitVFXColor"
						)
						Util.Debris:AddItem(depthOfFieldEffect, 1.5)
						TweenService:Create(
							depthOfFieldEffect,
							TweenInfo.new(0.333, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
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
			else
				local WindBall2 = require(script.Parent:WaitForChild("Modules").WindBall2)

				if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 or (projectilePart == nil or projectilePart.Parent == nil) then
					return
				end

				task.spawn(function()
					if HRP.Parent == game.Players.LocalPlayer.Character then
						task.spawn(function()
							task.wait(0.12)
							Util.CameraShaker:ShakeOnce(7, 7, 0.05, 1.4, createVector(1, 1, 1), createVector(1, 1, 1))
							local clone = script.DOF:Clone()
							local Debris = game:GetService("Debris")
							Debris:AddItem(clone, 1)
							Util.SetParentOverrideWithColor(clone, game.Lighting, player, "LeopardFruitVFXColor")
							TweenService:Create(
								clone,
								TweenInfo.new(0.233, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
								{
									FarIntensity = 0,
									FocusDistance = 0,
									InFocusRadius = 0,
									NearIntensity = 0
								}
							):Play()
						end)
					end
				end)
				Util.Sound:Play("BF_TigerFt_TFM_X_Air_Launch_0" .. tostring(math.random(1, 3)), HRP)
				local v4 = Util.Sound:Play("BF_TigerFt_TFM_X_AirTravel_01", projectilePart)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(v4, TweenInfo.new(1), {
					Volume = 1
				}):Play()
				local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone = FX3:WaitForChild("TigerEffects").X_Untrans.hrpwind.HitXWindStart:Clone()
				local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone2 = FX4:WaitForChild("TigerEffects").X_Untrans.hrpwind.HitXWind:Clone()
				Util.SetParentOverrideWithColor(clone2, HRP, player, "LeopardFruitVFXColor")
				Util.SetParentOverrideWithColor(clone, HRP, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone2, 2)
				Util.Debris:AddItem(clone, 2)
				task.spawn(function()
					task.wait(0.134)
				end)
				task.spawn(function()
					task.spawn(function()
						if HRP.Parent == game.Players.LocalPlayer.Character then
							task.spawn(function()
								task.wait(0.12)
								Util.CameraShaker:ShakeOnce(
									9,
									9,
									0.05,
									0.7,
									createVector(1, 1, 1),
									createVector(1, 1, 1)
								)
								local clone3 = script.DOF:Clone()
								local Debris = game:GetService("Debris")
								Debris:AddItem(clone3, 1)
								Util.SetParentOverrideWithColor(clone3, game.Lighting, player, "LeopardFruitVFXColor")
								TweenService:Create(
									clone3,
									TweenInfo.new(0.333, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
									{
										FarIntensity = 0,
										FocusDistance = 0,
										InFocusRadius = 0,
										NearIntensity = 0
									}
								):Play()
								TweenService:Create(
									Workspace.Camera,
									TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
									{
										FieldOfView = 45
									}
								):Play()
								task.wait(0.05)
								TweenService:Create(
									Workspace.Camera,
									TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										FieldOfView = 85
									}
								):Play()
								task.wait(0.05)
								TweenService:Create(
									Workspace.Camera,
									TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
									{
										FieldOfView = 70
									}
								):Play()
							end)
						end
					end)
				end)
				local clone3 = xSpiral2:Clone()
				ScaleAttachmentsAndEmittersWithin(clone3, projectileSizeMult)
				clone3.CFrame = projectilePart.CFrame * CFrame.Angles(0, 0, -1.5707963267948966)
				Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
				destroyAfter(clone3, fliesFor + 4)
				local windSwirlWeld2 = clone3.WindSwirlWeld2
				task.spawn(function()
					local function spinWeld()
						for _ = 1, 35 do
							local tween = TweenService:Create(
								windSwirlWeld2,
								TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
								{
									C1 = windSwirlWeld2.C1 * CFrame.Angles(0, 15.707963267948966, 0)
								}
							)
							tween:Play()
							tween.Completed:Wait()
						end
					end

					spinWeld()
				end)
				task.spawn(function()
					task.wait(0.35)

					for _, beam in pairs(clone3:GetDescendants()) do
						if beam:IsA("Beam") then
							beam.Enabled = true
						end
					end
				end)
				local clone4 = FX2:WaitForChild("TigerEffects").X_Untrans.hrpwind.HitXWind:Clone()
				Util.SetParentOverrideWithColor(clone4, HRP, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone4, 2.5)
				task.spawn(function()
					task.wait(0.3)

					for _ = 1, 3 do
						emitAll(clone3.WindSwirl.spin)
						task.wait(0.075)
					end
				end)
				task.spawn(function()
					task.wait(0.65)
				end)
				heartbeatLoopFor2(fliesFor, function()
					clone3.CFrame += -clone3.CFrame.Position + projectilePart.CFrame.Position + createVector(0, 6, 0)
				end, function()
					for _, effect in ipairs(clone3:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
							continue
						end

						effect.Enabled = false
					end

					for _, descendant in ipairs(clone3:GetDescendants()) do
						if descendant:IsA("Decal") or descendant:IsA("Texture") then
							descendant.Transparency = 1
						end
					end
				end)
				local emitters = {}

				for _, emitter in ipairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						table.insert(emitters, emitter)
					end
				end

				local v5 = NumSeqMap.new(script.SizeGraph:GetAttribute("Sequence"), 60)
				local v6 = 1
				local v7 = false
				awaitHeartbeatLoopFor(fliesFor, function(_, _, p)
					local v8 = v5:GetValue(p) * 3.5
					local v9 = v8 / v6

					for _, v10 in ipairs(emitters) do
						ScaleParticle(v10, v9)
					end

					if v9 > 1.1 and v7 == false then
						local clone5 = xSpiralGround.XCharge:Clone()

						if transformedRig then
							clone5:SetAttribute("PlaybackSpeed", clone5:GetAttribute("PlaybackSpeed") * 0.9)
						end

						Util.UtilSoundWrapper.Play(clone5, clone3)
						v7 = true
					end

					v6 = v8
				end, function()
					local v8 = v5:GetValue(1) * 3.5 / v6

					for _, v9 in ipairs(emitters) do
						ScaleParticle(v9, v8)
					end
				end)

				if v4 then
					Util.Sound:FadeOut(v4, 0.2)
				end

				task.spawn(function()
					for _, beam in pairs(clone3:GetDescendants()) do
						if beam:IsA("Beam") then
							beam:Destroy()
						end
					end

					task.wait(2)
					clone3:Destroy()
				end)
				local clone5 = pillarAir2:Clone()
				clone5.CFrame = clone3.CFrame * CFrame.Angles(0, 0, 1.5707963267948966)
				Util.SetParentOverrideWithColor(clone5, folder, player, "LeopardFruitVFXColor")
				Util.Sound:Play("BF_TigerFt_TFM_X_Air_Explosion_02", clone5.Position)
				emitAll(clone5)
				Util.Debris:AddItem(clone5, 3.5)
				task.spawn(function()
					task.wait(0.25)
					local clone6 = FX2:WaitForChild("TigerEffects").WindBall:Clone()
					clone6.Size *= 0.7
					clone6.CFrame = CFrame.new(clone5.Position)
					Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
					WindBall2(
						player,
						clone6,
						FX2:WaitForChild("TigerEffects").WindBallFX,
						0.25,
						clone6.CFrame.Position,
						createVector(0, 360, 0),
						0
					)
				end)
				local ray2 = Util.Ray
				local v8 = projectilePart.Position + createVector(0, 2, 0)
				local v9 = { Workspace.Characters, Workspace.Enemies, folder }
				local v10, v11, _ = ray2(v8, createVector(-0, -16, -0), v9, false)

				if v10 ~= nil then
					local cframe = CFrame.new(v11)
					local clone6 = floor:Clone()
					clone6.CFrame = cframe
					Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
					emitAll(clone6)
					Util.Debris:AddItem(clone6, 3.5)
				end

				for _ = 1, 3 do
					task.spawn(function()
						task.wait(0.15)
						local clone6 = FX2:WaitForChild("TigerEffects").X_Untrans.PillarExplosionMesh:Clone()
						clone6.CFrame = clone5.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
						Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
						Util.Debris:AddItem(clone6, 2)
						TweenService:Create(
							clone6,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CFrame = clone6.CFrame * CFrame.new(0, 78, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
							}
						):Play()
						TweenService:Create(
							clone6.Mesh,
							TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Scale = createVector(20.852, 64.222, 20.037)
							}
						):Play()
						TweenService:Create(
							clone6.Decal,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
					end)
					task.wait(0.075)
				end
			end
		end
	end
end