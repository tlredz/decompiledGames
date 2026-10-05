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

	local function RESSSSModel(player2, root2, model)
		if typeof(player2) == "Instance" then
			if player2:IsA("Player") then
				return player2.Character
			end

			if player2:IsA("Model") then
				return player2
			end
		end

		if typeof(model) == "Instance" and model:IsA("Model") then
			return model
		end

		if root2 then
			return root2:FindFirstAncestorOfClass("Model")
		end

		return nil
	end

	local rESSSSModel = RESSSSModel(player, root, rig)
	game:GetService("Debris")

	if rig then
		Util.Sound:Play("AkumaYeti_Z_Flamethrower_Start_01", root)
		local v2 = Util.Sound:Play("AkumaYeti_Z_Flamethrower_Loop_01", root)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(v2, TweenInfo.new(0.55), {
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
		clone.Parent = attachment
		local clone2 = z_Tr.FLAMETHROW2.flames:Clone()
		clone2.Parent = attachment

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		emitAll(clone2)
		local heartbeatConnection = nil
		local thread = task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken do
				if player then
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
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
			{
				FieldOfView = 85
			}
		):Play()
		local model = rig

		if (typeof(model) ~= "Instance" or not model:IsA("Model")) and rESSSSModel then
			local yetiRig = rESSSSModel:FindFirstChild("YetiRig")

			if yetiRig then
				local yetiRig2 = yetiRig:FindFirstChild("YetiRig")

				if yetiRig2 and yetiRig2:IsA("Model") then
					model = yetiRig2
				end
			end
		end

		local rootPart = model and model:FindFirstChild("RootPart")

		if rootPart and rootPart:IsA("BasePart") then
			local zChargeImpact = rootPart:FindFirstChild("ZChargeImpact")

			if zChargeImpact and zChargeImpact:IsA("Attachment") then
				emitAll(zChargeImpact)
			end
		end

		task.spawn(function()
			if player then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 0.3)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Color3.fromRGB(151, 25, 255),
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
						TintColor = Color3.fromRGB(173, 119, 255),
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
						TintColor = Color3.fromRGB(255, 255, 255),
						Brightness = 0,
						Saturation = 0,
						Contrast = 0
					}
				):Play()
			end
		end)
		local v3 = nil
		local yetiRig

		if typeof(rig) == "Instance" and rig:IsA("Model") or not rESSSSModel then
			yetiRig = rig
		else
			local yetiRig2 = rESSSSModel:FindFirstChild("YetiRig")
			yetiRig = yetiRig2 and yetiRig2:FindFirstChild("YetiRig")

			if yetiRig then
				if not yetiRig:IsA("Model") then
					yetiRig = rig
				end
			else
				yetiRig = rig
			end
		end

		local rootPart2 = yetiRig and yetiRig:FindFirstChild("RootPart")

		if rootPart2 and rootPart2:IsA("BasePart") then
			local zCharge = rootPart2:FindFirstChild("ZCharge")

			if zCharge then
				local light = zCharge:FindFirstChild("Light")

				if light and light:IsA("PointLight") then
					v3 = light
				end
			end
		end

		v3.Brightness = 35
		v3.Range = 24
		task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken do
				v3.Brightness = math.random(120, 450) / 10
				v3.Range = math.random(120, 270) / 10
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

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
			end

			Util.Sound:Play("AkumaYeti_Z_Flamethrower_Loop_02", root)

			if v3 then
				v3.Brightness = 0
				v3.Range = 0
			end

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

		local v4 = time()
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken or not (time() - v4 > 1) then
				if not (root and root.Parent) then
					cleanup()
					return
				end

				local _ = data.CFrame
				local unit = ((data.MousePos.Value - root.Position).Unit * createVector(1, 0.01, 1)).Unit
				local v5 = root.CFrame * cframe
				part.CFrame = CFrame.lookAt(v5.Position, v5.Position + unit)
			else
				cleanup()
				local model2 = rig

				if (typeof(model2) ~= "Instance" or not model2:IsA("Model")) and rESSSSModel then
					local yetiRig2 = rESSSSModel:FindFirstChild("YetiRig")
					local yetiRig3 = yetiRig2 and yetiRig2:FindFirstChild("YetiRig")

					if yetiRig3 and yetiRig3:IsA("Model") then
						model2 = yetiRig3
					end
				end

				if model2 then
					local zFireHands = model2:FindFirstChild("ZFireHands")

					if zFireHands and zFireHands:IsA("Attachment") then
						emitAll(zFireHands)
					end
				end
			end
		end)
	else
		CFrame.new(0, 0, -6)
		Util.Sound:Play("AkumaYeti_Z_Flamethrower_Start_01", root)
		local v2 = Util.Sound:Play("AkumaYeti_Z_Flamethrower_Loop_01", root)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(v2, TweenInfo.new(0.55), {
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
		clone.Parent = attachment
		local clone2 = z_Un.FLAMETHROW2.flames:Clone()
		clone2.Parent = attachment

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		emitAll(clone2)
		local heartbeatConnection = nil
		local thread = task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken do
				if player then
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
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
			{
				FieldOfView = 80
			}
		):Play()
		task.spawn(function()
			if player then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game.Lighting
				Util.Debris:AddItem(colorCorrectionEffect, 0.3)
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						TintColor = Color3.fromRGB(151, 25, 255),
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
						TintColor = Color3.fromRGB(173, 119, 255),
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
						TintColor = Color3.fromRGB(255, 255, 255),
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
		pointLight.Color = Color3.fromRGB(158, 79, 255)
		task.spawn(function()
			while holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken do
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

			if v2 then
				Util.Sound:FadeOut(v2, 0.2)
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

		local v3 = time()
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if holding.Value and holding:GetAttribute("HoldReleasedToken") ~= data.HoldReleasedToken or not (time() - v3 > 1) then
				if not (root and root.Parent) then
					cleanup()
					return
				end

				local _ = data.CFrame
				local unit = ((data.MousePos.Value - root.Position).Unit * createVector(1, 0.01, 1)).Unit
				local v4 = root.CFrame * cframe
				part.CFrame = CFrame.lookAt(v4.Position, v4.Position + unit)
			else
				cleanup()
				local clone3 = z_Un.RFire.Impact3:Clone()
				clone3.Parent = player.Character.RightHand
				emitAll(clone3)
				Util.Debris:AddItem(clone3, 2)
				local clone4 = z_Un.LFire.Impact3:Clone()
				clone4.Parent = player.Character.LeftHand
				emitAll(clone4)
				Util.Debris:AddItem(clone4, 2)
			end
		end)
	end
end