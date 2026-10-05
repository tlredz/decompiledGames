local createVector = vector.create
local InstanceWatch = require(game.ReplicatedStorage.Util.InstanceWatch)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local currentSeaAsync = Realm.getCurrentSeaAsync()
local v = {
	Head = true,
	LowerTorso = true,
	UpperTorso = true,
	LeftUpperArm = true,
	RightUpperArm = true,
	LeftLowerArm = true,
	RightLowerArm = true,
	LeftLowerLeg = true,
	RightLowerLeg = true,
	LeftUpperLeg = true,
	RightUpperLeg = true,
	LeftHand = true,
	RightHand = true,
	LeftFoot = true,
	RightFoot = true
}
local GetWaterHeightAtLocation = require(game.ReplicatedStorage.Util.GetWaterHeightAtLocation)
local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
PlayerUtil.ScreenReady({ "Main" }, function(p)
	local CollectionService = game:GetService("CollectionService")
	local RunService = game:GetService("RunService")
	local localPlayer = game.Players.LocalPlayer
	local blackscreen = assert(p.Main):WaitForChild("Blackscreen")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function available()
		if localPlayer.Character and localPlayer.Character:FindFirstChild("Busy") and localPlayer.Character.Busy.Value == false and localPlayer.Character:FindFirstChild("Humanoid") and localPlayer.Character.Humanoid.Sit == false then
			return true
		end

		return false
	end

	local function requestEntrance(p2)
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", p2)

		if typeof(v2) == "Vector3" and localPlayer.Character == character and humanoidRootPart and humanoidRootPart.Parent then
			humanoidRootPart.CFrame = CFrame.new(v2)
		end
	end

	local map = workspace:WaitForChild("Map")
	local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
	task.spawn(function()
		local checkTeleportGlitchFix = game.ReplicatedStorage.Remotes:WaitForChild("CheckTeleportGlitchFix", 999999)
		checkTeleportGlitchFix.OnClientEvent:Connect(function(p2)
			if p2 == "CheckBuggyFlingMasslessFix" then
				local character = game.Players.LocalPlayer.Character
				local v2 = {}

				if character then
					for _, part in character:GetChildren() do
						if part:IsA("BasePart") then
							v2[part.Name] = {
								part.Massless,
								part.CanCollide,
								part.CanTouch,
								part.CanQuery,
								part.Size
							}
						end
					end
				end

				checkTeleportGlitchFix:FireServer(v2)
			end
		end)
	end)
	task.spawn(function()
		local turtle = map:WaitForChild("Turtle", 1)

		if turtle and not workspace.StreamingEnabled then
			task.spawn(function()
				-- equivalent calls inferred from this helper; original call sites unknown
				local function hasPermission()
					return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("GetUnlockables").DefeatedIndraTrueForm
				end

				local function portals(p2, p3, instance)
					if not available() then
						return
					end

					if instance and localPlayer.Character and instance.Parent == localPlayer.Character and not CollectionService:HasTag(
						localPlayer,
						"Teleporting"
					) then
						local humanoidRootPart = instance.Parent:FindFirstChild("HumanoidRootPart")
						local Global = require(game.ReplicatedStorage.Global)

						if Global.TestGame then
							print(
								"me",
								humanoidRootPart.Position,
								"portal",
								p2.Position,
								"dist",
								(humanoidRootPart.Position - p2.Position).magnitude,
								humanoidRootPart.Size.Y * 2 + p2.Size.X / 2
							)
							print(
								humanoidRootPart,
								humanoidRootPart.Anchored == false,
								v[instance.Name],
								(humanoidRootPart.Position - p2.Position).magnitude < humanoidRootPart.Size.Y * 2 + p2.Size.X / 2
							)
						end

						if humanoidRootPart and humanoidRootPart.Anchored == false and v[instance.Name] and (humanoidRootPart.Position - p2.Position).magnitude < humanoidRootPart.Size.Y * 2 + p2.Size.X / 2 then
							CollectionService:AddTag(localPlayer, "Teleporting")
							local Global2 = require(game.ReplicatedStorage.Global)

							if Global2.TestGame then
								print("step")
							end

							if hasPermission() then
								local Global3 = require(game.ReplicatedStorage.Global)
								local _ = Global3.TestGame
								print("hasPermission")
								blackscreen.Position = UDim2.new(-1, 0, 0, -50)
								blackscreen.BackgroundTransparency = 0
								blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
								wait(0.3)
								wait()
								humanoidRootPart.Velocity = Vector3.new()
								local p4 = p3.CFrame.p

								if available() then
									local Global4 = require(game.ReplicatedStorage.Global)
									local _ = Global4.TestGame
									print("available")
									requestEntrance(p4)
									print("loading")
									local Global5 = require(game.ReplicatedStorage.Global)
									local _ = Global5.TestGame
									print("looping")
									wait(0.3)
								end

								wait(0.3)
								blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
								local lastTime = tick()
								local Global4 = require(game.ReplicatedStorage.Global)
								local _ = Global4.TestGame
								print("waiting to exit")

								repeat
									wait()
								until (humanoidRootPart.Position - p4).magnitude > humanoidRootPart.Size.Y * 2 + p2.Size.X or tick() - lastTime > 9

								local Global5 = require(game.ReplicatedStorage.Global)
								local _ = Global5.TestGame
								print("exited")
							else
								Notification.new("<Color=Red>You cannot access this portal yet.<Color=/>"):Display()
								wait(1.5)
							end

							CollectionService:RemoveTag(localPlayer, "Teleporting")
						end
					end
				end

				local group = InstanceWatch.group()
				group.add(turtle, "MapTeleportB"):Watch("Hitbox"):Once(function(portal, _, state)
					state.portal1 = portal
					state.portal1.Touched:Connect(function(...)
						local Global = require(game.ReplicatedStorage.Global)

						if Global.TestGame then
							print("[testgame] touch")
						end

						portals(state.portal1, state.portal2, ...)
					end)
				end)
				group.add(map, "Boat Castle"):WatchMany({
					MapTeleportA = function(object)
						object:Watch("Hitbox"):Once(function(portal, _, state)
							state.portal2 = portal
							state.portal2.Touched:Connect(function(...)
								portals(state.portal2, state.portal1, ...)
							end)
						end)
					end,
					MapTeleportB = function(object)
						object:Watch("Hitbox"):Once(function(portal, _, state)
							state.portal3 = portal
							state.portal3.Touched:Connect(function(...)
								portals(state.portal3, state.portal4, ...)
							end)
						end)
					end
				})
				local v2 = group.add(map, "Waterfall")
				local v3 = group.add(map, "Turtle")
				v2:Watch("MapTeleportA"):Watch("Hitbox"):Once(function(portal, _, state)
					state.portal4 = portal
					state.portal4.Touched:Connect(function(...)
						portals(state.portal4, state.portal3, ...)
					end)
				end)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function hasPermission2()
					local _, v4 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("GetUnlockables")
					return v4 >= 1950
				end

				v3:Watch("Entrance"):Watch("Door"):Watch("BossDoor"):Watch("Hitbox"):Once(function(data, _, _)
					data.Touched:Connect(function(otherPart)
						if not available() then
							return
						end

						if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
							localPlayer,
							"Teleporting"
						) then
							local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - data.Position).magnitude < humanoidRootPart.Size.Y * 2 + data.Size.Y then
								CollectionService:AddTag(localPlayer, "Teleporting")

								if hasPermission2() then
									pcall(function() end)
									blackscreen.Position = UDim2.new(-1, 0, 0, -50)
									blackscreen.BackgroundTransparency = 0
									blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
									wait(0.3)
									wait()
									humanoidRootPart.Velocity = Vector3.new()

									if available() then
										requestEntrance("WaterfallBossHitbox")
									end

									wait(0.3)
									blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
									wait(1.4)
								else
									Notification.new("<Color=Red>You must be Level 1950 to access this area.<Color=/>"):Display()
									wait(1.5)
								end

								CollectionService:RemoveTag(localPlayer, "Teleporting")
							end
						end
					end)
				end)
				local hitbox = map:WaitForChild("Waterfall"):WaitForChild("BossRoom"):WaitForChild("Door"):WaitForChild("BossDoor"):WaitForChild("Hitbox")
				hitbox.Touched:Connect(function(otherPart)
					if not available() then
						return
					end

					if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
						localPlayer,
						"Teleporting"
					) then
						local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - hitbox.Position).magnitude < humanoidRootPart.Size.Y * 2 + hitbox.Size.Y then
							CollectionService:AddTag(localPlayer, "Teleporting")

							if hasPermission2() then
								blackscreen.Position = UDim2.new(-1, 0, 0, -50)
								blackscreen.BackgroundTransparency = 0
								blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
								wait(0.3)
								humanoidRootPart.Velocity = Vector3.new()

								if available() then
									requestEntrance("TurtleEntranceBoss")
								end

								wait(0.3)
								blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
								wait(1.4)
								pcall(function()
									map.Waterfall.BossRoom.Parent = game.ReplicatedStorage.MapStash.Waterfall
								end)
							else
								Notification.new("<Color=Red>You must be Level 1950 to access this area.<Color=/>"):Display()
								wait(1.5)
							end

							CollectionService:RemoveTag(localPlayer, "Teleporting")
						end
					end
				end)
			end)
		end
	end)
	task.spawn(function()
		local dressrosa = map:WaitForChild("Dressrosa", 1)

		if dressrosa then
			local flamingoEntrance = dressrosa:WaitForChild("FlamingoEntrance")
			local flamingoExit = dressrosa:WaitForChild("FlamingoExit")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function hasPermission()
				return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("GetUnlockables").FlamingoAccess
			end

			flamingoEntrance.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - flamingoEntrance.Position).magnitude < humanoidRootPart.Size.Y * 2 + flamingoEntrance.Size.X / 2 then
						CollectionService:AddTag(localPlayer, "Teleporting")

						if hasPermission() then
							blackscreen.Position = UDim2.new(-1, 0, 0, -50)
							blackscreen.BackgroundTransparency = 0
							blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
							wait(0.3)
							wait()
							humanoidRootPart.Velocity = Vector3.new()

							if available() then
								requestEntrance(flamingoExit.CFrame * Vector3.new(0, 0, -humanoidRootPart.Size.Z - 4))
								wait()
							end

							wait(0.3)
							blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
							wait(1.4)
						else
							Notification.new("<Color=Red>You cannot access this area yet.<Color=/>"):Display()
							wait(1.5)
						end

						CollectionService:RemoveTag(localPlayer, "Teleporting")
					end
				end
			end)
			flamingoExit.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - flamingoExit.Position).magnitude < humanoidRootPart.Size.Y * 2 + flamingoExit.Size.X / 2 then
						CollectionService:AddTag(localPlayer, "Teleporting")

						if hasPermission() then
							blackscreen.Position = UDim2.new(-1, 0, 0, -50)
							blackscreen.BackgroundTransparency = 0
							blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
							wait(0.3)
							humanoidRootPart.Velocity = Vector3.new()

							if available() then
								requestEntrance(flamingoEntrance.CFrame * Vector3.new(
									0,
									0,
									-humanoidRootPart.Size.Z - 4
								))
								wait()
							end

							wait(0.3)
							blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
							wait(1.4)
						else
							Notification.new("<Color=Red>You cannot access this area yet.<Color=/>"):Display()
							wait(1.5)
						end

						CollectionService:RemoveTag(localPlayer, "Teleporting")
					end
				end
			end)
			local ghostShip = map:WaitForChild("GhostShip", 1)
			local ghostShipInterior = map:WaitForChild("GhostShipInterior", 1)
			local teleport = ghostShip:WaitForChild("Teleport")
			local teleport2 = ghostShipInterior:WaitForChild("Teleport")

			-- equivalent calls inferred from this helper; original call sites unknown
			local function hasPermission2()
				local _, v2 = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("GetUnlockables")
				return v2 >= 1000
			end

			teleport.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - teleport.Position).magnitude < humanoidRootPart.Size.Y * 2 + teleport.Size.Y / 2 then
						CollectionService:AddTag(localPlayer, "Teleporting")

						if hasPermission2() then
							blackscreen.Position = UDim2.new(-1, 0, 0, -50)
							blackscreen.BackgroundTransparency = 0
							blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
							wait(0.3)
							wait()
							humanoidRootPart.Velocity = Vector3.new()

							if available() then
								requestEntrance(ghostShipInterior.TeleportSpawn.Position)
								wait()
							end

							wait(0.3)
							blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
							wait(1.4)
						else
							Notification.new("<Color=Red>You must be Level 1000 to access this area.<Color=/>"):Display()
							wait(1.5)
						end

						CollectionService:RemoveTag(localPlayer, "Teleporting")
					end
				end
			end)
			teleport2.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - teleport2.Position).magnitude < humanoidRootPart.Size.Y * 2 + teleport2.Size.Y / 2 then
						CollectionService:AddTag(localPlayer, "Teleporting")
						blackscreen.Position = UDim2.new(-1, 0, 0, -50)
						blackscreen.BackgroundTransparency = 0
						blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
						wait(0.3)
						humanoidRootPart.Velocity = Vector3.new()

						if available() then
							requestEntrance(ghostShip.TeleportSpawn.Position)
							wait()
						end

						wait(0.3)
						blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
						wait(1.4)
						CollectionService:RemoveTag(localPlayer, "Teleporting")
					end
				end
			end)
			spawn(function()
				while game.Lighting:FindFirstChild("DarkbeardLighting") do
					wait(1)
				end

				local lighting = game.Lighting
				local ambient = game.Lighting.Ambient
				local fogEnd = game.Lighting.FogEnd
				local fogColor = game.Lighting.FogColor
				local brightness = game.Lighting.Brightness
				local vortex = ghostShip:WaitForChild("Vortex")
				local v2 = false
				local v3 = 0
				local color = Color3.fromRGB(100, 140, 220)
				local color2 = Color3.fromRGB(20, 30, 40)
				RunService.Heartbeat:Connect(function(dt)
					vortex.CFrame *= CFrame.Angles(0, 0, dt)
					v3 += dt

					if v3 < 0.2 then
						return
					end

					v3 %= 0.2
					local character = localPlayer.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart then
						return
					end

					local v4 = humanoidRootPart.Position.Z > 30000

					if v4 == v2 then
						return
					end

					v2 = v4

					if v4 then
						lighting.Ambient = color
						lighting.FogEnd = 375
						lighting.FogColor = color2
						lighting.Brightness = 1.85
					else
						lighting.Ambient = ambient
						lighting.Brightness = brightness

						if not lighting:FindFirstChild("DarkbeardLighting") then
							lighting.FogColor = fogColor
							lighting.FogEnd = fogEnd
						end
					end
				end)
			end)
		end
	end)
	local Lighting = game:GetService("Lighting")
	local ambient = game.Lighting.Ambient
	local fogEnd = game.Lighting.FogEnd
	local fogColor = game.Lighting.FogColor
	local brightness = game.Lighting.Brightness

	if currentSeaAsync == "Sea1" then
		local teleportSpawn = map:WaitForChild("Fishmen", 1) and map:WaitForChild("TeleportSpawn", 1)

		if teleportSpawn then
			local entrance = teleportSpawn:WaitForChild("Entrance")
			local exit = teleportSpawn:WaitForChild("Exit")
			local sky = map:WaitForChild("Sky")
			local skyArea2 = map:WaitForChild("SkyArea2")
			local entrance2 = sky:WaitForChild("Entrance")
			local exit2 = skyArea2:WaitForChild("Exit")
			local entrancePoint = skyArea2:WaitForChild("EntrancePoint")
			local exitPoint = sky:WaitForChild("ExitPoint")
			local now = 0

			local function entranceClouded()
				for _, part in sky:GetDescendants() do
					if part:IsA("BasePart") and part.Name == "cloud" and (part.Position - entrance2.Position).Magnitude < 50 and not part:GetAttribute("Broken") then
						return true
					end
				end

				return false
			end

			local v2 = false
			local v3 = 0
			local color = Color3.fromRGB(80, 60, 200)
			local color2 = Color3.fromRGB(0, 140, 255)
			RunService.Heartbeat:Connect(function(dt)
				entrance.CFrame *= CFrame.Angles(0, dt, 0)
				exit.CFrame *= CFrame.Angles(0, dt, 0)
				v3 += dt

				if v3 < 0.2 then
					return
				end

				v3 %= 0.2
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				local v4 = humanoidRootPart.Position.X > 59100

				if v4 == v2 then
					return
				end

				v2 = v4

				if v4 then
					Lighting.Ambient = color
					Lighting.FogEnd = 500
					Lighting.FogColor = color2
					Lighting.Brightness = 1
				else
					Lighting.FogEnd = fogEnd
					Lighting.Ambient = ambient
					Lighting.FogColor = fogColor
					Lighting.Brightness = brightness
				end
			end)
			local MapTransitionEffect = require(game.ReplicatedStorage.Controllers.MapServices.Transitions.MapTransitionEffect)

			local function swirlIntoWhirlpool(humanoidRootPart, p2, p3)
				local humanoid = humanoidRootPart.Parent:FindFirstChild("Humanoid")
				local position = p2.Position
				local v4 = humanoidRootPart.Position - position
				local v5 = math.max(Vector2.new(v4.X, v4.Z).Magnitude, 6)
				local v6 = math.atan2(v4.Z, v4.X)
				local v7 = p3 or GetWaterHeightAtLocation(position)
				local v8 = math.clamp(195 / (3.141592653589793 * v5), 1, 3)

				if humanoid then
					humanoid.PlatformStand = true
				end

				local position2 = humanoidRootPart.Position
				local total = 0

				while total < 1.3 do
					local v9 = RunService.RenderStepped:Wait()
					total += v9
					local v10 = math.min(total / 1.3, 1)
					local v11 = v6 + v10 * v10 * v8 * 3.141592653589793 * 2
					local v12 = math.max(v5 * (1 - v10), 1.5)
					local vector2 = Vector3.new(position.X + math.cos(v11) * v12, v7, position.Z + math.sin(v11) * v12)
					local unit = Vector3.new(-math.cos(v11), -0.8, -math.sin(v11)).Unit
					humanoidRootPart.CFrame = CFrame.lookAt(vector2, vector2 + unit)
					humanoidRootPart.AssemblyLinearVelocity = not (v9 > 0) and createVector(0, 0, 0) or (vector2 - position2) / v9 or createVector(
						0,
						0,
						0
					)
					position2 = vector2
				end
			end

			local function doWhirlpoolTeleport(p2, p3, p4)
				local character = localPlayer.Character
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				local humanoid = character and character:FindFirstChild("Humanoid")
				CollectionService:AddTag(localPlayer, "Teleporting")
				task.delay(1.1304347826086958, MapTransitionEffect.Play)
				swirlIntoWhirlpool(humanoidRootPart, p2, p4)

				if available() then
					requestEntrance(p3.Position)
					wait()
				end

				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)

				if humanoid then
					humanoid.PlatformStand = false
				end

				wait(0.5)
				MapTransitionEffect.StopEarly()
				wait(1)
				CollectionService:RemoveTag(localPlayer, "Teleporting")
			end

			entrance.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - entrance.Position).magnitude < humanoidRootPart.Size.Y * 2 + entrance.Size.X / 2 then
						doWhirlpoolTeleport(entrance, teleportSpawn.EntrancePoint)
					end
				end
			end)
			exit.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - exit.Position).magnitude < humanoidRootPart.Size.Y * 2 + exit.Size.X / 2 then
						doWhirlpoolTeleport(exit, teleportSpawn.ExitPoint)
					end
				end
			end)

			local function setupCaveExit(part)
				if not part:IsA("BasePart") then
					return
				end

				part.Touched:Connect(function(otherPart)
					if not available() or localPlayer:GetAttribute("FishmenCaveArriving") then
						return
					end

					if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
						localPlayer,
						"Teleporting"
					) then
						local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - part.Position).magnitude < humanoidRootPart.Size.Y * 2 + part.Size.X / 2 then
							doWhirlpoolTeleport(part, teleportSpawn.EntrancePoint, part.Position.Y)
						end
					end
				end)
			end

			for _, part in CollectionService:GetTagged("FishmenCaveExit") do
				if not part:IsA("BasePart") then
					continue
				end

				local v4 = part
				part.Touched:Connect(function(otherPart)
					if not available() or localPlayer:GetAttribute("FishmenCaveArriving") then
						return
					end

					if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
						localPlayer,
						"Teleporting"
					) then
						local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - v4.Position).magnitude < humanoidRootPart.Size.Y * 2 + v4.Size.X / 2 then
							doWhirlpoolTeleport(v4, teleportSpawn.EntrancePoint, v4.Position.Y)
						end
					end
				end)
			end

			CollectionService:GetInstanceAddedSignal("FishmenCaveExit"):Connect(setupCaveExit)
			RunService.Heartbeat:Connect(function(dt)
				for _, part in CollectionService:GetTagged("FishmenCaveExit") do
					if part:IsA("BasePart") and part.Parent then
						part.CFrame *= CFrame.Angles(0, dt, 0)
					end
				end
			end)
			entrance2.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - entrance2.Position).magnitude < humanoidRootPart.Size.Y * 2 + entrance2.Size.X / 2 then
						if entranceClouded() then
							if tick() - now > 3 then
								now = tick()
								Notification.new("<Color=Red>Break the clouds first!<Color=/>"):Display()
							end
						else
							CollectionService:AddTag(localPlayer, "Teleporting")
							blackscreen.Position = UDim2.new(-1, 0, 0, -50)
							blackscreen.BackgroundTransparency = 0
							blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
							wait(0.3)
							wait()
							humanoidRootPart.Velocity = Vector3.new()

							if available() then
								requestEntrance(entrancePoint.Position)
								wait()
							end

							wait(0.3)
							blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
							wait(1.4)
							CollectionService:RemoveTag(localPlayer, "Teleporting")
						end
					end
				end
			end)
			exit2.Touched:Connect(function(otherPart)
				if not available() then
					return
				end

				if otherPart and localPlayer.Character and otherPart.Parent == localPlayer.Character and not CollectionService:HasTag(
					localPlayer,
					"Teleporting"
				) then
					local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart and humanoidRootPart.Anchored == false and v[otherPart.Name] and (humanoidRootPart.Position - exit2.Position).magnitude < humanoidRootPart.Size.Y * 2 + exit2.Size.X / 2 then
						CollectionService:AddTag(localPlayer, "Teleporting")
						blackscreen.Position = UDim2.new(-1, 0, 0, -50)
						blackscreen.BackgroundTransparency = 0
						blackscreen:TweenPosition(UDim2.new(0, 0, 0, -50), "Out", "Linear", 0.3)
						wait(0.3)
						wait()
						humanoidRootPart.Velocity = Vector3.new()

						if available() then
							requestEntrance(exitPoint.Position)
							wait()
						end

						wait(0.3)
						blackscreen:TweenPosition(UDim2.new(1, 0, 0, -50), "Out", "Linear", 0.3)
						wait(1.4)
						CollectionService:RemoveTag(localPlayer, "Teleporting")
					end
				end
			end)
		end
	elseif currentSeaAsync == "Sea3" then
		local submergedIsland = Lighting:WaitForChild("LightingLayers"):WaitForChild("SubmergedIsland")
		local submergedColorCorrection = Lighting:WaitForChild("SubmergedColorCorrection")
		local v2 = nil
		local v3 = 0
		RunService.Heartbeat:Connect(function(dt)
			v3 += dt

			if v3 < 0.2 then
				return
			end

			v3 %= 0.2
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local _, _, v4 = GetWaterHeightAtLocation(humanoidRootPart.Position)
			local enabled = v4 == "Submerged Island" or v4 == "Sharkman Arena" or v4 == "Sealed Cavern1" or v4 == "Sealed Cavern2"

			if enabled == v2 then
				return
			end

			v2 = enabled
			submergedIsland:SetAttribute("Enabled", enabled)
			submergedIsland.Intensity.Value = enabled and 1 or 0
			submergedColorCorrection.Enabled = enabled
		end)
	end
end, (`Init {script.Name}`))