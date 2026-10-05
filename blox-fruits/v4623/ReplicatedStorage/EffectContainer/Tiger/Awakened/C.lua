local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tigerEffects = FX:WaitForChild("TigerEffects")
require(script.Parent.Parent.Modules.Beziers)
local TweenService = game:GetService("TweenService")
local heartbeatLoopFor = Util.HeartbeatLoopFor.HeartbeatLoopFor
local _ = Util.Sound
local _ = Util.DestroyAfter
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local RockRipple = require(script.Parent.Parent.Modules.RockRipple)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
require(script.Parent.Parent.Modules.SwirlsC)

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

function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local v2 = p or folder:GetPivot().Position
	local v3 = modelScale / v

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local v4 = part.CFrame - position
		local v5 = position - v2
		part.Size *= Vector3.new(v3, v3, v3)
		part.CFrame = v4 + v2 + v5 * v3
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local function randPointHalfCircle(p)
	local v = p * math.sqrt((math.random()))
	local v2 = 3.141592653589793 * math.random()
	return (Vector3.new(math.cos(v2) * v, math.sin(v2) * v, 0))
end

return function(data)
	local player = data.player
	local origin = data.Origin or data.hrp and data.hrp.Position

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage
	local rigModel = data.RigModel
	local root = data.Root or data.hrp

	if stage == 1 then
		task.spawn(function()
			if root.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(2, 8, 0.05, 0.4, createVector(1, 1, 1), createVector(0.9, 0.9, 0.9))
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				Util.SetParentOverrideWithColor(colorCorrectionEffect, game.Lighting, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(colorCorrectionEffect, 0.3)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(177, 52, 255),
							player,
							"LeopardFruitVFXColor"
						),
						Brightness = -0.2,
						Saturation = -0.2,
						Contrast = 3
					}
				):Play()
				task.wait(0.05)
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
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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
			end
		end)
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder", _WorldOrigin)
		local clone = tigerEffects.PART_TEMPLATE:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		local heartbeatConnection = nil

		if rigModel then
			local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone2 = FX2:WaitForChild("TigerEffects").C_Awak.Holding.LHand:Clone()
			Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
			clone2.RigidConstraint.Attachment0 = clone2.Attachment
			clone2.RigidConstraint.Attachment1 = rigModel.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.L"]["HandIK.L"]["Hand.L"]["Middle.L"]
			local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone3 = FX3:WaitForChild("TigerEffects").C_Awak.Holding.RHand:Clone()
			Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
			clone3.RigidConstraint.Attachment0 = clone3.Attachment
			clone3.RigidConstraint.Attachment1 = rigModel.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]["Middle.R"]
			emitAll(clone3)
			emitAll(clone2)
			local RunService = game:GetService("RunService")
			heartbeatConnection = RunService.Heartbeat:Connect(function(_)
				if root and root:FindFirstChild("UsedTigerUltimate") then
					heartbeatConnection:Disconnect()
				end
			end)
		end

		repeat
			task.wait()
			clone.CFrame = root.CFrame
		until not (holding.Value and holding)

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		task.delay(0.05, function()
			folder:Destroy()
		end)
	elseif stage == 2 then
		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 20)

		if not data.transformedRig then
			return
		end

		local origin2 = data.origin
		local fireDir = data.fireDir
		local _ = data.forwardCylinderRadius
		local forwardCylinderLength = data.forwardCylinderLength
		local endsAfter = data.endsAfter
		local tigerAwakenedCloneLoop = Util.Anims:Get(data.transformedRig, "TigerAwakenedClone_Loop")
		tigerAwakenedCloneLoop:Play()
		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.Size = createVector(5, 5, 5)
		Util.SetParentOverrideWithColor(part, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(part, endsAfter + 0.2)
		Util.Sound:Play("BF_TigerFt_AWK_C_BuildupSlashes_0" .. tostring(math.random(1, 2)), root)
		task.spawn(function()
			while part:IsDescendantOf(workspace) do
				if not data.transformedRig:IsDescendantOf(workspace) then
					part:Destroy()
					break
				end

				local torso2 = data.transformedRig.RootPart.Controller:FindFirstChild("Torso1", true):FindFirstChild(
					"Torso2",
					true
				)

				if torso2 then
					part.CFrame = torso2.WorldCFrame
				end

				task.wait()
			end
		end)
		local connection = tigerAwakenedCloneLoop:GetMarkerReachedSignal("Flashstep"):Connect(function()
			local _ = part.CFrame
			local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone = FX2:WaitForChild("TigerEffects").C_Awak.TPFourth:Clone()
			clone.CFrame = part.CFrame * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
			emitAll(clone)
			Util.Debris:AddItem(clone, 1.5)
			local ray = Util.Ray
			local v = root.Position + createVector(0, 2, 0)
			local v2 = {
				workspace.Characters,
				workspace.Enemies,
				_WorldOrigin,
				folder
			}
			local v3, v4, _ = ray(v, createVector(-0, -120, -0), v2, false)

			if v3 ~= nil then
				local cframe = CFrame.new(v4) or data.impactCF
				local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
				local clone2 = FX3:WaitForChild("TigerEffects").C_Awak.TPSlashGround:Clone()
				clone2.CFrame = cframe * CFrame.new(math.random(-15, 15), 0, math.random(-15, 15)) * CFrame.Angles(
					0,
					math.rad((math.random(-360, 360))),
					0
				)
				Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
				emitAll(clone2)
				Util.Debris:AddItem(clone2, 1.5)
				clone2.FloorPushSmoke.Color = ColorSequence.new(v3.Color)
			end
		end)
		local v = {}

		for _, effect in pairs(data.transformedRig.VFX:GetDescendants()) do
			if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) and effect.Enabled) then
				continue
			end

			effect:SetAttribute("WasEnabled", true)
			effect.Enabled = false
			v[effect] = true
		end

		task.delay(endsAfter, function()
			for k, _ in pairs(v) do
				k.Enabled = true
				k:SetAttribute("WasEnabled", nil)
			end
		end)
		local position = root.Position
		local connection2 = nil
		connection2 = heartbeatLoopFor(endsAfter, function(_, _, p)
			local v2 = p * forwardCylinderLength
			local cFrame = CFrame.lookAt(origin2, origin2 + fireDir) * CFrame.new(0, 0, -v2)
			local ray, _, _ = Util.Ray(
				position,
				cFrame.Position - position,
				{ workspace.Characters, workspace.Enemies, _WorldOrigin },
				false
			)

			if ray == nil then
				local player2 = data.player
				local Players = game:GetService("Players")

				if player2 == Players.LocalPlayer then
					root.CFrame = cFrame
				end

				position = cFrame.Position
			else
				connection2:Disconnect()
				connection2 = nil
			end
		end)
		task.delay(endsAfter, function()
			if connection then
				connection:Disconnect()
			end

			tigerAwakenedCloneLoop:Stop()
			local position2 = root.Position
			local position3 = root.Position
			local connection3 = nil
			local timeUntilFinalBlast = data.timeUntilFinalBlast
			Util.Anims:Get(data.transformedRig, "TigerAwakenedCSlam"):Play()
			connection3 = heartbeatLoopFor(timeUntilFinalBlast, function(_, _, p)
				local cFrame

				if p < 0.75 then
					local v3 = (p / 0.75) ^ 0.5
					cFrame = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -p * 45) * CFrame.Angles(
						-1.0995574287564276 * v3,
						0,
						0
					) + Vector3.new(0, 45 * v3 * (2 - v3), 0)
				else
					local v3 = (p - 0.75) / 0.25
					cFrame = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -p * 45) * CFrame.Angles(
						-1.7278759594743864,
						0,
						0
					) + Vector3.new(0, 45 * (1 - v3), 0)
				end

				local ray, _, _ = Util.Ray(
					position3,
					cFrame.Position - position3,
					{ workspace.Characters, workspace.Enemies, _WorldOrigin },
					false
				)

				if ray == nil then
					root.CFrame = cFrame
					position3 = cFrame.Position
				else
					connection3:Disconnect()
					connection3 = nil
				end
			end, function()
				local cFrame = CFrame.lookAt(position2, position2 + fireDir) * CFrame.new(0, 0, -45)
				local ray, _, _ = Util.Ray(
					position3,
					cFrame.Position - position3,
					{ workspace.Characters, workspace.Enemies, _WorldOrigin },
					false
				)

				if ray == nil then
					root.CFrame = cFrame
					position3 = cFrame.Position
				else
					connection3:Disconnect()
					connection3 = nil
				end
			end)
		end)
		task.spawn(function()
			local tigerRig = root.Parent.TigerRig:FindFirstChild("TigerRig")
			task.wait(endsAfter + data.timeUntilFinalBlast - 0.45)
			local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone = FX2:WaitForChild("TigerEffects").C_Awak.RHand:Clone()
			Util.SetParentOverrideWithColor(clone, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
			clone.RigidConstraint.Attachment0 = clone.Attachment
			clone.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]["Middle.R"]
			emitAll(clone)
			TweenService:Create(
				clone.Light.PointLight,
				TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Brightness = 0
				}
			):Play()
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(
						12,
						13,
						0.05,
						1,
						createVector(1.4, 1.6, 1.6),
						createVector(0.9, 0.9, 0.9)
					)
					task.spawn(function()
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								FieldOfView = 107
							}
						):Play()
						task.wait(0.15)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
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
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(197, 65, 255),
									player,
									"LeopardFruitVFXColor"
								),
								Brightness = -1,
								Saturation = -1,
								Contrast = 8
							}
						):Play()
						task.wait(0.15)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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
						task.wait(0.15)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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
		end)
		task.wait(endsAfter + data.timeUntilFinalBlast)
		local _ = data.willExecute
		local _ = root.Position
		Util.Sound:Play("BF_TigerFt_AWK_C_Explode_01", root)
		task.spawn(function()
			if (origin2 - workspace.CurrentCamera.CFrame.Position).Magnitude < 310 then
				task.wait(0.05)
				Util.CameraShaker:ShakeOnce(26, 23, 0.05, 1.2, createVector(1, 1, 1), createVector(1, 1, 1))
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
						workspace.Camera,
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 90
						}
					):Play()
					task.wait(0.05)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					task.wait(0.1532)
					local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
					depthOfFieldEffect:AddTag("FastModeDepthOfField")
					depthOfFieldEffect.FarIntensity = 0.8
					depthOfFieldEffect.FocusDistance = 54.82
					depthOfFieldEffect.InFocusRadius = 50
					depthOfFieldEffect.NearIntensity = 0.4
					Util.SetParentOverrideWithColor(depthOfFieldEffect, game.Lighting, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(depthOfFieldEffect, 1.5)
					TweenService:Create(
						depthOfFieldEffect,
						TweenInfo.new(1.133, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
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
		local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone = FX2:WaitForChild("TigerEffects").C_Awak.CSlamLift2:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, -4, 0)
		clone.Orientation = createVector(0, 0, 0)
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 3.5)
		local ray = Util.Ray
		local v2 = root.Position + createVector(0, 2, 0)
		local v3 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
		local v4, v5, v6 = ray(v2, createVector(-0, -40, -0), v3, false)

		if v4 ~= nil then
			local cframe = CFrame.new(v5) or data.impactCF
			local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone2 = FX3:WaitForChild("TigerEffects").C_Awak.CSlamFloor:Clone()
			clone2.CFrame = cframe
			Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 4.5)
			task.spawn(function()
				task.wait(2.5)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)

			for _ = 1, 9 do
				task.spawn(function()
					local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
					local clone3 = FX4:WaitForChild("TigerEffects").C_Awak.PillarExplosionMesh:Clone()
					clone3.CFrame = clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone3, 2)
					TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						CFrame = clone3.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
					}):Play()
					TweenService:Create(
						clone3.Mesh,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Scale = createVector(34.852, 94.222, 34.037)
						}
					):Play()
					TweenService:Create(
						clone3.Decal,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.wait(0.015)
			end

			task.spawn(function()
				local part2 = Instance.new("Part")
				part2.Name = "BAMPROCK"
				part2.CanTouch = false
				part2.CanQuery = false
				part2.CanCollide = false
				part2.Anchored = true
				RockRipple.createRippleEffect(part2, v5, 12, 5, 4, 3)
			end)
			local v7 = CFrame.new(v5, v5 + v6) * CFrame.Angles(-1.5707963267948966, 0, 0)
			local random = Random.new()

			for i = 1, 45 do
				local v8 = 6.283185307179586 * (i / 45)
				local v9 = Rock2.new({
					Type = "Ground",
					FadeOut = { 0.25, 0.5 },
					FadeIn = { 0.25, 0.5 },
					Lifetime = { 1, 2.5 },
					Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
					Scale = { 3.75, 7.5 }
				})

				if random:NextInteger(1, 20) % 4 == 0 then
					local unit = Vector3.new(
						math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
						random:NextNumber(0, 1) * 1.25,
						math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
					).Unit
					v9.Type = "Flying"
					v9:Spawn(v7 * CFrame.Angles(0, v8, 0) * CFrame.new(0, 0, -34.199999999999996))
					v9:Eject({
						Velocity = Util.Misc.Physics.Velocity(
							Vector3.new(),
							unit * random:NextNumber(30, 120),
							Vector3.new(0, -workspace.Gravity * random:NextNumber(0.25, 1), 0),
							0.25 + random:NextNumber(0, 2)
						),
						AngularVelocity = Vector3.new(
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1),
							random:NextNumber(-1, 1)
						) * 2 * 3.141592653589793 * (1 / v9.Scale)
					})
				else
					v9:Spawn(v7 * CFrame.Angles(0, v8, 0) * CFrame.new(0, 0, -34.199999999999996))
					v9:TweenShift((v7 * CFrame.Angles(0, v8, 0)).LookVector * 15 * random:NextNumber(1, 2), 0.25)
				end
			end

			local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
			local groundSpike = FX4:WaitForChild("TigerEffects").C_Awak.GroundSpike

			for i = 0, 20 do
				local number = random:NextNumber(i * 2 * 3.141592653589793 / 21, (i + 1) * 2 * 3.141592653589793 / 21)
				local v8 = math.random()
				local v9 = 22 + 16 * v8
				local clone3 = groundSpike:Clone()
				local v10 = 1.4 + 1.4 * v8
				ScaleModel(clone3, v10)
				local v11 = cframe * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v9) * CFrame.Angles(
					-math.rad(20 + 25 * v8),
					0,
					0
				) * CFrame.new(0, -26 * v10, 0)
				clone3:PivotTo(v11)
				Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone3, 6)
				task.spawn(function()
					TweenService:Create(
						clone3.lavaGradient.Spike,
						TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Color = Util.WrapColor3Constructor(
								Color3.fromRGB(202, 87, 42),
								player,
								"LeopardFruitVFXColor"
							)
						}
					):Play()
					task.wait(0.5)
					TweenService:Create(
						clone3.lavaGradient.Spike,
						TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Color = Util.WrapColor3Constructor(
								Color3.fromRGB(35, 15, 7),
								player,
								"LeopardFruitVFXColor"
							)
						}
					):Play()
				end)
				local v13 = clone3
				task.delay(random:NextNumber(0, 0.03), function()
					heartbeatLoopFor(0.2, function(p, p2, p3)
						v13:PivotTo(v11 * CFrame.new(0, 26 * v10 * p3, 0))
					end)
				end)
				local v16 = clone3
				task.spawn(function()
					task.wait(2.3)
					task.delay(random:NextNumber(0.4, 0.8), function()
						TweenService:Create(
							v16.PrimaryPart,
							TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{
								CFrame = v16.PrimaryPart.CFrame * CFrame.new(0, -42, 0)
							}
						):Play()
					end)
				end)
			end
		end
	end
end