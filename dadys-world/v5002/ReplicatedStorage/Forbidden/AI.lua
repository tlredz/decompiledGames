local createVector = vector.create
local AI = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local Debris = game:GetService("Debris")
local v = {}
local forbidden = ReplicatedStorage:WaitForChild("Forbidden")
local stopAI = script:WaitForChild("signals"):WaitForChild("StopAI")
local Standard = require(forbidden:WaitForChild("Standard"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local count = 0
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	count += 1

	if count % 60 == 0 then
		local Players = game:GetService("Players")

		for k, _ in pairs(v2) do
			if Players:GetPlayerByUserId(k) then
				continue
			end

			v2[k] = nil
			v3[k] = nil
			v4[k] = nil
			v5[k] = nil
		end
	end
end)

function AI.Stuck(object, p)
	if not (object and p) then
		return
	end

	local cFrame = p.CFrame
	local v6 = p.CFrame * CFrame.new(0, 0, 2)
	local unit = (v6.Position - cFrame.Position).Unit
	local v7 = (v6.Position - cFrame.Position).Magnitude + 0.65
	local _ = cFrame.Position + unit * v7
	object:Move(unit)
end

local count2 = 0
local nowsByParent = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function reset(instance)
	if instance:FindFirstChild("Humanoid") and instance.PrimaryPart then
		instance.Humanoid:MoveTo(instance.PrimaryPart.Position)
	end
end

local function updateAll() end

local function onStoppage(instance)
	if instance == nil then
		error("AI passed to AI:Stop() is nil.")
		return
	end

	if v[instance] == nil then
		return
	end

	if instance:FindFirstChild("Waypoints") then
		instance:FindFirstChild("Waypoints"):Destroy()
	end

	reset(instance) -- equivalent call inferred; original call site unknown
	v[instance] = false
end

function AI.Stop(p)
	stopAI:Fire(p)
	return nil
end

stopAI.Event:Connect(onStoppage)

function AI.SmartPathfind(parent, part, p, p2)
	if parent == nil or part == nil then
		return false
	end

	local v6 = {
		StandardPathfindSettings = {
			AgentRadius = 10,
			AgentHeight = parent:WaitForChild("Humanoid").HipHeight,
			AgentCanJump = false,
			AgentCanClimb = false,
			Costs = {
				Water = 20,
				DangerZone = 1e999
			}
		},
		Visualize = true,
		Tracking = false
	}

	if p2 then
		for k, v7 in pairs(p2) do
			v6[k] = v7
		end
	end

	local count3 = 0
	local humanoidRootPart = nil
	local humanoid = nil
	local humanoidRootPart2 = nil

	local function updateBasedOnType(humanoid2, p3)
		count3 += 1

		local function updateVars(instance)
			if count3 == 1 then
				humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart == nil then
					error("Could not find HRT. change to waitforchild to bypass")
					return
				end

				humanoid = instance:FindFirstChild("Humanoid")

				if humanoid == nil then
					error("Could not find Humanoid. change to waitforchild to bypass")
					return
				end
			end

			if count3 == 2 then
				humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart2 == nil then
					error("Could not find HRT. change to waitforchild to bypass")
				end
			end
		end

		if typeof(humanoid2) == "userdata" and humanoid2:IsA("Humanoid") then
			updateVars(humanoid2.Parent)
		end

		if p3 == "Model" then
			if count3 == 1 and humanoid2:FindFirstChild("Humanoid") then
				updateVars(humanoid2)
			end

			if count3 == 2 then
				if humanoid2:FindFirstChild("HumanoidRootPart") then
					humanoidRootPart2 = humanoid2:FindFirstChild("HumanoidRootPart")
				elseif humanoid2:FindFirstChild("Humanoid") then
					humanoidRootPart2 = humanoid2:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart2 then
						for _, part2 in ipairs(humanoid2:GetChildren()) do
							if not part2:IsA("BasePart") then
								continue
							end

							humanoidRootPart2 = part2
							break
						end
					end
				else
					humanoidRootPart2 = humanoid2:GetChildren()[1]
				end
			end
		end

		if p3 == "Player" then
			if humanoid2.Character ~= nil then
				updateVars(humanoid2.Character)
			end

			if humanoid2.Character == nil then
				return "char not found"
			end
		end

		if p3 == "Part" then
			if humanoid2.Parent:FindFirstChild("Humanoid") then
				updateVars(humanoid2.Parent)
			end

			if humanoid2.Parent.Parent:FindFirstChild("Humanoid") then
				updateVars(humanoid2.Parent.Parent)
			end

			if count3 == 1 then
				error("Are you sure you passed in the right part for the character, could not find a Humanoid")
			elseif count3 == 2 then
				humanoidRootPart2 = humanoid2
			end
		end
	end

	if parent == nil then
		error("Enemy/Tracker does not exist.")
	else
		updateBasedOnType(parent, Standard.basic.GetType(parent))
	end

	if part == nil then
		return "target not found"
	end

	updateBasedOnType(part, Standard.basic.GetType(part))
	local path = PathfindingService:CreatePath({
		AgentRadius = parent:WaitForChild("RecordedSize").Value * 0.5,
		AgentCanJump = false,
		AgentHeight = parent.Humanoid.HipHeight * 0.1,
		Waypoint_Threshold = 4,
		WaypointSpacing = 3,
		Costs = {
			Water = 20,
			DangerZone = 1e999
		}
	})

	local function canseetarget(parent2, model, p3)
		if not (model and model.Parent) then
			return false
		end

		if model:GetAttribute("DecoyTag") then
			print("[AI Debug] Detected decoy by DecoyTag attribute")
			return true
		end

		if model:FindFirstChildOfClass("AnimationController") and model:FindFirstChild("Humanoid") then
			print("[AI Debug] Detected potential decoy with AnimationController")
			return true
		end

		if model:IsA("Model") then
			local model2 = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

			if not model2 then
				return false
			end

			local monsters = model2:FindFirstChild("Monsters")

			if not monsters then
				return false
			end

			local humanoidRootPart3 = parent2:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart3 and model.PrimaryPart) then
				return false
			end

			local position = humanoidRootPart3.Position
			local v7 = (model.PrimaryPart.Position - position).Unit * p3
			local raycastParams = RaycastParams.new()
			local filterDescendantsInstances = {}

			for _, child in pairs(monsters:GetChildren()) do
				table.insert(filterDescendantsInstances, child)
			end

			if workspace:FindFirstChild("InGamePlayers") then
				for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
					if child ~= model then
						table.insert(filterDescendantsInstances, child)
					end
				end
			end

			table.insert(filterDescendantsInstances, parent2)
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			local raycastResult = game.Workspace:Raycast(position, v7, raycastParams)

			if raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(model) then
				return true
			end

			return false
		else
			local model2 = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

			if not model2 then
				return false
			end

			local monsters = model2:FindFirstChild("Monsters")

			if not monsters then
				return false
			end

			local humanoidRootPart3 = parent2:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart3 and model) then
				return false
			end

			local position = humanoidRootPart3.Position
			local v7 = (model.Position - position).Unit * p3
			local raycastParams = RaycastParams.new()
			local filterDescendantsInstances = {}

			for _, child in pairs(monsters:GetChildren()) do
				table.insert(filterDescendantsInstances, child)
			end

			if workspace:FindFirstChild("InGamePlayers") then
				for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
					table.insert(filterDescendantsInstances, child)
				end
			end

			table.insert(filterDescendantsInstances, parent2)
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			local raycastResult = game.Workspace:Raycast(position, v7, raycastParams)

			if raycastResult and raycastResult.Instance then
				return raycastResult.Instance == model
			end

			return false
		end
	end

	local function losCheck()
		local humanoidRootPart3 = parent:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart4 = part and part:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart3 and humanoidRootPart4) then
			return false
		end

		if canseetarget(parent, part, (humanoidRootPart4.Position - humanoidRootPart3.Position).Magnitude + 2) then
			return true
		end

		local partsInPart = workspace:GetPartsInPart(humanoidRootPart3)

		for _, v7 in ipairs(partsInPart) do
			if v7.Name == "HumanoidRootPart" and v7.Parent:FindFirstChild("Humanoid") and v7.Parent == part then
				return true
			end
		end

		return false
	end

	local function destroyWP()
		for _, child in pairs(parent:GetChildren()) do
			if child.Name == "Waypoints" then
				Debris:AddItem(child, 0)
			end
		end
	end

	local function moveTo()
		local v7 = nil

		local function invokeClientWithTimeout(playerFromCharacter, humanoidRootPart3, p3)
			local getCharacterPosition = ReplicatedStorage2.Events.GetCharacterPosition
			local v8 = false
			local v9 = nil
			coroutine.wrap(function()
				local _, _ = pcall(function()
					v9 = getCharacterPosition:InvokeClient(playerFromCharacter)
				end)
				v8 = true
			end)()
			local lastTime = tick()

			while not v8 and tick() - lastTime < p3 do
				local RunService2 = game:GetService("RunService")
				RunService2.Heartbeat:Wait()
			end

			if not v8 or v9 == nil then
				return humanoidRootPart3.Position
			end

			local position

			if typeof(v9) == "CFrame" then
				position = v9.Position
			elseif typeof(v9) == "Vector3" then
				position = v9
			else
				return humanoidRootPart3.Position
			end

			local magnitude = (position - humanoidRootPart3.Position).Magnitude

			if magnitude > 200 then
				warn("Suspicious position from client:", playerFromCharacter.Name, "Distance:", magnitude)
				return humanoidRootPart3.Position
			end

			if position.Magnitude > 10000 or math.abs(position.X) > 10000 or math.abs(position.Y) > 10000 or math.abs(position.Z) > 10000 then
				warn("Extreme position from client:", playerFromCharacter.Name, position)
				return humanoidRootPart3.Position
			end

			if position.X == position.X and position.Y == position.Y and position.Z == position.Z then
				return position
			end

			warn("NaN position from client:", playerFromCharacter.Name)
			return humanoidRootPart3.Position
		end

		if humanoidRootPart2 and humanoidRootPart2.Parent and game.Players:GetPlayerFromCharacter(humanoidRootPart2.Parent) then
			local stats = humanoidRootPart2.Parent:FindFirstChild("Stats")

			if stats and stats:FindFirstChild("InElevator") and stats.InElevator.Value or part:FindFirstChild("BoxAbilityActive") or part:FindFirstChild("NoDandy") or part:FindFirstChild("NoTarget") and not v6.NoTargetOverride then
				v7 = nil
			else
				local success, result = pcall(function()
					local playerFromCharacter = game.Players:GetPlayerFromCharacter(humanoidRootPart2.Parent)
					local humanoidRootPart3 = playerFromCharacter and part:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart3 then
						v7 = invokeClientWithTimeout(playerFromCharacter, humanoidRootPart3, 0.2)
					end
				end)

				if not success then
					warn("Error invoking client position:", result)
				end
			end
		end

		if v7 == nil or typeof(v7) ~= "Vector3" then
			humanoid:MoveTo(humanoidRootPart2.Position)
		elseif part:FindFirstChild("HumanoidRootPart") and parent and parent.PrimaryPart then
			local success, result = pcall(function()
				local vector2 = Vector3.new(0, -(parent.PrimaryPart.Size.Y / 2 + humanoid.HipHeight), 0)
				local humanoid2 = part:FindFirstChild("Humanoid")
				local humanoidRootPart3 = part:FindFirstChild("HumanoidRootPart")

				if not (humanoid2 and humanoidRootPart3) then
					humanoid:MoveTo(humanoidRootPart2.Position)
					return
				end

				local vector3 = Vector3.new(0, -(humanoidRootPart3.Size.Y / 2 + humanoid2.HipHeight), 0)
				local v8 = parent.PrimaryPart.Position + vector2
				local v9 = v7 + vector3 - v8

				if v9.Magnitude < 0.001 then
					humanoid:MoveTo(humanoidRootPart2.Position)
					return
				end

				local unit = v9.Unit
				local v10 = 0

				if humanoidRootPart3 and humanoidRootPart3:IsA("BasePart") and humanoidRootPart3.Velocity then
					local success2, result2 = pcall(function()
						return (math.abs(humanoidRootPart3.Velocity:Dot(unit) / 3))
					end)

					if success2 then
						v10 = result2
					end
				end

				local v11 = v8 + unit * (v9.Magnitude + v10)

				if v11.Magnitude > 10000 then
					warn("Extreme calculated movement position:", v11.Magnitude)
					humanoid:MoveTo(humanoidRootPart2.Position)
				else
					humanoid:MoveTo(v11)
				end
			end)

			if not success then
				warn("Movement calculation failed:", result)
				humanoid:MoveTo(humanoidRootPart2.Position)
			end
		else
			humanoid:MoveTo(humanoidRootPart2.Position)
		end

		if not v6.Tracking then
			humanoid.MoveToFinished:Wait()
		end
	end

	local flag = false
	local v7 = 0
	local v8 = 0

	local function pathfind()
		local WAIT_INTERVAL = 0.15
		local DELAY_DURATION = 1
		local now = tick()

		if v6.Tracking then
			if flag then
				if not (now - v8 > 2) then
					return
				end

				warn(parent.Name .. " pathfindRunning flag stuck for " .. tostring(now - v8) .. "s - auto-resetting")
				flag = false
				local humanoidRootPart3 = part and part:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart3 and humanoid and humanoid.WalkSpeed > 0 then
					humanoid:MoveTo(humanoidRootPart3.Position)
				end
			end

			if now - v7 < 0.05 then
				return
			end

			flag = true
			v8 = now
		end

		v7 = now
		local chasingValue = parent:WaitForChild("ChasingValue")

		if v6.Tracking == true then
			if chasingValue.Value ~= part then
				flag = false
				return
			end

			if part:FindFirstChild("NoTarget") and not v6.NoTargetOverride then
				flag = false
				return
			end

			if part:FindFirstChild("BoxAbilityActive") or part:FindFirstChild("NoDandy") then
				flag = false
				return
			end

			local stats = part:FindFirstChild("Stats")

			if stats and stats:FindFirstChild("InElevator") and stats.InElevator.Value then
				flag = false
				return
			end
		end

		if losCheck() then
			moveTo()
			flag = false
		else
			local v9 = nil
			local waypoints, v10, v11, v12, folder, part2, v13, position, onWaypointReached, humanoidRootPart3, cFrame, v14, count4, position2, unit, raycastParams, v15, v16, raycastResult, vector2, unit2, now2, lostInterest, humanoidRootPart4, v17, lastTime, moveToFinishedConnection, lostInterest2

			if part:FindFirstChild("Humanoid") and part:FindFirstChild("HumanoidRootPart") then
				local humanoid2 = part:FindFirstChild("Humanoid")
				local humanoidRootPart5 = part:FindFirstChild("HumanoidRootPart")

				if humanoid2 and humanoidRootPart5 then
					local playerFromCharacter = game.Players:GetPlayerFromCharacter(part)

					if playerFromCharacter then
						local _ = playerFromCharacter.UserId
					else
						local _ = part:GetAttribute("DecoyTag") or part:FindFirstChildOfClass("AnimationController")
					end

					if not v9 then
						local vector3 = Vector3.new(0, -(humanoidRootPart5.Size.Y / 2 + humanoid2.HipHeight), 0)
						v9 = humanoidRootPart5.Position + vector3
					end

					if (humanoidRootPart.Position - v9).Magnitude > 500 then
						local lostInterest3 = parent:FindFirstChild("LostInterest")

						if lostInterest3 then
							if lostInterest3.Value ~= true then
								lostInterest3.Value = true
								AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
								task.delay(DELAY_DURATION, function()
									if lostInterest3 and lostInterest3.Parent then
										lostInterest3.Value = false
									end
								end)
							end
						elseif parent:GetAttribute("LostInterest") ~= true then
							parent:SetAttribute("LostInterest", true)
							AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
							task.delay(DELAY_DURATION, function()
								if parent and parent.Parent then
									parent:SetAttribute("LostInterest", false)
								end
							end)
						end

						flag = false
						return false
					else
						path:ComputeAsync(humanoidRootPart.Position, v9)
						waypoints = path:GetWaypoints()

						if path.Status == Enum.PathStatus.Success then
							if path.Status == Enum.PathStatus.Success then
								if v6.Tracking then
									v10 = not (#waypoints > 2) and 2 or math.min(3, #waypoints)

									if waypoints[v10] then
										humanoid:MoveTo(waypoints[v10].Position)
									elseif #waypoints >= 2 and waypoints[2] then
										humanoid:MoveTo(waypoints[2].Position)
									elseif part and part:FindFirstChild("HumanoidRootPart") then
										humanoid:MoveTo(part.HumanoidRootPart.Position)
									end
								else
									v11 = 1
									count2 += 1
									v12 = count2
									v[parent] = v12

									if p2.Visualize then
										folder = Instance.new("Folder")
										folder.Parent = parent
										folder.Name = "Waypoints"

										for k, waypoint in pairs(waypoints) do
											part2 = Instance.new("Part")
											part2.Shape = Enum.PartType.Ball
											part2.Color = Color3.new(0.384314, 0.341176, 1)
											part2.Material = Enum.Material.Neon
											part2.CFrame = CFrame.new(waypoint.Position)
											part2.Parent = folder
											part2.Name = k
											part2.Anchored = true
											part2.Size = createVector(1, 1, 1)
											part2.CanCollide = false
										end
									end

									for i, waypoint in ipairs(waypoints) do
										if i > 1 then
											if humanoid.WalkSpeed == 0 then
												break
											end

											if #waypoints < v11 or v[parent] ~= v12 then
												v13 = parent
												reset(v13) -- equivalent call inferred; original call site unknown
												flag = false
												return
											else
												if waypoint.Action == Enum.PathWaypointAction.Jump then
													humanoid.Jump = true
												end

												if v6.Tracking == true and chasingValue.Value ~= part then
													flag = false
													return
												end

												humanoid:MoveTo(waypoint.Position)
												position = parent:WaitForChild("HumanoidRootPart").Position

												if humanoid.MoveToFinished:Wait() then
													onWaypointReached = parent:FindFirstChild("OnWaypointReached")

													if onWaypointReached and onWaypointReached:IsA("BindableEvent") then
														onWaypointReached:Fire(i, waypoint)
													end
												else
													humanoidRootPart3 = parent:FindFirstChild("HumanoidRootPart")

													if not humanoidRootPart3 then
														break
													end

													cFrame = humanoidRootPart3.CFrame
													v14 = false
													count4 = 0

													while not v14 and count4 < 3 do
														count4 += 1
														position2 = humanoidRootPart3.Position
														unit = nil
														raycastParams = RaycastParams.new()
														raycastParams.FilterDescendantsInstances = { parent }
														raycastParams.FilterType = Enum.RaycastFilterType.Exclude

														if count4 == 1 then
															v15 = cFrame.RightVector * (math.random() > 0.5 and 1 or -1)
															v16 = -cFrame.LookVector
															unit = (v15 + v16 * 0.4).Unit
															raycastResult = workspace:Raycast(
																humanoidRootPart3.Position + createVector(0, 2, 0),
																unit * 5,
																raycastParams
															)

															if raycastResult and raycastResult.Distance < 2 then
																unit = (-v15 + v16 * 0.4).Unit
															end
														elseif count4 == 2 then
															unit = (cFrame.RightVector * (math.random() > 0.5 and -1 or 1) + cFrame.LookVector * 0.5).Unit
														elseif count4 == 3 then
															unit = (-cFrame.LookVector + cFrame.RightVector * (math.random() > 0.5 and 1 or -1) * 0.7).Unit
														end

														humanoid:MoveTo(cFrame.Position + unit * 4)
														task.wait(WAIT_INTERVAL)
														v14 = (humanoidRootPart3.Position - position2).Magnitude > 0.8 or v14
													end

													if not v14 then
														vector2 = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))

														if vector2.Magnitude > 0 then
															unit2 = vector2.Unit
															humanoid:MoveTo(humanoidRootPart3.Position + unit2 * 6)
															humanoid.Jump = true
														end

														task.wait(WAIT_INTERVAL)

														if (humanoidRootPart3.Position - position).Magnitude < 0.5 then
															now2 = tick()

															if not nowsByParent[parent] or now2 - nowsByParent[parent] > 3 then
																warn(
																	parent.Name,
																	"gave up pathfinding - truly stuck at",
																	string.format(
																		"(%.1f, %.1f, %.1f)",
																		humanoidRootPart3.Position.X,
																		humanoidRootPart3.Position.Y,
																		humanoidRootPart3.Position.Z
																	),
																	"trying to reach waypoint",
																	i,
																	"at",
																	string.format(
																		"(%.1f, %.1f, %.1f)",
																		waypoint.Position.X,
																		waypoint.Position.Y,
																		waypoint.Position.Z
																	)
																)
																nowsByParent[parent] = now2
															end

															task.wait(0.5)
															break
														end
													end
												end
											end
										end

										v11 += 1
									end
								end
							else
								lostInterest = parent:FindFirstChild("LostInterest")

								if lostInterest then
									if lostInterest.Value ~= true then
										lostInterest.Value = true
										AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
										task.delay(DELAY_DURATION, function()
											if lostInterest and lostInterest.Parent then
												lostInterest.Value = false
											end
										end)
									end
								elseif parent:GetAttribute("LostInterest") ~= true then
									parent:SetAttribute("LostInterest", true)
									AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
									task.delay(DELAY_DURATION, function()
										if parent and parent.Parent then
											parent:SetAttribute("LostInterest", false)
										end
									end)
								end
							end

							flag = false
							return
						else
							warn("[AI] " .. parent.Name .. " path failed: " .. tostring(path.Status) .. " (AgentRadius: " .. tostring(parent:FindFirstChild("RecordedSize") and parent:FindFirstChild("RecordedSize").Value * 0.5 or "?") .. ")")
							humanoidRootPart4 = part and part:FindFirstChild("HumanoidRootPart")

							if humanoidRootPart4 and humanoid then
								humanoid:MoveTo(humanoidRootPart4.Position)
								v17 = false
								lastTime = tick()
								moveToFinishedConnection = nil
								moveToFinishedConnection = humanoid.MoveToFinished:Connect(function()
									v17 = true

									if moveToFinishedConnection then
										moveToFinishedConnection:Disconnect()
									end
								end)

								while not v17 and tick() - lastTime < 0.5 do
									task.wait()
								end

								if moveToFinishedConnection then
									moveToFinishedConnection:Disconnect()
								end
							elseif part and part:IsA("BasePart") and humanoid then
								humanoid:MoveTo(part.Position)
								humanoid.MoveToFinished:Wait()
							else
								lostInterest2 = parent:FindFirstChild("LostInterest")

								if lostInterest2 then
									if lostInterest2.Value ~= true then
										lostInterest2.Value = true
										AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
										task.delay(DELAY_DURATION, function()
											if lostInterest2 and lostInterest2.Parent then
												lostInterest2.Value = false
											end
										end)
									end
								elseif parent:GetAttribute("LostInterest") ~= true then
									parent:SetAttribute("LostInterest", true)
									AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
									task.delay(DELAY_DURATION, function()
										if parent and parent.Parent then
											parent:SetAttribute("LostInterest", false)
										end
									end)
								end
							end

							flag = false
							return false
						end
					end
				end
			end

			if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude > 500 then
				flag = false
				return false
			end

			path:ComputeAsync(humanoidRootPart.Position, humanoidRootPart2.Position)
			waypoints = path:GetWaypoints()

			if path.Status == Enum.PathStatus.Success then
				if path.Status == Enum.PathStatus.Success then
					if v6.Tracking then
						v10 = not (#waypoints > 2) and 2 or math.min(3, #waypoints)

						if waypoints[v10] then
							humanoid:MoveTo(waypoints[v10].Position)
						elseif #waypoints >= 2 and waypoints[2] then
							humanoid:MoveTo(waypoints[2].Position)
						elseif part and part:FindFirstChild("HumanoidRootPart") then
							humanoid:MoveTo(part.HumanoidRootPart.Position)
						end
					else
						v11 = 1
						count2 += 1
						v12 = count2
						v[parent] = v12

						if p2.Visualize then
							folder = Instance.new("Folder")
							folder.Parent = parent
							folder.Name = "Waypoints"

							for k, waypoint in pairs(waypoints) do
								part2 = Instance.new("Part")
								part2.Shape = Enum.PartType.Ball
								part2.Color = Color3.new(0.384314, 0.341176, 1)
								part2.Material = Enum.Material.Neon
								part2.CFrame = CFrame.new(waypoint.Position)
								part2.Parent = folder
								part2.Name = k
								part2.Anchored = true
								part2.Size = createVector(1, 1, 1)
								part2.CanCollide = false
							end
						end

						for i, waypoint in ipairs(waypoints) do
							if i > 1 then
								if humanoid.WalkSpeed == 0 then
									break
								end

								if #waypoints < v11 or v[parent] ~= v12 then
									v13 = parent
									reset(v13) -- equivalent call inferred; original call site unknown
									flag = false
									return
								else
									if waypoint.Action == Enum.PathWaypointAction.Jump then
										humanoid.Jump = true
									end

									if v6.Tracking == true and chasingValue.Value ~= part then
										flag = false
										return
									end

									humanoid:MoveTo(waypoint.Position)
									position = parent:WaitForChild("HumanoidRootPart").Position

									if humanoid.MoveToFinished:Wait() then
										onWaypointReached = parent:FindFirstChild("OnWaypointReached")

										if onWaypointReached and onWaypointReached:IsA("BindableEvent") then
											onWaypointReached:Fire(i, waypoint)
										end
									else
										humanoidRootPart3 = parent:FindFirstChild("HumanoidRootPart")

										if not humanoidRootPart3 then
											break
										end

										cFrame = humanoidRootPart3.CFrame
										v14 = false
										count4 = 0

										while not v14 and count4 < 3 do
											count4 += 1
											position2 = humanoidRootPart3.Position
											unit = nil
											raycastParams = RaycastParams.new()
											raycastParams.FilterDescendantsInstances = { parent }
											raycastParams.FilterType = Enum.RaycastFilterType.Exclude

											if count4 == 1 then
												v15 = cFrame.RightVector * (math.random() > 0.5 and 1 or -1)
												v16 = -cFrame.LookVector
												unit = (v15 + v16 * 0.4).Unit
												raycastResult = workspace:Raycast(
													humanoidRootPart3.Position + createVector(0, 2, 0),
													unit * 5,
													raycastParams
												)

												if raycastResult and raycastResult.Distance < 2 then
													unit = (-v15 + v16 * 0.4).Unit
												end
											elseif count4 == 2 then
												unit = (cFrame.RightVector * (math.random() > 0.5 and -1 or 1) + cFrame.LookVector * 0.5).Unit
											elseif count4 == 3 then
												unit = (-cFrame.LookVector + cFrame.RightVector * (math.random() > 0.5 and 1 or -1) * 0.7).Unit
											end

											humanoid:MoveTo(cFrame.Position + unit * 4)
											task.wait(WAIT_INTERVAL)
											v14 = (humanoidRootPart3.Position - position2).Magnitude > 0.8 or v14
										end

										if not v14 then
											vector2 = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))

											if vector2.Magnitude > 0 then
												unit2 = vector2.Unit
												humanoid:MoveTo(humanoidRootPart3.Position + unit2 * 6)
												humanoid.Jump = true
											end

											task.wait(WAIT_INTERVAL)

											if (humanoidRootPart3.Position - position).Magnitude < 0.5 then
												now2 = tick()

												if not nowsByParent[parent] or now2 - nowsByParent[parent] > 3 then
													warn(
														parent.Name,
														"gave up pathfinding - truly stuck at",
														string.format(
															"(%.1f, %.1f, %.1f)",
															humanoidRootPart3.Position.X,
															humanoidRootPart3.Position.Y,
															humanoidRootPart3.Position.Z
														),
														"trying to reach waypoint",
														i,
														"at",
														string.format(
															"(%.1f, %.1f, %.1f)",
															waypoint.Position.X,
															waypoint.Position.Y,
															waypoint.Position.Z
														)
													)
													nowsByParent[parent] = now2
												end

												task.wait(0.5)
												break
											end
										end
									end
								end
							end

							v11 += 1
						end
					end
				else
					lostInterest = parent:FindFirstChild("LostInterest")

					if lostInterest then
						if lostInterest.Value ~= true then
							lostInterest.Value = true
							AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
							task.delay(DELAY_DURATION, function()
								if lostInterest and lostInterest.Parent then
									lostInterest.Value = false
								end
							end)
						end
					elseif parent:GetAttribute("LostInterest") ~= true then
						parent:SetAttribute("LostInterest", true)
						AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
						task.delay(DELAY_DURATION, function()
							if parent and parent.Parent then
								parent:SetAttribute("LostInterest", false)
							end
						end)
					end
				end

				flag = false
			else
				warn("[AI] " .. parent.Name .. " path failed: " .. tostring(path.Status) .. " (AgentRadius: " .. tostring(parent:FindFirstChild("RecordedSize") and parent:FindFirstChild("RecordedSize").Value * 0.5 or "?") .. ")")
				humanoidRootPart4 = part and part:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart4 and humanoid then
					humanoid:MoveTo(humanoidRootPart4.Position)
					v17 = false
					lastTime = tick()
					moveToFinishedConnection = nil
					moveToFinishedConnection = humanoid.MoveToFinished:Connect(function()
						v17 = true

						if moveToFinishedConnection then
							moveToFinishedConnection:Disconnect()
						end
					end)

					while not v17 and tick() - lastTime < 0.5 do
						task.wait()
					end

					if moveToFinishedConnection then
						moveToFinishedConnection:Disconnect()
					end
				elseif part and part:IsA("BasePart") and humanoid then
					humanoid:MoveTo(part.Position)
					humanoid.MoveToFinished:Wait()
				else
					lostInterest2 = parent:FindFirstChild("LostInterest")

					if lostInterest2 then
						if lostInterest2.Value ~= true then
							lostInterest2.Value = true
							AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
							task.delay(DELAY_DURATION, function()
								if lostInterest2 and lostInterest2.Parent then
									lostInterest2.Value = false
								end
							end)
						end
					elseif parent:GetAttribute("LostInterest") ~= true then
						parent:SetAttribute("LostInterest", true)
						AI.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
						task.delay(DELAY_DURATION, function()
							if parent and parent.Parent then
								parent:SetAttribute("LostInterest", false)
							end
						end)
					end
				end

				flag = false
				return false
			end
		end
	end

	if p or p == nil then
		v[parent] = "starting"

		if v6.Tracking == true then
			while v[parent] ~= false do
				if v6.Visualize then
					destroyWP()
				end

				spawn(pathfind)
				task.wait()
			end
		end

		if v6.Tracking == nil or v6.Tracking == false then
			if v6.Visualize then
				destroyWP()
			end

			pathfind()
		end
	end

	if not p then
		spawn(function()
			v[parent] = "starting"

			if v6.Tracking == true then
				while v[parent] ~= false do
					if v6.Visualize then
						destroyWP()
					end

					spawn(pathfind)
					task.wait()
				end
			end

			if v6.Tracking == nil or v6.Tracking == false then
				if v6.Visualize then
					destroyWP()
				end

				spawn(pathfind)
			end
		end)
	end

	if v6.Visualize then
		destroyWP()
	end
end

return AI