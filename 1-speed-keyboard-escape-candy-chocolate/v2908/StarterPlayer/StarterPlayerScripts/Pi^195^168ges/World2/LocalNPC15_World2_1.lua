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
	CHASE_SPEED = 220,
	PATHFIND_SPEED = 220,
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
	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Include
	raycastParams2.FilterDescendantsInstances = CollectionService:GetTagged("Boss15collide")

	local function refreshBossCollide()
		raycastParams2.FilterDescendantsInstances = CollectionService:GetTagged("Boss15collide")
	end

	CollectionService:GetInstanceAddedSignal("Boss15collide"):Connect(refreshBossCollide)
	CollectionService:GetInstanceRemovedSignal("Boss15collide"):Connect(refreshBossCollide)
	local Y = pivot.Y

	local function getGroundY(vector2: Vector3)
		local vector3 = Vector3.new(vector2.X, Y + 10, vector2.Z)
		local raycastResult = workspace:Raycast(vector3, createVector(0, -200, 0), raycastParams)
		local raycastResult2 = workspace:Raycast(vector3, createVector(0, -200, 0), raycastParams2)
		local v4 = raycastResult and raycastResult.Position.Y + 3 or nil
		local v5 = raycastResult2 and raycastResult2.Position.Y + 3 or nil
		local v6 = nil
		local v7

		if v4 and v5 then
			v7 = math.max(v4, v5)
		else
			v7 = v4 or v5 or v6
		end

		if v7 then
			Y = v7
			return Y
		end

		local vector4 = Vector3.new(vector2.X, Y + 50, vector2.Z)
		local raycastResult3 = workspace:Raycast(vector4, createVector(0, -200, 0), raycastParams)
		local raycastResult4 = workspace:Raycast(vector4, createVector(0, -200, 0), raycastParams2)
		local v8 = raycastResult3 and raycastResult3.Position.Y + 3 or nil
		local v9 = raycastResult4 and raycastResult4.Position.Y + 3 or nil

		if v8 and v9 then
			Y = math.max(v8, v9)
			return Y
		end

		if v8 then
			Y = v8
			return Y
		end

		if not v9 then
			return Y
		end

		Y = v9
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
	local v8 = 220
	local v9 = 220
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

	local raycastParams3 = RaycastParams.new()
	raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams3.FilterDescendantsInstances = { clone }

	local function hasLineOfSight(position: Vector3, vector3: Vector3)
		local character = localPlayer.Character
		local v15 = raycastParams3
		local filterDescendantsInstances

		if character then
			filterDescendantsInstances = { clone, character }
		else
			filterDescendantsInstances = { clone }
		end

		v15.FilterDescendantsInstances = filterDescendantsInstances
		local vector4 = Vector3.new(vector3.X - position.X, 0, vector3.Z - position.Z)
		return workspace:Raycast(position, vector4, raycastParams3) == nil
	end

	local v15 = 0

	local function moveWaypoints(dt: number)
		local now2 = os.clock()

		if now2 < v15 then
			track:Stop(0.1)
			track2:Play()
		else
			if v15 > 0 then
				v15 = 0
				track2:Stop()
				track:Play()
			end

			while v7 <= #v2 do
				local v16 = v2[v7]
				local position = humanoidRootPart.Position
				local v17 = v16.Position.X - position.X
				local v18 = v16.Position.Y - position.Y
				local v19 = v16.Position.Z - position.Z

				if math.sqrt(v17 * v17 + v18 * v18 + v19 * v19) >= 5 then
					break
				end

				local pause = v16:GetAttribute("Pause")

				if pause and typeof(pause) == "number" and pause > 0 then
					v15 = os.clock() + pause
					v7 += 1
					return
				else
					v7 += 1
				end
			end

			if v7 > #v2 then
				goChasingPathfind() -- equivalent call inferred; original call site unknown
			else
				local position = v2[v7].Position
				local position2 = humanoidRootPart.Position
				local v16 = position.X - position2.X
				local v17 = position.Z - position2.Z
				local v18 = math.sqrt(v16 * v16 + v17 * v17)

				if v18 > 0.1 then
					vector2 = Vector3.new(v16 / v18, 0, v17 / v18)
				end

				if now2 - v3 >= 0.5 then
					v3 = now2
					footstep:Play()
				end

				local v19 = math.min(dt, 0.1)
				local v20 = math.min(v8 * v19, v18) / v18
				local v21 = position2.X + v16 * v20
				local v22 = position2.Z + v17 * v20
				local v23 = position2.Y + (position.Y - position2.Y) * v20
				local vector3 = Vector3.new(v21, v23, v22)
				local v24 = v16 / v18
				local v25 = v17 / v18
				local vector4 = Vector3.new(v21 + v24, v23, v22 + v25)
				clone:PivotTo(CFrame.lookAt(vector3, vector4))
			end
		end
	end

	local function moveDirectToPlayer(dt: number, vector3: Vector3)
		local position = humanoidRootPart.Position
		local v16 = vector3 - position
		local magnitude = v16.Magnitude

		if magnitude < 0.5 then
			return
		end

		local now2 = os.clock()

		if now2 - v3 >= 0.5 then
			v3 = now2
			footstep:Play()
		end

		local v17 = math.min(dt, 0.1)
		local v18 = math.min(v8 * v17, magnitude)
		local v19 = v16 / magnitude
		local v20 = position + v19 * v18
		vector2 = Vector3.new(v19.X, 0, v19.Z).Unit
		local vector4 = Vector3.new(v20.X + v19.X, v20.Y, v20.Z + v19.Z)
		clone:PivotTo(CFrame.lookAt(v20, vector4))
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
			local v16 = position.X - position2.X
			local v17 = position.Z - position2.Z

			if math.sqrt(v16 * v16 + v17 * v17) < 5 then
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

		local v16 = position2.X - position.X
		local v17 = position2.Z - position.Z
		local v18 = math.sqrt(v16 * v16 + v17 * v17)

		if v18 > 0.5 then
			local now3 = os.clock()

			if now3 - v3 >= 0.5 then
				v3 = now3
				footstep:Play()
			end

			local v19 = math.min(dt, 0.1)
			local v20 = math.min(v9 * v19, v18) / v18
			local v21 = position.X + v16 * v20
			local v22 = position.Z + v17 * v20
			local groundY = getGroundY(Vector3.new(v21, position.Y, v22))
			local vector4 = Vector3.new(v21, groundY, v22)
			local v23 = v16 / v18
			local v24 = v17 / v18
			local vector5 = Vector3.new(v21 + v23, groundY, v22 + v24)
			clone:PivotTo(CFrame.lookAt(vector4, vector5))
		end
	end

	local v16 = nil
	local v17 = nil
	local v18 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateDebugVisuals()
		if v16 then
			v16:Destroy()
			v16 = nil
		end

		if v17 then
			v17:Destroy()
			v17 = nil
		end

		if v18 then
			v18:Destroy()
			v18 = nil
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

		local v19 = humanoidRootPart.Position.X - humanoidRootPart2.Position.X
		local v20 = humanoidRootPart.Position.Z - humanoidRootPart2.Position.Z

		if math.sqrt(v19 * v19 + v20 * v20) < 13 then
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
		local v19 = position2.X - position.X
		local v20 = position2.Z - position.Z
		local v21 = vector2.X * v19 + vector2.Z * v20
		local v22 = math.sqrt(v19 * v19 + v20 * v20)

		if v21 < -2 and v22 < 120 and math.abs(vector2.X * v20 - vector2.Z * v19) < 100 then
			humanoid.Health = 0
		end
	end

	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if clone.Parent then
			local character = localPlayer.Character
			local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v19

			if humanoidRootPart2 == nil or humanoid == nil then
				v19 = false
			else
				v19 = humanoid.Health > 0
			end

			local position = v19 and humanoidRootPart2.Position or nil
			local position2 = humanoidRootPart.Position

			if position then
				v10 = position
			end

			local v20

			if (position or v10) == nil then
				v20 = false
			else
				v20 = isInAnyZonePart(position or v10) or false
			end

			local v21

			if (position or v10) == nil then
				v21 = false
			else
				v21 = isInSpeedZone(position or v10) or false
			end

			v8 = v21 and 280 or 220
			v9 = v21 and 280 or 220

			if not v19 and (v4 == "ChasingWaypoints" or v4 == "ChasingPathfind" or v4 == "Countdown") then
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
				if v20 then
					startCountdown() -- equivalent call inferred; original call site unknown
				end
			elseif v4 == "Countdown" then
				if not v20 then
					v5 = false
					goIdle()
				end
			elseif v4 == "ChasingWaypoints" then
				local v22 = os.clock() - now > 2

				if v20 or not v22 then
					if v21 then
						flag2 = true
						local v23 = position or v10

						if v23 then
							moveDirectToPlayer(dt, v23)
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
				local v22 = os.clock() - now > 2

				if v20 or not v22 then
					local v23 = position or v10

					if v23 then
						if v21 then
							flag2 = true
							moveDirectToPlayer(dt, v23)
						else
							flag2 = false
							movePathfind(dt, v23)
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