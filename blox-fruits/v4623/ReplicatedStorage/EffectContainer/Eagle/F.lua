local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local eagleZ = FX:WaitForChild("Eagle").EagleZ
local _WorldOrigin = workspace._WorldOrigin
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local random = Random.new()

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			if effect:GetAttribute("EmitDelay") then
				local v = effect
				delay(effect:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				effect:Emit(effect:GetAttribute("EmitCount"))
			end
		else
			effect.Enabled = enabled
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
return function(data)
	local player = data.player
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor", true)
		local flying = data.Flying

		if not flying then
			return
		end

		local random2 = Random.new(data.Seed)
		local windUp = data.WindUp
		local char = data.Char
		local root = data.Root
		local humanoid = char:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		local startCFrame = data.StartCFrame
		local clone = eagleZ.TransformEnable:Clone()
		clone.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone, player, "EagleFruitVFXColor", true)
		Util.BodyMover.new(char):Create("BodyPosition", {
			Position = startCFrame.Position + createVector(0, 1, 0) * data.UpDistance,
			Priority = 100000,
			P = 1500,
			Duration = windUp
		})
		local clone2 = eagleZ.Launch:Clone()
		clone2.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone2, player, "EagleFruitVFXColor", true)
		Util.Sound:Play("EagleFt_F_Transform_03_V1", root)
		task.spawn(function()
			local lastTime = os.clock()

			while os.clock() - lastTime <= windUp do
				task.spawn(function()
					local clone3 = eagleZ["Bezier" .. random:NextInteger(1, 2)]:Clone()
					local position2 = root.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					)
					local v2 = root.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					)
					local v3 = root.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					)
					local position = root.Position
					clone3.Position = position2
					Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor", true)
					Util.SyncColorsOnChange(clone3, player, "EagleFruitVFXColor", true)
					clone3.Trail.Lifetime = random:NextNumber(0.05, 0.2)

					for i = 0, 1, 0.1 do
						position = root.Position
						local v4 = position2 + (v2 - position2) * i
						local v5 = v2 + (v3 - v2) * i
						local v6 = v3 + (position - v3) * i
						local v7 = v4 + (v5 - v4) * i
						clone3.Position = v7 + (v5 + (v6 - v5) * i - v7) * i
						task.wait(0.015)
					end

					clone3.Position = position
				end)
				task.wait(random:NextNumber(0.02, 0.045))
			end
		end)
		task.wait(windUp * 0.7)
		local clone3 = eagleZ.Circle:Clone()
		clone3.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone3, player, "EagleFruitVFXColor", true)
		TweenService:Create(clone3, TweenInfo.new(windUp * 0.1, Enum.EasingStyle.Linear), {
			Size = createVector(30, 30, 30)
		}):Play()
		local clone4 = eagleZ.BehindCircle:Clone()
		clone4.CFrame = clone3.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone4, player, "EagleFruitVFXColor", true)
		TweenService:Create(clone4, TweenInfo.new(windUp * 0.2, Enum.EasingStyle.Linear), {
			Size = createVector(35, 35, 35)
		}):Play()
		task.wait(windUp * 0.2)
		clone3:Destroy()
		clone4:Destroy()
		local clone5 = eagleZ.CircleDisapear:Clone()
		clone5.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone5, folder, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone5, player, "EagleFruitVFXColor", true)
		ParticleState(clone5)
		task.wait(windUp * 0.1)

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local clone6 = eagleZ.Transform:Clone()
		clone6.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone6, folder, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone6, player, "EagleFruitVFXColor", true)
		ParticleState(clone6)

		if (currentCamera.CFrame.p - clone6.Position).Magnitude <= 80 then
			Util.CameraShaker:ShakeOnce(24, 16, 0.2, 0.25)
		end

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local clone7 = eagleZ.WingRoot:Clone()
		clone7.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone7, char, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone7, player, "EagleFruitVFXColor", true)
		local v = nil
		local raycastResult = nil
		local v2 = false
		local v3 = false
		local clone8 = eagleZ.FloorTrail:Clone()
		Util.SetParentOverrideWithColor(clone8, root, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone8, player, "EagleFruitVFXColor", true)
		local clone9 = eagleZ.Flight:Clone()
		Util.SetParentOverrideWithColor(clone9, root, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone9, player, "EagleFruitVFXColor", true)
		local position = nil
		local color = nil
		local v4 = nil

		local function playFlightSound(p)
			if v4 and v4.Name == p then
				return
			end

			if v4 then
				Util.Sound:FadeOut(v4, 0.2)
			end

			v4 = Util.Sound:Play(p, root)
			TweenService:Create(v4, TweenInfo.new(0.4), {
				Volume = 0.3
			}):Play()
		end

		playFlightSound("EagleFt_F_FlightLoop_01_V1")
		local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if root and not root:FindFirstChildOfClass("BodyGyro") then
				raycastResult = workspace:Raycast(root.Position, createVector(0, -15, 0), raycastParams)

				if raycastResult then
					if position == nil then
						position = raycastResult.Position
					else
						clone8.CFrame = CFrame.lookAt(raycastResult.Position, position) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						)
						position = raycastResult.Position

						if v2 == false or raycastResult.Instance.Color ~= color then
							color = raycastResult.Instance.Color

							if v2 == false then
								playFlightSound("EagleFt_F_FlightLoop_Ground_Additional_01_V1")
							end

							ParticleState(clone8, true, raycastResult.Instance.Color)
							v2 = true
						end
					end
				elseif v2 == true then
					local folder2 = clone8

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					v2 = false
					playFlightSound("EagleFt_F_FlightLoop_Moving_01_V1")
					position = nil
				end

				v = (humanoid.MoveDirection ~= createVector(0, 0, 0) and currentCamera.CFrame.LookVector * 1 or createVector(
					0,
					0,
					0
				)) * 110 * (0.5 + 0.5 * (humanoid.Health / humanoid.MaxHealth))

				if v == createVector(0, 0, 0) and v2 == true or v == createVector(0, 0, 0) and v3 == true then
					local folder2 = clone9

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					playFlightSound("EagleFt_F_FlightLoop_01_V1")
					v2 = raycastResult ~= nil

					if not v2 then
						local folder3 = clone8

						for _, effect in pairs(folder3:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end

					v3 = false
				elseif v3 == false and v ~= createVector(0, 0, 0) then
					local folder2 = clone9

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end

					playFlightSound("EagleFt_F_FlightLoop_Moving_01_V1")
					v3 = true
				end

				clone9.CFrame = CFrame.lookAt(root.Position, root.Position + root.Velocity)
			elseif v2 or v3 then
				local folder2 = clone8

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				local folder3 = clone9

				for _, effect in pairs(folder3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				playFlightSound("EagleFt_F_FlightLoop_Moving_01_V1")
				v2 = false
				v3 = false
			end
		end)
		task.spawn(function()
			local lastTime = os.clock()
			os.clock()

			while true do
				if os.clock() - lastTime >= random:NextNumber(0.2, 0.4) then
					lastTime = os.clock()
					local cframe = CFrame.new(
						random:NextNumber(-clone7.Wing1.Size.X / 2, clone7.Wing1.Size.X / 2),
						random:NextNumber(-clone7.Wing1.Size.Y / 2, clone7.Wing1.Size.Y / 2),
						random:NextInteger(-clone7.Wing1.Size.Z / 2, clone7.Wing1.Size.Z / 2)
					)
					local clone10 = eagleZ["Feather" .. math.random(1, 4)]:Clone()
					clone10.CFrame = clone7["Wing" .. random:NextInteger(1, 2)].CFrame * cframe * CFrame.Angles(
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586)
					)
					Util.SetParentOverrideWithColor(clone10, folder, player, "EagleFruitVFXColor", true)
					Util.SyncColorsOnChange(clone10, player, "EagleFruitVFXColor", true)
					Util.Debris:AddItem(clone10, 1)
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					).Unit * random:NextNumber(10, 30)
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					Util.SetParentOverrideWithColor(bodyVelocity, clone10, player, "EagleFruitVFXColor", true)
					Util.SyncColorsOnChange(bodyVelocity, player, "EagleFruitVFXColor", true)
					TweenService:Create(bodyVelocity, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Velocity = createVector(0, -40, 0)
					}):Play()
					task.delay(random:NextNumber(0.2, 0.4), function()
						local folder2 = clone10

						for i, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end
					end)
				end

				task.wait()

				if flying.Parent and flying.Value then
					continue
				end

				if v4 then
					Util.Sound:FadeOut(v4, 0.2)
				end

				task.delay(5, function()
					folder:Destroy()
				end)

				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end

				local folder2 = clone7

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				task.delay(1.5, clone7.Destroy, clone7)
				local folder3 = clone9

				for _, effect in pairs(folder3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				local folder4 = clone8

				for _, effect in pairs(folder4:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				task.delay(0.7, clone8.Destroy, clone8)
				task.delay(0.7, clone9.Destroy, clone9)
				break
			end
		end)
		local featherCount = data.FeatherCount
		local feathersCF = data.FeathersCF

		for _ = 0, featherCount do
			task.spawn(function()
				local clone10 = eagleZ["Feather" .. math.random(1, 4)]:Clone()
				clone10.CFrame = feathersCF * CFrame.Angles(
					random2:NextNumber(0, 6.283185307179586),
					random2:NextNumber(0, 6.283185307179586),
					random2:NextNumber(0, 6.283185307179586)
				)
				Util.SetParentOverrideWithColor(clone10, folder, player, "EagleFruitVFXColor", true)
				Util.SyncColorsOnChange(clone10, player, "EagleFruitVFXColor", true)
				local v5 = false
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = clone10.CFrame.LookVector * 100
				bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
				Util.SetParentOverrideWithColor(bodyVelocity, clone10, player, "EagleFruitVFXColor", true)
				Util.SyncColorsOnChange(bodyVelocity, player, "EagleFruitVFXColor", true)
				TweenService:Create(bodyVelocity, TweenInfo.new(0.7, Enum.EasingStyle.Linear), {
					Velocity = createVector(0, -40, 0)
				}):Play()
				TweenService:Create(
					clone10,
					TweenInfo.new(random2:NextNumber(0.3, 0.6), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Orientation = Vector3.new(
							random2:NextNumber(0, 360),
							random2:NextNumber(0, 360),
							random2:NextNumber(0, 360)
						)
					}
				):Play()
				local raycastResult2 = nil
				local lastTime = os.clock()
				local number = random2:NextNumber(0.5, 1)
				local heartbeatConnection2 = nil
				heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
					raycastResult2 = workspace:Raycast(clone10.Position, bodyVelocity.Velocity * dt, raycastParams)
					local clone11, folder2

					if raycastResult2 then
						heartbeatConnection2:Disconnect()

						if raycastResult2 then
							bodyVelocity:Destroy()
							clone10.Anchored = true
							v5 = true
							clone11 = eagleZ.Explode:Clone()
							clone11.CFrame = clone10.CFrame
							Util.SetParentOverrideWithColor(clone11, folder, player, "EagleFruitVFXColor", true)
							Util.SyncColorsOnChange(clone11, player, "EagleFruitVFXColor", true)
							ParticleState(clone11)
							Util.Sound:Play(
								"EagleFt_F_Explosions_0" .. tostring(math.random(1, 10)) .. "_V1",
								clone11.Position
							)
							TweenService:Create(clone11.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
								Range = 0,
								Brightness = 0
							}):Play()
							folder2 = clone10

							for i, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end
					elseif number <= os.clock() - lastTime then
						heartbeatConnection2:Disconnect()

						if raycastResult2 then
							bodyVelocity:Destroy()
							clone10.Anchored = true
							v5 = true
							clone11 = eagleZ.Explode:Clone()
							clone11.CFrame = clone10.CFrame
							Util.SetParentOverrideWithColor(clone11, folder, player, "EagleFruitVFXColor", true)
							Util.SyncColorsOnChange(clone11, player, "EagleFruitVFXColor", true)
							ParticleState(clone11)
							Util.Sound:Play(
								"EagleFt_F_Explosions_0" .. tostring(math.random(1, 10)) .. "_V1",
								clone11.Position
							)
							TweenService:Create(clone11.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
								Range = 0,
								Brightness = 0
							}):Play()
							folder2 = clone10

							for i, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end
					end
				end)
				task.wait(number)

				if not v5 then
					local clone11 = eagleZ.Explode:Clone()
					clone11.CFrame = clone10.CFrame
					Util.SetParentOverrideWithColor(clone11, folder, player, "EagleFruitVFXColor", true)
					Util.SyncColorsOnChange(clone11, player, "EagleFruitVFXColor", true)
					ParticleState(clone11)
					Util.Sound:Play("EagleFt_F_Explosions_0" .. tostring(math.random(1, 10)) .. "_V1", clone11.Position)
					TweenService:Create(clone11.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Range = 0,
						Brightness = 0
					}):Play()

					for _, effect in pairs(clone10:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end
			end)
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor", true)
		Util.Debris:AddItem(folder, 10)
		local random2 = Random.new(data.Seed)
		local featherCount = data.FeatherCount
		local root = data.Root
		Util.Sound:Play("EagleFt_F_UnTransform_01_V1", root)
		local feathersCF = data.FeathersCF

		for _ = 0, featherCount do
			task.spawn(function()
				local v = false
				local clone = eagleZ["Feather" .. math.random(1, 4)]:Clone()
				clone.CFrame = feathersCF * CFrame.Angles(
					random2:NextNumber(0, 6.283185307179586),
					random2:NextNumber(0, 6.283185307179586),
					random2:NextNumber(0, 6.283185307179586)
				)
				Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor", true)
				Util.SyncColorsOnChange(clone, player, "EagleFruitVFXColor", true)
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = clone.CFrame.LookVector * 100
				bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
				Util.SetParentOverrideWithColor(bodyVelocity, clone, player, "EagleFruitVFXColor", true)
				TweenService:Create(bodyVelocity, TweenInfo.new(0.7, Enum.EasingStyle.Linear), {
					Velocity = createVector(0, -40, 0)
				}):Play()
				TweenService:Create(
					clone,
					TweenInfo.new(random2:NextNumber(0.3, 0.6), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Orientation = Vector3.new(
							random2:NextNumber(0, 360),
							random2:NextNumber(0, 360),
							random2:NextNumber(0, 360)
						)
					}
				):Play()
				local raycastResult = nil
				local lastTime = os.clock()
				local number = random2:NextNumber(0.5, 1)
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					raycastResult = workspace:Raycast(clone.Position, bodyVelocity.Velocity * dt, raycastParams)
					local clone2, folder2

					if raycastResult then
						heartbeatConnection:Disconnect()

						if raycastResult then
							v = true
							clone.Anchored = true
							bodyVelocity:Destroy()
							clone2 = eagleZ.Explode:Clone()
							clone2.CFrame = clone.CFrame
							Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor", true)
							Util.SyncColorsOnChange(clone2, player, "EagleFruitVFXColor", true)
							ParticleState(clone2)
							Util.Sound:Play(
								"EagleFt_F_Explosions_0" .. tostring(math.random(1, 10)) .. "_V1",
								clone2.Position
							)
							TweenService:Create(clone2.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
								Range = 0,
								Brightness = 0
							}):Play()
							folder2 = clone

							for i, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end
					elseif number <= os.clock() - lastTime then
						heartbeatConnection:Disconnect()

						if raycastResult then
							v = true
							clone.Anchored = true
							bodyVelocity:Destroy()
							clone2 = eagleZ.Explode:Clone()
							clone2.CFrame = clone.CFrame
							Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor", true)
							Util.SyncColorsOnChange(clone2, player, "EagleFruitVFXColor", true)
							ParticleState(clone2)
							Util.Sound:Play(
								"EagleFt_F_Explosions_0" .. tostring(math.random(1, 10)) .. "_V1",
								clone2.Position
							)
							TweenService:Create(clone2.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
								Range = 0,
								Brightness = 0
							}):Play()
							folder2 = clone

							for i, effect in pairs(folder2:GetDescendants()) do
								if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
									effect.Enabled = false
								end
							end
						end
					end
				end)
				task.wait(number)

				if not v then
					local clone2 = eagleZ.Explode:Clone()
					clone2.CFrame = clone.CFrame
					Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor", true)
					Util.SyncColorsOnChange(clone2, player, "EagleFruitVFXColor", true)
					ParticleState(clone2)
					Util.Sound:Play("EagleFt_F_Explosions_0" .. tostring(math.random(1, 10)) .. "_V1", clone2.Position)
					TweenService:Create(clone2.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Range = 0,
						Brightness = 0
					}):Play()

					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end
			end)
		end
	end
end