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
local z_Tr = FX:WaitForChild("YetiEffects").Z_Tr
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
	local player = data.player
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local root = data.Root
		local holding = data.Holding

		if not ((holding or holding.Value) and data.Rig) then
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
							clone5.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
							clone5.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
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
							clone5.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
							clone5.CFrame * CFrame.new(math.random(-25, 25), math.random(-1, 15), math.random(-25, 25)),
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
			until not (holding:IsDescendantOf(workspace) and holding.Value)
		end)

		while true do
			task.wait()

			if hand2R and hand2L then
				part.CFrame = hand2R.WorldCFrame
				part2.CFrame = hand2L.WorldCFrame
			end

			if holding:IsDescendantOf(workspace) and holding.Value then
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
		Util.Debris:AddItem(part, 7)
		local clone = z_Tr.DecalRingBlue1.ring1_1:Clone()
		local clone2 = z_Tr.DecalRingBlue1.ring1_2:Clone()
		local clone3 = z_Tr.DecalRingBlue2.ring2_1:Clone()
		local clone4 = z_Tr.DecalRingBlue2.ring2_2:Clone()
		local clone5 = z_Tr.DecalRingBlue3.ring3_1:Clone()
		local clone6 = z_Tr.DecalRingBlue3.ring3_2:Clone()
		local clone7 = z_Tr.DecalRingBlue4.ring4_1:Clone()
		local clone8 = z_Tr.DecalRingBlue4.ring4_2:Clone()
		local clone9 = z_Tr.BackPart:Clone()
		local clone10 = z_Tr.PushForce:Clone()
		local clone11 = z_Tr.Clap:Clone()
		clone11.CFrame = part.CFrame * CFrame.new(0, 7, -3)
		Util.SetParentOverrideWithColor(clone11, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone11, 1.5)
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
		clone3.CFrame = part.CFrame * CFrame.new(0, 0, -50.505) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)
		clone4.CFrame = part.CFrame * CFrame.new(0, 0, -50.505) * CFrame.Angles(
			0,
			1.5707963267948966,
			1.5707963267948966
		)
		Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone3, 1.5)
		Util.Debris:AddItem(clone4, 1.5)
		clone5.CFrame = part.CFrame * CFrame.new(0, 0, -108.78) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)
		clone6.CFrame = part.CFrame * CFrame.new(0, 0, -108.78) * CFrame.Angles(
			0,
			1.5707963267948966,
			1.5707963267948966
		)
		Util.SetParentOverrideWithColor(clone5, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone6, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone5, 1.5)
		Util.Debris:AddItem(clone6, 1.5)
		clone7.CFrame = part.CFrame * CFrame.new(0, 0, -170.94) * CFrame.Angles(
			0,
			-1.5707963267948966,
			1.5707963267948966
		)
		clone8.CFrame = part.CFrame * CFrame.new(0, 0, -170.94) * CFrame.Angles(
			0,
			1.5707963267948966,
			1.5707963267948966
		)
		Util.SetParentOverrideWithColor(clone7, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.SetParentOverrideWithColor(clone8, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone7, 1.5)
		Util.Debris:AddItem(clone8, 1.5)
		task.spawn(function()
			local WAIT_INTERVAL = 0.035
			task.wait(WAIT_INTERVAL)
			emitAll(clone11)
			emitAll(clone9)
			emitAll(clone10)
			TweenService:Create(clone.ring1_1, TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Scale = createVector(-27.612, -70.397, -27.612)
			}):Play()
			TweenService:Create(
				clone2.ring1_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(27.612, 70.397, 27.612)
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
					Scale = createVector(-66.946, -97.509, -66.946)
				}
			):Play()
			TweenService:Create(
				clone4.ring2_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(66.946, 97.509, 66.946)
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
					Scale = createVector(-108.827, -167.742, -108.827)
				}
			):Play()
			TweenService:Create(
				clone6.ring3_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(108.827, 167.742, 108.827)
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
					Scale = createVector(160.451, 294.019, 160.451)
				}
			):Play()
			TweenService:Create(
				clone8.ring4_2,
				TweenInfo.new(0.817, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Scale = createVector(-160.451, -294.018, -160.451)
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
		clone9.CFrame = part.CFrame * CFrame.new(0, -2, -1)
		Util.SetParentOverrideWithColor(clone9, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone9, 1.5)
		clone10.CFrame = part.CFrame * CFrame.new(0, 35, 35)
		Util.SetParentOverrideWithColor(clone10, _WorldOrigin, player, "YetiFruitVFXColor")
		Util.Debris:AddItem(clone10, 1.5)
		task.spawn(function()
			local clone12 = z_Tr.Cracks:Clone()
			local lookVector = part.CFrame.LookVector
			local v = part.Position + lookVector * 1
			local ray = Util.Ray
			local v2 = { workspace.Characters, workspace.Enemies }
			local v3, v4, v5 = ray(v, createVector(0, -35, 0), v2)
			Util.Sound:Play(
				v3 and "YETI_TSFM_Z_IceClap_LaunchGround_02_V2" or "YETI_TSFM_Z_IceClap_LaunchAir_02_V2",
				part.Position
			)

			if v3 then
				local v6 = v5 * 0.1
				local cFrame2 = part.CFrame
				clone12.CFrame = CFrame.new(v4 + v6) * cFrame2 - cFrame2.p
				Util.SetParentOverrideWithColor(clone12, _WorldOrigin, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone12, 2.5)
				Util.Debris:AddItem(clone9, 2.5)

				if data.Tool.IsDemonOgreMutant.Value == false then
					Spikes2.Ground(
						player,
						11,
						z_Tr.IceRock,
						z_Tr.IceSpike,
						clone12,
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
						clone12,
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
				else
					Spikes2.Ground(
						player,
						11,
						z_Tr.IceRock,
						z_Tr.RedSpike,
						clone12,
						2,
						1.2,
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
						z_Tr.RedSpike,
						clone12,
						2,
						1.2,
						14,
						0.315,
						"BearIceSpike",
						_WorldOrigin,
						-650,
						650,
						false
					)
				end
			end
		end)
		task.spawn(function()
			for _ = 1, 24 do
				local clone12 = z_Tr.IceWind:Clone()
				clone12.CFrame = part.CFrame * CFrame.Angles(
					math.rad(math.random(-350, 350) / 10),
					math.rad(math.random(-250, 250) / 10),
					(math.rad(math.random(-2, 2) / 10))
				)
				clone12.Position = part.position
				clone12.Anchored = false
				Util.SetParentOverrideWithColor(clone12, _WorldOrigin, player, "YetiFruitVFXColor")
				local v = math.random(5, 13) / 5
				local v2 = math.random(20, 60) / 5

				if math.random(2) == 1 then
					v2 *= -1
				end

				for _, attachment in pairs(clone12:GetDescendants()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					attachment.Position = Vector3.new(0, attachment.Name == "Top" and v or -v, 0)
					attachment.Position += Vector3.new(0, v2, 0)
				end

				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Velocity = clone12.CFrame.LookVector * math.random(140, 290)
				Util.SetParentOverrideWithColor(bodyVelocity, clone12, player, "YetiFruitVFXColor")
				local v3 = math.random(-22, 21) / 1.5
				clone12.RotVelocity = clone12.CFrame.LookVector * v3
				coroutine.resume(coroutine.create(function()
					task.wait(math.random(110, 130) / 100)
					clone12.Anchored = true
					Util.Debris:AddItem(clone12, 1.5)
				end))
			end
		end)

		if player2 == game.Players.LocalPlayer or (workspace.CurrentCamera.CFrame.p - origin).Magnitude <= 180 then
			task.spawn(function()
				local clone12 = z_Tr.BillboardGui:Clone()
				local imageLabel = clone12:WaitForChild("ImageLabel")
				Util.SetParentOverrideWithColor(clone12, part, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone12, 4)
				imageLabel.Size = UDim2.new(0, 0, 0, 0)
				imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				TweenService:Create(
					imageLabel,
					TweenInfo.new(0.356, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
					{
						Size = UDim2.new(1, 0, 1, 0),
						Position = UDim2.new(0, 0, 0, 0),
						ImageTransparency = 1
					}
				):Play()
				Util.CameraShaker:ShakeOnce(15, 17, 0.05, 1.4, createVector(1.5, 1.5, 1.5), createVector(1.5, 1.5, 1.5))
				local clone13 = script.LTN:Clone()
				Util.SetParentOverrideWithColor(clone13, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone13, 2)
				TweenService:Create(clone13, TweenInfo.new(0.01), {
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(84, 110, 255),
						player,
						"YetiFruitVFXColor"
					),
					Brightness = 0.2,
					Contrast = 1,
					Saturation = 0.2
				}):Play()
				task.wait(0.01)
				TweenService:Create(clone13, TweenInfo.new(0.01), {
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
				TweenService:Create(clone13, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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
						FieldOfView = 113
					}
				):Play()
				Util.Debris:AddItem(clone13, 1)
				local clone14 = script.DepthOfField:Clone()
				Util.SetParentOverrideWithColor(clone14, game.Lighting, player, "YetiFruitVFXColor")
				Util.Debris:AddItem(clone14, 2)
				TweenService:Create(clone14, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
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
				TweenService:Create(clone14, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					FarIntensity = 0.5,
					FocusDistance = 250,
					InFocusRadius = 50,
					NearIntensity = 0.4
				}):Play()
				task.wait(0.1)
				TweenService:Create(clone14, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
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