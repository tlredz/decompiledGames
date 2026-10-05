local createVector = vector.create
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local _ = {
	CHASE_SPEED = 190,
	RETURN_SPEED = 250,
	COUNTDOWN = 5,
	KILL_RADIUS = 13,
	WAYPOINT_REACH = 3,
	PATH_RECOMPUTE = 0.3,
	STOP_DISTANCE = 6,
	ID_WALK = "rbxassetid://104571570562605",
	ID_IDLE = "rbxassetid://123873530367173"
}
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://104571570562605"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://123873530367173"
task.spawn(function()
	ContentProvider:PreloadAsync({ animation, animation2 })
end)
local v = {}
local v2 = {
	AgentRadius = 1,
	AgentHeight = 5,
	AgentCanJump = false,
	AgentCanClimb = false,
	WaypointSpacing = 4
}

local function isInZone(instance, position: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(position)
	return math.abs(pointToObjectSpace.X) <= instance.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= math.max(
		instance.Size.Y / 2,
		30
	) and math.abs(pointToObjectSpace.Z) <= instance.Size.Z / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveSpawnCFrame(instance, instance2, p)
	local pVInstance = p or instance:FindFirstChild("Spawn")

	if pVInstance and pVInstance:IsA("PVInstance") then
		return pVInstance:GetPivot()
	end

	return instance2:GetPivot()
end

local function startNPC(instance, instance2, p, tag: string?)
	local v3 = tag or instance

	if v[v3] then
		return
	end

	v[v3] = true
	task.spawn(function()
		ContentProvider:PreloadAsync({ instance2 })
	end)
	local spawnCFrame = resolveSpawnCFrame(instance, instance2, p) -- equivalent call inferred; original call site unknown
	local clone = instance2:Clone()
	clone:PivotTo(spawnCFrame)
	clone.Parent = workspace
	local humanoidRootPart = clone:WaitForChild("HumanoidRootPart")
	local animator = clone:WaitForChild("Humanoid"):WaitForChild("Animator")
	local chaseMusic = humanoidRootPart:WaitForChild("ChaseMusic")
	local footstep = humanoidRootPart:WaitForChild("Footstep")
	local v4 = 0
	humanoidRootPart.Anchored = true
	local Y = spawnCFrame.Y
	task.spawn(function()
		local path = PathfindingService:CreatePath(v2)
		pcall(function()
			path:ComputeAsync(spawnCFrame.Position, spawnCFrame.Position + createVector(10, 0, 10))
		end)
	end)
	local track = animator:LoadAnimation(animation)
	local track2 = animator:LoadAnimation(animation2)
	track2:Play()
	local v5 = "Idle"
	local v6 = false
	local v7 = true
	local now = 0
	local v8 = {}
	local v9 = 0
	local flag = false
	local v10 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function requestPath(position: Vector3, vector2: Vector3)
		if flag then
			return
		end

		flag = true
		task.spawn(function()
			local path = PathfindingService:CreatePath(v2)

			if pcall(function()
				path:ComputeAsync(position, vector2)
			end) and path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()

				if #waypoints >= 2 then
					local position2 = humanoidRootPart.Position
					local v11 = 1e999
					local v12 = 1

					for i = 1, #waypoints do
						local v13 = position2.X - waypoints[i].Position.X
						local v14 = position2.Z - waypoints[i].Position.Z
						local v15 = v13 * v13 + v14 * v14

						if not (v15 < v11) then
							continue
						end

						v12 = i
						v11 = v15
					end

					v8 = waypoints
					v9 = math.min(v12 + 1, #waypoints)
				end
			end

			flag = false
		end)
	end

	local function goIdle()
		v5 = "Idle"
		v6 = false
		track:Stop(0.1)
		track2:Play()

		if chaseMusic.IsPlaying then
			chaseMusic:Stop()
		end

		footstep:Stop()
		v8 = {}
		v9 = 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function goChase()
		v5 = "Chasing"
		now = os.clock()
		track:Play()
		track2:Stop()

		if not chaseMusic.IsPlaying then
			chaseMusic:Play()
		end

		if #v8 == 0 then
			v10 = 0
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function goReturn()
		v5 = "Returning"
		v8 = {}
		v9 = 0
		v10 = 0
	end

	local v11 = {
		[3] = Color3.fromRGB(255, 160, 0),
		[2] = Color3.fromRGB(255, 80, 0),
		[1] = Color3.fromRGB(255, 20, 0)
	}

	local function showBossUI(p2: number?, flag2: boolean?)
		local playerGui = localPlayer.PlayerGui
		local bossCountdownGui = playerGui:FindFirstChild("BossCountdownGui")

		if bossCountdownGui then
			bossCountdownGui:Destroy()
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "BossCountdownGui"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui
		local frame = Instance.new("Frame")
		frame.Name = "BossNotif"
		frame.Size = UDim2.new(0.6, 0, 0.2, 0)
		frame.Position = UDim2.new(0.5, 0, 0.45, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundTransparency = 1
		frame.Parent = screenGui
		local uIListLayout = Instance.new("UIListLayout", frame)
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.Padding = UDim.new(0.05, 0)
		local uIScale = Instance.new("UIScale", frame)
		uIScale.Scale = 0
		local textLabel = Instance.new("TextLabel", frame)
		textLabel.Size = UDim2.new(1, 0, 0.4, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = flag2 and "💀 BOSS IS CHASING 💀" or "⚠️ BOSS INCOMING ⚠️"
		local textColor

		if flag2 then
			textColor = Color3.fromRGB(255, 80, 80)
		else
			textColor = Color3.fromRGB(255, 160, 0)
		end

		textLabel.TextColor3 = textColor
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.GothamBlack
		local uIStroke = Instance.new("UIStroke", textLabel)
		uIStroke.Thickness = 4
		uIStroke.Color = Color3.fromRGB(0, 0, 0)
		local textLabel2 = Instance.new("TextLabel", frame)
		textLabel2.Size = UDim2.new(1, 0, 0.45, 0)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = flag2 and "RUN !" or tostring(p2)
		local textColor2

		if flag2 then
			textColor2 = Color3.fromRGB(255, 255, 255)
		else
			textColor2 = v11[p2] or Color3.fromRGB(255, 30, 30)
		end

		textLabel2.TextColor3 = textColor2
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.GothamBlack
		local uIStroke2 = Instance.new("UIStroke", textLabel2)
		uIStroke2.Thickness = 4
		uIStroke2.Color = Color3.fromRGB(0, 0, 0)
		TweenService:Create(uIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
		TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 0.4, 0)
		}):Play()
		task.delay(flag2 and 2.2 or 0.9, function()
			if not screenGui.Parent then
				return
			end

			TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0.5, 0, 0.3, 0)
			}):Play()
			TweenService:Create(uIScale, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Scale = 0
			}):Play()
			local tweenInfo = TweenInfo.new(0.5)

			for _, descendant in ipairs(frame:GetDescendants()) do
				if descendant:IsA("TextLabel") then
					TweenService:Create(descendant, tweenInfo, {
						TextTransparency = 1
					}):Play()
				elseif descendant:IsA("UIStroke") then
					TweenService:Create(descendant, tweenInfo, {
						Transparency = 1
					}):Play()
				end
			end

			task.delay(0.65, function()
				if screenGui.Parent then
					screenGui:Destroy()
				end
			end)
		end)
	end

	local function startCountdown()
		v5 = "Countdown"
		v6 = true
		local character = localPlayer.Character
		local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			requestPath(spawnCFrame.Position, humanoidRootPart2.Position) -- equivalent call inferred; original call site unknown
		end

		task.spawn(function()
			for i = 5, 1, -1 do
				if v6 and v7 then
					showBossUI(i, false)
					task.wait(1)
				else
					local bossCountdownGui = localPlayer.PlayerGui:FindFirstChild("BossCountdownGui")

					if bossCountdownGui then
						bossCountdownGui:Destroy()
					end

					return
				end
			end

			if v6 and v7 then
				showBossUI(nil, true)
				goChase() -- equivalent call inferred; original call site unknown
			else
				local bossCountdownGui = localPlayer.PlayerGui:FindFirstChild("BossCountdownGui")

				if bossCountdownGui then
					bossCountdownGui:Destroy()
				end
			end
		end)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { clone }

	local function hasLineOfSight(position: Vector3, vector2: Vector3)
		local character = localPlayer.Character
		local v12 = raycastParams
		local filterDescendantsInstances

		if character then
			filterDescendantsInstances = { clone, character }
		else
			filterDescendantsInstances = { clone }
		end

		v12.FilterDescendantsInstances = filterDescendantsInstances
		local vector3 = Vector3.new(vector2.X - position.X, 0, vector2.Z - position.Z)
		return workspace:Raycast(position, vector3, raycastParams) == nil
	end

	local function moveToward(dt: number, position: Vector3, p2: number)
		local position2 = humanoidRootPart.Position
		local now2 = os.clock()

		if now2 - v10 > 0.3 then
			v10 = now2
			requestPath(position2, position) -- equivalent call inferred; original call site unknown
		end

		local position3 = nil

		if hasLineOfSight(position2, position) then
			position3 = position
		elseif v9 > 0 and v9 <= #v8 then
			position3 = v8[v9].Position
			local v12 = position2.X - position3.X
			local v13 = position2.Z - position3.Z

			if math.sqrt(v12 * v12 + v13 * v13) < 3 then
				v9 += 1

				if v9 <= #v8 then
					position3 = v8[v9].Position
				else
					position3 = nil
				end
			end
		end

		if not position3 then
			return
		end

		local v12 = position3.X - position2.X
		local v13 = position3.Z - position2.Z
		local v14 = math.sqrt(v12 * v12 + v13 * v13)

		if v14 > 0.5 then
			local now3 = os.clock()

			if now3 - v4 >= 0.5 then
				v4 = now3
				footstep:Play()
			end

			local v15 = math.min(p2 * math.min(dt, 0.1), v14) / v14
			local v16 = position2.X + v12 * v15
			local v17 = position2.Z + v13 * v15
			local vector2 = Vector3.new(v16, Y, v17)
			local v18 = v12 / v14
			local v19 = v13 / v14
			local vector3 = Vector3.new(v16 + v18, Y, v17 + v19)
			clone:PivotTo(CFrame.lookAt(vector2, vector3))
		end
	end

	local function checkKill()
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			return
		end

		local v12 = humanoidRootPart.Position.X - humanoidRootPart2.Position.X
		local v13 = humanoidRootPart.Position.Z - humanoidRootPart2.Position.Z

		if math.sqrt(v12 * v12 + v13 * v13) < 13 then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end
	end

	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if clone.Parent then
			local v12

			if tag then
				v12 = #CollectionService:GetTagged(tag) > 0
			else
				v12 = instance.Parent ~= nil
			end

			if v12 then
				local character = localPlayer.Character
				local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local v13

				if humanoidRootPart2 == nil or humanoid == nil then
					v13 = false
				else
					v13 = humanoid.Health > 0
				end

				local position = v13 and humanoidRootPart2.Position or nil
				local position2 = humanoidRootPart.Position
				local v14 = false

				if position then
					if tag then
						for _, part in CollectionService:GetTagged(tag) do
							if not (part:IsA("BasePart") and isInZone(part, position)) then
								continue
							end

							v14 = true
							break
						end
					else
						v14 = isInZone(instance, position)
					end
				end

				if not v13 and (v5 == "Chasing" or v5 == "Countdown") then
					v6 = false
					goReturn() -- equivalent call inferred; original call site unknown
				end

				if position2.Y < Y - 50 then
					local vector2 = Vector3.new(position2.X, Y, position2.Z)
					clone:PivotTo(CFrame.new(vector2))
				end

				if v5 == "Idle" then
					if v14 then
						startCountdown()
						return
					end
				elseif v5 == "Countdown" then
					if not v14 then
						v6 = false
						goIdle()
						return
					end
				elseif v5 == "Chasing" then
					local v15 = os.clock() - now > 2

					if v14 or not v15 then
						if position then
							moveToward(dt, position, 190)
							checkKill()
							return
						end
					else
						goReturn() -- equivalent call inferred; original call site unknown
						return
					end
				elseif v5 == "Returning" then
					if ((position2 - spawnCFrame.Position) * createVector(1, 0, 1)).Magnitude < 6 then
						goIdle()
						clone:PivotTo(spawnCFrame)
						return
					else
						moveToward(dt, spawnCFrame.Position, 250)
					end
				end

				return
			end
		end

		renderSteppedConnection:Disconnect()
		v[v3] = nil
		v7 = false
		clone:Destroy()
	end)
