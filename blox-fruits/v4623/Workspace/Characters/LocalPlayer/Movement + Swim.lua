local createVector = vector.create
workspace.Gravity = 196.2
require(game.ReplicatedStorage.DragonAim)
local parent = script.Parent
local busy = parent:WaitForChild("Busy")
local stun = parent:WaitForChild("Stun")
local FX = require(game.ReplicatedStorage.FX)
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local humanoid = parent:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
task.spawn(function()
	local died = humanoidRootPart:WaitForChild("Died", 10)

	if died then
		died.Volume = 0
	end
end)
local localPlayer = game.Players.LocalPlayer
local data = localPlayer:WaitForChild("Data")
local devilFruit = data:WaitForChild("DevilFruit")
local race = data:WaitForChild("Race")
local Global = require(game.ReplicatedStorage.Global)
Global.Swimming = false
local now = 0
local v = false
UserInputService.JumpRequest:Connect(function()
	if tick() - now < 0.5 or humanoidRootPart.Position.Y > -humanoidRootPart.Size.Y - 0.5 then
		return
	end

	v = true
	now = tick()
end)
humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
	if humanoidRootPart:FindFirstChild("BodyPosition") then
		humanoid.Jump = false
	end
end)
local v2 = workspace.Map:FindFirstChild("WaterBase-Plane")

if not v2 then
	v2 = Instance.new("Part")
	v2.Size = createVector(1000, 80, 1000)
	v2.CFrame = CFrame.new(0, -10000, 0)
	v2.Material = "Neon"
	v2.Transparency = 1
	v2.Anchored = true
	v2.CanCollide = true
	v2.CanTouch = false
	v2.Name = "WaterBase-Plane"
	v2.Parent = workspace.Map
end

local Effect = require(game.ReplicatedStorage.Effect)
local v3 = {
	["Ice-Ice"] = true,
	["Magma-Magma"] = true,
	["Yeti-Yeti"] = "YetiRig",
	["Fiend (Yeti)-Fiend (Yeti)"] = "YetiRig",
	["Control-Control"] = true
}
local Util = require(game.ReplicatedStorage.Util)
local total = 0
local v4 = 0
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 1
local swimming = Global.Swimming
local now2 = tick()
local Y = 0
local fallLand = Util.Anims:Get(parent, "FallLand")
local SwimSurface = require(game.ReplicatedStorage.Util.SwimSurface)
local v9 = 0
local jumpPower = humanoid.JumpPower
local walkSpeed = humanoid.WalkSpeed
humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
	jumpPower = humanoid.JumpPower
end)
humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	walkSpeed = humanoid.WalkSpeed
end)

