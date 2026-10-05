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
	CHASE_SPEED = 230,
	PATHFIND_SPEED = 230,
	BOOST_SPEED = 280,
	RETURN_SPEED = 500,
	COUNTDOWN = 3,
	KILL_RADIUS = 13,
	KILL_WALL_HALF_WIDTH = 100,
	KILL_WALL_BEHIND = 2,
	KILL_WALL_MAX_DIST = 120,
	WAYPOINT_REACH = 5,
	PATH_RECOMPUTE = 0.3,
	STOP_DISTANCE = 6,
	ID_WALK = "rbxassetid://118196541350091",
	ID_IDLE = "rbxassetid://118196541350091"
}
local nPC15_World2 = ReplicatedStorage:WaitForChild("NPC15_World2")
local pivot = nPC15_World2:GetPivot()
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://118196541350091"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://118196541350091"
task.spawn(function()
	ContentProvider:PreloadAsync({ animation, animation2, nPC15_World2 })
end)

local function loadWaypoints()
	local parts = {}

	for _, part in ipairs(CollectionService:GetTagged("NPC15_World2_Waypoint")) do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b)
		return (a:GetAttribute("Order") or 0) < (b:GetAttribute("Order") or 0)
	end)
	return parts
end

local v = {
	AgentRadius = 1,
	AgentHeight = 5,
	AgentCanJump = false,
	AgentCanClimb = false,
	WaypointSpacing = 4
}

local function isInAnyZonePart(vector2: Vector3)
	for _, part in ipairs(CollectionService:GetTagged("NPC15_World2_Zone")) do
		if not part:IsA("BasePart") then
			continue
		end

		local pointToObjectSpace = part.CFrame:PointToObjectSpace(vector2)

		if math.abs(pointToObjectSpace.X) <= part.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= math.max(
			part.Size.Y / 2,
			30
		) and math.abs(pointToObjectSpace.Z) <= part.Size.Z / 2 then
			return true
		end
	end

	return false
end

local function isInSpeedZone(vector2: Vector3)
	for _, part in ipairs(CollectionService:GetTagged("NPC15_World2_SpeedZone")) do
		if not part:IsA("BasePart") then
			continue
		end

		local pointToObjectSpace = part.CFrame:PointToObjectSpace(vector2)

		if math.abs(pointToObjectSpace.X) <= part.Size.X / 2 and math.abs(pointToObjectSpace.Y) <= math.max(
			part.Size.Y / 2,
			30
		) and math.abs(pointToObjectSpace.Z) <= part.Size.Z / 2 then
			return true
		end
	end

	return false
end

local flag = false