end

local LabyrinthNpcStages = require(ReplicatedStorage._FRAMEWORK.Libraries.LabyrinthNpcStages)

local function checkZoneReady(part, p)
	local model = ReplicatedStorage:FindFirstChild(p.templateName)
	local v3 = nil

	if p.spawnTag then
		for _, part2 in CollectionService:GetTagged(p.spawnTag) do
			if not (part2:IsA("BasePart") and part2:IsDescendantOf(workspace)) then
				continue
			end

			v3 = part2
			break
		end
	end

	if part:IsA("BasePart") and part:IsDescendantOf(workspace) and model and model:IsA("Model") and (p.spawnTag == nil or v3 ~= nil) then
		return true, model, v3
	end

	return false, nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onZone(p, p2)
	local v3, v4, v5 = checkZoneReady(p, p2)

	if not (v3 and v4) then
		return
	end

	local v7

	if p2.sharedZones then
		v7 = p2.zoneTag
	end

	task.spawn(startNPC, p, v4, v5, v7)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshStage(p)
	for _, v3 in CollectionService:GetTagged(p.zoneTag) do
		onZone(v3, p) -- equivalent call inferred; original call site unknown
	end
end

for _, labyrinthNpcStage in LabyrinthNpcStages do
	local v3 = labyrinthNpcStage
	CollectionService:GetInstanceAddedSignal(labyrinthNpcStage.zoneTag):Connect(function(p)
		onZone(p, v3) -- equivalent call inferred; original call site unknown
	end)

	if labyrinthNpcStage.spawnTag then
		local v4 = labyrinthNpcStage
		CollectionService:GetInstanceAddedSignal(labyrinthNpcStage.spawnTag):Connect(function()
			refreshStage(v4) -- equivalent call inferred; original call site unknown
		end)
	end

	local v4 = labyrinthNpcStage
	ReplicatedStorage.ChildAdded:Connect(function(child)
		if child.Name == v4.templateName then
			refreshStage(v4) -- equivalent call inferred; original call site unknown
		end
	end)

	for _, v5 in CollectionService:GetTagged(labyrinthNpcStage.zoneTag) do
		local v6, v7, v8 = checkZoneReady(v5, labyrinthNpcStage)

		if not (v6 and v7) then
			continue
		end

		local v9

		if labyrinthNpcStage.sharedZones then
			v9 = labyrinthNpcStage.zoneTag
		end

		task.spawn(startNPC, v5, v7, v8, v9)
	end
end