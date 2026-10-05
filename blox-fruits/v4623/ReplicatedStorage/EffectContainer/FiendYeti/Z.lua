local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local FX = require(ReplicatedStorage.FX)
local z_Un = FX:WaitForChild("YetiEffectsRed").Z_Un

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
	Util.DestroyAfter(part, 7)
	return part
end

local Beziers = require(script.Parent.Modules.Beziers)
return function(data)
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		local holding = data.Holding

		if not (holding or holding.Value) then
			return
		end

		local clone = z_Un.Hands.FreezeL:Clone()
		local clone2 = z_Un.Hands.FreezeR:Clone()
		local clone3 = z_Un.Hands.FreezeL2:Clone()
		local clone4 = z_Un.Hands.FreezeR2:Clone()
		local clones = {}
		Util.SetParentOverrideWithColor(clone, root.Parent.LeftHand, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, root.Parent.RightHand, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone3, root.Parent.LeftHand, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone4, root.Parent.RightHand, player, "YetiFruitVFXColor")
		emitAll(clone)
		emitAll(clone2)
		clone2.Aura.Enabled = true
		clone2.SpikeSide.Enabled = true
		clone2.AuraIn.Enabled = true
		clone.Aura.Enabled = true
		clone.SpikeSide.Enabled = true
		clone2.AuraIn.Enabled = true
		table.insert(clones, clone)
		table.insert(clones, clone3)
		table.insert(clones, clone2)
		table.insert(clones, clone4)
		local v = Util.Sound:Play("YETI_UNTSFM_Z_IceClap_Charge_01", root)
		local rightHand = root.Parent:FindFirstChild("RightHand")
		local leftHand = root.Parent:FindFirstChild("LeftHand")
		local now = tick()

		while true do
			task.wait()

			if now < tick() then
				now = tick() + 0.075
				task.spawn(function()
					local clone5 = z_Un.partflybamp:Clone()
					clone5.CFrame = rightHand.CFrame * CFrame.new(
						math.random(-5, 5),
						math.random(-1.5, 5),
						math.random(-5, 5)
					)
					Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone5, 2)
					local v2 = math.random(15, 35) / 100
					Beziers.Interpolate(
						"Cubic",
						v2,
						100,
						v2,
						nil,
						clone5.CFrame,
						clone5.CFrame * CFrame.new(math.random(-10, 10), math.random(-1, 10), math.random(-10, 10)),
						clone5.CFrame * CFrame.new(math.random(-10, 10), math.random(-1, 10), math.random(-10, 10)),
						rightHand.CFrame,
						clone5,
						"CFrame"
					)
				end)
				task.spawn(function()
					local clone5 = z_Un.partflybamp:Clone()
					clone5.CFrame = leftHand.CFrame * CFrame.new(
						math.random(-5, 5),
						math.random(-1.5, 5),
						math.random(-5, 5)
					)
					Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "YetiFruitVFXColor")
					Util.Debris:AddItem(clone5, 2)
					local v2 = math.random(15, 35) / 100
					Beziers.Interpolate(
						"Cubic",
						v2,
						100,
						v2,
						nil,
						clone5.CFrame,
						clone5.CFrame * CFrame.new(math.random(-10, 10), math.random(-1, 10), math.random(-10, 10)),
						clone5.CFrame * CFrame.new(math.random(-10, 10), math.random(-1, 10), math.random(-10, 10)),
						leftHand.CFrame,
						clone5,
						"CFrame"
					)
				end)
			end

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			task.wait(0.05)

			for _, folder in pairs(clones) do
				if folder:IsDescendantOf(workspace) then
					for _, effect in pairs(folder:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							effect.Enabled = false
						end
					end
				end

				local v2 = folder
				task.spawn(function()
					task.wait(1)
					v2:Destroy()
				end)
			end

			return
		end
	elseif stage == 2 then
		local _ = data.Root
		local player2 = data.Player
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
		Util.DestroyAfter(part, 7)
		local clone = z_Un.DecalRingBlue1.ring1_1:Clone()
		local clone2 = z_Un.DecalRingBlue1.ring1_2:Clone()
		local clone3 = z_Un.DecalRingBlue2.ring2_1:Clone()
		local clone4 = z_Un.DecalRingBlue2.ring2_2:Clone()
		local clone5 = z_Un.DecalRingBlue3.ring3_1:Clone()
		local clone6 = z_Un.DecalRingBlue3.ring3_2:Clone()
		local clone7 = z_Un.DecalRingBlue4.ring4_1:Clone()
		local clone8 = z_Un.DecalRingBlue4.ring4_2:Clone()
		local clone9 = z_Un.BackPart:Clone()
		local clone10 = z_Un.Clap:Clone()
		clone10.CFrame = part.CFrame * CFrame.new(0, 1, -3)
		Util.SetParentOverrideWithColor(clone10, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone10, 1.5)
		clone7.CFrame = part.CFrame * CFrame.new(0, 0, -69.93) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)
		clone8.CFrame = part.CFrame * CFrame.new(0, 0, -69.93) * CFrame.Angles(
			0,
			1.5707963267948966,
			1.5707963267948966
		)
		Util.SetParentOverrideWithColor(clone7, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone8, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone7, 1.5)
		Util.Debris:AddItem(clone8, 1.5)
		clone.CFrame = part.CFrame * CFrame.new(0, 0, -11.655000000000001) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)
		clone2.CFrame = part.CFrame * CFrame.new(0, 0, -11.655000000000001) * CFrame.Angles(
			0,
			1.5707963267948966,
			1.5707963267948966
		)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		Util.Debris:AddItem(clone2, 1.5)
		clone3.CFrame = part.CFrame * CFrame.new(0, 0, -38.85) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)
		clone4.CFrame = part.CFrame * CFrame.new(0, 0, -38.85) * CFrame.Angles(
			0,
			1.5707963267948966,
			1.5707963267948966
		)
		Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone3, 1.5)
		Util.Debris:AddItem(clone4, 1.5)
		clone5.CFrame = part.CFrame * CFrame.new(0, 0, -69.93) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)
		clone6.CFrame = part.CFrame * CFrame.new(0, 0, -69.93) * CFrame.Angles(
			0,
			1.5707963267948966,
			1.5707963267948966
		)
		Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone5, 1.5)
		Util.Debris:AddItem(clone6, 1.5)
		task.spawn(function()
			local WAIT_INTERVAL = 0.015
			task.wait(WAIT_INTERVAL)
			TweenService:Create(clone.ring1_1, TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Scale = createVector(-24.942, -20.852, -24.942)
			}):Play()
			TweenService:Create(
				clone2.ring1_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(24.942, 20.852, 24.942)
				}
			):Play()
			TweenService:Create(
				clone.Decal1_1,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(
				clone2.Decal1_2,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			emitAll(clone.EMIT)
			task.wait(WAIT_INTERVAL)
			TweenService:Create(
				clone3.ring2_1,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(-49.925, -46.311, -49.925)
				}
			):Play()
			TweenService:Create(
				clone4.ring2_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(49.925, 46.311, 49.925)
				}
			):Play()
			TweenService:Create(
				clone3.Decal2_1,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(
				clone4.Decal2_2,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			emitAll(clone3.EMIT)
			task.wait(WAIT_INTERVAL)
			TweenService:Create(
				clone5.ring3_1,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(-72.655, -80.771, -72.655)
				}
			):Play()
			TweenService:Create(
				clone6.ring3_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(72.655, 80.771, 72.655)
				}
			):Play()
			TweenService:Create(
				clone5.Decal3_1,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(
				clone6.Decal3_2,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			emitAll(clone5.EMIT)
			task.wait(WAIT_INTERVAL)
			TweenService:Create(
				clone7.ring4_1,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(99.082, 144.604, 99.082)
				}
			):Play()
			TweenService:Create(
				clone8.ring4_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(-99.082, -144.604, -99.082)
				}
			):Play()
			TweenService:Create(
				clone7.Decal4_1,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(
				clone8.Decal4_2,
				TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut),
				{
					Transparency = 1
				}
			):Play()
			emitAll(clone7.EMIT)
		end)
		emitAll(clone10)
		clone9.CFrame = part.CFrame * CFrame.new(0, -2, -1)
		Util.SetParentOverrideWithColor(clone9, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone9, 1.5)
		emitAll(clone9)

		if (workspace.CurrentCamera.CFrame.p - origin).Magnitude <= 60 or player2 == game.Players.LocalPlayer then
			task.spawn(function()
				Util.CameraShaker:ShakeOnce(8, 11, 0.05, 0.8, createVector(1, 1, 1), createVector(1, 1, 1))
				local clone11 = script.LTN:Clone()
				Util.SetParentOverrideWithColor(clone11, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone11, 2)
				TweenService:Create(clone11, TweenInfo.new(0.01), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(147, 223, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0.5,
					Contrast = 1,
					Saturation = 0.2
				}):Play()
				task.wait(0.01)
				TweenService:Create(clone11, TweenInfo.new(0.01), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(169, 222, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0.3,
					Contrast = 0.4,
					Saturation = 0.5
				}):Play()
				task.wait(0.01)
				TweenService:Create(clone11, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				Util.Debris:AddItem(clone11, 1)
				local clone12 = script.Blur:Clone()
				Util.SetParentOverrideWithColor(clone12, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone12, 2)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						FieldOfView = 83
					}
				):Play()
				TweenService:Create(clone12, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = 15
				}):Play()
				task.wait(0.082)
				TweenService:Create(clone12, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = 0
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

		task.spawn(function()
			for _ = 1, 14 do
				local clone11 = z_Un.IceWind:Clone()
				clone11.CFrame = part.CFrame * CFrame.Angles(
					math.rad(math.random(-450, 450) / 10),
					math.rad(math.random(-450, 450) / 10),
					(math.rad(math.random(-2, 2) / 10))
				)
				clone11.Position = part.position
				clone11.Anchored = false
				Util.SetParentOverrideWithColor(clone11, _WorldOrigin, player, "YetiFruitVFXColor")
				local v = math.random(2, 5) / 5
				local v2 = math.random(10, 20) / 5

				if math.random(2) == 1 then
					v2 *= -1
				end

				for _, attachment in pairs(clone11:GetDescendants()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					attachment.Position = Vector3.new(0, attachment.Name == "Top" and v or -v, 0)
					attachment.Position += Vector3.new(0, v2, 0)
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = clone11.CFrame.LookVector * math.random(120, 320)
				Util.SetParentOverrideWithColor(bodyVelocity, clone11, player, "YetiFruitVFXColor")
				local v3 = math.random(-42, 41) / 1.5
				clone11.RotVelocity = clone11.CFrame.LookVector * v3
				coroutine.resume(coroutine.create(function()
					task.wait(math.random(50, 80) / 100)
					clone11.Anchored = true
					Util.Debris:AddItem(clone11, 1.5)
				end))
			end
		end)
		task.spawn(function()
			local clone11 = z_Un.Cracks:Clone()
			local lookVector = part.CFrame.LookVector
			local v = part.Position + lookVector * 1
			local ray = Util.Ray
			local v2 = { workspace.Characters, workspace.Enemies }
			local v3, v4, v5 = ray(v, createVector(0, -15, 0), v2)
			Util.Sound:Play(
				v3 and "YETI_UNTSFM_Z_IceClap_Fire_Ground_03_V2" or "YETI_UNTSFM_Z_IceClap_Fire_Air_03_V2",
				part.Position
			)

			if v3 then
				local v6 = v5 * 0.1
				local cFrame2 = part.CFrame
				clone11.CFrame = CFrame.new(v4 + v6) * cFrame2 - cFrame2.p
				Util.SetParentOverrideWithColor(clone11, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone11, 2.5)
				Util.Debris:AddItem(clone9, 2.5)
				local _ = clone11.CFrame
				local _ = clone11.Position
				local _ = clone11.CFrame * CFrame.new(15, 0, 0)
				local _ = clone11.Position * createVector(15, 0, 0)

				local function multNumberSequence(size, p)
					local numberSequenceKeypoints = {}

					for i = 1, #size.Keypoints do
						local keypoint = size.Keypoints[i]
						table.insert(
							numberSequenceKeypoints,
							NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p)
						)
					end

					return NumberSequence.new(numberSequenceKeypoints)
				end

				task.wait(0.035)
				coroutine.resume(coroutine.create(function()
					local folder = Instance.new("Folder", _WorldOrigin)
					Util.Debris:AddItem(folder, 5)
					local total = 8
					local total2 = 6

					for _ = 1, 13 do
						local v7 = math.random(-1350, 1350) / 100
						local cFrame3 = clone11.CFrame * CFrame.new(v7, math.random(0.3, 1.5), -total) * CFrame.Angles(
							math.rad((math.random(-6, 6))),
							math.rad((math.random(-360, 360))),
							(math.rad((math.random(-6, 6))))
						)
						local ray2 = Util.Ray
						local position = cFrame3.Position
						local v9 = { workspace.Characters, workspace.Enemies }
						local v10, _, _ = ray2(position, createVector(-0, -15, -0), v9)

						if not v10 then
							continue
						end

						local clone12 = z_Un.GroundHold:Clone()
						clone12.CFrame = cFrame3
						clone12.Size = createVector(1, 1, 1)
						Util.SetParentOverrideWithColor(clone12, folder, player, "YetiFruitVFXColor")
						TweenService:Create(
							clone12,
							TweenInfo.new(0.175, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = createVector(4.5, 0.6, 4.5) * total2 / 2,
								CFrame = clone12.CFrame * CFrame.new(
									math.random(-1, 1),
									math.random(0.2, 0.6),
									math.random(-1.5, 1.5)
								)
							}
						):Play()
						local size = clone12.Attachment.White.Size
						clone12.Attachment.White.Size = multNumberSequence(size, total2 / 10)
						emitAll(clone12)
						task.delay(0.175 + math.random() * 0.2, function()
							TweenService:Create(
								clone12,
								TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Size = clone12.Size * createVector(0, 0, 0),
									CFrame = clone12.CFrame * CFrame.new(0, -4, 0)
								}
							):Play()
							task.spawn(function()
								task.wait(0.7)
								clone12.Attachment.Rocks:Emit(4)
							end)
						end)
						total += 7
						total2 += 1.8
					end
				end))
			end
		end)
	end
end