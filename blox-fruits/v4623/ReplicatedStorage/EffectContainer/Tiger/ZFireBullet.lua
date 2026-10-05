local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fieryBullet = FX:WaitForChild("TigerEffects").Z_Untrans.FieryBullet
local bottom = FX:WaitForChild("TigerEffects").Z_Untrans.Bottom
local zFieryHand = FX:WaitForChild("TigerEffects").Z_Untrans.ZFieryHand
local fieryBulletTransformed = FX:WaitForChild("TigerEffects").Z_Trans.FieryBulletTransformed
local bottomTransformed = FX:WaitForChild("TigerEffects").Z_Trans.BottomTransformed
local fieryHandTransformed = FX:WaitForChild("TigerEffects").Z_Trans.FieryHandTransformed
local shockbubble = FX:WaitForChild("TigerEffects").Z_Trans.shockbubble
local _ = FX:WaitForChild("TigerEffects").Z_Trans.FireWind
local pillarExplosionMesh = FX:WaitForChild("TigerEffects").Z_Trans.PillarExplosionMesh
local windSwirlPop = FX:WaitForChild("TigerEffects").Z_Trans.WindSwirlPop
local spikeBack = FX:WaitForChild("TigerEffects").Z_Trans.SpikeBack
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
require(script.Parent.Modules:WaitForChild("DynamicDebris"))
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

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

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
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

