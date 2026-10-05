local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local FX = ReplicatedStorage:WaitForChild("FX")
local z_Tr = FX:WaitForChild("YetiEffectsRed").Z_Tr
local z_Un = FX:WaitForChild("YetiEffectsRed").Z_Un
require(script.Parent.Parent.Modules.Spikes2)
Util.ResizeModel(z_Tr.Hands, 2)
require(script.Parent.Parent.Modules.Beziers)

local function mockRootPart(cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = workspace._WorldOrigin
	return part
end

return function(data)
	print("Running held")
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local player = data.Player
	local root = data.Root
	local _ = data.Origin
	local rig = data.Rig
	local holding = data.Holding
	local cFrame = data.CFrame

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
						if holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken then
							v:Emit(v2)
						end
					end)
				else
					emitter:Emit(emitCount)
				end
			else
				emitter:Emit(1)
			end
		end
	end

	game:GetService("Debris")

	if rig then
		Util.Sound:Play("AkumaYeti_Z_Flamethrower_Start_01", root)
		local v = Util.Sound:Play("AkumaYeti_Z_Flamethrower_Loop_01", root)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(v, TweenInfo.new(0.55), {
			Volume = 1
		}):Play()
		CFrame.new(0, 0, -6)
		local cframe = CFrame.new(0, 1.3, -1)
		local part = Instance.new("Part")
		part.Name = "HeldFlameCaster"
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.Size = createVector(0.2, 0.2, 0.2)
		part.Parent = _WorldOrigin
		local attachment = Instance.new("Attachment")
		attachment.Name = "FlameAttachment"
		attachment.Parent = part
		local clone = z_Tr.FLAMETHROW.flames:Clone()
		Util.SetParentOverrideWithColor(clone, attachment, player, "YetiFruitVFXColor")
		local clone2 = z_Tr.FLAMETHROW2.flames:Clone()
		Util.SetParentOverrideWithColor(clone2, attachment, player, "YetiFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		emitAll(clone2)
		local heartbeatConnection = nil
		local thread = task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken do
				local Players = game:GetService("Players")

				if player == Players.LocalPlayer or (workspace.CurrentCamera.CFrame.p - origin).Magnitude <= 150 then
					Util.CameraShaker:ShakeOnce(
						2.3,
						5.7,
						0.05,
						0.3,
						createVector(0.8, 0.8, 0.8),
						createVector(0.8, 0.8, 0.8)
					)
				end

				task.wait(0.08)
			end
		end)
		local Players = game:GetService("Players")

		if player == Players.LocalPlayer then
			TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
				{
					FieldOfView = 85
				}
			):Play()
		end

		emitAll(player.Character.YetiRig.YetiRig.RootPart.ZChargeImpact)
		task.spawn(function()
			local Players2 = game:GetService("Players")

			if player == Players2.LocalPlayer then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 0.3)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(151, 25, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = -0.4,
						Saturation = -0.4,
						Contrast = 8
					}
				):Play()
				task.wait(0.05)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(173, 119, 255),
							player,
							"YetiFruitVFXColor"
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
							"YetiFruitVFXColor"
						),
						Brightness = 0,
						Saturation = 0,
						Contrast = 0
					}
				):Play()
			end
		end)
		local light = player.Character.YetiRig.YetiRig.RootPart.ZCharge.Light
		light.Brightness = 35
		light.Range = 24
		task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken and holding:IsDescendantOf(workspace) do
				light.Brightness = math.random(120, 450) / 10
				light.Range = math.random(120, 270) / 10
				task.wait(0.05)
			end
		end)

		local function cleanup()
			print("cleanup")
			heartbeatConnection:Disconnect()

			if thread then
				task.cancel(thread)
				thread = nil
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			Util.Sound:Play("AkumaYeti_Z_Flamethrower_Loop_02", root)
			player.Character.YetiRig.YetiRig.RootPart.ZCharge.Light.Brightness = 0
			player.Character.YetiRig.YetiRig.RootPart.ZCharge.Light.Range = 0
			TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2), {
				FieldOfView = 70
			}):Play()

			if part then
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.delay(1, function()
					part:Destroy()
				end)
			end
		end

		time()
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken and holding:IsDescendantOf(workspace) then
				if not (root and root.Parent) then
					cleanup()
					return
				end

				local _ = data.CFrame
				local unit = ((data.MousePos.Value - root.Position).Unit * createVector(1, 0.01, 1)).Unit
				local v2 = root.CFrame * cframe
				part.CFrame = CFrame.lookAt(v2.Position, v2.Position + unit)
			else
				cleanup()
				emitAll(player.Character.YetiRig.YetiRig.ZFireHands)
			end
		end)
	else
		CFrame.new(0, 0, -6)
		Util.Sound:Play("AkumaYeti_Z_Flamethrower_Start_01", root)
		local v = Util.Sound:Play("AkumaYeti_Z_Flamethrower_Loop_01", root)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(v, TweenInfo.new(0.55), {
			Volume = 1
		}):Play()
		local cframe = CFrame.new(0, 1.3, -1)
		local part = Instance.new("Part")
		part.Name = "HeldFlameCaster"
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Transparency = 1
		part.Size = createVector(0.2, 0.2, 0.2)
		part.Parent = _WorldOrigin
		local attachment = Instance.new("Attachment")
		attachment.Name = "FlameAttachment"
		attachment.Parent = part
		local clone = z_Un.FLAMETHROW.flames:Clone()
		Util.SetParentOverrideWithColor(clone, attachment, player, "YetiFruitVFXColor")
		local clone2 = z_Un.FLAMETHROW2.flames:Clone()
		Util.SetParentOverrideWithColor(clone2, attachment, player, "YetiFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		emitAll(clone2)
		local heartbeatConnection = nil
		local thread = task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken and holding:IsDescendantOf(workspace) do
				local Players = game:GetService("Players")

				if player == Players.LocalPlayer or (workspace.CurrentCamera.CFrame.p - origin).Magnitude <= 150 then
					Util.CameraShaker:ShakeOnce(
						1.5,
						3.8,
						0.05,
						0.3,
						createVector(0.8, 0.8, 0.8),
						createVector(0.8, 0.8, 0.8)
					)
				end

				task.wait(0.08)
			end
		end)
		local Players = game:GetService("Players")

		if player == Players.LocalPlayer then
			TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
				{
					FieldOfView = 80
				}
			):Play()
		end

		task.spawn(function()
			local Players2 = game:GetService("Players")

			if player == Players2.LocalPlayer then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 0.3)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(151, 25, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = -0.2,
						Saturation = -0.2,
						Contrast = 4
					}
				):Play()
				task.wait(0.05)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(173, 119, 255),
							player,
							"YetiFruitVFXColor"
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
							"YetiFruitVFXColor"
						),
						Brightness = 0,
						Saturation = 0,
						Contrast = 0
					}
				):Play()
			end
		end)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = player.Character.PrimaryPart
		pointLight.Name = "XUnlight"
		pointLight.Brightness = 13
		pointLight.Range = 9
		pointLight.Color = Util.WrapColor3Constructor(Color3.fromRGB(158, 79, 255), player, "YetiFruitVFXColor")
		task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken and holding:IsDescendantOf(workspace) do
				pointLight.Brightness = math.random(70, 220) / 10
				pointLight.Range = math.random(80, 150) / 10
				task.wait(0.05)
			end
		end)

		local function cleanup()
			print("cleanup")
			pointLight:Destroy()
			heartbeatConnection:Disconnect()

			if thread then
				task.cancel(thread)
				thread = nil
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			Util.Sound:Play("AkumaYeti_Z_Flamethrower_Loop_02", root)
			TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2), {
				FieldOfView = 70
			}):Play()

			if part then
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.delay(1, function()
					part:Destroy()
				end)
			end
		end

		time()
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken and holding:IsDescendantOf(workspace) then
				if not (root and root.Parent) then
					cleanup()
					return
				end

				local _ = data.CFrame
				local unit = ((data.MousePos.Value - root.Position).Unit * createVector(1, 0.01, 1)).Unit
				local v2 = root.CFrame * cframe
				part.CFrame = CFrame.lookAt(v2.Position, v2.Position + unit)
			else
				cleanup()
				local clone3 = z_Un.RFire.Impact3:Clone()
				Util.SetParentOverrideWithColor(clone3, player.Character.RightHand, player, "YetiFruitVFXColor")
				emitAll(clone3)
				Util.Debris:AddItem(clone3, 2)
				local clone4 = z_Un.LFire.Impact3:Clone()
				Util.SetParentOverrideWithColor(clone4, player.Character.LeftHand, player, "YetiFruitVFXColor")
				emitAll(clone4)
				Util.Debris:AddItem(clone4, 2)
			end
		end)
	end
end