while true do
	local RunService = game:GetService("RunService")

	if not RunService.RenderStepped:Wait() or humanoid.Health <= 0 then
		break
	end

	if jumpPower ~= humanoid.JumpPower then
		humanoid.JumpPower = jumpPower
	end

	if walkSpeed ~= humanoid.WalkSpeed then
		humanoid.WalkSpeed = walkSpeed
	end

	local now3 = tick()
	local v10 = now3 - now2
	total += v10
	local kitsune = parent:FindFirstChild("Kitsune")
	local tigerRig = parent:FindFirstChild("TigerRig")
	local mammoth = parent:FindFirstChild("Mammoth")
	local westernDragonRig = parent:FindFirstChild("WesternDragonRig")
	local v11, v12, _, v13, v14 = SwimSurface.get(parent, humanoidRootPart.Position)
	local v15 = not v14
	local v16 = race:FindFirstChild("Evolved") and not Global.InSafeZone

	if Global.Swimming and v then
		v = false
		humanoid.WalkSpeed = 16
		initialSplash = false
		Global.Swimming = false
		humanoidRootPart.Velocity += Vector3.new(0, humanoid.JumpPower * 1.65, 0)
		humanoidRootPart.CFrame += createVector(0, 0.25, 0)
		Effect.new("Water.Splash"):replicate({
			CFrame = CFrame.new(humanoidRootPart.Position.X, v11, humanoidRootPart.Position.Z),
			Scale = humanoidRootPart.Size.Y * 1.5,
			Duration = 0.8
		})
		v7 = now3
	elseif now3 - now > 0.3 then
		local v17 = v3[devilFruit.Value]

		if v17 and typeof(v17) == "string" and not parent:FindFirstChild(v17) then
			v17 = false
		end

		local flag

		if v17 or not parent:GetAttribute("WaterWalking") then
			flag = false
		else
			v17 = true
			flag = true
		end

		local v18 = (devilFruit.Value == "Yeti-Yeti" or devilFruit.Value == "Fiend (Yeti)-Fiend (Yeti)") and 15 or 0
		local v19, v20

		if v17 then
			local ray = Util.Ray
			local v21 = humanoidRootPart.Position + ((humanoidRootPart.Velocity * createVector(1, 0, 1)).magnitude > 0.5 and (humanoidRootPart.Velocity * createVector(
				1,
				0,
				1
			)).unit * v10 * 3 or humanoidRootPart.CFrame.LookVector * 2)
			local v22 = { workspace.Characters, workspace.Enemies }
			v19, v20 = ray(v21, createVector(0, -25, 0), v22)
		else
			v20 = createVector(0, 10.069, 0)
		end

		local unit, Y2

		if v17 and humanoidRootPart.Position.Y < -humanoidRootPart.Size.Y + (v11 + 15) + v18 then
			local Y3 = humanoidRootPart.Position.Y

			if v11 + 3 < Y3 and parent.Energy.Value >= 4 and (v19 == nil or v20.Y < v11) then
				local vector2 = Vector3.new(v20.X, math.max(v11, v20.Y), v20.Z)
				local v21 = localPlayer.Backpack:FindFirstChild(devilFruit.Value) or localPlayer.Character:FindFirstChild(devilFruit.Value)

				if v21 or flag then
					local awakenedMoves

					if v21 then
						awakenedMoves = v21:FindFirstChild("AwakenedMoves")
					end

					local v22 = nil

					if awakenedMoves then
						local v23 = {
							"Z",
							"X",
							"C",
							"V",
							"F",
							awakenedMoves:FindFirstChild("TAP") and "TAP"
						}
						local v24 = {}
						local count = 0

						for _, childName in pairs(v23) do
							if not awakenedMoves:FindFirstChild(childName) then
								continue
							end

							v24[childName] = true
							count += 1
						end

						v22 = count > 0 or v22
						local _ = #v23 <= count
						local _ = v24.F
					end

					local position = humanoidRootPart.Position
					local respectHeight = v12 and true or nil

					if v12 then
						position = humanoidRootPart.Position * createVector(1, 0, 1) + createVector(0, 1, 0) * (v11 + 0.3)
					end

					if devilFruit.Value == "Ice-Ice" then
						game.ReplicatedStorage.Remotes.CommE:FireServer(
							"IceWalk",
							humanoidRootPart.CFrame,
							respectHeight
						)
						Effect.new("Ice1.Waterwalk", true):replicate({
							CFrame = CFrame.new(position),
							RespectHeight = respectHeight
						})
					elseif devilFruit.Value == "Yeti-Yeti" or devilFruit.Value == "Fiend (Yeti)-Fiend (Yeti)" then
						game.ReplicatedStorage.Remotes.CommE:FireServer(
							"YetiIceWalk",
							CFrame.lookAt(
								createVector(0, 0, 0),
								humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
							) + vector2
						)
						Effect.new("Yeti.Transformed.Waterwalk"):play({
							CFrame = CFrame.lookAt(
								createVector(0, 0, 0),
								humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
							) + vector2,
							RespectHeight = respectHeight,
							player = game.Players.LocalPlayer
						})
						v9 = now3
					elseif devilFruit.Value == "Magma-Magma" then
						if v22 then
							game.ReplicatedStorage.Remotes.CommE:FireServer(
								"MagmaWalk",
								humanoidRootPart.CFrame.p,
								respectHeight
							)
							Effect.new("Shared.MagmaWalk", true):replicate({
								Type = "AwakenedBlob",
								Position = position,
								Duration = parent.Busy.Value and 0.6,
								RespectHeight = respectHeight
							})
						end
					elseif devilFruit.Value == "Control-Control" then
						game.ReplicatedStorage.Remotes.CommE:FireServer(
							"ControlWalk",
							humanoidRootPart.CFrame.p,
							respectHeight
						)
						Effect.new("Shared.ControlWalk", true):replicate({
							Position = position,
							Duration = parent.Busy.Value and 0.6,
							RespectHeight = respectHeight,
							HumanoidRootPart = humanoidRootPart
						})
					elseif flag then
						game.ReplicatedStorage.Remotes.CommE:FireServer(
							"WaterWalkingStat",
							CFrame.lookAt(
								createVector(0, 0, 0),
								humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
							) + vector2
						)
						Effect.new("Ice1.Waterwalk", true):replicate({
							CFrame = CFrame.new(humanoidRootPart.Position)
						})
					end
				end
			elseif humanoidRootPart.Position.Y < v11 and now3 - v7 > 0.3 and not v15 then
				v9 = 0

				if not westernDragonRig then
					if race.Value == "Fishman" then
						humanoid.WalkSpeed = v16 and 100 or 60
					elseif devilFruit.Value ~= "" then
						humanoid.WalkSpeed = v16 and 26 or 16
					end

					unit = humanoid.MoveDirection * createVector(1, 0, 1)

					if unit.Magnitude > 0.01 then
						unit = unit.unit
					end

					humanoidRootPart.Velocity = unit * humanoid.WalkSpeed
					Global.Swimming = true
				end

				humanoidRootPart.CFrame = CFrame.new(
					humanoidRootPart.Position.X,
					v11 + SwimSurface.ROOT_OFFSET,
					humanoidRootPart.Position.Z
				) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p)

				if not initialSplash then
					Effect.new("Water.AcuteSplash"):replicate({
						CFrame = CFrame.new(humanoidRootPart.Position.X, v11, humanoidRootPart.Position.Z),
						Scale = humanoidRootPart.Size.Y,
						Duration = 0.8
					})
					initialSplash = true
				end
			elseif Global.Swimming then
				if v15 then
					if not v then
						initialSplash = false
					end

					humanoid.WalkSpeed = 16
					Global.Swimming = false
					v7 = now3
				else
					Y2 = humanoidRootPart.Position.Y

					if v11 + 0.25 < Y2 then
						if not v then
							initialSplash = false
						end

						humanoid.WalkSpeed = 16
						Global.Swimming = false
						v7 = now3
					end
				end
			end
		elseif humanoidRootPart.Position.Y < v11 and now3 - v7 > 0.3 and not v15 then
			v9 = 0

			if not westernDragonRig then
				if race.Value == "Fishman" then
					humanoid.WalkSpeed = v16 and 100 or 60
				elseif devilFruit.Value ~= "" then
					humanoid.WalkSpeed = v16 and 26 or 16
				end

				unit = humanoid.MoveDirection * createVector(1, 0, 1)

				if unit.Magnitude > 0.01 then
					unit = unit.unit
				end

				humanoidRootPart.Velocity = unit * humanoid.WalkSpeed
				Global.Swimming = true
			end

			humanoidRootPart.CFrame = CFrame.new(
				humanoidRootPart.Position.X,
				v11 + SwimSurface.ROOT_OFFSET,
				humanoidRootPart.Position.Z
			) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p)

			if not initialSplash then
				Effect.new("Water.AcuteSplash"):replicate({
					CFrame = CFrame.new(humanoidRootPart.Position.X, v11, humanoidRootPart.Position.Z),
					Scale = humanoidRootPart.Size.Y,
					Duration = 0.8
				})
				initialSplash = true
			end
		elseif Global.Swimming then
			if v15 then
				if not v then
					initialSplash = false
				end

				humanoid.WalkSpeed = 16
				Global.Swimming = false
				v7 = now3
			else
				Y2 = humanoidRootPart.Position.Y

				if v11 + 0.25 < Y2 then
					if not v then
						initialSplash = false
					end

					humanoid.WalkSpeed = 16
					Global.Swimming = false
					v7 = now3
				end
			end
		end
	end

	local v17 = 0
	local v18 = 0
	local v19

	if race.Value == "Ghoul" then
		v19 = v16 and 1.4 or 1.2

		if game.Lighting.ClockTime > 18 or game.Lighting.ClockTime < 6 or parent:FindFirstChild("RaceTransformed") and parent.RaceTransformed.Value and race:FindFirstChild("B") and race.B.Value >= 1 then
			v19 *= 1.25
		end
	else
		v19 = race.Value == "Mink" and (v16 and 1.95 or 1.45) or v16 and 1.325 or 1
	end

	if parent:GetAttribute("SpeedMultiplier") then
		v17 = v17 + parent:GetAttribute("SpeedMultiplier") - 1
	end

	if parent:GetAttribute("FishmanDebuff1b") then
		local fishmanDebuff1a = parent:GetAttribute("FishmanDebuff1a")

		if parent:GetAttribute("FishmanDebuff1b") > workspace:GetServerTimeNow() then
			v18 = -1.5 * fishmanDebuff1a
		end
	end

	if parent:GetAttribute("FishmanDebuff2b") then
		local fishmanDebuff2a = parent:GetAttribute("FishmanDebuff2a")

		if parent:GetAttribute("FishmanDebuff2b") > workspace:GetServerTimeNow() then
			v18 = -3 * fishmanDebuff2a
		end
	end

	if parent:FindFirstChild("LeopardRig") then
		v17 += 0.75
	end

	if parent:FindFirstChild("KitsuneTail3") then
		v17 += 0.875
	end

	if parent:FindFirstChild("LeopardBoost") then
		v17 += 1.5
	end

	if humanoidRootPart:FindFirstChild("Agility") then
		v17 += 2
	elseif humanoidRootPart:FindFirstChild("Heightened Senses") then
		v17 += 1.15
	end

	if mammoth then
		v17 /= 4
		v18 /= 2
		v19 = 1.25
	end

	local v20 = westernDragonRig and 64 or kitsune and 32 or tigerRig and 30 or 18
	local walkSpeed2

	if kitsune then
		walkSpeed2 = (v17 * 0.25 + 1) * 36 + v18
	elseif tigerRig then
		walkSpeed2 = (v17 * 0.5 + 1) * 40 + v18
	elseif westernDragonRig then
		walkSpeed2 = (v17 * 0.0135 + 1) * 64 + v18 / 2
	else
		walkSpeed2 = 36 * (humanoidRootPart:FindFirstChild("Buddha") and v17 * 0.25 + 1.15 or v19 + v17) + v18
	end

	if parent:FindFirstChild("MagnetLanding") then
		walkSpeed2 = 0
		v20 = 0
	end

	if not Global.Running then
		walkSpeed2 = math.min(walkSpeed2, v20)
	end

	if (Global.Swimming == false and busy.Value == false or walkSpeed2 < humanoid.WalkSpeed) and not parent:GetAttribute("IgnoreWalkSpeed") then
		humanoid.WalkSpeed = walkSpeed2
	end

	if Global.Swimming then
		if swimming ~= Global.Swimming then
			swimming = Global.Swimming
			humanoid:SetStateEnabled("Running", false)
			humanoid:SetStateEnabled("RunningNoPhysics", false)
			humanoid:SetStateEnabled("Climbing", false)
			humanoid:SetStateEnabled("GettingUp", false)
			workspace.Gravity = 1.962
			humanoid:SetStateEnabled("Swimming", true)
		end

		humanoid:ChangeState("Swimming")

		if (humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude > 0.2 then
			if now3 - v4 > 0.45 then
				local magnitude = (humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude
				local v22 = v8 == 1 and 1 or -1
				local v23 = Util.Misc.AlignCFrame(CFrame.new(Vector3.new(), humanoid.MoveDirection) + humanoidRootPart.Position) * CFrame.new(
					v22 * humanoidRootPart.Size.X * 1.3,
					0,
					0
				) * CFrame.new(0, 0, -magnitude * 2 * v10)
				Effect.new("Water.Swim.Splash"):replicate({
					CFrame = v23 - v23.p + (v23.p * createVector(1, 0, 1) + Vector3.new(0, v11, 0)),
					Scale = humanoidRootPart.Size.X,
					Duration = 0.9
				})
				v8 = v8 % 2 + 1
				v4 = now3
			end
		elseif now3 - v5 > 1.5 then
			local vector2 = Vector3.new(humanoidRootPart.Position.X, v11, humanoidRootPart.Position.Z)
			Effect.new("Water.Swim.Idle"):replicate({
				CFrame = CFrame.new(vector2),
				Scale = humanoidRootPart.Size.Y,
				Duration = 1.65
			})
			v5 = now3
		end
	elseif not Global.Swimming and swimming ~= Global.Swimming then
		swimming = Global.Swimming
		humanoid:SetStateEnabled("Running", true)
		humanoid:SetStateEnabled("RunningNoPhysics", true)
		humanoid:SetStateEnabled("Climbing", true)
		humanoid:SetStateEnabled("GettingUp", true)
		humanoid:SetStateEnabled("Swimming", false)
		workspace.Gravity = 196.2
	end

	if v13 and not Global.Swimming and humanoidRootPart.Position.Y < v11 and now3 - v6 > 0.35 and (humanoidRootPart.Velocity * createVector(
		1,
		0,
		1
	)).Magnitude > 2 then
		Effect.new("Water.Swim.Splash"):replicate({
			CFrame = CFrame.new(humanoidRootPart.Position.X, v11, humanoidRootPart.Position.Z),
			Scale = humanoidRootPart.Size.X,
			Duration = 0.7
		})
		v6 = now3
	end

	local v22 = kitsune and (humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude > 5 and 16 or 0

	if v12 and not v13 then
		v22 += v11
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera and currentCamera.CFrame.Y < v11 then
		if v2.Parent ~= workspace._WorldOrigin then
			v2.Parent = workspace._WorldOrigin
			v2.CFrame = CFrame.new(humanoidRootPart.Position.X, v22 + -60, humanoidRootPart.Position.Z)
		end
	elseif v2.Parent ~= workspace.Map then
		v2.Parent = workspace.Map
		v2.CFrame = CFrame.new(humanoidRootPart.Position.X, v22 + -60, humanoidRootPart.Position.Z)
	end

	if (kitsune and 0.125 or 0.3) <= total then
		total = 0
		v2.CFrame = CFrame.new(humanoidRootPart.Position.X, v22 + -60, humanoidRootPart.Position.Z)

		if kitsune and humanoidRootPart.Position.Y < 5 and v22 > 0 then
			local cFrame = humanoidRootPart.CFrame
			Effect.new("Water.Swim.Splash"):replicate({
				CFrame = cFrame - cFrame.p + (cFrame.p * createVector(1, 0, 1) + Vector3.new(0, v11, 0)),
				Scale = humanoidRootPart.Size.Y,
				Duration = 0.4,
				Volume = 0.025,
				TimeInfluence = 0.6,
				Root = humanoidRootPart
			})
		end

		if not (game.Lighting:FindFirstChild("LightingLayers") and game.Lighting.LightingLayers:FindFirstChild("LeviathanFog")) then
			local ray = Util.Ray
			local position = humanoidRootPart.Position
			local v23 = { workspace.Characters, workspace.Enemies }
			local _, v24 = ray(position, createVector(0, -800, 0), v23)
			local v25 = (humanoidRootPart.Position - v24).Magnitude / 800

			if v25 > 0.6 then
				local gravity = 196.2 * (1 + (v25 - 0.6) / 0.4)

				if workspace.Gravity < gravity then
					workspace.Gravity = workspace.Gravity + (gravity - workspace.Gravity) * 0.03
				else
					workspace.Gravity = gravity
				end
			else
				workspace.Gravity = 196.2
			end
		end
	end

	if fallLand.IsPlaying then
		if humanoid.FloorMaterial == Enum.Material.Air then
			fallLand:Stop()
		end
	else
		local v23 = humanoid.JumpPower ^ 2 / 392.4

		if Y < -(humanoid.HipHeight + 20 + v23 * 5) and Y < humanoidRootPart.Velocity.Y and busy.Value == false and stun.Value <= 0 and not (parent:FindFirstChild("__Room") and parent:GetAttribute("AuraActive")) and humanoid.FloorMaterial ~= Enum.Material.Air then
			fallLand:Play()
			local v24 = 0.1 + humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight
			local ray, position, _ = Util.Ray(
				humanoidRootPart.Position,
				createVector(0, 1, 0) * -v24,
				{ workspace.Characters, workspace.Enemies }
			)

			if ray and ray.Transparency == 0 then
				local clone = FX:WaitForChild("Attachments").GroundLand:Clone()
				clone.dust.Color = ColorSequence.new(ray.Color)
				clone.rocks.Color = ColorSequence.new(ray.Color)
				clone.Position = position
				clone.Parent = workspace.Terrain
				clone.rocks:Emit(6)
				clone.dust:Emit(9)
				Util.Debris:AddItem(clone, 1.5)
			end
		end
	end

	local v23 = humanoidRootPart.Position.Y - (humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight)
	local v24

	if devilFruit.Value == "Yeti-Yeti" or devilFruit.Value == "Fiend (Yeti)-Fiend (Yeti)" then
		v24 = parent:FindFirstChild("YetiRig") ~= nil
	else
		v24 = false
	end

	local v25 = math.abs(v23 - v11) <= 1.5

	if v24 and not Global.Swimming and v25 and now3 - v9 <= 1 then
		v9 = now3
	end

	local v26 = v24 and not Global.Swimming and now3 - v9 <= 0.35

	if parent:GetAttribute("YetiOnWater") ~= v26 then
		parent:SetAttribute("YetiOnWater", v26)

		if script.YetiOnWaterRemote.Value and script.YetiOnWaterRemote.Value:IsDescendantOf(game) then
			script.YetiOnWaterRemote.Value:FireServer(parent, v26)
		end
	end

	Y = humanoidRootPart.Velocity.Y
	now2 = now3
end

while script.Parent do
	task.wait(0.1)

	if not (humanoid.Health > 0) then
		continue
	end

	game.ReplicatedStorage:WaitForChild("Effect"):WaitForChild("Bindable"):Fire(function()
		script.Enabled = false
		task.wait()
		script.Enabled = true
	end)
	return
end

workspace.Gravity = 196.2