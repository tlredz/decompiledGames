local createVector = vector.create
local v = 35
local total = 90
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local sharedDodge

if game.ReplicatedStorage.EffectContainer:FindFirstChild("Shared") and game.ReplicatedStorage.EffectContainer.Shared:FindFirstChild("Dodge") then
	sharedDodge = Effect.new("Shared.Dodge")
else
	sharedDodge = nil
end

local Util = require(game.ReplicatedStorage.Util)
local _ = workspace.CurrentCamera
local v2 = {
	LastAfter = 0,
	LastUse = 0
}
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local character = localPlayer.Character
local humanoid = character.Humanoid
local humanoidRootPart = character.HumanoidRootPart
task.spawn(function()
	repeat
		wait()
		local Global = require(game.ReplicatedStorage.Global)
	until Global.skyp

	local Global = require(game.ReplicatedStorage.Global)
	Global.skyp.noflight = false
end)
local total2 = 0
local energy = 100
humanoid.StateChanged:Connect(function(_, p)
	if p == Enum.HumanoidStateType.Landed then
		total2 = 0
		energy = 100
	end
end)
local now = 0
local v4 = false

local function jumped(p)
	local value = character:FindFirstChild("GeppoCount") and character:FindFirstChild("GeppoCount").Value
	task.spawn(function()
		local lastfireflyshard = character:GetAttribute("Lastfireflyshard")

		if lastfireflyshard and workspace:GetServerTimeNow() - lastfireflyshard <= 10 then
			total2 = 0
		end
	end)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.skyp then
		local Global2 = require(game.ReplicatedStorage.Global)

		if Global2.skyp.noflight then
			local Global3 = require(game.ReplicatedStorage.Global)

			if Global3.skyp.Mode == 2 then
				local Global4 = require(game.ReplicatedStorage.Global)
				Global4.skyp.noflight = false
				local Global5 = require(game.ReplicatedStorage.Global)
				Global5.skyp:SetFlight(0)
			end
		end
	end

	local Global2 = require(game.ReplicatedStorage.Global)

	if Global2.skyp then
		local Global3 = require(game.ReplicatedStorage.Global)

		if Global3.skyp.Mode == 1 then
			local Global4 = require(game.ReplicatedStorage.Global)
			Global4.skyp:SetFlight(0)
		end
	end

	local function fixHumanoidState()
		local humanoid2 = character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if humanoid2 and humanoidRootPart2 then
			if humanoid2:GetState() ~= Enum.HumanoidStateType.Running then
				humanoid2:ChangeState(Enum.HumanoidStateType.Running)
			end

			task.spawn(function()
				for _ = 1, 5 do
					local Global3 = require(game.ReplicatedStorage.Global)

					if Global3.Shiftlock then
						humanoidRootPart2.AssemblyAngularVelocity = createVector(0, 0, 0)
						local position = humanoidRootPart2.Position
						local lookVector = humanoidRootPart2.CFrame.LookVector
						local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
						local v5 = vector2.Magnitude < 0.001 and createVector(0, 0, -1) or vector2.Unit
						humanoidRootPart2.CFrame = CFrame.lookAt(position, position + v5, createVector(0, 1, 0))
					else
						local upVector = humanoidRootPart2.CFrame.UpVector
						local cross = upVector:Cross(createVector(0, 1, 0))
						local v5 = math.atan2(cross.Magnitude, (upVector:Dot(createVector(0, 1, 0))))
						humanoidRootPart2.AssemblyAngularVelocity = not (cross.Magnitude > 0) and createVector(0, 0, 0) or cross.Unit * v5
					end

					task.wait(0.05)
					local busy = character:FindFirstChild("Busy")

					if busy and busy.Value then
						break
					end
				end
			end)
		end
	end

	local v5 = humanoid.JumpPower ^ 2 / 392.4
	local v6 = 4 + (character:FindFirstChild("HydraRig") and 8 or 0)
	local CollectionService = game:GetService("CollectionService")
	local tagged = CollectionService:GetTagged("IgnoreForMovementGroundCheck")
	table.insert(tagged, character)

	if Util.Ray(
		humanoidRootPart.Position,
		Vector3.new(0, -v5 - v6 - humanoid.HipHeight - humanoidRootPart.Size.Y / 2, 0),
		tagged
	) then
		return
	end

	if localPlayer.Data.Race.Value == "Skypiea" and localPlayer.Data.Race:FindFirstChild("Evolved") then
		v = 15
		total = 70
	else
		v = 35
		total = 85
	end

	if value then
		v = math.clamp(total - 5 * value, v, total)
	elseif character:GetAttribute("SkyjumpBoost") and character:GetAttribute("SkyjumpBoost") > 0 then
		total += 5 * character:GetAttribute("SkyjumpBoost")
	end

	local now2 = tick()

	if now2 - v2.LastUse < 0.3 or localPlayer.Character.Humanoid.Health <= 0 or humanoid.Sit then
		return
	end

	if not character.Busy.Value or character:GetAttribute("NoTransform") then
		local Global3 = require(game.ReplicatedStorage.Global)

		if not Global3.Swimming then
			local Global4 = require(game.ReplicatedStorage.Global)

			if not (Global4.Dodging or character.Stun.Value > 0) then
				if not character:FindFirstChild("DoorMode") then
					if character:FindFirstChild("Phoenix") or humanoidRootPart:FindFirstChild("MagnetEnableFlight") or character:FindFirstChild("GravityFlight") or character:FindFirstChild("FalconFlight") or character:FindFirstChild("Dragon") then
						return
					end

					if character:FindFirstChild("DisableMovement") and not character:GetAttribute("NoDashing") then
						return
					end
				end

				local now3 = tick()
				local Global5 = require(game.ReplicatedStorage.Global)

				if now3 - (Global5.mobilityCooldown or 0) < 0.1 then
					return
				end

				local value2 = character.Energy.Value
				local v7 = math.clamp(v + total2, 0, total)
				local v8 = v7 == 15 and 1.33 or 1

				if localPlayer.Data.Race.Value == "Draco" and localPlayer.Data.Race:FindFirstChild("Evolved") then
					local v9 = value2 < v7
					local v10 = total <= v7 or v9
					local v11 = character:GetAttribute("NoDashing") and true or v10
					task.delay(v11 and 0 or 0.3, function()
						if not humanoidRootPart:FindFirstChild("Buddha") then
							local IsTransformed = require(game.ReplicatedStorage.Util.IsTransformed)

							if IsTransformed(character, true, false) then
								return
							end
						end

						local folder = Instance.new("Folder")
						folder.Name = "__DracoJetpack"
						folder.Parent = character
						Effect.new("DracoRace.Jetpack"):play({
							Root = character.UpperTorso,
							Reference = folder,
							Energy = energy,
							player = localPlayer
						})
						local skyJumpJetpack = Util.Anims:Get(character, "SkyJumpJetpack")
						skyJumpJetpack:Play(0.1)
						game.ReplicatedStorage.Remotes.CommE:FireServer("Jetpack", energy)
						local v12 = character:FindFirstChild("RaceTransformed") and character.RaceTransformed.Value and 6 or 4
						local lastTime = tick()

						while energy > 0 and p.UserInputState ~= Enum.UserInputState.End do
							local v13 = task.wait()
							local v14 = math.max(workspace:GetRealPhysicsFPS() / 60, 1)
							local v15 = math.max((tick() - lastTime) / 0.016666666666666666, v14)
							lastTime = tick()
							local v16 = math.max(humanoid.JumpPower * ((energy / 100) ^ 2 * 0.9 + 0.7) * 1.025, 0)

							if v12 > 4 then
								v16 *= 1.5
							end

							local v17 = math.max(humanoidRootPart.Velocity.Y, 1) + v16 / 10 * v15
							humanoidRootPart.Velocity = Vector3.new(
								humanoidRootPart.Velocity.X,
								math.min(humanoidRootPart.Velocity.Y + v17, v16),
								humanoidRootPart.Velocity.Z
							)
							energy -= v13 * 100 / v12

							if character.Busy.Value and not character:GetAttribute("NoTransform") then
								break
							end

							local Global6 = require(game.ReplicatedStorage.Global)

							if Global6.Swimming then
								break
							end

							local Global7 = require(game.ReplicatedStorage.Global)

							if Global7.Dodging or character.Stun.Value > 0 then
								break
							end
						end

						skyJumpJetpack:Stop()
						game.ReplicatedStorage.Remotes.CommE:FireServer("Jetpack", false)
						folder:Destroy()
					end)
				end

				local CollectionService2 = game:GetService("CollectionService")

				if not CollectionService2:HasTag(character, "Geppo") or character:GetAttribute("NoDashing") then
					return
				end

				local tool = character:FindFirstChildOfClass("Tool")

				if tool and tool:GetAttribute("State") == "StartCasting" or value2 < v7 or total <= v7 then
					return
				end

				if localPlayer.Data.Race.Value == "Skypiea" and localPlayer.Character and localPlayer.Character:FindFirstChild("RaceTransformed") and localPlayer.Character.RaceTransformed.Value and localPlayer.Data.Race:FindFirstChild("A") and localPlayer.Data.Race.A.Value >= 1 then
					now = os.clock()
					local v9 = now
					task.delay(0.3, function()
						if now ~= v9 then
							return
						end

						local Global6 = require(game.ReplicatedStorage.Global)
						Global6.skyp.noflight = true
						local floorMaterialChangedConnection = nil
						floorMaterialChangedConnection = character.Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
							if character.Humanoid.FloorMaterial and character.Humanoid.FloorMaterial ~= Enum.Material.Air then
								local Global7 = require(game.ReplicatedStorage.Global)

								if Global7.skyp.Mode == 2 then
									local Global8 = require(game.ReplicatedStorage.Global)
									Global8.skyp.noflight = false
									local Global9 = require(game.ReplicatedStorage.Global)
									Global9.skyp:SetFlight(0)
								end

								floorMaterialChangedConnection:Disconnect()
							end
						end)
						local v10 = character.Humanoid.Health / character.Humanoid.MaxHealth
						local _ = character.Humanoid.MaxHealth
						local healthChangedConnection = nil
						local maxHealthChangedConnection = nil
						healthChangedConnection = character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
							local v11 = character.Humanoid.Health / character.Humanoid.MaxHealth

							if v11 < v10 then
								local Global7 = require(game.ReplicatedStorage.Global)

								if Global7.skyp.Mode == 2 then
									local Global8 = require(game.ReplicatedStorage.Global)
									Global8.skyp.noflight = false
									local Global9 = require(game.ReplicatedStorage.Global)
									Global9.skyp:SetFlight(0)
								end
							end

							v10 = v11
							local Global7 = require(game.ReplicatedStorage.Global)

							if Global7.skyp.Mode ~= 2 then
								healthChangedConnection:Disconnect()
								maxHealthChangedConnection:Disconnect()
							end
						end)
						maxHealthChangedConnection = character.Humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
							v10 = character.Humanoid.Health / character.Humanoid.MaxHealth
						end)
						local Global7 = require(game.ReplicatedStorage.Global)
						Global7.skyp:SetFlight(2, 1 + (localPlayer.Data.Race.A.Value - 1) * 0.275)
					end)
				end

				total2 += 5
				game.ReplicatedStorage.Remotes.CommE:FireServer("Dodge", "Geppo", v7, nil, workspace:GetServerTimeNow())
				game.ReplicatedStorage.PlayerSkyJumped:Fire()
				v4 = not v4
				local v9 = "SkyJump" .. (v4 and "1" or "2")
				local v10 = 1.65
				local falconWings_Accessory = character:FindFirstChild("FalconWings_Accessory")
				local magnetArmFunctions = character:FindFirstChild("MagnetArmFunctions")

				if character:FindFirstChild("KitsuneTail3") then
					v9 = "KitsuneSkyJump"
					v10 = 1
				elseif character:FindFirstChild("PainTransformed") then
					v9 = v4 and "PainSkyJumpR" or "PainSkyJumpL"
				elseif character:FindFirstChild("Dark Blade") or character:FindFirstChild("Triple Dark Blade") then
					v9 = "DBSkyJump"
					v10 = 1.2
				elseif falconWings_Accessory then
					v9 = "EagleSkyHop"
				end

				local eagleSkyHop = Util.Anims:Get(character, v9)

				if falconWings_Accessory then
					eagleSkyHop = Util.Anims:Get(character, "EagleSkyHop")
					Util.Anims:Get(falconWings_Accessory.FalconWings, "EagleSkyHop"):Play()
				end

				local changedConnection = nil
				changedConnection = character.Busy.Changed:Connect(function()
					if character.Busy.Value then
						changedConnection:Disconnect()

						if eagleSkyHop.IsPlaying then
							eagleSkyHop:Stop(0)
						end
					end
				end)

				if magnetArmFunctions then
					local folder = Instance.new("Folder")
					folder.Name = "EnableBoost"
					folder:SetAttribute("Jump", true)
					folder.Parent = magnetArmFunctions
					Util.Debris:AddItem(folder, 0.33)
				end

				eagleSkyHop:Play(0.1, nil, v10)

				if sharedDodge then
					sharedDodge:replicate({
						Multiplier = v8 * 0.7,
						Duration = v8 * 0.17,
						HRP = character.HumanoidRootPart,
						Humanoid = character.Humanoid,
						Direction = createVector(0, 1, 0)
					})
				end

				v2.LastUse = now2
				humanoidRootPart.Velocity = Vector3.new(
					humanoidRootPart.Velocity.X,
					humanoid.JumpPower * (localPlayer.Data.Race.Value == "Skypiea" and 1.4 or 1.5) * v8,
					humanoidRootPart.Velocity.Z
				)
				fixHumanoidState()
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed and not UserInputService.GamepadEnabled then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
		jumped(input)
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed and not UserInputService.GamepadEnabled then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
		now = 0
	end
end)
wait(1)
wait(0.5)

if UserInputService.TouchEnabled then
	local v5 = {
		UserInputState = Enum.UserInputState.None
	}
	local touchGui = playerGui:WaitForChild("TouchGui", 10)

	if touchGui then
		local jumpButton = touchGui:WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
		jumpButton.MouseButton1Down:Connect(function(_: number, _: number)
			v5.UserInputState = Enum.UserInputState.Begin
			jumped(v5)
		end)
		jumpButton.MouseButton1Up:Connect(function(_: number, _: number)
			v5.UserInputState = Enum.UserInputState.End
			now = 0
		end)
	end
end