local function startNPC()
	if flag then
		return
	end

	flag = true
	local v2 = loadWaypoints()

	if #v2 == 0 then
		local count = 0

		while #v2 == 0 and count < 30 do
			task.wait(0.5)
			v2 = loadWaypoints()
			count += 1
		end

		if #v2 == 0 then
			warn("[NPC15_W2] Aucun waypoint trouvé après 15s d'attente !")
		end
	end

	CollectionService:GetInstanceAddedSignal("NPC15_World2_Waypoint"):Connect(function()
		v2 = loadWaypoints()
	end)
	local clone = nPC15_World2:Clone()
	clone:PivotTo(pivot)
	clone.Parent = workspace
	local humanoidRootPart = clone:WaitForChild("HumanoidRootPart")
	local animator = clone:WaitForChild("Humanoid"):WaitForChild("Animator")
	local chaseMusic = humanoidRootPart:WaitForChild("ChaseMusic")
	local footstep = humanoidRootPart:WaitForChild("Footstep")
	local v3 = 0
	humanoidRootPart.Anchored = true

	if #v2 > 0 then
		local _ = v2[#v2].Position.Y
	else
		local _ = pivot.Y
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { clone }
	local Y = pivot.Y

	local function getGroundY(vector2: Vector3)
		local vector3 = Vector3.new(vector2.X, Y + 10, vector2.Z)
		local raycastResult = workspace:Raycast(vector3, createVector(0, -200, 0), raycastParams)

		if raycastResult then
			Y = raycastResult.Position.Y + 3
			return Y
		end

		local vector4 = Vector3.new(vector2.X, Y + 50, vector2.Z)
		local raycastResult2 = workspace:Raycast(vector4, createVector(0, -200, 0), raycastParams)

		if not raycastResult2 then
			return Y
		end

		Y = raycastResult2.Position.Y + 3
		return Y
	end

	task.spawn(function()
		local path = PathfindingService:CreatePath(v)
		pcall(function()
			path:ComputeAsync(pivot.Position, pivot.Position + createVector(10, 0, 10))
		end)
	end)
	local track = animator:LoadAnimation(animation)
	local track2 = animator:LoadAnimation(animation2)
	track2:Play()
	local v4 = "Idle"
	local v5 = false
	local v6 = true
	local now = 0
	local v7 = 1
	local vector2 = createVector(0, 0, 1)
	local v8 = 230
	local v9 = 230
	local v10 = nil
	local flag2 = false

	local function findClosestWaypointIndex()
		local position = humanoidRootPart.Position
		local v11 = 1e999
		local v12 = 1

		for i, v13 in ipairs(v2) do
			local v14 = position.X - v13.Position.X
			local v15 = position.Z - v13.Position.Z
			local v16 = v14 * v14 + v15 * v15

			if not (v16 < v11) then
				continue
			end

			v12 = i
			v11 = v16
		end

		return v12
	end

	local v11 = {}
	local v12 = 0
	local flag3 = false
	local v13 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function requestPath(position: Vector3, vector3: Vector3)
		if flag3 then
			return
		end

		flag3 = true
		task.spawn(function()
			local path = PathfindingService:CreatePath(v)

			if pcall(function()
				path:ComputeAsync(position, vector3)
			end) and path.Status == Enum.PathStatus.Success then
				local waypoints = path:GetWaypoints()

				if #waypoints >= 2 then
					local position2 = humanoidRootPart.Position
					local v14 = 1e999
					local v15 = 1

					for i = 1, #waypoints do
						local v16 = position2.X - waypoints[i].Position.X
						local v17 = position2.Z - waypoints[i].Position.Z
						local v18 = v16 * v16 + v17 * v17

						if not (v18 < v14) then
							continue
						end

						v15 = i
						v14 = v18
					end

					v11 = waypoints
					v12 = math.min(v15 + 1, #waypoints)
				end
			end

			flag3 = false
		end)
	end

	local function goIdle()
		v4 = "Idle"
		v5 = false
		track:Stop(0.1)
		track2:Play()

		if chaseMusic.IsPlaying then
			chaseMusic:Stop()
		end

		footstep:Stop()
		v11 = {}
		v12 = 0
		v7 = 1
		Y = pivot.Y
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function goChasingWaypoints()
		v4 = "ChasingWaypoints"
		now = os.clock()
		v7 = 1
		track:Play()
		track2:Stop()

		if not chaseMusic.IsPlaying then
			chaseMusic:Play()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function goChasingPathfind()
		v4 = "ChasingPathfind"
		v11 = {}
		v12 = 0
		v13 = 0
		Y = humanoidRootPart.Position.Y
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function goReturn()
		v4 = "Returning"
		v11 = {}
		v12 = 0
		v13 = 0
		v7 = 1
	end

	local v14 = {
		[3] = Color3.fromRGB(255, 160, 0),
		[2] = Color3.fromRGB(255, 80, 0),
		[1] = Color3.fromRGB(255, 20, 0)
	}

	local function showBossUI(p: number?, flag4: boolean?)
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
		textLabel.Text = flag4 and "💀 BOSS IS CHASING 💀" or "⚠️ BOSS INCOMING ⚠️"
		local textColor

		if flag4 then
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
		textLabel2.Text = flag4 and "RUN !" or tostring(p)
		local textColor2

		if flag4 then
			textColor2 = Color3.fromRGB(255, 255, 255)
		else
			textColor2 = v14[p] or Color3.fromRGB(255, 30, 30)
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
		task.delay(flag4 and 2.2 or 0.9, function()
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

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startCountdown()
		v4 = "Countdown"
		v5 = true
		task.spawn(function()
			for i = 3, 1, -1 do
				if v5 and v6 then
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

			if v5 and v6 then
				showBossUI(nil, true)
				goChasingWaypoints() -- equivalent call inferred; original call site unknown
			else
				local bossCountdownGui = localPlayer.PlayerGui:FindFirstChild("BossCountdownGui")

				if bossCountdownGui then
					bossCountdownGui:Destroy()
				end
			end
		end)
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams2.FilterDescendantsInstances = { clone }

	local function hasLineOfSight(position: Vector3, vector3: Vector3)
		local character = localPlayer.Character
		local v15 = raycastParams2
		local filterDescendantsInstances

		if character then
			filterDescendantsInstances = { clone, character }
		else
			filterDescendantsInstances = { clone }
		end

		v15.FilterDescendantsInstances = filterDescendantsInstances
		local vector4 = Vector3.new(vector3.X - position.X, 0, vector3.Z - position.Z)
		return workspace:Raycast(position, vector4, raycastParams2) == nil
	end

	local function moveWaypoints(dt: number)
		while v7 <= #v2 do
			local v15 = v2[v7]
			local position = humanoidRootPart.Position
			local v16 = v15.Position.X - position.X
			local v17 = v15.Position.Z - position.Z

			if math.sqrt(v16 * v16 + v17 * v17) >= 5 then
				break
			else
				v7 += 1
			end
		end

		if v7 > #v2 then
			goChasingPathfind() -- equivalent call inferred; original call site unknown
		else
			local position = v2[v7].Position
			local position2 = humanoidRootPart.Position
			local v15 = position.X - position2.X
			local v16 = position.Z - position2.Z
			local v17 = math.sqrt(v15 * v15 + v16 * v16)

			if v17 > 0.1 then
				vector2 = Vector3.new(v15 / v17, 0, v16 / v17)
			end

			local now2 = os.clock()

			if now2 - v3 >= 0.5 then
				v3 = now2
				footstep:Play()
			end

			local v18 = math.min(dt, 0.1)
			local v19 = math.min(v8 * v18, v17) / v17
			local v20 = position2.X + v15 * v19
			local v21 = position2.Z + v16 * v19
			local v22 = position2.Y + (position.Y - position2.Y) * v19
			local vector3 = Vector3.new(v20, v22, v21)
			local v23 = v15 / v17
			local v24 = v16 / v17
			local vector4 = Vector3.new(v20 + v23, v22, v21 + v24)
			clone:PivotTo(CFrame.lookAt(vector3, vector4))
		end
	end

	local function moveDirectToPlayer(dt: number, vector3: Vector3)
		local position = humanoidRootPart.Position
		local v15 = vector3 - position
		local magnitude = v15.Magnitude

		if magnitude < 0.5 then
			return
		end

		local now2 = os.clock()

		if now2 - v3 >= 0.5 then
			v3 = now2
			footstep:Play()
		end

		local v16 = math.min(dt, 0.1)
		local v17 = math.min(v8 * v16, magnitude)
		local v18 = v15 / magnitude
		local v19 = position + v18 * v17
		vector2 = Vector3.new(v18.X, 0, v18.Z).Unit
		local vector4 = Vector3.new(v19.X + v18.X, v19.Y, v19.Z + v18.Z)
		clone:PivotTo(CFrame.lookAt(v19, vector4))
	end

	local function movePathfind(dt: number, vector3: Vector3)
		local position = humanoidRootPart.Position
		local now2 = os.clock()

		if now2 - v13 > 0.3 then
			v13 = now2
			requestPath(position, vector3) -- equivalent call inferred; original call site unknown
		end

		local position2 = nil

		if hasLineOfSight(position, vector3) then
			position2 = vector3
		elseif v12 > 0 and v12 <= #v11 then
			position2 = v11[v12].Position
			local v15 = position.X - position2.X
			local v16 = position.Z - position2.Z

			if math.sqrt(v15 * v15 + v16 * v16) < 5 then
				v12 += 1

				if v12 <= #v11 then
					position2 = v11[v12].Position
				else
					position2 = nil
				end
			end
		end

		if not position2 then
			return
		end

		local v15 = position2.X - position.X
		local v16 = position2.Z - position.Z
		local v17 = math.sqrt(v15 * v15 + v16 * v16)

		if v17 > 0.5 then
			local now3 = os.clock()

			if now3 - v3 >= 0.5 then
				v3 = now3
				footstep:Play()
			end

			local v18 = math.min(dt, 0.1)
			local v19 = math.min(v9 * v18, v17) / v17
			local v20 = position.X + v15 * v19
			local v21 = position.Z + v16 * v19
			local groundY = getGroundY(Vector3.new(v20, position.Y, v21))
			local vector4 = Vector3.new(v20, groundY, v21)
			local v22 = v15 / v17
			local v23 = v16 / v17
			local vector5 = Vector3.new(v20 + v22, groundY, v21 + v23)
			clone:PivotTo(CFrame.lookAt(vector4, vector5))
		end
	end

	local v15 = nil
	local v16 = nil
	local v17 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateDebugVisuals()
		if v15 then
			v15:Destroy()
			v15 = nil
		end

		if v16 then
			v16:Destroy()
			v16 = nil
		end

		if v17 then
			v17:Destroy()
			v17 = nil
		end
	end

	local function checkKillRadius()
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			return
		end

		local v18 = humanoidRootPart.Position.X - humanoidRootPart2.Position.X
		local v19 = humanoidRootPart.Position.Z - humanoidRootPart2.Position.Z

		if math.sqrt(v18 * v18 + v19 * v19) < 13 then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end
	end

	local function checkKillWall()
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local position = humanoidRootPart.Position
		local position2 = humanoidRootPart2.Position
		local v18 = position2.X - position.X
		local v19 = position2.Z - position.Z
		local v20 = vector2.X * v18 + vector2.Z * v19
		local v21 = math.sqrt(v18 * v18 + v19 * v19)

		if v20 < -2 and v21 < 120 and math.abs(vector2.X * v19 - vector2.Z * v18) < 100 then
			humanoid.Health = 0
		end
	end

	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if clone.Parent then
			local character = localPlayer.Character
			local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v18

			if humanoidRootPart2 == nil or humanoid == nil then
				v18 = false
			else
				v18 = humanoid.Health > 0
			end

			local position = v18 and humanoidRootPart2.Position or nil
			local position2 = humanoidRootPart.Position

			if position then
				v10 = position
			end

			local v19

			if (position or v10) == nil then
				v19 = false
			else
				v19 = isInAnyZonePart(position or v10) or false
			end

			local v20

			if (position or v10) == nil then
				v20 = false
			else
				v20 = isInSpeedZone(position or v10) or false
			end

			v8 = v20 and 280 or 230
			v9 = v20 and 280 or 230

			if not v18 and (v4 == "ChasingWaypoints" or v4 == "ChasingPathfind" or v4 == "Countdown") then
				v5 = false
				goReturn() -- equivalent call inferred; original call site unknown
			end

			if v4 ~= "ChasingWaypoints" then
				local Y2

				if v4 == "Idle" or v4 == "Returning" then
					Y2 = pivot.Y
				else
					Y2 = Y
				end

				if position2.Y < Y2 - 50 then
					local vector3 = Vector3.new(position2.X, Y2, position2.Z)
					clone:PivotTo(CFrame.new(vector3))
				end
			end

			if v4 == "Idle" then
				if v19 then
					startCountdown() -- equivalent call inferred; original call site unknown
				end
			elseif v4 == "Countdown" then
				if not v19 then
					v5 = false
					goIdle()
				end
			elseif v4 == "ChasingWaypoints" then
				local v21 = os.clock() - now > 2

				if v19 or not v21 then
					if v20 then
						flag2 = true
						local v22 = position or v10

						if v22 then
							moveDirectToPlayer(dt, v22)
						end

						checkKillWall()
						checkKillRadius()
					else
						if flag2 then
							flag2 = false
							v7 = findClosestWaypointIndex()
						end

						moveWaypoints(dt)
						checkKillWall()
						checkKillRadius()
					end
				else
					goReturn() -- equivalent call inferred; original call site unknown
				end
			elseif v4 == "ChasingPathfind" then
				local v21 = os.clock() - now > 2

				if v19 or not v21 then
					local v22 = position or v10

					if v22 then
						if v20 then
							flag2 = true
							moveDirectToPlayer(dt, v22)
						else
							flag2 = false
							movePathfind(dt, v22)
						end

						checkKillRadius()
					end
				else
					goReturn() -- equivalent call inferred; original call site unknown
				end
			elseif v4 == "Returning" then
				clone:PivotTo(pivot)
				goIdle()
			end

			updateDebugVisuals() -- equivalent call inferred; original call site unknown
		else
			renderSteppedConnection:Disconnect()
			v6 = false
			clone:Destroy()
		end
	end)
end

local function tryStart()
	if flag then
		return
	end

	if #CollectionService:GetTagged("NPC15_World2_Zone") > 0 then
		task.spawn(startNPC)
	end
end

CollectionService:GetInstanceAddedSignal("NPC15_World2_Zone"):Connect(tryStart)

if not flag and #CollectionService:GetTagged("NPC15_World2_Zone") > 0 then
	task.spawn(startNPC)
end