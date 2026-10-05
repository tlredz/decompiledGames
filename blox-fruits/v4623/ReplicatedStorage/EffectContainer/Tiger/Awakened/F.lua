local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _WorldOrigin = workspace._WorldOrigin
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { _WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local tigerEffects = FX:WaitForChild("TigerEffects")
local Beziers = require(script.Parent.Parent.Modules.Beziers)
local TweenService = game:GetService("TweenService")

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

local function enableAll(folder, enabled: boolean)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

return function(data)
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage
	local rigModel = data.RigModel
	local root = data.Root

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder", _WorldOrigin)
		local clone = tigerEffects.PART_TEMPLATE:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")

		repeat
			task.wait()
			clone.CFrame = root.CFrame
		until not (holding.Value and holding)

		task.delay(1, function()
			folder:Destroy()
		end)
	elseif stage == 2 then
		local tigerRig = root.Parent.TigerRig:FindFirstChild("TigerRig")
		local _ = data.StartCFrame
		local timeout = data.Timeout
		local _ = data.WindUp
		local grabExists = data.GrabExists

		if not grabExists then
			return
		end

		local folder = Instance.new("Folder", _WorldOrigin)
		Util.Debris:AddItem(folder, 10)
		local Players = game:GetService("Players")
		local playerFromCharacter = Players:GetPlayerFromCharacter(root.Parent)
		local Players2 = game:GetService("Players")
		local v2

		if playerFromCharacter == Players2.LocalPlayer then
			v2 = true
		else
			local Players3 = game:GetService("Players")
			local playerFromCharacter2 = Players3:GetPlayerFromCharacter(data.VictimChar)
			local Players4 = game:GetService("Players")
			v2 = playerFromCharacter2 == Players4.LocalPlayer or false
		end

		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(5, 5, 5)
		part.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(part, timeout + 0.2)
		Util.Sound:Play("BF_TigerFt_AWK_F_GrabSequence_03", root)
		task.spawn(function()
			if rigModel then
				while part:IsDescendantOf(workspace) do
					if not rigModel:IsDescendantOf(workspace) then
						part:Destroy()
						return
					end

					local torso2 = rigModel.RootPart.Controller:FindFirstChild("Torso1", true):FindFirstChild(
						"Torso2",
						true
					)

					if torso2 then
						part.CFrame = torso2.WorldCFrame
					end

					task.wait()
				end
			end
		end)
		task.spawn(function()
			local attackerChar = data.AttackerChar
			local attackerHum = data.AttackerHum
			local victimChar = data.VictimChar
			local victimHum = data.VictimHum
			local grabExists2 = data.GrabExists
			local timeout2 = data.Timeout or 5
			local humanoidRootPart = attackerChar:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = victimChar:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 and grabExists2 then
				local lastTime = tick()

				while RunService.RenderStepped:Wait() and grabExists2 and grabExists2.Parent and humanoidRootPart and humanoidRootPart2 and humanoidRootPart.Parent and humanoidRootPart2.Parent and attackerHum and victimHum do
					if victimHum.Health <= 0 or attackerHum.Health <= 0 then
						print("whjat the heck just happopened")
						return
					end

					if timeout2 < tick() - lastTime then
						break
					else
						humanoidRootPart2.CFrame = grabExists2.Value
					end
				end
			end
		end)
		local victimChar = data.VictimChar
		Util.Anims:Get(victimChar, "TigerAwakenedFSuccess"):Play()
		local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone = FX2:WaitForChild("TigerEffects").F_Awak.LungeWeld:Clone()
		local primaryPart = clone.PrimaryPart
		primaryPart.CFrame = tigerRig.PrimaryPart.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 10.5)
		local FX3 = require(ReplicatedStorage:WaitForChild("FX"))
		local clone2 = FX3:WaitForChild("TigerEffects").F_Awak.RHand:Clone()
		Util.SetParentOverrideWithColor(clone2, tigerRig.VFX.XGround, player, "LeopardFruitVFXColor")
		clone2.RigidConstraint.Attachment0 = clone2.Attachment
		clone2.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3["Shoulder.R"]["HandIK.R"]["Hand.R"]["Middle.R"]
		TweenService:Create(
			clone2.Light.PointLight,
			TweenInfo.new(0.96, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				Brightness = 0
			}
		):Play()
		Util.Debris:AddItem(clone2, 3.5)
		local weld = Instance.new("Weld")
		weld.Part0 = tigerRig.PrimaryPart
		weld.Part1 = primaryPart
		weld.C0 = weld.Part1.CFrame:inverse()
		weld.C1 = weld.Part1.CFrame:inverse()
		weld.Parent = primaryPart

		local function victimhitFX()
			local victimChar2 = data.VictimChar
			local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone3 = FX4:WaitForChild("TigerEffects").F_Awak.victimhit.EmitHit:Clone()
			Util.SetParentOverrideWithColor(clone3, victimChar2.PrimaryPart, player, "LeopardFruitVFXColor")
			emitAll(clone3)
			Util.Debris:AddItem(clone3, 0.95)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ColorCorrectionFlick()
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					local blurEffect = Instance.new("BlurEffect")
					Util.SetParentOverrideWithColor(blurEffect, game.Lighting, player, "LeopardFruitVFXColor")
					blurEffect.Size = 8
					Util.Debris:AddItem(blurEffect, 0.06)
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					Util.SetParentOverrideWithColor(
						colorCorrectionEffect,
						game.Lighting,
						player,
						"LeopardFruitVFXColor"
					)
					Util.Debris:AddItem(colorCorrectionEffect, 0.3)
					TweenService:Create(
						blurEffect,
						TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Size = 0
						}
					):Play()
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(255, 226, 206),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = 0.07,
							Saturation = 0.1
						}
					):Play()
					task.wait(0.02)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.01, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
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
				end
			end)
		end

		task.spawn(function()
			if v2 then
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						FieldOfView = 80
					}
				):Play()
				task.wait(0.1)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.217, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						FieldOfView = 70
					}
				):Play()
				task.wait(0.217)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						FieldOfView = 45
					}
				):Play()

				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(3, 4, 0.05, 0.8, createVector(1, 1, 1), createVector(0.6, 0.6, 0.6))
				end

				task.wait(0.35)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.083, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						FieldOfView = 80
					}
				):Play()
				task.wait(0.083)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						FieldOfView = 45
					}
				):Play()
				task.wait(0.5)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.267, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						FieldOfView = 75
					}
				):Play()
				task.wait(0.267)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(1.9, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						FieldOfView = 30
					}
				):Play()

				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(7, 8, 0.05, 1.8, createVector(1, 1, 1), createVector(0.6, 0.6, 0.6))
				end

				task.wait(1.9)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()

				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(
						12,
						13,
						0.05,
						1.8,
						createVector(1.4, 1.6, 1.6),
						createVector(0.9, 0.9, 0.9)
					)
				end

				task.wait(0.15)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end
		end)
		task.spawn(function()
			local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone3 = FX4:WaitForChild("TigerEffects").F_Awak.Flames:Clone()
			Util.SetParentOverrideWithColor(clone3, tigerRig.VFX.FSkill, player, "LeopardFruitVFXColor")
			clone3.RigidConstraint.Attachment0 = clone3.Attachment
			clone3.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head.Jaw
			enableAll(clone3, false)
			task.wait(0.2)
			enableAll(clone3, false)
			task.wait(0.2)
			enableAll(clone3, true)
			task.wait(0.6)
			enableAll(clone3, false)
			task.wait(0.367)
			enableAll(clone3, true)
			task.wait(0.683)
			enableAll(clone3, false)
			task.wait(0.6)
			enableAll(clone3, true)
			task.wait(0.35)
			enableAll(clone3, false)
		end)

		local function Ftp()
			local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone3 = FX4:WaitForChild("TigerEffects").F_Awak.TPFourth:Clone()
			clone3.CFrame = part.CFrame
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "LeopardFruitVFXColor")
			emitAll(clone3)
			Util.Debris:AddItem(clone3, 1.5)
		end

		task.spawn(function()
			Ftp()
			task.wait(0.443)
			local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone3 = FX4:WaitForChild("TigerEffects").F_Awak.TPFirst:Clone()
			clone3.CFrame = part.CFrame
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "LeopardFruitVFXColor")
			emitAll(clone3)
			Util.Debris:AddItem(clone3, 1.5)
			Ftp()
		end)
		task.spawn(function()
			local WAIT_INTERVAL = 0.05
			task.wait(0.683)
			emitAll(clone.Lunge1st)
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(0.1)
			emitAll(clone.Lunge2nd)
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(0.1)
			emitAll(clone.Lunge3rd)
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge4th)
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(0.5)
			local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
			local clone3 = FX4:WaitForChild("TigerEffects").F_Awak.Start:Clone()
			clone3.CFrame = tigerRig.PrimaryPart.CFrame
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "LeopardFruitVFXColor")
			emitAll(clone3)
			Util.Debris:AddItem(clone3, 1.5)
			task.wait(0.067)
			Ftp()
			emitAll(clone.Lunge6th)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(0.033)
			emitAll(clone.Lunge1st)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(0.084)
			emitAll(clone.Lunge3rd)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge2nd)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge3rd)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge2nd)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge5th)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge1st)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge7th)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge1st)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge3rd)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(0.066)
			emitAll(clone.Lunge4th)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
			task.wait(WAIT_INTERVAL)
			emitAll(clone.Lunge5th)
			Ftp()
			ColorCorrectionFlick() -- equivalent call inferred; original call site unknown
			victimhitFX()
		end)
		task.spawn(function()
			task.wait(2.45)
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(4, 4, 0.05, 1, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
					task.spawn(function()
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								FieldOfView = 107
							}
						):Play()
						task.wait(0.35)
						TweenService:Create(
							workspace.Camera,
							TweenInfo.new(0.633, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
							{
								FieldOfView = 40
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
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(197, 65, 255),
									player,
									"LeopardFruitVFXColor"
								),
								Brightness = -0.4,
								Saturation = -0.4,
								Contrast = 3
							}
						):Play()
						task.wait(0.25)
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								TintColor = Util.WrapColor3ConstructorForTintColor(
									Color3.fromRGB(255, 166, 93),
									player,
									"LeopardFruitVFXColor"
								),
								Brightness = 0.2,
								Saturation = 0,
								Contrast = 0.4
							}
						):Play()
						task.wait(0.25)
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
			emitAll(clone2)
			Util.Debris:AddItem(clone2, 1.5)
			task.wait(0.3)
			task.spawn(function()
				for _ = 1, 9 do
					task.spawn(function()
						for _ = 1, 2 do
							local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
							local clone3 = FX4:WaitForChild("TigerEffects").F_Awak.partfly:Clone()
							clone3.CFrame = root.CFrame * CFrame.new(
								math.random(-15, 15),
								math.random(-1.5, 15),
								math.random(-15, 15)
							)
							Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "LeopardFruitVFXColor")
							Util.Debris:AddItem(clone3, 2)
							local v3 = math.random(15, 23) / 100
							Beziers.Interpolate(
								"Cubic",
								v3,
								100,
								v3,
								nil,
								clone3.CFrame,
								clone3.CFrame * CFrame.new(
									math.random(-45, 45),
									math.random(-1, 15),
									math.random(-45, 45)
								),
								clone3.CFrame * CFrame.new(
									math.random(-45, 45),
									math.random(-1, 15),
									math.random(-45, 45)
								),
								root.CFrame,
								clone3,
								"CFrame"
							)
						end
					end)
					task.wait(0.0075)
				end
			end)
			task.wait(0.2)
			emitAll(clone.LoadPunch)
			task.wait(0.05)
			emitAll(clone.PushForce)
			task.wait(0.05)
			emitAll(clone.PunchInch)
			task.wait(0.383)
			emitAll(clone.Explosion)
			task.spawn(function()
				task.wait(0.09533)
				local ray = Util.Ray
				local v3 = root.Position + createVector(0, 2, 0)
				local v4 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
				local v5, v6, _ = ray(v3, createVector(-0, -100, -0), v4, false)

				if v5 ~= nil then
					local cframe = CFrame.new(v6)
					local FX4 = require(ReplicatedStorage:WaitForChild("FX"))
					local clone3 = FX4:WaitForChild("TigerEffects").F_Awak.FSlamFloor:Clone()
					clone3.CFrame = cframe
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "LeopardFruitVFXColor")
					emitAll(clone3)
					Util.Debris:AddItem(clone3, 4.5)
				end
			end)

			if root.Parent == game.Players.LocalPlayer.Character then
				Util.CameraShaker:ShakeOnce(4, 4, 0.05, 1, createVector(1.4, 1.6, 1.6), createVector(0.9, 0.9, 0.9))
			end

			task.spawn(function()
				if v2 then
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							FieldOfView = 107
						}
					):Play()
					task.wait(0.1)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
				end
			end)
			task.spawn(function()
				if root.Parent == game.Players.LocalPlayer.Character then
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
						TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Util.WrapColor3ConstructorForTintColor(
								Color3.fromRGB(197, 65, 255),
								player,
								"LeopardFruitVFXColor"
							),
							Brightness = -3,
							Saturation = -1,
							Contrast = 8
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
				end
			end)
			weld:Destroy()
			primaryPart.Anchored = true
		end)
		root.Anchored = true
		root.CFrame = data.StartCFrame
		local cFrame1 = data.CFrame1
		local magnitude = (root.Position - cFrame1.Position).Magnitude
		local lastTime = os.clock()

		while os.clock() - lastTime < 0.95 do
			local v3 = (os.clock() - lastTime) / 0.95
			root.CFrame = cFrame1 * CFrame.new(0, -magnitude * (1 - v3 ^ 0.5), 0)
			grabExists.Value = CFrame.lookAt(root.Position, root.Position - root.CFrame.LookVector)
			RunService.PreSimulation:Wait()
		end

		root.CFrame = cFrame1
		grabExists.Value = CFrame.lookAt(cFrame1.Position, cFrame1.Position - cFrame1.LookVector)
		task.wait(0.5)
		task.spawn(function() end)
		local cFrame2 = data.CFrame2
		local magnitude2 = (root.Position - cFrame2.Position).Magnitude
		local lastTime2 = os.clock()

		while os.clock() - lastTime2 < 0.8 do
			local v3 = (os.clock() - lastTime2) / 0.8
			root.CFrame = cFrame2 * CFrame.new(0, -magnitude2 * (1 - v3 ^ 0.5), 0)
			grabExists.Value = CFrame.lookAt(root.Position, root.Position - root.CFrame.LookVector)
			RunService.PreSimulation:Wait()
		end

		root.CFrame = cFrame2
		grabExists.Value = CFrame.lookAt(cFrame2.Position, cFrame2.Position - cFrame2.LookVector)
		local cFrame3 = data.CFrame3
		local magnitude3 = (root.Position - cFrame3.Position).Magnitude
		local lastTime3 = os.clock()

		while os.clock() - lastTime3 < 0.8 do
			local v3 = (os.clock() - lastTime3) / 0.8
			root.CFrame = cFrame3 * CFrame.new(0, -magnitude3 * (1 - v3 ^ 0.5), 0)
			grabExists.Value = CFrame.lookAt(root.Position, root.Position - root.CFrame.LookVector)
			RunService.PreSimulation:Wait()
		end

		root.CFrame = cFrame3
		grabExists.Value = CFrame.lookAt(cFrame3.Position, cFrame3.Position - cFrame3.LookVector)
		task.wait(0.3)
		task.wait(0.5)
		root.Anchored = false
	end
end