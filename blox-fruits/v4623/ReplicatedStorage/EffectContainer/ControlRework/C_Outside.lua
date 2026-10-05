local createVector = vector.create
local _ = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local c_Outside = FX:WaitForChild("ControlRework").C_Outside
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local shared = script.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
local MathHelper = require(utility.MathHelper)
local HexsStormClass = require(shared:WaitForChild("HexsStormClass"))
local Textures = require(shared.Textures)
local Rocks = require(shared.Rocks)
local currentCamera = workspace.CurrentCamera
local cameraShaker = Util.CameraShaker

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

function Debris(instance, duration: number)
	if not instance then
		return
	end

	if duration > 0 then
		return task.delay(duration, instance.Destroy, instance)
	end

	instance:Destroy()
end

for _, child in pairs(c_Outside.Phase1:GetChildren()) do
	if child:IsA("BasePart") then
		Util.ResizeModel(child, 0.6, child.Position)
	elseif child:IsA("Model") then
		child:ScaleTo(child:GetScale() * 0.6)
	end
end

return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player.Player)
		folder.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	if player.StateChange then
		local child = _WorldOrigin:FindFirstChild("ControlC_" .. VisualHelper:OwnerName(player.Player))

		if child then
			child:SetAttribute("ReleasedTimestamp", player.StateChange)
			child:SetAttribute("Released", player.StartCFrame)
		end
	else
		local character = player.Character
		local model = Instance.new("Model")
		model.Name = "ControlC_" .. VisualHelper:OwnerName(player.Player)
		model.Parent = _WorldOrigin
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local _ = humanoidRootPart.CFrame
		Util.Sound:Play("C_Boomerang_Activate_01", humanoidRootPart)
		local v = Util.Sound:Play("C_Boomerang_Held_01", humanoidRootPart)
		TweenService:Create(v, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = false
		raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local clone = c_Outside.Phase0.DaggerSpiral:Clone()
		VisualHelper:CapEmitterRates(clone, 20)
		clone.GroundPart.Position = createVector(-0, -500000, -0)
		clone.Size = createVector(0, 0, 0)
		Util.SetParentOverrideWithColor(clone, model, player.Player, "ControlFruitVFXColor")
		clone.Anchored = false
		clone.Massless = true
		local weld = clone.Weld
		weld.Part0 = character.RightHand
		weld.C1 = CFrame.new(0, -weld.C1.Position.Y, 0) * CFrame.Angles(3.141592653589793, 0, 0)
		clone.Light.PointLight.Brightness = 0
		local clone2 = c_Outside.Phase0.Indicator:Clone()
		clone2.Anchored = false
		clone2.Massless = true
		clone2.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone2, model, player.Player, "ControlFruitVFXColor")
		clone2.End.Position *= createVector(0, 1, 0)
		local clone3 = c_Outside.Phase0.DoubleNeonEye:Clone()
		clone3.Anchored = false
		clone3.Massless = true
		clone3.Weld.Part0 = character.Head
		Util.SetParentOverrideWithColor(clone3, model, player.Player, "ControlFruitVFXColor")
		local clone4 = c_Outside.Phase0.FloorSpawn:Clone()
		clone4.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2.8, 0)
		Util.SetParentOverrideWithColor(clone4, model, player.Player, "ControlFruitVFXColor")
		local clone5 = c_Outside.Phase0.NeonRotation:Clone()
		clone5:ScaleTo(1.2)
		clone5.Main.Anchored = false
		clone5.Main.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone5, model, player.Player, "ControlFruitVFXColor")
		local clone6 = c_Outside.Phase0.FloorHandle:Clone()
		clone6.Anchored = false
		clone6.Massless = true
		clone6.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone6, model, player.Player, "ControlFruitVFXColor")
		VisualHelper:Tween(clone2.End, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Position = clone2.End.Position + createVector(0, 0, -33)
		})
		clone.Light.PointLight.Brightness = 1
		VisualHelper:Tween(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
			Size = c_Outside.Phase0.DaggerSpiral.Size
		})
		VisualHelper:EmitAll(clone.Init)
		local windStorm = clone.Charge.WindStorm
		VisualHelper:Tween(windStorm, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = windStorm.Orientation - createVector(0, 360, 0)
		})
		local storm = clone.Charge.Storm
		VisualHelper:Tween(storm, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = storm.Orientation - createVector(0, 360, 0)
		})
		VisualHelper:SetEnableAll(clone.Charge, true)
		VisualHelper:SetEnableAll(clone.GroundPart, true)
		cameraShaker:Shake("Fast")
		local clone7 = c_Outside.Phase0.ShaderScreen:Clone()
		clone7.Image.ImageTransparency = 1
		clone7.Name = character.Name .. "Shader_Screen"
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local v3

		if player.Player == game.Players.LocalPlayer then
			v3 = player.Player:FindFirstChild("PlayerGui") or model
		else
			v3 = model
		end

		setParentOverrideWithColor(clone7, v3, player.Player, "ControlFruitVFXColor")
		VisualHelper:Tween(clone7.Image, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			ImageTransparency = 0.86
		})
		local v4 = HexsStormClass.new(humanoidRootPart, true, player.Player)
		local random = Random.new()

		for i = -1, 1, 0.2 do
			v4:AddHex(
				i > 0.3 and "Gradient" or "Normal",
				i,
				random:NextNumber(13, 14),
				i * 360,
				random:NextNumber(50, 110)
			)
		end

		v4:Enable()
		v4:ApplyTransparencyTransition(TweenInfo.new(0.45, Enum.EasingStyle.Sine), 1, 0)
		VisualHelper:SetEnableAll(clone3, true)
		VisualHelper:Tween(clone4.CircleWinds, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Orientation = clone4.CircleWinds.Orientation + createVector(0, 180, 0)
		})
		VisualHelper:EmitAll(clone4)
		clone4.PointLight.Enabled = true
		VisualHelper:Tween(clone4.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			Brightness = 0
		})

		for _, child in clone4.CircleWinds:GetChildren() do
			local beam = child.Beam
			beam.Enabled = true
			VisualHelper:Tween(beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		Debris(clone5, 2)
		clone5.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

		for i, child in clone5.Main.Layers:GetChildren() do
			child.Orientation *= 1.5
			local beam = child.Beam
			beam.Enabled = true
			local number = random:NextNumber(0.17, 0.25)
			VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
				Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
			})
			VisualHelper:Tween(beam, TweenInfo.new(number, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end

		VisualHelper:Tween(clone6.Beams, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = clone6.Beams.Orientation - createVector(0, 360, 0)
		})
		VisualHelper:SetEnableAll(clone6, true)
		local clone8 = c_Outside.Phase0.BigDaggerSpiral:Clone()
		VisualHelper:CapEmitterRates(clone8, 15, true)
		clone8:PivotTo(CFrame.new(0, -1000000, 0))
		Util.SetParentOverrideWithColor(clone8, model, player.Player, "ControlFruitVFXColor")
		local clone9 = c_Outside.Phase0.BoltExplosionLite:Clone()
		Util.SetParentOverrideWithColor(clone9, model, player.Player, "ControlFruitVFXColor")
		local workspace2 = workspace
		tick()
		local total = 0
		local total2 = 0
		local count = 0

		while true do
			local v5 = task.wait()
			total += v5
			total2 += v5
			local _, v6, _ = clone.CFrame:ToEulerAnglesYXZ()
			local groundPart = clone.GroundPart
			local v7 = clone.Size.X / 2 + 1.5
			local rayCast = MathHelper:RayCast(
				clone.Position,
				clone.CFrame.RightVector * -1 * v7,
				{ workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
			)
			groundPart.CFrame = (rayCast and CFrame.new(rayCast.Position) or CFrame.new(clone.CFrame * CFrame.new(
				-1 * v7,
				0,
				0
			).Position)) * CFrame.Angles(0, v6, 0) * CFrame.new(0, 0, 0.14)

			for _, child in clone.Surfaces:GetChildren() do
				for _, child2 in child:GetChildren() do
					child2.Rotation += child2:GetAttribute("RotationSpeed") * 12.5 * v5
				end
			end

			if total2 > 0.25 then
				total2 = 0
				local clone10 = c_Outside.Phase0.SingleSpark:Clone()
				clone10.CFrame = groundPart.CFrame * CFrame.new(0, 0, random:NextNumber(1, 2.25)) * CFrame.Angles(
					math.rad((random:NextNumber(-360, 360))),
					math.rad((random:NextNumber(-360, 360))),
					(math.rad((random:NextNumber(-360, 360))))
				)
				Util.SetParentOverrideWithColor(clone10, model, player.Player, "ControlFruitVFXColor")
				clone10.AssemblyLinearVelocity = (groundPart.CFrame.LookVector + createVector(0, 1.5, 0)) * -random:NextNumber(
					15,
					65
				)
				clone10.AssemblyAngularVelocity = Vector3.new(
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20)
				)
				VisualHelper:EmitAll(clone10.Main)
				VisualHelper:Tween(clone10.Main.PointLight, TweenInfo.new(2.3, Enum.EasingStyle.Sine), {
					Brightness = 0
				})
				Debris(clone10, 3)
				local v8 = humanoidRootPart.CFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
					0,
					1,
					-math.random(15, 20)
				)
				local rayCast2 = MathHelper:RayCast(
					v8.Position,
					v8.UpVector * -10,
					{ workspace2 },
					Enum.RaycastFilterType.Include
				)

				if rayCast2 then
					clone9.CFrame = CFrame.new(rayCast2.Position + createVector(0, 0.05, 0))
					VisualHelper:EmitAll(clone9)
				end
			end

			if total > 0.09 then
				count += 1
				local v8 = 0.2 + math.random(3) * 0.03
				local position2 = clone6.Position + Vector3.new(
					math.random(-15, 15),
					math.random(10),
					math.random(-15, 15)
				)
				local position = clone6.Position
				local clone10 = c_Outside.Phase0.Vault[`HexTrailSpecs{count % 2 + 1}`]:Clone()
				clone10.Position = position2
				Util.SetParentOverrideWithColor(clone10, workspace.Terrain, player.Player, "ControlFruitVFXColor")
				Debris(clone10, v8 + 0.5)
				local magnitude = (position2 - position).Magnitude
				local cframe = CFrame.lookAt(position2, position)
				local v14 = cframe * CFrame.new(math.random(-45, 45), math.random(-45, 45), -magnitude * 0.25).Position
				local v15 = cframe * CFrame.new(math.random(-45, 45), math.random(-45, 45), -magnitude * 0.75).Position
				VisualHelper:TweenNumberValue(1, TweenInfo.new(v8, Enum.EasingStyle.Sine), function(p: number)
					clone10.Position = MathHelper:CubicBezier(p, position2, v14, v15, position)
				end)
				total = 0
			end

			if not (humanoidRootPart.Parent and humanoidRootPart.Parent:FindFirstChild("Humanoid") and humanoidRootPart.Parent:FindFirstChild("Humanoid").Sit or not model:IsDescendantOf(workspace) or model:GetAttribute("Released")) then
				continue
			end

			if v then
				Util.Sound:FadeOut(v, 0.25)
			end

			model.Name = "Destroying"
			local released = model and model:GetAttribute("Released") or humanoidRootPart.CFrame
			local releasedTimestamp = model:GetAttribute("ReleasedTimestamp") or workspace:GetServerTimeNow()
			Util.Debris:AddItem(model, 7)
			Debris(clone9, 1)
			local clone10 = c_Outside.Phase1.StartImpact:Clone()
			clone10.CFrame = released * CFrame.new(0, 5, -15)
			Util.SetParentOverrideWithColor(clone10, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			DeleteImpactAfterDuration(clone10) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone10:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v8 = emitter
				task.spawn(function()
					if v8:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v8:GetAttribute("EmitDelay"))
					end

					v8:Emit(v8:GetAttribute("EmitCount"))
				end)
			end

			clone.Light.PointLight.Brightness = 0

			for _, weld2 in clone:GetChildren() do
				if weld2:IsA("Weld") or weld2.Name == "Init" or weld2.Name == "GroundPart" then
					continue
				end

				weld2:Destroy()
			end

			VisualHelper:EmitAll(clone.Init)
			VisualHelper:SetEnableAll(clone.GroundPart, false)

			for k in v4.Data do
				VisualHelper:Tween(k, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = createVector(0, 0, 0)
				})
			end

			task.delay(1, function()
				v4:Destroy()
			end)
			clone2:Destroy()
			VisualHelper:EmitAll(clone4)
			Debris(clone4, 2.15)
			VisualHelper:SetEnableAll(clone6, false)
			Debris(clone6, 2)
			VisualHelper:SetEnableAll(clone3, false)
			Debris(clone3, 1)
			cameraShaker:Shake("Fast")
			Util.Sound:Play("C_Boomerang_Release_0" .. tostring(math.random(1, 2)), humanoidRootPart)
			local cframe = CFrame.Angles(0, 0, -1.5707963267948966)
			clone8:PivotTo(released * CFrame.new(0, 0, -5) * cframe)
			local main = clone8.Main
			local groundPart2 = clone8.GroundPart
			local charge = main.Charge
			local smash = main.Smash
			local v8 = Util.Sound:Play("C_Boomerang_Travel_Loop_01", main)
			local flag = true
			VisualHelper:SetEnableAll(groundPart2, flag)
			local windStorm2 = charge.WindStorm
			VisualHelper:Tween(windStorm2, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Orientation = windStorm2.Orientation - createVector(0, 360, 0)
			})
			local storm2 = charge.Storm
			VisualHelper:Tween(storm2, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Orientation = storm2.Orientation - createVector(0, 360, 0)
			})
			VisualHelper:SetEnableAll(charge, true)
			VisualHelper:Tween(smash.Winds, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Orientation = smash.Winds.Orientation - createVector(0, 360, 0)
			})
			local frontWinds = smash.FrontWinds
			frontWinds.Parent = workspace.Terrain
			frontWinds.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			VisualHelper:Tween(frontWinds, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				CFrame = frontWinds.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
			})
			local v9 = 0.0125
			local v10 = 0

			for _, child in frontWinds:GetChildren() do
				local beamMain = child.BeamMain
				beamMain.Enabled = true
				VisualHelper:Tween(beamMain, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
					Width0 = 0,
					Width1 = 0
				})
			end

			Debris(frontWinds, 0.2)
			task.delay(0.175, function()
				for i, child in smash.Winds:GetChildren() do
					VisualHelper:Tween(
						child.BeamMain,
						TweenInfo.new(0.2 + math.random() * 0.4, Enum.EasingStyle.Sine),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
				end
			end)
			Debris(smash, 1)
			local hexTrail = charge.TrailsBeam.Point1.HexTrail
			local beam = charge.TrailsBeam.Point3.Beam
			local beam2 = charge.TrailsBeam.Point4.Beam
			local thread = task.spawn(function()
				while true do
					for k, texture in Textures.HexTrailBeam do
						hexTrail.Texture = texture
						task.wait(0.016666666666666666)
					end
				end
			end)
			local thread2 = task.spawn(function()
				while true do
					for k, texture in Textures.WindBeam do
						beam.Texture = texture
						beam2.Texture = texture
						task.wait(0.02)
					end
				end
			end)
			local clone11 = c_Outside.Phase1.MarkGUI:Clone()
			clone11.Adornee = humanoidRootPart
			clone11.Enabled = false
			Util.SetParentOverrideWithColor(clone11, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			local main2 = clone11.Main
			VisualHelper:Tween(main2.IconA, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
				Rotation = main2.IconA.Rotation - 360
			})
			VisualHelper:Tween(
				main2.IconB,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
				{
					ImageTransparency = 0.8,
					Size = UDim2.fromScale(0.85, 0.85)
				}
			)
			VisualHelper:Tween(
				main2.IconC,
				TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true),
				{
					ImageTransparency = 1,
					Size = UDim2.fromScale(0.8, 0.8)
				}
			)
			local v15 = {}
			local heartbeatConnection = nil
			local v17 = 0

			for _, beam3 in charge.TrailsBeam:GetDescendants() do
				if not beam3:IsA("Beam") then
					continue
				end

				local width0 = beam3.Width0
				local width1 = beam3.Width1
				beam3.Width0 = 0
				beam3.Width1 = 0
				v15[beam3] = { width0, width1 }
			end

			local smokes = groundPart2.Smokes
			smokes.Parent = workspace.Terrain
			clone8:ScaleTo(v9)
			task.spawn(function()
				for i = 1, 10 do
					local v19 = 0.3 + math.random() * 0.3
					local position = clone6.Position + Vector3.new(
						math.random(-20, 20),
						math.random(13.333333333333334),
						math.random(-20, 20)
					)
					local clone12 = c_Outside.Phase0.Vault.HexTrailSpecs3:Clone()
					clone12.Position = position
					Util.SetParentOverrideWithColor(clone12, workspace.Terrain, player.Player, "ControlFruitVFXColor")
					Debris(clone12, v19 + 0.5)
					local cframe2 = CFrame.new(math.random(-50, 50), math.random(-50, 50), 0)
					local cframe3 = CFrame.new(math.random(-50, 50), math.random(-50, 50), 0)
					local v21 = Vector3.new(math.random(-6, 6), math.random(35), math.random(-6, 6))
					VisualHelper:TweenNumberValue(1, TweenInfo.new(v19, Enum.EasingStyle.Sine), function(p: number)
						local v26 = main.Position + v21
						local magnitude = (position - v26).Magnitude
						local cframe4 = CFrame.lookAt(position, v26)
						clone12.Position = MathHelper:CubicBezier(
							p,
							position,
							cframe4 * CFrame.new(0, 0, -magnitude * 0.25) * cframe2.Position,
							cframe4 * CFrame.new(0, 0, -magnitude * 0.75) * cframe3.Position,
							v26
						)
					end)
					task.wait(0.03)
				end
			end)
			local clone12 = c_Outside.Phase1.CameraEffects:Clone()

			if player.Player == game.Players.LocalPlayer then
				Util.SetParentOverrideWithColor(clone12, currentCamera, player.Player, "ControlFruitVFXColor")
			end

			if player.Player == game.Players.LocalPlayer then
				VisualHelper:SetEnableAll(clone12, true)
				VisualHelper:EmitAll(clone12)
			end

			local total3 = 0
			local v19 = false

			local function DestroyConnection()
				if v8 then
					Util.Sound:FadeOut(v8, 0.2)
				end

				if not heartbeatConnection.Connected then
					return
				end

				task.cancel(thread)
				task.cancel(thread2)
				heartbeatConnection:Disconnect()
				clone8:Destroy()
				clone12:Destroy()
				main2.Magnitude.Text = "Nice!"
				VisualHelper:Tween(
					main2,
					TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0.15),
					{
						Size = UDim2.new()
					}
				)
				Debris(clone11, 1)
				VisualHelper:SetEnableAll(smokes, false)
				Debris(smokes, 4)
				VisualHelper:Tween(currentCamera, TweenInfo.new(5, Enum.EasingStyle.Sine), {
					FieldOfView = 70
				})
				VisualHelper:Tween(clone7.Image, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					ImageTransparency = 1
				})
				Debris(clone7, 0.5)
			end

			local v27 = false
			local flag2 = false
			local cFrame = main.CFrame
			local v28 = false
			local v29 = 0
			local v30 = 300
			local v31 = 0 + math.max(0, workspace:GetServerTimeNow() - releasedTimestamp - 0.05)
			local v32 = clone12
			local part = main
			local v35 = clone11
			local main3 = main2
			local DestroyConnection2 = DestroyConnection
			local smokes2 = smokes
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				v31 += dt
				total3 += dt
				v32.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -2.15) * CFrame.Angles(0, 1.5707963267948966, 0)
				local v41 = math.clamp(v31 / 0.5, 0, 1)
				local v42

				if v31 > 0.5 then
					local position = humanoidRootPart.Position
					local position2 = part.Position
					local magnitude = (position - position2).Magnitude

					if v27 == false and flag2 == false then
						v27 = true
						flag2 = true
						Util.Sound:Play("C_Boomerang_MaxDistance_Flip_01", position2)
						TweenService:Create(
							part,
							TweenInfo.new(0.115, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = part.CFrame * CFrame.new(0, 0, -16.666666666666668) * CFrame.Angles(
									0,
									0,
									1.5707963267948966
								)
							}
						):Play()
						local clone13 = c_Outside.Phase1.ChangeImpact:Clone()
						clone13.CFrame = part.CFrame
						Util.SetParentOverrideWithColor(
							clone13,
							workspace.Terrain,
							player.Player,
							"ControlFruitVFXColor"
						)
						DeleteImpactAfterDuration(clone13) -- equivalent call inferred; original call site unknown

						for i, emitter in pairs(clone13:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v43 = emitter
							task.spawn(function()
								if v43:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v43:GetAttribute("EmitDelay"))
								end

								v43:Emit(v43:GetAttribute("EmitCount"))
							end)
						end

						VisualHelper:SetEnableAll(groundPart2, false)
						local waitScheduler = Util.WaitScheduler.new()
						waitScheduler:wait(0.115)
						TweenService:Create(
							part,
							TweenInfo.new(0.225, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								CFrame = part.CFrame * CFrame.new(0, 0, -8.333333333333334)
							}
						):Play()
						local clone14 = c_Outside.Phase1.TurnImpact:Clone()
						clone14.CFrame = part.CFrame
						Util.SetParentOverrideWithColor(clone14, model, player.Player, "ControlFruitVFXColor")
						VisualHelper:EmitAll(clone14)
						local clone15 = c_Outside.Phase1.BackAura:Clone()
						VisualHelper:CapEmitterRates(clone15, 15, true)
						clone15.CFrame = part.CFrame
						Util.SetParentOverrideWithColor(clone15, part, player.Player, "ControlFruitVFXColor")
						clone15.Anchored = false
						clone15.Weld.Part1 = part
						VisualHelper:SetEnableAll(clone15, true)
						waitScheduler:wait(0.225)
						clone8.GroundPart.FloorTrail.Trail:Destroy()
						v27 = false
						return
					else
						if v27 == true then
							return
						end

						if v17 == 0 then
							cameraShaker:Shake("Fast")
							v35.Enabled = true
							main3.Size = UDim2.new()
							VisualHelper:Tween(
								main3,
								TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Size = UDim2.fromScale(1, 1)
								}
							)
							v17 = magnitude
							v9 = 0.1
							task.spawn(function()
								for i = 1, 5 do
									local v43 = 0.15 + math.random() * 0.2
									local position3 = part.Position + Vector3.new(
										math.random(-35, 35),
										math.random(23.333333333333332),
										math.random(-35, 35)
									)
									local clone13 = c_Outside.Phase0.Vault.HexTrailSpecs3:Clone()
									clone13.Position = position3
									Util.SetParentOverrideWithColor(
										clone13,
										workspace.Terrain,
										player.Player,
										"ControlFruitVFXColor"
									)
									Debris(clone13, v43 + 0.5)
									local v46 = CFrame.new(math.random(-50, 50), math.random(-50, 50), 0)
									local v47 = CFrame.new(math.random(-50, 50), math.random(-50, 50), 0)
									VisualHelper:TweenNumberValue(
										1,
										TweenInfo.new(v43, Enum.EasingStyle.Sine),
										function(p: number)
											local v49 = humanoidRootPart.Position - createVector(0, 3, 0)
											local magnitude2 = (position3 - v49).Magnitude
											local cframe4 = CFrame.lookAt(position3, v49)
											clone13.Position = MathHelper:CubicBezier(
												p,
												position3,
												cframe4 * CFrame.new(0, 0, -magnitude2 * 0.25) * v46.Position,
												cframe4 * CFrame.new(0, 0, -magnitude2 * 0.75) * v47.Position,
												v49
											)
										end
									)
									task.wait(0.025)
								end
							end)
						end

						main3.Magnitude.Text = `{string.format("%.1f", magnitude)}m`

						if magnitude <= 10 then
							cameraShaker:Shake("Fast")
							VisualHelper:EmitAll(clone.Init)
							Util.Sound:Play("C_Boomerang_Return_To_Hand_01", humanoidRootPart)
							return DestroyConnection2()
						else
							if not v28 then
								v28 = true
								v29 = v31
								v30 = 300
							end

							local v43 = math.max(0, v31 - v29)
							local v44 = v30 + v43 * 225
							local unit = (position - position2).Unit
							local v45 = position2 + unit * (v44 * dt) + Vector3.new(0, dt * 60 * 0.05, 0)
							v10 = magnitude / v17
							v42 = CFrame.lookAt(v45, v45 + unit) * cframe * CFrame.Angles(0, 0, 1.5707963267948966)
						end
					end
				else
					v10 = v41
					local v43 = v31
					local v44 = v43 * 5
					local v45 = v43 * 300 + (v43 - v43 * v43 / 1) * 100
					v42 = cFrame * CFrame.new(0, v44, -v45)
				end

				local v43 = math.clamp(v10, v9, 1) * 0.75
				local v44 = math.abs(v43 - clone8:GetScale())

				if v43 * 0.005 < v44 then
					clone8:ScaleTo(v43)
				end

				if v42 then
					local v45 = math.clamp(75 * dt, 0, 1)
					part.CFrame = part.CFrame:Lerp(v42, v45)
				end

				local scale = clone8:GetScale()

				if v41 <= 1 then
					local v45 = scale * v41

					for k, v46 in v15 do
						local width = v46[1] * v45
						local width2 = v46[2] * v45
						k.Width0 = width
						k.Width1 = width2
					end
				end

				local v45 = part.Size.X / 2 + 1.5
				local raycastResult

				if flag2 then
					raycastResult = workspace:Raycast(
						part.Position + createVector(0, 1, 0),
						CFrame.new(part.Position).UpVector * -50,
						raycastParams
					)
				else
					raycastResult = workspace:Raycast(part.Position, part.CFrame.RightVector * v45, raycastParams)
				end

				if raycastResult then
					local eulerAnglesYXZ, v46 = part.CFrame:ToEulerAnglesYXZ()
					groundPart2.CFrame = CFrame.new(raycastResult.Position + createVector(0, 0.15, 0)) * CFrame.Angles(
						0,
						v46,
						0
					)
					smokes2.CFrame = groundPart2.CFrame

					if not flag then
						flag = true
						VisualHelper:SetEnableAll(groundPart2, flag)
						VisualHelper:SetEnableAll(smokes2, flag)
					end

					if total3 > 0.08 then
						total3 = 0
						v19 = not v19
						cameraShaker:Shake("Regular Explosion Super Smooth")
						local cframe2 = CFrame.new(raycastResult.Position)

						if v19 then
							Rocks:AirRocks(
								cframe2,
								Vector3.new(1, random:NextNumber(0.6, 1), random:NextNumber(1, 1.5)) * random:NextNumber(
									0.7,
									1.2
								),
								true,
								math.random(25, 115),
								random:NextNumber(0.5, 1),
								1.5 + math.random() * 0.5,
								false,
								raycastResult.Instance.Color,
								raycastResult.Instance.Material
							)

							if flag2 == false then
								local clone13 = c_Outside.Phase1.SliceGround:Clone()
								clone13:ScaleTo(random:NextNumber(1, 2.45))
								clone13:PivotTo(CFrame.lookAt(
									raycastResult.Position,
									raycastResult.Position + raycastResult.Normal
								) * CFrame.Angles(-1.5707963267948966, math.rad((math.random(360))), 0))
								Util.SetParentOverrideWithColor(
									clone13,
									workspace._WorldOrigin,
									player.Player,
									"ControlFruitVFXColor"
								)
								VisualHelper:EmitAll(clone13)
								local size = clone13.SliceGround.Size
								clone13.SliceGround.Size = createVector(0, 0, 0)
								VisualHelper:Tween(clone13.SliceGround, TweenInfo.new(0.22, Enum.EasingStyle.Sine), {
									Size = size
								})
								task.delay(0.3, function()
									VisualHelper:Tween(clone13.SliceGround.Decal, TweenInfo.new(0.25), {
										Color3 = Color3.fromRGB(0, 0, 0)
									})
									VisualHelper:Tween(clone13.SliceGround, TweenInfo.new(0.3), {
										Size = Vector3.new(0, 0, clone13.SliceGround.Size.Z)
									})
									task.wait(0.3)
									clone13:Destroy()
								end)
							end

							local v47 = 0.1 + math.random() * 0.2
							local position4 = part.Position + Vector3.new(
								math.random(-25, 25),
								math.random(25),
								math.random(-25, 25)
							)
							local position = (part.CFrame * CFrame.new(
								math.random(-25, 25),
								math.random(-25, 25),
								(part.Size.Z + 25) * 1.6
							)).Position
							local clone13 = c_Outside.Phase0.Vault.HexTrailSpecs4:Clone()
							clone13.Position = position4
							Util.SetParentOverrideWithColor(
								clone13,
								workspace.Terrain,
								player.Player,
								"ControlFruitVFXColor"
							)
							Debris(clone13, v47 + 0.5)
							local magnitude = (position4 - position).Magnitude
							local cframe3 = CFrame.lookAt(position4, position)
							local position2 = (cframe3 * CFrame.new(
								math.random(-60, 60),
								math.random(-60, 60),
								-magnitude * 0.25
							)).Position
							local position3 = (cframe3 * CFrame.new(
								math.random(-60, 60),
								math.random(-60, 60),
								-magnitude * 0.75
							)).Position
							VisualHelper:TweenNumberValue(
								1,
								TweenInfo.new(v47, Enum.EasingStyle.Sine),
								function(p: number)
									clone13.Position = MathHelper:CubicBezier(
										p,
										position4,
										position2,
										position3,
										position
									)
								end
							)
						end

						local airRocks = Rocks:AirRocks(
							cframe2,
							c_Outside.Phase1.IronSingleSpark.Size,
							true,
							math.random(50, 100),
							2,
							0,
							20,
							false,
							false,
							c_Outside.Phase1.IronSingleSpark:Clone(),
							function(instance)
								instance.Anchored = true
								instance.Main.Trail.Enabled = false
								task.wait(2)
								instance:Destroy()
							end
						)
						VisualHelper:EmitAll(airRocks.Main)
						VisualHelper:Tween(airRocks.Main.PointLight, TweenInfo.new(2.3, Enum.EasingStyle.Sine), {
							Brightness = 0
						})
					end
				elseif flag then
					flag = false
					VisualHelper:SetEnableAll(groundPart2, flag)
					VisualHelper:SetEnableAll(smokes2, flag)
				end

				for i, child in part.Surfaces:GetChildren() do
					for i2, child2 in child:GetChildren() do
						child2.Rotation += child2:GetAttribute("RotationSpeed") * 30 * dt
					end
				end
			end)
			task.delay(15, DestroyConnection)
			return
		end
	end
end