local function ScaleAttachmentsAndEmittersWithin(folder, fieryBulletSizeMult: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= fieryBulletSizeMult
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, fieryBulletSizeMult)
		end
	end
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
	local hrp = data.hrp
	local projectilePart = data.projectilePart
	local explodesAfter = data.explodesAfter
	local fieryBulletSizeMult = data.fieryBulletSizeMult
	local transformed = data.transformed
	local fury = data.fury
	local currentCamera = Workspace.CurrentCamera

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local position = hrp.Position

	if (position - currentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if projectilePart then
		projectilePart.CanCollide = false
	end

	local folder = Instance.new("Folder", Workspace._WorldOrigin)
	Util.Debris:AddItem(folder, 15)

	if transformed == false then
		task.spawn(function()
			task.wait(0.1)

			if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 310 then
				Util.CameraShaker:ShakeOnce(7, 7, 0.05, 0.35)
				task.spawn(function()
					local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
					depthOfFieldEffect:AddTag("FastModeDepthOfField")
					depthOfFieldEffect.FarIntensity = 1
					depthOfFieldEffect.FocusDistance = 50
					depthOfFieldEffect.InFocusRadius = 0
					depthOfFieldEffect.NearIntensity = 0
					Util.SetParentOverrideWithColor(depthOfFieldEffect, game.Lighting, player, "LeopardFruitVFXColor")
					TweenService:Create(
						depthOfFieldEffect,
						TweenInfo.new(0.033, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
						{
							FarIntensity = 0.18,
							FocusDistance = 45.84,
							InFocusRadius = 0,
							NearIntensity = 0.018
						}
					):Play()
					task.wait(0.033)
					TweenService:Create(
						depthOfFieldEffect,
						TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
						{
							FarIntensity = 0,
							FocusDistance = 0,
							InFocusRadius = 0,
							NearIntensity = 0
						}
					):Play()
					task.wait(0.4)
					depthOfFieldEffect:Destroy()
				end)
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Name = "LeopardZBloom"
				bloomEffect.Intensity = 0.7
				bloomEffect.Threshold = 0.2
				bloomEffect.Size = 14
				Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "LeopardFruitVFXColor")
				heartbeatLoopFor2(0.1, function(_, _, p)
					bloomEffect.Intensity = 4 - 4 * p
					bloomEffect.Threshold = 0.4 + 0.6 * p
					bloomEffect.Size = 25 - 25 * p
				end, function()
					bloomEffect:Destroy()
				end)
			end
		end)

		if hrp.Parent:FindFirstChild("RightHand") then
			local clone = zFieryHand:Clone()
			local pointToWorldSpace = hrp.CFrame:PointToWorldSpace(createVector(1.5883179, 0.8143921, -1.8314514))
			clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), projectilePart.CFrame.LookVector) * CFrame.lookAt(
				createVector(0, 0, 0),
				createVector(-1, -0, -0)
			):Inverse() + pointToWorldSpace
			Util.SetParentOverrideWithColor(clone, game.Workspace, player, "LeopardFruitVFXColor")
			destroyAfter(clone, 2)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end

		if projectilePart == nil or projectilePart.Parent == nil then
			return
		end

		local clone = fieryBullet:Clone()
		local clone2 = bottom:Clone()
		ScaleAttachmentsAndEmittersWithin(clone, fieryBulletSizeMult)
		local clone3 = clone.Attachment0:Clone()
		local clone4 = clone.Attachment1:Clone()
		local clone5 = clone.FX:Clone()
		local clone6 = clone.HitFX:Clone()
		local clone7 = clone.Push:Clone()
		local clone8 = clone.Start:Clone()
		local clone9 = clone.Explosion2:Clone()
		local clone10 = clone.Stars:Clone()
		local clone11 = clone.THROW:Clone()

		for _, child in ipairs(clone3:GetChildren()) do
			child.Attachment0 = clone3
			child.Attachment1 = clone4
		end

		local clone12 = clone.A0:Clone()
		local clone13 = clone.A1:Clone()
		local groundTrail = clone12.GroundTrail
		local groundTrail2 = clone12.GroundTrail
		groundTrail.Attachment0 = clone12
		groundTrail2.Attachment1 = clone13
		heartbeatLoopFor2(explodesAfter, function()
			local ray = Util.Ray
			local v = projectilePart.Position + createVector(0, 2, 0)
			local v2 = {
				Workspace.Characters,
				Workspace.Enemies,
				folder,
				projectilePart
			}
			local v3, v4, _ = ray(v, createVector(-0, -6, -0), v2, false)

			if v3 == nil and clone12.GroundTrail.Enabled == true then
				clone12.GroundTrail.Enabled = false
				return
			end

			if v3 ~= nil and clone12.GroundTrail.Enabled == false then
				clone12.GroundTrail.Enabled = true
			end

			clone12.WorldPosition = clone12.WorldPosition * createVector(1, 0, 1) + (v4.Y + 0.1) * createVector(0, 1, 0)
			clone13.WorldPosition = clone13.WorldPosition * createVector(1, 0, 1) + (v4.Y + 0.1) * createVector(0, 1, 0)
		end)
		Util.SetParentOverrideWithColor(clone3, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone4, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone5, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone6, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone8, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone9, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone7, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone10, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone11, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone12, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone13, projectilePart, player, "LeopardFruitVFXColor")
		local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone14 = FX2:WaitForChild("TigerEffects").Z_Untrans.Throw.Attachment:Clone()
		emitAll(clone11)
		Util.SetParentOverrideWithColor(clone14, hrp, player, "LeopardFruitVFXColor")
		emitAll(clone14)
		Util.Debris:AddItem(clone14, 5)
		Util.Sound:Play("TigerFt_Z_Launch_Finisher_01", projectilePart)
		task.spawn(function()
			task.wait(0.1)
			emitAll(clone8)

			for _ = 1, 15 do
				task.wait(0.025)
				emitAll(clone7)
				CFrame.new(projectilePart.Position)
			end
		end)
		task.wait(explodesAfter + 0.125)

		for _ = 1, 100 do
			if projectilePart:FindFirstChild("Stopped") then
				break
			else
				task.wait()
			end
		end

		if not projectilePart:FindFirstChild("Stopped") then
			return
		end

		local cFrame = projectilePart.Stopped.Value
		projectilePart.Anchored = true
		projectilePart.CFrame = cFrame
		Util.Sound:Play("TigerFt_Z_Explosion_01", cFrame.Position)
		task.spawn(function()
			clone10:Emit(15)
			task.wait(0.1)
			emitAll(clone6)
			clone9:Emit(20)
			task.spawn(function()
				task.wait(0.085)

				for i = 1, 8 do
					local v = i
					task.spawn(function()
						if 20 % v ~= 0 then
							local v2 = CFrame.new(projectilePart.Position) * CFrame.new(0, 0, -math.random(5, 14)) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							)
							task.spawn(function()
								local cframe = CFrame.new(v2.p)
								local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
								windRibbon(
									player,
									cframe,
									1.4,
									3,
									folder,
									FX3:WaitForChild("TigerEffects").WINDRIBBONS.Ribbon:Clone()
								)
								local cframe2 = CFrame.new(v2.p)
								local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
								windRibbon(
									player,
									cframe2,
									4,
									5.7,
									folder,
									FX4:WaitForChild("TigerEffects").WINDRIBBONS.RibbonFire2:Clone()
								)
							end)
						end
					end)
				end
			end)

			for _, child in ipairs(clone3:GetChildren()) do
				child.Enabled = false
			end

			enableAll(projectilePart, false)

			if (cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 150 * fieryBulletSizeMult or (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 300 * fieryBulletSizeMult then
				Util.CameraShaker:ShakeOnce(25, 25, 0.05, 0.75)
				task.spawn(function()
					local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
					depthOfFieldEffect:AddTag("FastModeDepthOfField")
					depthOfFieldEffect.FarIntensity = 1
					depthOfFieldEffect.FocusDistance = 50
					depthOfFieldEffect.InFocusRadius = 0
					depthOfFieldEffect.NearIntensity = 0
					Util.SetParentOverrideWithColor(depthOfFieldEffect, game.Lighting, player, "LeopardFruitVFXColor")
					TweenService:Create(
						depthOfFieldEffect,
						TweenInfo.new(0.033, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
						{
							FarIntensity = 0.18,
							FocusDistance = 45.84,
							InFocusRadius = 0,
							NearIntensity = 0.018
						}
					):Play()
					task.wait(0.033)
					TweenService:Create(
						depthOfFieldEffect,
						TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In),
						{
							FarIntensity = 0,
							FocusDistance = 0,
							InFocusRadius = 0,
							NearIntensity = 0
						}
					):Play()
					task.wait(0.4)
					depthOfFieldEffect:Destroy()
				end)
				local bloomEffect = Instance.new("BloomEffect")
				bloomEffect.Name = "LeopardZBloom"
				bloomEffect.Intensity = 0.7
				bloomEffect.Threshold = 0.2
				bloomEffect.Size = 14
				Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "LeopardFruitVFXColor")
				heartbeatLoopFor2(0.1, function(_, _, p)
					bloomEffect.Intensity = 4 - 4 * p
					bloomEffect.Threshold = 0.4 + 0.6 * p
					bloomEffect.Size = 25 - 25 * p
				end, function()
					bloomEffect:Destroy()
				end)
			end

			local ray = Util.Ray
			local v = cFrame.Position + createVector(0, 2, 0)
			local v2 = { Workspace.Characters, Workspace.Enemies, folder }
			local v3, v4, _ = ray(v, createVector(-0, -16, -0), v2, false)

			if v3 ~= nil then
				local cframe = CFrame.new(v4)
				local _ = createVector(100, 0.05, 100) * fieryBulletSizeMult
				clone2.CFrame = cframe
				Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
				emitAll(clone2)
				Util.Debris:AddItem(clone2, 3.5)
				task.spawn(function()
					local ray2 = Util.Ray
					local v5 = clone2.Position + createVector(0, 2, 0)
					local v6 = { Workspace.Characters, Workspace.Enemies, folder }
					local v7, v8, v9 = ray2(v5, createVector(-0, -100, -0), v6, false)

					if v7 then
						local v10 = CFrame.new(v8, v8 + v9) * CFrame.Angles(-1.5707963267948966, 0, 0)
						local random = Random.new()

						for i = 1, 30 do
							local v11 = 6.283185307179586 * (i / 30)
							local v12 = Rock2.new({
								Type = "Ground",
								FadeOut = { 0.25, 0.5 },
								FadeIn = { 0.25, 0.5 },
								Lifetime = { 1, 2.5 },
								Size = Vector3.new(
									random:NextNumber(1, 2),
									random:NextNumber(1, 2),
									random:NextNumber(1, 2)
								),
								Scale = { 2.5, 5 }
							})

							if random:NextInteger(1, 8) % 4 == 0 then
								local unit = Vector3.new(
									math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
									random:NextNumber(0, 1) * 1.25,
									math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
								).Unit
								v12.Type = "Flying"
								v12:Spawn(v10 * CFrame.Angles(0, v11, 0) * CFrame.new(0, 0, -22.5))
								v12:Eject({
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
									) * 2 * 3.141592653589793 * (1 / v12.Scale)
								})
							else
								v12:Spawn(v10 * CFrame.Angles(0, v11, 0) * CFrame.new(0, 0, -22.5))
								v12:TweenShift(
									(v10 * CFrame.Angles(0, v11, 0)).LookVector * 10 * random:NextNumber(1, 2),
									0.25
								)
							end
						end
					end
				end)
			end
		end)
	elseif transformed == true then
		task.spawn(function()
			if hrp.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(12, 13, 0.05, 1, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
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
						TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 119, 0),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = -1,
							Saturation = -1,
							Contrast = 8
						}
					):Play()
					task.wait(0.02)
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

		if hrp.Parent:FindFirstChild("RightHand") then
			local clone = fieryHandTransformed:Clone()
			local pointToWorldSpace = hrp.CFrame:PointToWorldSpace(createVector(1.5883179, 0.8143921, -1.8314514))
			clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), projectilePart.CFrame.LookVector) * CFrame.lookAt(
				createVector(0, 0, 0),
				createVector(-1, -0, -0)
			):Inverse() + pointToWorldSpace
			Util.SetParentOverrideWithColor(clone, game.Workspace, player, "LeopardFruitVFXColor")
			destroyAfter(clone, 2)

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end

		if projectilePart == nil or projectilePart.Parent == nil then
			return
		end

		local clone = fieryBulletTransformed:Clone()
		local clone2 = bottomTransformed:Clone()
		ScaleAttachmentsAndEmittersWithin(clone, fieryBulletSizeMult)
		local clone3 = clone.Attachment0:Clone()
		local clone4 = clone.Attachment1:Clone()
		local clone5 = clone.FX:Clone()
		local clone6 = clone.HitFX:Clone()
		local clone7 = clone.PrePop:Clone()
		local clone8 = clone.Push:Clone()

		for _, child in ipairs(clone3:GetChildren()) do
			child.Attachment0 = clone3
			child.Attachment1 = clone4
		end

		local clone9 = clone.A0:Clone()
		local clone10 = clone.A1:Clone()
		local groundTrail = clone9.GroundTrail
		local groundTrail2 = clone9.GroundTrail
		groundTrail.Attachment0 = clone9
		groundTrail2.Attachment1 = clone10
		heartbeatLoopFor2(explodesAfter, function()
			local ray = Util.Ray
			local v = projectilePart.Position + createVector(0, 2, 0)
			local v2 = {
				Workspace.Characters,
				Workspace.Enemies,
				folder,
				projectilePart
			}
			local v3, v4, _ = ray(v, createVector(-0, -6, -0), v2, false)

			if v3 == nil and clone9.GroundTrail.Enabled == true then
				clone9.GroundTrail.Enabled = false
				return
			end

			if v3 ~= nil and clone9.GroundTrail.Enabled == false then
				clone9.GroundTrail.Enabled = true
			end

			clone9.WorldPosition = clone9.WorldPosition * createVector(1, 0, 1) + (v4.Y + 0.1) * createVector(0, 1, 0)
			clone10.WorldPosition = clone10.WorldPosition * createVector(1, 0, 1) + (v4.Y + 0.1) * createVector(0, 1, 0)
		end)
		Util.SetParentOverrideWithColor(clone3, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone4, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone5, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone6, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone7, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone8, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone9, projectilePart, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone10, projectilePart, player, "LeopardFruitVFXColor")
		Util.Sound:Play("BF_TigerFt_TFM_Z_LaunchFinisher_01", projectilePart)
		task.spawn(function()
			for _ = 1, 8 do
				task.spawn(function()
					local clone11 = spikeBack:Clone()
					clone11.CFrame = projectilePart.CFrame * CFrame.Angles(0, 1.5707963267948966, 3.141592653589793)
					Util.SetParentOverrideWithColor(clone11, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone11, 2)
					TweenService:Create(
						clone11,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							CFrame = clone11.CFrame
						}
					):Play()
					TweenService:Create(
						clone11.Mesh,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							Scale = createVector(1.802, 1.4, 1.4)
						}
					):Play()
					TweenService:Create(
						clone11.Decal,
						TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.wait(0.1)
			end
		end)
		local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone11 = FX2:WaitForChild("TigerEffects").Z_Trans.FieryBulletTransformed.TrailRotate:Clone()
		local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone12 = FX3:WaitForChild("TigerEffects").Z_Trans.FieryBulletTransformed.TrailRotateweld:Clone()
		Util.SetParentOverrideWithColor(clone11, folder, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone12, clone11, player, "LeopardFruitVFXColor")
		clone12.Part0 = projectilePart
		clone12.Part1 = clone11
		local C0 = clone12.C0
		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			local v = os.clock() - lastTime

			if explodesAfter <= os.clock() - lastTime then
				heartbeatConnection:Disconnect()
				task.spawn(function()
					task.wait(0.5)
					clone11:Destroy()
				end)
			end

			local v3 = v * 30
			clone12.C0 = C0 * CFrame.Angles(0, 0, v3)
		end)

		if fury == true then
			task.spawn(function()
				task.wait(0.12)
				local clone13 = clone.FlowFire:Clone()
				Util.SetParentOverrideWithColor(clone13, projectilePart, player, "LeopardFruitVFXColor")
			end)
		end

		task.spawn(function()
			task.wait(explodesAfter)
			emitAll(clone7)
		end)
		task.wait(explodesAfter + 0.125)

		for _ = 1, 100 do
			if projectilePart:FindFirstChild("Stopped") then
				break
			else
				task.wait()
			end
		end

		if not projectilePart:FindFirstChild("Stopped") then
			return
		end

		local cFrame = projectilePart.Stopped.Value
		projectilePart.Anchored = true
		projectilePart.CFrame = cFrame
		Util.Sound:Play("BF_TigerFt_TFM_Z_Finisher_Explosion_01", cFrame.Position)
		emitAll(clone6)
		task.spawn(function()
			for _ = 1, 9 do
				task.spawn(function()
					local clone13 = pillarExplosionMesh:Clone()
					clone13.CFrame = projectilePart.CFrame * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					Util.SetParentOverrideWithColor(clone13, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone13, 2)
					TweenService:Create(
						clone13,
						TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{
							CFrame = clone13.CFrame * CFrame.new(0, 15, 0) * CFrame.Angles(
								math.rad((math.random(-360, -360))),
								math.rad((math.random(-360, -360))),
								(math.rad((math.random(-360, -360))))
							)
						}
					):Play()
					TweenService:Create(
						clone13.Mesh,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Scale = createVector(50.852, 94.222, 50.037)
						}
					):Play()
					TweenService:Create(
						clone13.Decal,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.wait(0.025)
			end
		end)

		for _, child in ipairs(clone3:GetChildren()) do
			child.Enabled = false
		end

		enableAll(projectilePart, false)
		local clone13 = shockbubble:Clone()
		clone13.CFrame = projectilePart.CFrame
		Util.SetParentOverrideWithColor(clone13, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone13, 0.5)
		TweenService:Create(clone13, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Size = createVector(120, 120, 120),
			Transparency = 1
		}):Play()

		if (cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 * fieryBulletSizeMult or (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 * fieryBulletSizeMult then
			Util.CameraShaker:ShakeOnce(25, 25, 0.05, 0.35)
			local bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Name = "LeopardZBloom"
			bloomEffect.Intensity = 0.7
			bloomEffect.Threshold = 0.2
			bloomEffect.Size = 24
			Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "LeopardFruitVFXColor")
			heartbeatLoopFor2(0.4, function(_, _, p)
				bloomEffect.Intensity = 2 - 2 * p
				bloomEffect.Threshold = 0.4 + 0.6 * p
				bloomEffect.Size = 35 - 35 * p
			end, function()
				bloomEffect:Destroy()
			end)
		end

		local ray = Util.Ray
		local v = cFrame.Position + createVector(0, 2, 0)
		local v2 = { Workspace.Characters, Workspace.Enemies, folder }
		local v3, v4, _ = ray(v, createVector(-0, -16, -0), v2, false)

		if v3 ~= nil then
			local cframe = CFrame.new(v4)
			local _ = createVector(100, 0.05, 100) * fieryBulletSizeMult
			clone2.CFrame = cframe
			Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 3.5)
			task.spawn(function()
				task.wait(0.085)
				local clone14 = windSwirlPop:Clone()
				clone14.CFrame = projectilePart.CFrame * CFrame.Angles(3.141592653589793, 0, 0)
				Util.SetParentOverrideWithColor(clone14, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone14, 1)
				TweenService:Create(clone14, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone14.CFrame * CFrame.new(0, 54, 0) * CFrame.Angles(0, 2.8797932657906435, 0)
				}):Play()
				TweenService:Create(
					clone14.Mesh,
					TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Scale = createVector(133, 113, 133)
					}
				):Play()
				TweenService:Create(
					clone14.Decal,
					TweenInfo.new(0.185, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Transparency = 1
					}
				):Play()
			end)
			task.spawn(function()
				local ray2 = Util.Ray
				local v5 = clone2.Position + createVector(0, 2, 0)
				local v6 = { Workspace.Characters, Workspace.Enemies, folder }
				local v7, v8, v9 = ray2(v5, createVector(-0, -100, -0), v6, false)

				if v7 then
					local v10 = CFrame.new(v8, v8 + v9) * CFrame.Angles(-1.5707963267948966, 0, 0)
					local random = Random.new()

					for i = 1, 42 do
						local v11 = 6.283185307179586 * (i / 42)
						local v12 = Rock2.new({
							Type = "Ground",
							FadeOut = { 0.25, 0.5 },
							FadeIn = { 0.25, 0.5 },
							Lifetime = { 1, 2.5 },
							Size = Vector3.new(
								random:NextNumber(1, 2),
								random:NextNumber(1, 2),
								random:NextNumber(1, 2)
							),
							Scale = { 3.5, 7 }
						})

						if random:NextInteger(1, 8) % 4 == 0 then
							local unit = Vector3.new(
								math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
								random:NextNumber(0, 1) * 1.25,
								math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
							).Unit
							v12.Type = "Flying"
							v12:Spawn(v10 * CFrame.Angles(0, v11, 0) * CFrame.new(0, 0, -31.5))
							v12:Eject({
								Velocity = Util.Misc.Physics.Velocity(
									Vector3.new(),
									unit * random:NextNumber(28, 112),
									Vector3.new(0, -Workspace.Gravity * random:NextNumber(0.25, 1), 0),
									0.25 + random:NextNumber(0, 2)
								),
								AngularVelocity = Vector3.new(
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1),
									random:NextNumber(-1, 1)
								) * 2 * 3.141592653589793 * (1 / v12.Scale)
							})
						else
							v12:Spawn(v10 * CFrame.Angles(0, v11, 0) * CFrame.new(0, 0, -31.5))
							v12:TweenShift(
								(v10 * CFrame.Angles(0, v11, 0)).LookVector * 14 * random:NextNumber(1, 2),
								0.25
							)
						end
					end
				end
			end)
		end
	end
end