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
	CHASE_SPEED = 165,
	RETURN_SPEED = 250,
	COUNTDOWN = 5,
	KILL_RADIUS = 13,
	WAYPOINT_REACH = 3,
	PATH_RECOMPUTE = 0.3,
	STOP_DISTANCE = 6,
	ID_WALK = "rbxassetid://90717240038055",
	ID_IDLE = "rbxassetid://78010228363636"
}
local NPC9 = ReplicatedStorage:WaitForChild("NPC9")
local pivot = NPC9:GetPivot()
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://90717240038055"
local animation2 = Instance.new("Animation")
animation2.AnimationId = "rbxassetid://78010228363636"
task.spawn(function()
	ContentProvider:PreloadAsync({ animation, animation2, NPC9 })
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

local function startNPC(p)
	if v[p] then
		return
	end

	v[p] = true
	local clone = NPC9:Clone()
	clone:PivotTo(pivot)
	clone.Parent = workspace
	local humanoidRootPart = clone:WaitForChild("HumanoidRootPart")
	local animator = clone:WaitForChild("Humanoid"):WaitForChild("Animator")
	local chaseMusic = humanoidRootPart:WaitForChild("ChaseMusic")
	local footstep = humanoidRootPart:WaitForChild("Footstep")
	local v3 = 0
	humanoidRootPart.Anchored = true
	local Y = pivot.Y
	task.spawn(function()
		local path = PathfindingService:CreatePath(v2)
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
	local v7 = {}
	local v8 = 0
	local flag = false
	local v9 = 0

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
					local v10 = 1e999
					local v11 = 1

					for i = 1, #waypoints do
						local v12 = position2.X - waypoints[i].Position.X
						local v13 = position2.Z - waypoints[i].Position.Z
						local v14 = v12 * v12 + v13 * v13

						if not (v14 < v10) then
							continue
						end

						v11 = i
						v10 = v14
					end

					v7 = waypoints
					v8 = math.min(v11 + 1, #waypoints)
				end
			end

			flag = false
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
		v7 = {}
		v8 = 0
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function goChase()
		v4 = "Chasing"
		now = os.clock()
		track:Play()
		track2:Stop()

		if not chaseMusic.IsPlaying then
			chaseMusic:Play()
		end

		if #v7 == 0 then
			v9 = 0
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function goReturn()
		v4 = "Returning"
		v7 = {}
		v8 = 0
		v9 = 0
	end

	local v10 = {
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
			textColor2 = v10[p2] or Color3.fromRGB(255, 30, 30)
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
		v4 = "Countdown"
		v5 = true
		local character = localPlayer.Character
		local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			requestPath(pivot.Position, humanoidRootPart2.Position) -- equivalent call inferred; original call site unknown
		end

		task.spawn(function()
			for i = 5, 1, -1 do
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
		local v11 = raycastParams
		local filterDescendantsInstances

		if character then
			filterDescendantsInstances = { clone, character }
		else
			filterDescendantsInstances = { clone }
		end

		v11.FilterDescendantsInstances = filterDescendantsInstances
		local vector3 = Vector3.new(vector2.X - position.X, 0, vector2.Z - position.Z)
		return workspace:Raycast(position, vector3, raycastParams) == nil
	end

	local function moveToward(dt: number, position: Vector3, p2: number)
		local position2 = humanoidRootPart.Position
		local now2 = os.clock()

		if now2 - v9 > 0.3 then
			v9 = now2
			requestPath(position2, position) -- equivalent call inferred; original call site unknown
		end

		local position3 = nil

		if hasLineOfSight(position2, position) then
			position3 = position
		elseif v8 > 0 and v8 <= #v7 then
			position3 = v7[v8].Position
			local v11 = position2.X - position3.X
			local v12 = position2.Z - position3.Z

			if math.sqrt(v11 * v11 + v12 * v12) < 3 then
				v8 += 1

				if v8 <= #v7 then
					position3 = v7[v8].Position
				else
					position3 = nil
				end
			end
		end

		if not position3 then
			return
		end

		local v11 = position3.X - position2.X
		local v12 = position3.Z - position2.Z
		local v13 = math.sqrt(v11 * v11 + v12 * v12)

		if v13 > 0.5 then
			local now3 = os.clock()

			if now3 - v3 >= 0.5 then
				v3 = now3
				footstep:Play()
			end

			local v14 = math.min(p2 * math.min(dt, 0.1), v13) / v13
			local v15 = position2.X + v11 * v14
			local v16 = position2.Z + v12 * v14
			local vector2 = Vector3.new(v15, Y, v16)
			local v17 = v11 / v13
			local v18 = v12 / v13
			local vector3 = Vector3.new(v15 + v17, Y, v16 + v18)
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

		local v11 = humanoidRootPart.Position.X - humanoidRootPart2.Position.X
		local v12 = humanoidRootPart.Position.Z - humanoidRootPart2.Position.Z

		if math.sqrt(v11 * v11 + v12 * v12) < 13 then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end
	end

	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		if clone.Parent and p.Parent then
			local character = localPlayer.Character
			local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local v11

			if humanoidRootPart2 == nil or humanoid == nil then
				v11 = false
			else
				v11 = humanoid.Health > 0
			end

			local position = v11 and humanoidRootPart2.Position or nil
			local position2 = humanoidRootPart.Position
			local v12

			if position == nil then
				v12 = false
			else
				v12 = isInZone(p, position) or false
			end

			if not v11 and (v4 == "Chasing" or v4 == "Countdown") then
				v5 = false
				goReturn() -- equivalent call inferred; original call site unknown
			end

			if position2.Y < Y - 50 then
				local vector2 = Vector3.new(position2.X, Y, position2.Z)
				clone:PivotTo(CFrame.new(vector2))
			end

			if v4 == "Idle" then
				if v12 then
					startCountdown()
				end
			elseif v4 == "Countdown" then
				if not v12 then
					v5 = false
					goIdle()
				end
			elseif v4 == "Chasing" then
				local v13 = os.clock() - now > 0.2

				if v12 or not v13 then
					if position then
						moveToward(dt, position, 165)
						checkKill()
					end
				else
					goReturn() -- equivalent call inferred; original call site unknown
				end
			elseif v4 == "Returning" then
				if ((position2 - pivot.Position) * createVector(1, 0, 1)).Magnitude < 6 then
					goIdle()
					clone:PivotTo(pivot)
				else
					moveToward(dt, pivot.Position, 250)
				end
			end
		else
			renderSteppedConnection:Disconnect()
			v[p] = nil
			v6 = false
			clone:Destroy()
		end
	end)
end

local function onZone(p)
	startNPC(p)
end

CollectionService:GetInstanceAddedSignal("NPC9_Zone"):Connect(onZone)

for _, v3 in ipairs(CollectionService:GetTagged("NPC9_Zone")) do
	task.spawn(onZone, v3)
end