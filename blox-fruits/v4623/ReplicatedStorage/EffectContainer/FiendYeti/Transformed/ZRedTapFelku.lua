local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local FX = ReplicatedStorage:WaitForChild("FX")
local z_Tr = FX:WaitForChild("YetiEffectsRed").Z_Tr
local z_Un = FX:WaitForChild("YetiEffectsRed").Z_Un

local function preloadRetextureImages(...)
	if not RunService:IsClient() then
		return
	end

	local v = {}
	local v2 = {}

	for _, folder in { ... } do
		for _, configuration in folder:GetDescendants() do
			if not (configuration:IsA("Configuration") and configuration.Name == "RetextureForRecolor") then
				continue
			end

			local decal = configuration:FindFirstChildWhichIsA("Decal")
			local preloadTexture = configuration:GetAttribute("PreloadTexture")

			if not preloadTexture and decal then
				preloadTexture = decal.Texture
			end

			if not preloadTexture or preloadTexture == "" or v[preloadTexture] then
				continue
			end

			v[preloadTexture] = true
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Image = preloadTexture
			table.insert(v2, imageLabel)
		end
	end

	if #v2 > 0 then
		local success, result = pcall(function()
			ContentProvider:PreloadAsync(v2)
		end)

		for _, v3 in v2 do
			v3:Destroy()
		end

		if not success then
			warn("Failed to preload Z recolor textures:", result)
		end
	end
end

preloadRetextureImages(z_Tr, z_Un)
local Spikes2 = require(script.Parent.Parent.Modules.Spikes2)
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

local Beziers = require(script.Parent.Parent.Modules.Beziers)

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
	print("Running")
	local player = data.Player or data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		if data.Rig then
			local root = data.Root
			local holding = data.Holding

			if not (holding and data.Rig) then
				return
			end

			local hand2R = data.Rig.RootPart:FindFirstChild("Hand2.R", true)
			local hand2L = data.Rig.RootPart:FindFirstChild("Hand2.L", true)

			if not (hand2R and hand2L) then
				return
			end

			local worldCFrame = hand2R.WorldCFrame
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = worldCFrame
			part.Parent = workspace._WorldOrigin
			local worldCFrame2 = hand2L.WorldCFrame
			local part2 = Instance.new("Part")
			part2.Name = "Mock" .. part2.Name
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.Transparency = 1
			part2.CFrame = worldCFrame2
			part2.Parent = workspace._WorldOrigin
			part.Size = createVector(5, 5, 5)
			part2.Size = createVector(5, 5, 5)
			local clone = z_Tr.Hands.FreezeL:Clone()
			local clone2 = z_Tr.Hands.FreezeR:Clone()
			local clone3 = z_Tr.Hands.FreezeL2:Clone()
			local clone4 = z_Tr.Hands.FreezeR2:Clone()
			local v = {}
			local v2 = Util.Sound:Play("YETI_TNSFM_Z_IceClap_Charge_01", root)
			Util.SetParentOverrideWithColor(clone, part2, player, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone2, part, player, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone3, part2, player, "YetiFruitVFXColor")
			Util.SetParentOverrideWithColor(clone4, part, player, "YetiFruitVFXColor")
			emitAll(clone)
			emitAll(clone2)

			local function enableAll(folder, enabled: boolean)
				for _, effect in folder:GetDescendants() do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = enabled
					end
				end
			end

			local zCharge = root.Parent.YetiRig:FindFirstChild("YetiRig").ZCharge
			enableAll(zCharge, true)
			enableAll(clone, true)
			enableAll(clone2, true)
			table.insert(v, clone)
			table.insert(v, clone3)
			table.insert(v, clone2)
			table.insert(v, clone4)
			table.insert(v, part)
			table.insert(v, part2)
			local fCharge = root.Parent.YetiRig:FindFirstChild("YetiRig").FCharge
			task.spawn(function()
				local now = tick()

				repeat
					task.wait()

					if now < tick() then
						now = tick() + 0.075
						task.spawn(function()
							local clone5 = z_Tr.partfly:Clone()
							clone5.CFrame = fCharge["Hand2.R"].CFrame * CFrame.new(
								math.random(-15, 15),
								math.random(-1.5, 15),
								math.random(-15, 15)
							)
							Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone5, 2)
							local v3 = math.random(15, 35) / 100
							Beziers.Interpolate(
								"Cubic",
								v3,
								100,
								v3,
								nil,
								clone5.CFrame,
								clone5.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 15),
									math.random(-25, 25)
								),
								clone5.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 15),
									math.random(-25, 25)
								),
								fCharge["Hand2.R"].CFrame,
								clone5,
								"CFrame"
							)
						end)
						task.spawn(function()
							local clone5 = z_Tr.partfly:Clone()
							clone5.CFrame = fCharge["Hand2.L"].CFrame * CFrame.new(
								math.random(-15, 15),
								math.random(-1.5, 15),
								math.random(-15, 15)
							)
							Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "YetiFruitVFXColor")
							Util.Debris:AddItem(clone5, 2)
							local v3 = math.random(12, 23) / 100
							Beziers.Interpolate(
								"Cubic",
								v3,
								100,
								v3,
								nil,
								clone5.CFrame,
								clone5.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 15),
									math.random(-25, 25)
								),
								clone5.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 15),
									math.random(-25, 25)
								),
								fCharge["Hand2.L"].CFrame,
								clone5,
								"CFrame"
							)
						end)

						if root.Parent == game.Players.LocalPlayer.Character then
							Util.CameraShaker:ShakeOnce(
								3,
								3,
								0.05,
								0.1,
								createVector(0.5, 0.5, 0.5),
								createVector(0.5, 0.5, 0.5)
							)
						end
					end
				until not holding:IsDescendantOf(workspace)
			end)

			while true do
				task.wait()

				if hand2R and hand2L then
					part.CFrame = hand2R.WorldCFrame
					part2.CFrame = hand2L.WorldCFrame
				end

				if holding:IsDescendantOf(workspace) then
					continue
				end

				if v2 then
					Util.Sound:FadeOut(v2, 0.2)
				end

				task.wait(0.05)
				enableAll(zCharge, false)

				for _, folder in pairs(v) do
					if folder:IsDescendantOf(workspace) then
						for _, effect in pairs(folder:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
								effect.Enabled = false
							end
						end
					end

					local v3 = folder
					task.spawn(function()
						task.wait(1)
						v3:Destroy()
					end)
				end

				return
			end
		else
			local holding = data.Holding

			if not holding then
				return
			end

			local folder = Instance.new("Folder")
			folder.Parent = workspace._WorldOrigin

			repeat
				task.wait()
			until not holding:IsDescendantOf(workspace)

			Util.Debris:AddItem(folder, 5)
		end
	elseif stage == 2 then
		local _ = data.Root
		local player2 = data.Player

		if data.Rig then
			local cFrame = data.CFrame
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cFrame
			part.Parent = workspace._WorldOrigin
			Util.Debris:AddItem(part, 7)
			local clone = z_Tr.BackPart:Clone()
			local clone2 = z_Tr.PushForce:Clone()
			local clone3 = z_Tr.Clap:Clone()
			clone3.CFrame = part.CFrame * CFrame.new(0, 7, -3)
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone3, 1.5)
			task.spawn(function()
				task.wait(0.035)
				emitAll(clone3)
				emitAll(clone)
				emitAll(clone2)
				emitAll(data.Root.Parent.YetiRig.YetiRig.ZFireHands)
			end)
			clone.CFrame = part.CFrame * CFrame.new(0, -2, -1)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone, 1.5)
			clone2.CFrame = part.CFrame * CFrame.new(0, 35, 35)
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 1.5)
			task.spawn(function()
				local clone4 = z_Tr.Cracks:Clone()
				local lookVector = part.CFrame.LookVector
				local v = part.Position + lookVector * 1
				local ray = Util.Ray
				local v2 = { workspace.Characters, workspace.Enemies }
				local v3, v4, v5 = ray(v, createVector(0, -35, 0), v2)
				Util.Sound:Play("AkumaYeti_Z_Tap_Launch_02", part)

				if v3 then
					local v6 = v5 * 0.1
					local cFrame2 = part.CFrame
					clone4.CFrame = CFrame.new(v4 + v6) * cFrame2 - cFrame2.p
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2.5)
					Util.Debris:AddItem(clone, 2.5)
					Spikes2.Ground(
						player,
						11,
						z_Tr.IceRock,
						z_Tr.IceSpike,
						clone4,
						2,
						0.7,
						14,
						0.315,
						"BearIceSpike",
						_WorldOrigin,
						-650,
						650,
						true
					)
					Spikes2.Ground(
						player,
						11,
						z_Tr.IceRock,
						z_Tr.IceSpike2,
						clone4,
						2,
						0.7,
						14,
						0.315,
						"BearIceSpike",
						_WorldOrigin,
						-650,
						650,
						false
					)
				end
			end)

			if player2 == game.Players.LocalPlayer or (workspace.CurrentCamera.CFrame.p - origin).Magnitude <= 180 then
				task.spawn(function()
					Util.CameraShaker:ShakeOnce(
						15,
						17,
						0.05,
						1.4,
						createVector(1.5, 1.5, 1.5),
						createVector(1.5, 1.5, 1.5)
					)
					local clone4 = script.LTN:Clone()
					Util.SetParentOverrideWithColor(clone4, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2)
					TweenService:Create(clone4, TweenInfo.new(0.01), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(153, 37, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0.2,
						Contrast = 1,
						Saturation = 0.2
					}):Play()
					task.wait(0.01)
					TweenService:Create(clone4, TweenInfo.new(0.01), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0.4,
						Contrast = 0.4,
						Saturation = 0.5
					}):Play()
					task.wait(0.01)
					TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					}):Play()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 93
						}
					):Play()
					Util.Debris:AddItem(clone4, 1)
					local clone5 = script.DepthOfField:Clone()
					Util.SetParentOverrideWithColor(clone5, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone5, 2)
					TweenService:Create(clone5, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						FarIntensity = 0.4,
						FocusDistance = -50,
						InFocusRadius = -50,
						NearIntensity = 0.4
					}):Play()
					task.wait(0.1)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					TweenService:Create(clone5, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						FarIntensity = 0.5,
						FocusDistance = 250,
						InFocusRadius = 50,
						NearIntensity = 0.4
					}):Play()
					task.wait(0.1)
					TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						FarIntensity = 0,
						FocusDistance = 0,
						InFocusRadius = 0,
						NearIntensity = 0
					}):Play()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							FieldOfView = 70
						}
					):Play()
				end)
			end
		else
			print("UNTRANS BAMP HIT")
			local _ = data.Root
			local player3 = data.Player
			local cFrame = data.CFrame
			local part = Instance.new("Part")
			part.Name = "Mock" .. part.Name
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Transparency = 1
			part.CFrame = cFrame
			part.Parent = workspace._WorldOrigin
			Util.Debris:AddItem(part, 7)
			local clone = z_Un.BackPart:Clone()
			local clone2 = z_Un.PushForce:Clone()
			local clone3 = z_Un.Clap:Clone()
			clone3.CFrame = part.CFrame * CFrame.new(0, 7, -3)
			Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone3, 1.5)
			task.spawn(function()
				task.wait(0.035)
				emitAll(clone3)
				emitAll(clone)
				emitAll(clone2)
			end)
			clone.CFrame = part.CFrame * CFrame.new(0, -2, -1)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone, 1.5)
			clone2.CFrame = part.CFrame * CFrame.new(0, 35, 35)
			Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
			Util.Debris:AddItem(clone2, 1.5)
			task.spawn(function()
				local clone4 = z_Un.Cracks:Clone()
				local lookVector = part.CFrame.LookVector
				local v = part.Position + lookVector * 1
				local ray = Util.Ray
				local v2 = { workspace.Characters, workspace.Enemies }
				local v3, v4, v5 = ray(v, createVector(0, -35, 0), v2)
				Util.Sound:Play("AkumaYeti_Z_Tap_Launch_02", part)

				if v3 then
					local v6 = v5 * 0.1
					local cFrame2 = part.CFrame
					clone4.CFrame = CFrame.new(v4 + v6) * cFrame2 - cFrame2.p
					Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2.5)
					Util.Debris:AddItem(clone, 2.5)
					Spikes2.Ground(
						player,
						11,
						z_Un.IceRock,
						z_Un.IceSpike,
						clone4,
						2,
						0.7,
						14,
						0.315,
						"BearIceSpike",
						_WorldOrigin,
						-650,
						650,
						true
					)
					Spikes2.Ground(
						player,
						11,
						z_Un.IceRock,
						z_Un.IceSpike2,
						clone4,
						2,
						0.7,
						14,
						0.315,
						"BearIceSpike",
						_WorldOrigin,
						-650,
						650,
						false
					)
				end
			end)

			if player3 == game.Players.LocalPlayer or (workspace.CurrentCamera.CFrame.p - origin).Magnitude <= 180 then
				task.spawn(function()
					Util.CameraShaker:ShakeOnce(
						5,
						6,
						0.05,
						1.4,
						createVector(1.5, 1.5, 1.5),
						createVector(1.5, 1.5, 1.5)
					)
					local clone4 = script.LTN:Clone()
					Util.SetParentOverrideWithColor(clone4, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone4, 2)
					TweenService:Create(clone4, TweenInfo.new(0.01), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(153, 37, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0.2,
						Contrast = 1,
						Saturation = 0.2
					}):Play()
					task.wait(0.01)
					TweenService:Create(clone4, TweenInfo.new(0.01), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0.4,
						Contrast = 0.4,
						Saturation = 0.5
					}):Play()
					task.wait(0.01)
					TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TintColor = Util.WrapColor3ConstructorForTintColor(
							Color3.fromRGB(255, 255, 255),
							player,
							"YetiFruitVFXColor"
						),
						Brightness = 0,
						Contrast = 0,
						Saturation = 0
					}):Play()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 83
						}
					):Play()
					Util.Debris:AddItem(clone4, 1)
					local clone5 = script.DepthOfField:Clone()
					Util.SetParentOverrideWithColor(clone5, game.Lighting, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone5, 2)
					TweenService:Create(clone5, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						FarIntensity = 0.4,
						FocusDistance = -50,
						InFocusRadius = -50,
						NearIntensity = 0.4
					}):Play()
					task.wait(0.1)
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					TweenService:Create(clone5, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						FarIntensity = 0.5,
						FocusDistance = 250,
						InFocusRadius = 50,
						NearIntensity = 0.4
					}):Play()
					task.wait(0.1)
					TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						FarIntensity = 0,
						FocusDistance = 0,
						InFocusRadius = 0,
						NearIntensity = 0
					}):Play()
					TweenService:Create(
						workspace.Camera,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							FieldOfView = 70
						}
					):Play()
				end)
			end
		end
	end
end