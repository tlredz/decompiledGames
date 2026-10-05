local createVector = vector.create
local AINew = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local v = {}
local v2 = {}
local forbidden = ReplicatedStorage:WaitForChild("Forbidden")
local parent3 = script:FindFirstChild("signals")

if not (parent3 and parent3:IsA("Folder")) then
	if parent3 then
		parent3:Destroy()
	end

	parent3 = Instance.new("Folder")
	parent3.Name = "signals"
	parent3.Parent = script
end

local v4 = parent3:FindFirstChild("StopAI")

if not (v4 and v4:IsA("BindableEvent")) then
	if v4 then
		v4:Destroy()
	end

	v4 = Instance.new("BindableEvent")
	v4.Name = "StopAI"
	v4.Parent = parent3
end

local Standard = require(forbidden:WaitForChild("Standard"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Config = require(forbidden:WaitForChild("Config"))
local v5 = nil
pcall(function()
	local PositionalOptimization = require(ReplicatedStorage2.Modules.Core.PositionalOptimization)
	v5 = PositionalOptimization
end)
local v6 = nil
pcall(function()
	local ObstacleAvoidance = require(ReplicatedStorage2.Modules.ObstacleAvoidance)
	v6 = ObstacleAvoidance
end)
local v7 = nil
pcall(function()
	local FlockingBehavior = require(ReplicatedStorage2.Modules.Gameplay.FlockingBehavior)
	v7 = FlockingBehavior
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function isDebugEnabled()
	return workspace:GetAttribute("DebugModeEnabled") == true
end

local function debugLog(p, p2, ...)
	if workspace:GetAttribute("DebugModeEnabled") ~= true then
		return
	end

	local v8 = p and Config.GetConfig(p)

	if v8 then
		if not v8.DebugEnabled or (v8.DebugVerbosity or 3) < p2 or not v8.DebugOutputToConsole then
			return
		end
	end

	local v9 = (p and "[AINew:" .. p.Name .. "]" or "[AINew]") .. " "

	for _, v10 in ipairs({ ... }) do
		v9 ..= tostring(v10)
	end

	if p2 == 1 then
		warn(v9)
	else
		print(v9)
	end
end

local function debugError(p, ...)
	debugLog(p, 1, ...)
end

local function debugWarn(p, ...)
	debugLog(p, 2, ...)
end

local function debugInfo(p, ...)
	debugLog(p, 3, ...)
end

local function debugVerbose(p, ...)
	debugLog(p, 4, ...)
end

local function debugTrace(p, ...)
	debugLog(p, 5, ...)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFlockingEnabled()
	local enableFlocking = workspace:FindFirstChild("Info") and workspace.Info:FindFirstChild("EnableFlocking")

	if enableFlocking then
		return enableFlocking.Value
	end

	return false
end

local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}
local v14 = {}
local v15 = {}
local v16 = {}
local v17 = {}
local v18 = {}
local v19 = {}
local v20 = {}
local v21 = {}
local v22 = {}
local v23 = {}
local v24 = {}
local v25 = {}
local v26 = {}
local v27 = {}
local v28 = {}
local v29 = {}
local v30 = {}
local v31 = {}
local v32 = {}
local count = 0
local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	count += 1

	if count % 60 == 0 then
		local Players = game:GetService("Players")

		for k, _ in pairs(v8) do
			if Players:GetPlayerByUserId(k) then
				continue
			end

			v8[k] = nil
			v9[k] = nil
			v10[k] = nil
			v11[k] = nil
			v12[k] = nil
		end

		for k, _ in pairs(v13) do
			if k and k.Parent and k:IsDescendantOf(game) then
				continue
			end

			v13[k] = nil
			v14[k] = nil
			v15[k] = nil
			v16[k] = nil
			v17[k] = nil
			v18[k] = nil
			v20[k] = nil
			v21[k] = nil
			v27[k] = nil
			v28[k] = nil
			v29[k] = nil
			v30[k] = nil
			v31[k] = nil
			v22[k] = nil
			v23[k] = nil
			v24[k] = nil
			v25[k] = nil
			v32[k] = nil
			v[k] = nil
			v19[k] = nil
		end

		for k, _ in pairs(v2) do
			if not (k and k.Parent and k:IsDescendantOf(game)) then
				v2[k] = nil
			end
		end
	end

	local now = os.clock()

	for k, v33 in pairs(v29) do
		if not (v33 < 1 and (v31[k] or 0) <= now) then
			continue
		end

		local turnSpeedPenaltyRecovery = Config.GetConfig(k).TurnSpeedPenaltyRecovery or 3
		v29[k] = math.min(1, v33 + turnSpeedPenaltyRecovery * 0.016666666666666666)
	end

	for k, _ in pairs(v2) do
		if not (k and k.Parent) then
			continue
		end

		local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart or humanoidRootPart.Anchored then
			continue
		end

		local v33 = humanoidRootPart
		local success, result = pcall(function()
			return v33:GetNetworkOwnershipAuto()
		end)

		if not (success and result) then
			continue
		end

		local v34 = humanoidRootPart
		pcall(function()
			v34:SetNetworkOwner(nil)
		end)
	end
end)

function AINew.Stuck(object, part)
	if object and part then
		pcall(function()
			if not part:IsA("BasePart") then
				return
			end

			local cFrame = part.CFrame
			object:Move(((part.CFrame * CFrame.new(0, 0, 2)).Position - cFrame.Position).Unit)
		end)
	end
end

local count2 = 0

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
	elseif v[instance] == nil then
		v19[instance] = nil

		if instance.Parent then
			v[instance] = false
		end
	else
		if instance:FindFirstChild("Waypoints") then
			instance:FindFirstChild("Waypoints"):Destroy()
		end

		local v33 = v30[instance]
		local humanoid = v33 and v33 < 1 and instance:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.WalkSpeed /= v33
		end

		v30[instance] = nil
		v29[instance] = nil
		v27[instance] = nil
		v28[instance] = nil
		v31[instance] = nil
		v22[instance] = nil
		v23[instance] = nil
		v25[instance] = nil
		reset(instance) -- equivalent call inferred; original call site unknown
		v[instance] = false
		v32[instance] = nil
		v17[instance] = nil
		v18[instance] = nil
		v19[instance] = nil
	end
end

function AINew.Stop(p)
	v4:Fire(p)
	return nil
end

v4.Event:Connect(onStoppage)

function AINew.SoftStop(instance)
	if instance == nil then
		return
	end

	if v[instance] ~= nil then
		if instance:FindFirstChild("Waypoints") then
			instance:FindFirstChild("Waypoints"):Destroy()
		end

		local v33 = v30[instance]
		local humanoid = v33 and v33 < 1 and instance:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.WalkSpeed /= v33
		end

		v30[instance] = nil
		v29[instance] = nil
		v27[instance] = nil
		v28[instance] = nil
		v31[instance] = nil
		v22[instance] = nil
		v23[instance] = nil
		v25[instance] = nil
		v[instance] = false
		v32[instance] = nil
		v17[instance] = nil
		v18[instance] = nil
	end
end

function AINew.SmartPathfind(parent, instance, p, p2)
	if parent == nil or instance == nil or not parent:FindFirstChild("Humanoid") then
		return false
	end

	v2[parent] = true
	local config = Config.GetConfig(parent)
	local costs = {
		Water = 20,
		DangerZone = 1e999
	}

	if config.AgentCost then
		for k, v34 in pairs(config.AgentCost) do
			costs[k] = v34
		end
	end

	local v34 = {
		StandardPathfindSettings = {
			AgentRadius = config.AgentRadius,
			AgentHeight = config.AgentHeight,
			AgentCanJump = false,
			AgentCanClimb = false,
			Costs = costs
		},
		Visualize = true,
		Tracking = false
	}

	if p2 then
		for k, v35 in pairs(p2) do
			v34[k] = v35
		end
	end

	local count3 = 0
	local humanoidRootPart = nil
	local humanoid = nil
	local humanoidRootPart2 = nil

	local function updateBasedOnType(humanoid2, p3)
		count3 += 1

		local function updateVars(instance2)
			if count3 == 1 then
				humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart == nil then
					error("Could not find HRT. change to waitforchild to bypass")
					return
				end

				humanoid = instance2:FindFirstChild("Humanoid")

				if humanoid == nil then
					error("Could not find Humanoid. change to waitforchild to bypass")
					return
				end
			end

			if count3 == 2 then
				humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

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
						for _, part in ipairs(humanoid2:GetChildren()) do
							if not part:IsA("BasePart") then
								continue
							end

							humanoidRootPart2 = part
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
			if not humanoid2.Parent then
				return "part parent destroyed"
			end

			if humanoid2.Parent:FindFirstChild("Humanoid") then
				updateVars(humanoid2.Parent)
			end

			if humanoid2.Parent.Parent and humanoid2.Parent.Parent:FindFirstChild("Humanoid") then
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

	if instance == nil then
		return "target not found"
	end

	updateBasedOnType(instance, Standard.basic.GetType(instance))
	local config2 = Config.GetConfig(parent)
	local costs2 = {
		Water = 20,
		DangerZone = 1e999,
		Cocoa = 1e999
	}

	if config2.AgentCost then
		for k, v36 in pairs(config2.AgentCost) do
			costs2[k] = v36
		end
	end

	if config2.AgentCost and not config2._pathCostsLogged then
		config2._pathCostsLogged = true
		local v36 = ""

		for k, v37 in pairs(costs2) do
			if v37 ~= 1e999 then
				v36 ..= k .. "=" .. tostring(v37) .. " "
			end
		end

		if v36 ~= "" then
			print(string.format("[AINew] %s: PathCosts overrides = {%s}", parent.Name, v36))
		end
	end

	local path = PathfindingService:CreatePath({
		AgentRadius = config2.AgentRadius,
		AgentCanJump = false,
		AgentHeight = config2.AgentHeight,
		Waypoint_Threshold = 4,
		WaypointSpacing = 3,
		Costs = costs2
	})

	local function canCrossFloor(parent2, instance2)
		if not config2.FloorCheckMinDistance then
			return true
		end

		local humanoidRootPart3 = parent2:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart4 = instance2 and instance2:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart3 and humanoidRootPart4) then
			return true
		end

		local position = humanoidRootPart3.Position
		local position2 = humanoidRootPart4.Position
		local magnitude = (position2 - position).Magnitude

		if magnitude < (config2.FloorCheckAlwaysRaycastDistance or 2) or magnitude < (config2.FloorCheckMinDistance or 10) then
			return true
		end

		if v25[parent2] and os.clock() - v25[parent2] < 3 then
			return false
		end

		local floorCheckRaycastSpacing = config2.FloorCheckRaycastSpacing or 5
		local floorCheckFailHeight = config2.FloorCheckFailHeight or 12
		local unit = (position2 - position).Unit
		local v36 = math.floor(magnitude / floorCheckRaycastSpacing)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local model = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

		if model and model:FindFirstChild("Monsters") then
			raycastParams.FilterDescendantsInstances = model.Monsters:GetChildren()
		end

		for i = 1, v36 do
			local v37 = position + unit * (floorCheckRaycastSpacing * i)

			if workspace:Raycast(v37, Vector3.new(0, -floorCheckFailHeight, 0), raycastParams) then
				continue
			end

			v25[parent2] = os.clock()
			return false
		end

		return true
	end

	local function canseetarget(parent2, model, p3)
		if not (model and model.Parent) then
			return false
		end

		if model:GetAttribute("DecoyTag") then
			if isDebugEnabled() then
				print("[AI Debug] Detected decoy by DecoyTag attribute")
			end

			return true
		elseif model:FindFirstChildOfClass("AnimationController") and model:FindFirstChild("Humanoid") then
			if isDebugEnabled() then
				print("[AI Debug] Detected potential decoy with AnimationController")
			end

			return true
		else
			local config3 = Config.GetConfig(parent2)

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
				local position2 = model.PrimaryPart.Position
				local v36 = math.min((position2 - position).Magnitude + 2, p3)
				local v37 = (position2 - position).Unit * v36
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
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
				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
				local raycastResult = game.Workspace:Raycast(position, v37, raycastParams)

				if not (raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(model)) then
					return false
				end

				if not config3.DirectMoveToWidthCheck then
					return true
				end

				local v39 = humanoidRootPart3.Size.X / 2
				local v40 = position2 - position
				local unit = Vector3.new(v40.X, 0, v40.Z).Unit
				local vector2 = Vector3.new(-unit.Z, 0, unit.X)
				local v41 = position + vector2 * v39
				local raycastResult2 = game.Workspace:Raycast(v41, v37, raycastParams)

				if raycastResult2 and raycastResult2.Instance and not raycastResult2.Instance:IsDescendantOf(model) then
					return false
				end

				local v42 = position - vector2 * v39
				local raycastResult3 = game.Workspace:Raycast(v42, v37, raycastParams)

				if raycastResult3 and raycastResult3.Instance and not raycastResult3.Instance:IsDescendantOf(model) then
					return false
				end

				return true
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
				local position2 = model.Position
				local v36 = math.min((position2 - position).Magnitude + 2, p3)
				local v37 = (position2 - position).Unit * v36
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
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
				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
				local raycastResult = game.Workspace:Raycast(position, v37, raycastParams)

				if not (raycastResult and raycastResult.Instance and raycastResult.Instance == model) then
					return false
				end

				if not config3.DirectMoveToWidthCheck then
					return true
				end

				local v39 = humanoidRootPart3.Size.X / 2
				local v40 = position2 - position
				local unit = Vector3.new(v40.X, 0, v40.Z).Unit
				local vector2 = Vector3.new(-unit.Z, 0, unit.X)
				local v41 = position + vector2 * v39
				local raycastResult2 = game.Workspace:Raycast(v41, v37, raycastParams)

				if raycastResult2 and raycastResult2.Instance and raycastResult2.Instance ~= model then
					return false
				end

				local v42 = position - vector2 * v39
				local raycastResult3 = game.Workspace:Raycast(v42, v37, raycastParams)
				return not (raycastResult3 and raycastResult3.Instance) or raycastResult3.Instance == model
			end
		end
	end

	local function shouldJump(parent2, instance2)
		if not config2.JumpHandlerEnabled then
			return false
		end

		local humanoidRootPart3 = parent2:FindFirstChild("HumanoidRootPart")
		local humanoid2 = parent2:FindFirstChildOfClass("Humanoid")

		if not (humanoidRootPart3 and humanoid2) then
			return false
		end

		local humanoidRootPart4 = instance2:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart4 then
			return false
		end

		if (humanoidRootPart3.Position - humanoidRootPart4.Position).Magnitude < config2.CollinearOffset + config2.DistanceMovedThreshold + 0.1 then
			v14[parent2] = nil
			return false
		end

		local assemblyLinearVelocity = humanoidRootPart3.AssemblyLinearVelocity
		local magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

		if humanoid2.WalkSpeed * config2.JumpVelocityThreshold <= assemblyLinearVelocity.Magnitude then
			v14[parent2] = nil
			return false
		end

		if humanoid2.WalkSpeed * 0.33 <= magnitude then
			v14[parent2] = nil
			return false
		end

		if (humanoid2.WalkToPoint - humanoidRootPart3.Position).Magnitude <= config2.JumpDistanceFromGoal then
			return false
		end

		if not v14[parent2] then
			v14[parent2] = os.clock()
			return false
		end

		if os.clock() - v14[parent2] < config2.JumpMinStuckTime then
			return false
		end

		local v36 = v15[parent2] or 0

		if os.clock() - v36 < config2.JumpCooldown then
			return false
		end

		v15[parent2] = os.clock()
		v14[parent2] = nil
		return true
	end

	local function performUnstuckJump(instance2)
		local humanoid2 = instance2:FindFirstChildOfClass("Humanoid")

		if not humanoid2 then
			return
		end

		local jumpPower = humanoid2.JumpPower
		humanoid2.JumpPower = config2.UnstuckJumpPower or 10
		humanoid2.Jump = true
		task.defer(function()
			if humanoid2 and humanoid2.Parent then
				humanoid2.JumpPower = jumpPower
			end
		end)
	end

	local function getGroundedPosition(position, options, value)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = options or {}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.RespectCanCollide = true
		local raycastResult = workspace:Raycast(position, createVector(0, -1, 0) * (value or 3), raycastParams)

		if raycastResult and raycastResult.Instance then
			return raycastResult.Position + createVector(0, 2, 0)
		end

		return position
	end

	local function losCheck()
		if canseetarget(parent, instance, 100) then
			return true
		end

		local humanoidRootPart3 = parent:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart3 then
			return false
		end

		local partsInPart = workspace:GetPartsInPart(humanoidRootPart3)

		for _, v36 in ipairs(partsInPart) do
			if v36.Name == "HumanoidRootPart" and v36.Parent:FindFirstChild("Humanoid") and v36.Parent == instance then
				return true
			end
		end

		return false
	end

	local function canUseDirectMoveTo()
		if config2.DirectMoveToEnabled == false or v34.ForcePathfinding or v23[parent] and os.clock() < v23[parent] or not losCheck() then
			return false
		end

		local humanoidRootPart3 = parent:FindFirstChild("HumanoidRootPart")
		local humanoidRootPart4 = instance and instance:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart3 and humanoidRootPart4) then
			return false
		end

		local position = humanoidRootPart3.Position
		local position2 = humanoidRootPart4.Position

		if (position - position2).Magnitude > (config2.DirectMoveToActivationDistance or 60) then
			return false
		end

		return not (math.abs(position.Y - position2.Y) > (config2.DirectMoveToHeightLimit or 10))
	end

	local function destroyWP()
		for _, child in pairs(parent:GetChildren()) do
			if child.Name == "Waypoints" then
				Debris:AddItem(child, 0)
			end
		end
	end

	local function moveTo()
		if v34.Tracking and parent and parent.PrimaryPart then
			pcall(function()
				parent.PrimaryPart:SetNetworkOwner(nil)
			end)
		end

		local v36 = nil

		local function invokeClientWithTimeout(playerFromCharacter, humanoidRootPart3, p3)
			local userId = playerFromCharacter.UserId
			local now = tick()
			local distance = not (parent and parent.PrimaryPart and humanoidRootPart3) and 1e999 or (parent.PrimaryPart.Position - humanoidRootPart3.Position).Magnitude

			if distance >= 20 then
				return humanoidRootPart3.Position
			end

			local v38 = false
			local v39 = v10[userId]

			if v39 and not (now - v39.time > 0.15) then
				if v39.monster == parent or distance < v39.distance then
					v10[userId] = {
						monster = parent,
						distance = distance,
						time = now
					}
					v38 = true
				end
			else
				v10[userId] = {
					monster = parent,
					distance = distance,
					time = now
				}
				v38 = true
			end

			if not v38 then
				return humanoidRootPart3.Position
			end

			local getCharacterPosition = ReplicatedStorage2.Events.GetCharacterPosition
			local v40 = false
			local v41 = nil
			coroutine.wrap(function()
				local _, _ = pcall(function()
					v41 = getCharacterPosition:InvokeClient(playerFromCharacter)
				end)
				v40 = true
			end)()
			local lastTime = tick()

			while not v40 and tick() - lastTime < p3 do
				local RunService2 = game:GetService("RunService")
				RunService2.Heartbeat:Wait()
			end

			if not v40 or v41 == nil then
				return humanoidRootPart3.Position
			end

			local position

			if typeof(v41) == "CFrame" then
				position = v41.Position
			elseif typeof(v41) == "Vector3" then
				position = v41
			else
				return humanoidRootPart3.Position
			end

			local magnitude = (position - humanoidRootPart3.Position).Magnitude

			if magnitude > 75 then
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

			if stats and stats:FindFirstChild("InElevator") and stats.InElevator.Value then
				v36 = nil
			else
				local success, result = pcall(function()
					local playerFromCharacter = game.Players:GetPlayerFromCharacter(humanoidRootPart2.Parent)
					local humanoidRootPart3 = playerFromCharacter and instance:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart3 then
						v36 = invokeClientWithTimeout(playerFromCharacter, humanoidRootPart3, 0.2)
					end
				end)

				if not success then
					warn("Error invoking client position:", result)
				end
			end
		end

		if v36 == nil or typeof(v36) ~= "Vector3" then
			if humanoidRootPart2 and humanoidRootPart2.Parent then
				humanoid:MoveTo(humanoidRootPart2.Position)
			end
		elseif instance:FindFirstChild("HumanoidRootPart") and parent and parent.PrimaryPart then
			local success, result = pcall(function()
				local vector2 = Vector3.new(0, -(parent.PrimaryPart.Size.Y / 2 + humanoid.HipHeight), 0)
				local humanoid2 = instance:FindFirstChild("Humanoid")
				local humanoidRootPart3 = instance:FindFirstChild("HumanoidRootPart")

				if humanoid2 and humanoidRootPart3 then
					local vector3 = Vector3.new(0, -(humanoidRootPart3.Size.Y / 2 + humanoid2.HipHeight), 0)
					local v37 = parent.PrimaryPart.Position + vector2
					local v38 = v36 + vector3

					if v5 and v34.Tracking and humanoidRootPart3 then
						local movementPredictionMagnitude = config2.MovementPredictionMagnitude or 2

						if config2.EnablePrediction ~= false and movementPredictionMagnitude > 0 then
							local assemblyLinearVelocity = humanoidRootPart3.AssemblyLinearVelocity
							local vector4 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

							if vector4.Magnitude > 1 then
								local unit = vector4.Unit
								local v39 = v26[instance]

								if v39 and v39.dir then
									local dot = unit:Dot(v39.dir)

									if dot < 0.7 then
										movementPredictionMagnitude *= 0.3
									elseif dot < 0.85 then
										movementPredictionMagnitude *= 0.6
									end
								else
									movementPredictionMagnitude *= 0.5
								end

								v26[instance] = {
									dir = unit,
									time = os.clock()
								}
							end

							local position = v5.PredictMovement(humanoidRootPart3, movementPredictionMagnitude)
							local magnitude = (position - humanoidRootPart3.Position).Magnitude

							if magnitude > 0.5 then
								local raycastParams = RaycastParams.new()
								raycastParams.FilterType = Enum.RaycastFilterType.Exclude
								raycastParams.FilterDescendantsInstances = { parent, instance }
								local raycastResult = workspace:Raycast(
									humanoidRootPart3.Position + createVector(0, 2, 0),
									position - humanoidRootPart3.Position,
									raycastParams
								)

								if raycastResult and raycastResult.Distance < magnitude - 0.3 then
									position = humanoidRootPart3.Position
								end
							end

							v38 = position + vector3
						end

						v38 = v5.GetCollinearTargetPositionOffset(v38, v37, config2.CollinearOffset)
					end

					if parent.PrimaryPart then
						local v39 = createVector(0, 0, 0)
						local flockingEnabled = isFlockingEnabled() -- equivalent call inferred; original call site unknown

						if flockingEnabled and v7 then
							local v41 = 0
							local model = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

							if model then
								local monsters = model:FindFirstChild("Monsters")

								if monsters then
									for i, child in ipairs(monsters:GetChildren()) do
										if child ~= parent then
											continue
										end

										v41 = i - 1
										break
									end
								end
							end

							v39 = v7.CalculateFlockingForce(parent, instance, nil, "Swarm", v41)
						else
							local model = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

							if model then
								local monsters = model:FindFirstChild("Monsters")

								if monsters then
									local position = parent.PrimaryPart.Position

									for _, child in pairs(monsters:GetChildren()) do
										if not (child ~= parent and child:FindFirstChild("HumanoidRootPart")) then
											continue
										end

										local position2 = child.HumanoidRootPart.Position
										local magnitude = (position - position2).Magnitude

										if magnitude < 3.5 and magnitude > 0.1 then
											v39 += (position - position2).Unit * ((3.5 - magnitude) / 3.5 * 0.7)
										end
									end
								end
							end
						end

						if v39.Magnitude > 0 then
							local vector4 = Vector3.new(v39.X, 0, v39.Z)

							if vector4.Magnitude > 6 then
								vector4 = vector4.Unit * 6
							end

							local v40 = v38 + vector4
							local raycastParams = RaycastParams.new()
							raycastParams.FilterType = Enum.RaycastFilterType.Exclude
							raycastParams.FilterDescendantsInstances = { parent, instance }

							if not workspace:Raycast(
								v37 + createVector(0, 2, 0),
								(v40 - v37).Unit * math.min((v40 - v37).Magnitude, 8),
								raycastParams
							) then
								v38 += vector4
							end
						end
					end

					local v39 = v38 - v37

					if not (v39.Magnitude < 0.001) then
						local unit = v39.Unit
						local v40 = 0
						local v41

						if config2.EnablePrediction == false or not ((config2.MovementPredictionMagnitude or 2) > 0) then
							v41 = false
						else
							v41 = v34.Tracking
						end

						if not v41 and humanoidRootPart3 and humanoidRootPart3:IsA("BasePart") and humanoidRootPart3.Velocity then
							local success2, result2 = pcall(function()
								return (math.abs(humanoidRootPart3.Velocity:Dot(unit) / 3))
							end)

							if success2 then
								v40 = result2
							end
						end

						local position = v37 + unit * (v39.Magnitude + v40)

						if position.Magnitude > 10000 then
							warn("Extreme calculated movement position:", position.Magnitude)
						else
							local flag = true

							if config2.DirectMoveToWallCheck and humanoidRootPart3 and (v37 - humanoidRootPart3.Position).Magnitude < 15 then
								local raycastParams = RaycastParams.new()
								raycastParams.FilterType = Enum.RaycastFilterType.Exclude
								raycastParams.FilterDescendantsInstances = { parent, instance }
								local v43 = math.min((position - v37).Magnitude, 8)
								local raycastResult = workspace:Raycast(
									v37 + createVector(0, 2, 0),
									(position - v37).Unit * v43,
									raycastParams
								)

								if raycastResult and raycastResult.Distance < v43 - 1 then
									flag = false
								end
							end

							if flag then
								if config2.OnMovingToWaypoint then
									pcall(function()
										config2.OnMovingToWaypoint(parent, {
											Position = position,
											Action = "Walk",
											Label = "DirectMoveTo"
										}, "DirectMoveTo")
									end)
								end

								if config2.TurnSpeedPenaltyEnabled and v34.Tracking then
									local vector4 = Vector3.new(unit.X, 0, unit.Z)

									if vector4.Magnitude > 0.01 then
										local unit2 = vector4.Unit
										local now = os.clock()

										if not v27[parent] then
											v27[parent] = unit2
											v28[parent] = now
										end

										local dot = unit2:Dot(v27[parent])
										local turnSpeedPenaltyThreshold = config2.TurnSpeedPenaltyThreshold or 0.7

										if dot < turnSpeedPenaltyThreshold then
											local v43 = 1 - math.clamp(
												(turnSpeedPenaltyThreshold - dot) / turnSpeedPenaltyThreshold,
												0,
												1
											) * (1 - (config2.TurnSpeedPenaltyMin or 0.6))
											local v44 = v29[parent] or 1
											v29[parent] = math.min(v44, v43)
											local turnSpeedPenaltyHoldTime = config2.TurnSpeedPenaltyHoldTime or 0.8
											v31[parent] = now + turnSpeedPenaltyHoldTime
										end

										if now - (v28[parent] or 0) >= 0.4 then
											v27[parent] = unit2
											v28[parent] = now
										end
									end
								end

								if config2.TurnSpeedPenaltyEnabled and v34.Tracking then
									local v43 = v30[parent]

									if v43 and v43 < 1 then
										humanoid.WalkSpeed /= v43
									end

									local v44 = v29[parent] or 1

									if v44 < 1 then
										humanoid.WalkSpeed *= v44
									end

									v30[parent] = v44

									if v44 < 0.95 and isDebugEnabled() then
										print(string.format(
											"[AINew TurnPenalty] %s: DirectMoveTo penalty=%.2f speed=%.1f",
											parent.Name,
											v44,
											humanoid.WalkSpeed
										))
									end
								end

								humanoid:MoveTo(position)
							elseif humanoidRootPart2 and humanoidRootPart2.Parent then
								humanoid:MoveTo(humanoidRootPart2.Position)
							end

							local humanoid3 = shouldJump(parent, instance) and parent:FindFirstChildOfClass("Humanoid")

							if humanoid3 then
								local jumpPower = humanoid3.JumpPower
								humanoid3.JumpPower = config2.UnstuckJumpPower or 10
								humanoid3.Jump = true
								task.defer(function()
									if humanoid3 and humanoid3.Parent then
										humanoid3.JumpPower = jumpPower
									end
								end)
							end

							if not (v34.Tracking and parent.PrimaryPart) then
								return
							end

							local assemblyLinearVelocity = parent.PrimaryPart.AssemblyLinearVelocity

							if Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude < 1 then
								if not v22[parent] then
									v22[parent] = os.clock()
								end

								local v43 = os.clock() - v22[parent]

								if (config2.PathfindingLinkReached and 0.2 or 0.5) < v43 then
									v23[parent] = os.clock() + 3
									v22[parent] = nil

									if isDebugEnabled() then
										warn(string.format(
											"[AINew] %s: DirectMoveTo stuck %.1fs, forcing pathfinding for 3s",
											parent.Name,
											v43
										))
										return
									end
								end
							else
								v22[parent] = nil
							end

							return
						end
					end
				end

				if humanoidRootPart2 and humanoidRootPart2.Parent then
					humanoid:MoveTo(humanoidRootPart2.Position)
				end
			end)

			if not success then
				warn("Movement calculation failed:", result)

				if humanoidRootPart2 and humanoidRootPart2.Parent then
					humanoid:MoveTo(humanoidRootPart2.Position)
				end
			end
		elseif humanoidRootPart2 and humanoidRootPart2.Parent then
			humanoid:MoveTo(humanoidRootPart2.Position)
		end

		if not v34.Tracking then
			humanoid.MoveToFinished:Wait()
		end
	end

	local function pathfind()
		local chasingValue = parent:FindFirstChild("ChasingValue")

		if not chasingValue then
			return
		end

		if v34.Tracking == true then
			if chasingValue.Value ~= instance or (instance:FindFirstChild("BoxAbilityActive") or instance:FindFirstChild("NoDandy")) or instance:FindFirstChild("NoTarget") and not v34.NoTargetOverride then
				return
			end

			local stats = instance:FindFirstChild("Stats")

			if stats and stats:FindFirstChild("InElevator") and stats.InElevator.Value then
				return
			end
		end

		if config2.OnPathingStarted then
			pcall(function()
				config2.OnPathingStarted(parent, instance)
			end)
		end

		if canUseDirectMoveTo() and canCrossFloor(parent, instance) then
			v20[parent] = "DirectMoveTo"
			moveTo()
		else
			local position, position2, v36, humanoid2, humanoidRootPart3, playerFromCharacter, userId, decoyTag, vector2, waypoints, v37, v38, stats, chasingValue2, v39, v40, flag, raycastParams, model, v41, raycastResult, v42, v43, v44, raycastParams2, children, model2, v45, raycastResult2, v46, position3, v47, v48, success, result, humanoidRootPart4, v49, assemblyLinearVelocity, magnitude, v50, v51, vector3, vector4, raycastParams3, raycastResult3, raycastResult4, v52, humanoidRootPart5, magnitude2, position4, v53, magnitude3, v54, vector5, unit, now, v55, turnSpeedPenaltyThreshold, v56, v57, turnSpeedPenaltyHoldTime, v58, v59, humanoid3, jumpPower, v60, v61, folder, part, v62, v63, humanoidRootPart6, humanoidRootPart7, magnitude4, position5, humanoidRootPart8, v64, success2, result2, humanoidRootPart9, humanoidRootPart10, v65, magnitude5, raycastParams4, v66, raycastResult5, instance2, v67, humanoid4, humanoidRootPart11, position6, v68, v69, lastTime, heartbeatConnection, count4, position7, moveToFinishedConnection, RunService2, onWaypointReached, v70, success3, result3, humanoidRootPart12, cFrame, v71, count5, position8, unit2, raycastParams5, v72, v73, raycastResult6, position9, vector6, unit3, humanoid5, jumpPower2, now2, assemblyLinearVelocity2, position13, position14, v76, magnitude6, magnitude7, v77, v78, parent2, getOrCreateMarker, v80, v81, now3, position10, v82, v83, magnitude8, v84, position11, _PathFailDebug, name2, v86, now4, humanoidRootPart13, humanoidRootPart14, v87, v88, vector7, vector8, raycastParams6, raycastResult7, raycastResult8, v89, v90

			if v34.Tracking or v34.BypassThreshold or not instance:FindFirstChild("HumanoidRootPart") then
				if not (humanoidRootPart and humanoidRootPart.Parent) then
					return false
				end

				position2 = humanoidRootPart.Position

				if humanoid then
					v36 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
					position2 = humanoidRootPart.Position - Vector3.new(0, v36, 0)
				end

				if instance:FindFirstChild("Humanoid") and instance:FindFirstChild("HumanoidRootPart") then
					humanoid2 = instance:FindFirstChild("Humanoid")
					humanoidRootPart3 = instance:FindFirstChild("HumanoidRootPart")

					if humanoid2 and humanoidRootPart3 then
						playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

						if playerFromCharacter then
							userId = playerFromCharacter.UserId
						else
							local decoyTag = instance:GetAttribute("DecoyTag") or instance:FindFirstChildOfClass("AnimationController") or instance:GetAttribute("IsBotCharacter")
						end

						if not position then
							vector2 = Vector3.new(0, -(humanoidRootPart3.Size.Y / 2 + humanoid2.HipHeight), 0)
							position = humanoidRootPart3.Position + vector2
						end

						path:ComputeAsync(position2, position)
					else
						if not (humanoidRootPart2 and humanoidRootPart2.Parent) then
							return false
						end

						path:ComputeAsync(position2, humanoidRootPart2.Position)
					end
				else
					if humanoidRootPart2 and humanoidRootPart2.Parent then
						position = humanoidRootPart2.Position
					else
						if not (instance and instance:IsA("BasePart")) then
							return false
						end

						position = instance.Position
					end

					path:ComputeAsync(position2, position)
				end

				waypoints = path:GetWaypoints()

				if v[parent] == false then
					print(string.format(
						"[AINew] %s: discarded stale path computed across an interrupt (stopped) — no MoveTo issued",
						parent.Name
					))
					return
				end

				if v34.Tracking == true then
					if instance:FindFirstChild("BoxAbilityActive") or instance:FindFirstChild("NoDandy") then
						v38 = "stealth"
					elseif instance:FindFirstChild("NoTarget") and not v34.NoTargetOverride then
						v38 = "NoTarget (smoke bomb)"
					else
						stats = instance:FindFirstChild("Stats")
						v38 = stats and stats:FindFirstChild("InElevator") and stats.InElevator.Value and "elevator" or v37
					end

					if v38 then
						print(string.format(
							"[AINew] %s: discarded stale path computed across an interrupt (%s) — no MoveTo issued",
							parent.Name,
							v38
						))
						return
					end

					chasingValue2 = parent:FindFirstChild("ChasingValue")

					if not chasingValue2 or chasingValue2.Value ~= instance then
						return
					end
				end

				v39 = not v34.Tracking and 0 or config2.WaypointSkipCountTracking or 3

				if waypoints and v39 < #waypoints and v39 > 0 then
					v40 = waypoints[v39 + 1]
					flag = true

					if v40 and humanoidRootPart then
						raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						model = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

						if model and model:FindFirstChild("Monsters") then
							raycastParams.FilterDescendantsInstances = model.Monsters:GetChildren()
						end

						v41 = v40.Position - humanoidRootPart.Position
						raycastResult = workspace:Raycast(humanoidRootPart.Position, v41, raycastParams)

						if raycastResult and raycastResult.Instance then
							flag = false
						end
					end

					if flag then
						v42 = {}

						for i = v39 + 1, #waypoints do
							table.insert(v42, waypoints[i])
						end

						waypoints = v42
					end
				end

				if path.Status == Enum.PathStatus.Success then
					if path.Status == Enum.PathStatus.Success then
						v20[parent] = "Pathfind"

						if v34.Tracking then
							v21[parent] = {
								time = os.clock(),
								waypoints = waypoints,
								target = instance
							}
						end

						if v34.Tracking then
							v43 = 2

							if not config2.PathfindingLinkReached and #waypoints > 2 and humanoidRootPart then
								v44 = waypoints[3]

								if v44 and v44.Action ~= Enum.PathWaypointAction.Custom then
									raycastParams2 = RaycastParams.new()
									raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
									children = { parent }
									model2 = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

									if model2 and model2:FindFirstChild("Monsters") then
										for i, child in ipairs(model2.Monsters:GetChildren()) do
											table.insert(children, child)
										end
									end

									raycastParams2.FilterDescendantsInstances = children
									v45 = v44.Position - humanoidRootPart.Position
									raycastResult2 = workspace:Raycast(humanoidRootPart.Position, v45, raycastParams2)

									if not (raycastResult2 and raycastResult2.Instance) then
										v43 = 3
									end
								end
							end

							v46 = waypoints[v43]

							if v46 and v46.Action == Enum.PathWaypointAction.Custom then
								v47 = v24[parent] and os.clock() - v24[parent] or 1e999
								v48 = not humanoidRootPart and 0 or (humanoidRootPart.Position - v46.Position).Magnitude or 0

								if v47 < 1 then
									print(string.format(
										"[HopDiag] %s: ON COOLDOWN (%.1fs ago) dist=%.1f to wp#%d — skipping hop",
										parent.Name,
										v47,
										v48,
										v43
									))
								elseif v48 > 35 then
									print(string.format(
										"[HopDiag] %s: TOO FAR (%.1f > %d) to wp#%d — skipping hop",
										parent.Name,
										v48,
										35,
										v43
									))
								else
									print(string.format(
										"[HopDiag] %s: HOPPING dist=%.1f to wp#%d pos=(%.0f,%.0f,%.0f)",
										parent.Name,
										v48,
										v43,
										v46.Position.X,
										v46.Position.Y,
										v46.Position.Z
									))

									if config2.OnMovingToWaypoint then
										pcall(function()
											config2.OnMovingToWaypoint(parent, v46, "PathfindingLink")
										end)
									end

									if config2.PathfindingLinkReached then
										success, result = pcall(config2.PathfindingLinkReached, parent, v46)

										if not success then
											pcall(function()
												parent:SetAttribute("_HopInProgress", nil)
											end)
										end

										if success and result then
											v24[parent] = os.clock()
											v22[parent] = nil
											print(string.format("[HopDiag] %s: HOP OK — landed", parent.Name))
											return
										elseif success then
											print(string.format("[HopDiag] %s: HOP RETURNED FALSE", parent.Name))
										else
											print(string.format(
												"[HopDiag] %s: HOP ERROR: %s",
												parent.Name,
												(tostring(result))
											))
										end
									else
										humanoidRootPart4 = parent:FindFirstChild("HumanoidRootPart")

										if humanoidRootPart4 then
											v49 = getGroundedPosition(v46.Position, { parent, instance }, 5)
											humanoidRootPart4.CFrame = CFrame.new(v49 + Vector3.new(
												0,
												humanoidRootPart4.Size.Y / 2 + humanoid.HipHeight,
												0
											))
										end
									end

									v24[parent] = os.clock()
								end

								v22[parent] = nil
							else
								if v46 then
									position3 = getGroundedPosition(v46.Position, { parent, instance }, 5)
								elseif #waypoints >= 2 and waypoints[2] then
									position3 = getGroundedPosition(waypoints[2].Position, { parent, instance }, 5)
								elseif instance and instance:FindFirstChild("HumanoidRootPart") then
									position3 = instance.HumanoidRootPart.Position
								end

								if humanoidRootPart and humanoid then
									assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
									magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

									if magnitude < 1 then
										if not v22[parent] then
											v22[parent] = os.clock()
										end

										v50 = os.clock() - v22[parent]

										if v50 > 0.5 and position3 then
											v51 = position3 - humanoidRootPart.Position
											vector3 = Vector3.new(v51.X, 0, v51.Z)

											if vector3.Magnitude > 0.1 then
												vector4 = Vector3.new(-vector3.Unit.Z, 0, vector3.Unit.X)
												raycastParams3 = RaycastParams.new()
												raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
												raycastParams3.FilterDescendantsInstances = { parent }
												raycastResult3 = workspace:Raycast(
													humanoidRootPart.Position,
													vector4 * 5,
													raycastParams3
												)
												raycastResult4 = workspace:Raycast(
													humanoidRootPart.Position,
													-vector4 * 5,
													raycastParams3
												)
												v52 = (raycastResult3 and raycastResult3.Distance or 5) >= (raycastResult4 and raycastResult4.Distance or 5) and vector4 or -vector4
												position3 = humanoidRootPart.Position + v52 * 4 + vector3.Unit * 2

												if isDebugEnabled() then
													warn(string.format(
														"[AINew] %s: Pathfind STALL nudge stuck=%.1fs nudge=(%.0f,%.0f,%.0f)",
														parent.Name,
														v50,
														position3.X,
														position3.Y,
														position3.Z
													))
												end

												v22[parent] = os.clock()
											end
										end

										if magnitude < humanoid.WalkSpeed * 0.2 and isDebugEnabled() then
											humanoidRootPart5 = instance and instance:FindFirstChild("HumanoidRootPart")
											magnitude2 = humanoidRootPart5 and (humanoidRootPart.Position - humanoidRootPart5.Position).Magnitude or -1
											position4 = humanoidRootPart.Position
											warn(string.format(
												"[AINew STALL] %s: vel=%.1f wpCount=%d wpIdx=%d distToTarget=%.1f moveToPos=%s",
												parent.Name,
												magnitude,
												#waypoints,
												v43,
												magnitude2,
												not position3 and "nil" or string.format(
													"(%.0f,%.0f,%.0f)",
													position3.X,
													position3.Y,
													position3.Z
												) or "nil"
											))

											for i = 1, math.min(#waypoints, 8) do
												v53 = waypoints[i]
												magnitude3 = (v53.Position - position4).Magnitude
												warn(string.format(
													"  wp#%d (%.0f,%.0f,%.0f) dist=%.1f action=%s",
													i,
													v53.Position.X,
													v53.Position.Y,
													v53.Position.Z,
													magnitude3,
													(tostring(v53.Action))
												))
											end
										end
									else
										v22[parent] = nil
									end
								end

								if position3 then
									if config2.OnMovingToWaypoint and v46 then
										pcall(function()
											config2.OnMovingToWaypoint(parent, v46, "Pathfind")
										end)
									end

									if config2.TurnSpeedPenaltyEnabled and v34.Tracking and humanoidRootPart then
										v54 = position3 - humanoidRootPart.Position
										vector5 = Vector3.new(v54.X, 0, v54.Z)

										if vector5.Magnitude > 0.01 then
											unit = vector5.Unit
											now = os.clock()

											if not v27[parent] then
												v27[parent] = unit
												v28[parent] = now
											end

											v55 = unit:Dot(v27[parent])
											turnSpeedPenaltyThreshold = config2.TurnSpeedPenaltyThreshold or 0.7

											if v55 < turnSpeedPenaltyThreshold then
												v56 = 1 - math.clamp(
													(turnSpeedPenaltyThreshold - v55) / turnSpeedPenaltyThreshold,
													0,
													1
												) * (1 - (config2.TurnSpeedPenaltyMin or 0.6))
												v57 = v29[parent] or 1
												v29[parent] = math.min(v57, v56)
												turnSpeedPenaltyHoldTime = config2.TurnSpeedPenaltyHoldTime or 0.8
												v31[parent] = now + turnSpeedPenaltyHoldTime
											end

											if now - (v28[parent] or 0) >= 0.4 then
												v27[parent] = unit
												v28[parent] = now
											end
										end
									end

									if config2.TurnSpeedPenaltyEnabled and v34.Tracking then
										v58 = v30[parent]

										if v58 and v58 < 1 then
											humanoid.WalkSpeed /= v58
										end

										v59 = v29[parent] or 1

										if v59 < 1 then
											humanoid.WalkSpeed *= v59
										end

										v30[parent] = v59

										if v59 < 0.95 and isDebugEnabled() then
											print(string.format(
												"[AINew TurnPenalty] %s: Pathfind penalty=%.2f speed=%.1f",
												parent.Name,
												v59,
												humanoid.WalkSpeed
											))
										end
									end

									humanoid:MoveTo(position3)

									if shouldJump(parent, instance) then
										humanoid3 = parent:FindFirstChildOfClass("Humanoid")

										if not humanoid3 then
											return
										end

										jumpPower = humanoid3.JumpPower
										humanoid3.JumpPower = config2.UnstuckJumpPower or 10
										humanoid3.Jump = true
										task.defer(function()
											if humanoid3 and humanoid3.Parent then
												humanoid3.JumpPower = jumpPower
											end
										end)
									end
								end
							end
						else
							v60 = 1
							count2 += 1
							v61 = count2
							v[parent] = v61

							if p2.Visualize then
								folder = Instance.new("Folder")
								folder.Parent = parent
								folder.Name = "Waypoints"

								for k, waypoint in pairs(waypoints) do
									part = Instance.new("Part")
									part.Shape = Enum.PartType.Ball
									part.Color = Color3.new(0.384314, 0.341176, 1)
									part.Material = Enum.Material.Neon
									part.CFrame = CFrame.new(waypoint.Position)
									part.Parent = folder
									part.Name = k
									part.Anchored = true
									part.Size = createVector(1, 1, 1)
									part.CanCollide = false
								end
							end

							for i, waypoint in ipairs(waypoints) do
								if i > 1 then
									if humanoid.WalkSpeed == 0 then
										break
									end

									if #waypoints < v60 or v[parent] ~= v61 then
										if v[parent] ~= false then
											v62 = parent
											reset(v62) -- equivalent call inferred; original call site unknown
										end

										return
									else
										if waypoint.Action == Enum.PathWaypointAction.Jump and config2.JumpOnWaypoint then
											humanoid.Jump = true
										end

										if v34.Tracking == true and chasingValue.Value ~= instance then
											return
										end

										v63 = getGroundedPosition(waypoint.Position, { parent, instance }, 5)
										humanoidRootPart6 = parent:FindFirstChild("HumanoidRootPart")

										if not humanoidRootPart6 then
											break
										end

										if v34.Tracking and instance then
											humanoidRootPart7 = nil

											if typeof(instance) == "Instance" then
												if instance:IsA("Model") then
													humanoidRootPart7 = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
												elseif instance:IsA("BasePart") then
													humanoidRootPart7 = instance
												end
											end

											if humanoidRootPart7 then
												magnitude4 = (v63 - humanoidRootPart6.Position).Magnitude

												if (humanoidRootPart7.Position - humanoidRootPart6.Position).Magnitude < magnitude4 * 0.7 then
													break
												end

												if position then
													position5 = humanoidRootPart7.Position

													if (position5 - Vector3.new(position.X, position5.Y, position.Z)).Magnitude > 5 then
														break
													end
												end
											end
										end

										if waypoint.Action == Enum.PathWaypointAction.Custom then
											if config2.OnMovingToWaypoint then
												local v91 = waypoint
												pcall(function()
													config2.OnMovingToWaypoint(parent, v91, "PathfindingLink")
												end)
											end

											if config2.PathfindingLinkReached then
												humanoidRootPart8 = parent:FindFirstChild("HumanoidRootPart")
												v64 = not humanoidRootPart8 and 0 or (humanoidRootPart8.Position - waypoint.Position).Magnitude or 0

												if v64 > 35 then
													warn(string.format(
														"[AINew] %s: Skipping hop — waypoint too far (%.1f studs)",
														parent.Name,
														v64
													))
												else
													success2, result2 = pcall(
														config2.PathfindingLinkReached,
														parent,
														waypoint
													)

													if not (success2 and result2) and not success2 then
														warn(string.format(
															"[AINew] %s: PathfindingLinkReached error: %s",
															parent.Name,
															(tostring(result2))
														))
													end
												end
											else
												humanoidRootPart9 = parent:FindFirstChild("HumanoidRootPart")

												if humanoidRootPart9 then
													humanoidRootPart9.CFrame = CFrame.new(v63 + Vector3.new(
														0,
														humanoidRootPart9.Size.Y / 2 + humanoid.HipHeight,
														0
													))
												end
											end
										else
											humanoidRootPart10 = parent:FindFirstChild("HumanoidRootPart")

											if not humanoidRootPart10 then
												break
											end

											v65 = v63 - humanoidRootPart10.Position
											magnitude5 = v65.Magnitude

											if magnitude5 > 1 then
												raycastParams4 = RaycastParams.new()
												raycastParams4.FilterType = Enum.RaycastFilterType.Exclude
												raycastParams4.FilterDescendantsInstances = { parent, instance }
												v66 = math.min(magnitude5, 8)
												raycastResult5 = workspace:Raycast(
													humanoidRootPart10.Position + createVector(0, 2, 0),
													v65.Unit * v66,
													raycastParams4
												)
												instance2 = raycastResult5 and raycastResult5.Distance < v66 - 1 and raycastResult5.Instance

												if instance2 then
													v67 = instance2.Name:match("Generator") or instance2.Parent and instance2.Parent.Name:match("Generator")
													humanoid4 = instance2.Parent and instance2.Parent:FindFirstChild("Humanoid")

													if CollectionService:HasTag(instance2, "Wall") or CollectionService:HasTag(
														instance2,
														"Obstacle"
													) or instance2.CanCollide and not (v67 or humanoid4) then
														continue
													end
												end
											end

											if config2.OnMovingToWaypoint then
												local v91 = waypoint
												pcall(function()
													config2.OnMovingToWaypoint(parent, v91, "Pathfind")
												end)
											end

											humanoid:MoveTo(v63)
											humanoidRootPart11 = parent:FindFirstChild("HumanoidRootPart")

											if not humanoidRootPart11 then
												break
											end

											position6 = humanoidRootPart11.Position
											v68 = not v34.Tracking
											v69 = false

											if v68 then
												v69 = humanoid.MoveToFinished:Wait()
											else
												lastTime = tick()
												heartbeatConnection = nil
												count4 = 0
												position7 = humanoidRootPart11.Position
												moveToFinishedConnection = nil
												moveToFinishedConnection = humanoid.MoveToFinished:Connect(function(p3)
													v69 = p3

													if moveToFinishedConnection then
														moveToFinishedConnection:Disconnect()
													end

													if heartbeatConnection then
														heartbeatConnection:Disconnect()
													end
												end)
												RunService2 = game:GetService("RunService")
												local v91 = humanoidRootPart11
												local v92 = lastTime
												heartbeatConnection = RunService2.Heartbeat:Connect(function()
													count4 += 1

													if count4 % 9 == 0 then
														local position122 = v91.Position
														local assemblyLinearVelocity3 = v91.AssemblyLinearVelocity
														local magnitude9 = Vector3.new(
															assemblyLinearVelocity3.X,
															0,
															assemblyLinearVelocity3.Z
														).Magnitude
														local magnitude10 = (position122 - position7).Magnitude

														if not parent:GetAttribute("UsingAbility") and (not parent:FindFirstChild("Grabbing") or parent.Grabbing.Value ~= true) and magnitude9 < 0.5 and magnitude10 < 0.3 and tick() - v92 > 0.3 then
															v69 = false

															if moveToFinishedConnection then
																moveToFinishedConnection:Disconnect()
															end

															if heartbeatConnection then
																heartbeatConnection:Disconnect()
															end
														end

														position7 = position122
													end
												end)

												while not v69 and tick() - lastTime < 1.5 do
													task.wait(0.05)

													if parent:GetAttribute("UsingAbility") or not (not parent:FindFirstChild("Grabbing") or parent.Grabbing.Value ~= true) or not ((humanoidRootPart11.Position - position6).Magnitude < 0.1) then
														continue
													end

													if not (tick() - lastTime > 0.4) then
														continue
													end

													if moveToFinishedConnection then
														moveToFinishedConnection:Disconnect()
													end

													if not heartbeatConnection then
														break
													end

													heartbeatConnection:Disconnect()
													break
												end

												if moveToFinishedConnection then
													moveToFinishedConnection:Disconnect()
												end

												if heartbeatConnection then
													heartbeatConnection:Disconnect()
												end
											end

											if v69 and config2.OnWaypointReached then
												local v91 = waypoint
												pcall(function()
													config2.OnWaypointReached(parent, v91)
												end)
											end

											if v69 then
												onWaypointReached = parent:FindFirstChild("OnWaypointReached")

												if onWaypointReached and onWaypointReached:IsA("BindableEvent") then
													onWaypointReached:Fire(i, waypoint)
												end
											else
												v70 = false

												if config2.OnStuck then
													success3, result3 = pcall(function()
														return config2.OnStuck(parent, instance)
													end)
													v70 = success3 and result3 == true and true or false
												end

												if not v70 then
													humanoidRootPart12 = parent:FindFirstChild("HumanoidRootPart")

													if not humanoidRootPart12 then
														break
													end

													cFrame = humanoidRootPart12.CFrame
													v71 = false
													count5 = 0

													while not v71 and count5 < 3 do
														count5 += 1
														position8 = humanoidRootPart12.Position
														unit2 = nil
														raycastParams5 = RaycastParams.new()
														raycastParams5.FilterDescendantsInstances = { parent, instance }
														raycastParams5.FilterType = Enum.RaycastFilterType.Exclude

														if count5 == 1 then
															v72 = cFrame.RightVector * (math.random() > 0.5 and 1 or -1)
															v73 = -cFrame.LookVector
															unit2 = (v72 + v73 * 0.4).Unit
															raycastResult6 = workspace:Raycast(
																humanoidRootPart12.Position + createVector(0, 2, 0),
																unit2 * 5,
																raycastParams5
															)

															if raycastResult6 and raycastResult6.Distance < 2 then
																unit2 = (-v72 + v73 * 0.4).Unit
															end
														elseif count5 == 2 then
															unit2 = (cFrame.RightVector * (math.random() > 0.5 and -1 or 1) + cFrame.LookVector * 0.5).Unit
														elseif count5 == 3 then
															unit2 = (-cFrame.LookVector + cFrame.RightVector * (math.random() > 0.5 and 1 or -1) * 0.7).Unit
														end

														humanoid:MoveTo(cFrame.Position + unit2 * 3)
														task.wait(0.12)
														v71 = (humanoidRootPart12.Position - position8).Magnitude > 0.8 or v71
													end

													if not v71 then
														position9 = humanoidRootPart12.Position
														vector6 = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))

														if vector6.Magnitude > 0 then
															unit3 = vector6.Unit
															humanoid:MoveTo(humanoidRootPart12.Position + unit3 * 6)
															humanoid5 = parent:FindFirstChildOfClass("Humanoid")

															if humanoid5 then
																jumpPower2 = humanoid5.JumpPower
																humanoid5.JumpPower = config2.UnstuckJumpPower or 10
																humanoid5.Jump = true
																local v91 = humanoid5
																local jumpPower3 = jumpPower2
																task.defer(function()
																	if v91 and v91.Parent then
																		v91.JumpPower = jumpPower3
																	end
																end)
															end
														end

														task.wait(0.15)

														if not (parent and parent.Parent and humanoidRootPart12 and humanoidRootPart12.Parent) then
															break
														end

														if (humanoidRootPart12.Position - position9).Magnitude < 0.5 then
															now2 = tick()

															if not v32[parent] or now2 - v32[parent] > 5 then
																if isDebugEnabled() then
																	local v91 = humanoidRootPart12
																	local v92 = i
																	local v93 = waypoint
																	pcall(function()
																		warn(
																			parent.Name,
																			"gave up pathfinding - truly stuck at",
																			string.format(
																				"(%.1f, %.1f, %.1f)",
																				v91.Position.X,
																				v91.Position.Y,
																				v91.Position.Z
																			),
																			"trying to reach waypoint",
																			v92,
																			"at",
																			string.format(
																				"(%.1f, %.1f, %.1f)",
																				v93.Position.X,
																				v93.Position.Y,
																				v93.Position.Z
																			)
																		)
																	end)
																end

																v32[parent] = now2
															end

															task.wait(0.5)
														end
													end
												end
											end

											v60 += 1
										end
									end
								else
									v60 += 1
								end
							end

							if config2.OnGoalReached then
								pcall(function()
									config2.OnGoalReached(parent, instance)
								end)
							end
						end
					elseif not parent:GetAttribute("LostInterest") then
						parent:SetAttribute("LostInterest", true)
						AINew.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
						task.delay(1, function()
							parent:SetAttribute("LostInterest", false)
						end)
					end
				else
					assemblyLinearVelocity2 = humanoidRootPart and humanoidRootPart.AssemblyLinearVelocity or createVector(
						0,
						0,
						0
					)
					position13 = position2 or humanoidRootPart and humanoidRootPart.Position or createVector(0, 0, 0)
					position14 = position or createVector(0, 0, 0)
					v76 = v21[parent]

					if isDebugEnabled() then
						magnitude6 = position and humanoidRootPart and (humanoidRootPart.Position - position).Magnitude or -1
						magnitude7 = Vector3.new(assemblyLinearVelocity2.X, 0, assemblyLinearVelocity2.Z).Magnitude
						v77 = not v76 and "none" or string.format("%.1fs", os.clock() - v76.time) or "none"
						v78 = not v76 and 0 or #v76.waypoints or 0
						warn(string.format(
							"[AINew PATH_FAIL] %s: status=%s dist=%.1f vel=%.1f target=%s tracking=%s",
							parent.Name,
							tostring(path.Status),
							magnitude6,
							magnitude7,
							instance and instance.Name or "nil",
							(tostring(v34.Tracking))
						))
						warn(string.format(
							"  from=(%.0f,%.0f,%.0f) to=(%.0f,%.0f,%.0f) agent=%.1f/%.1f cache=%s(%dwp)",
							position13.X,
							position13.Y,
							position13.Z,
							position14.X,
							position14.Y,
							position14.Z,
							config2.AgentRadius,
							config2.AgentHeight,
							v77,
							v78
						))
					end

					if isDebugEnabled() then
						parent2 = workspace:FindFirstChild("_PathFailDebug")

						if not parent2 then
							parent2 = Instance.new("Folder")
							parent2.Name = "_PathFailDebug"
							parent2.Parent = workspace
						end

						getOrCreateMarker = function(name, color, p3)
							local v92 = parent2:FindFirstChild(name)

							if not v92 then
								v92 = Instance.new("Part")
								v92.Name = name
								v92.Shape = Enum.PartType.Ball
								v92.Size = p3 or createVector(2, 2, 2)
								v92.Anchored = true
								v92.CanCollide = false
								v92.CanQuery = false
								v92.Material = Enum.Material.Neon
								v92.Color = color
								v92.Parent = parent2
							end

							v92.Transparency = 0.3
							return v92
						end

						v80 = getOrCreateMarker(parent.Name .. "_FailStart", Color3.fromRGB(255, 0, 0))
						v80.Position = position13
						v81 = getOrCreateMarker(parent.Name .. "_FailTarget", Color3.fromRGB(255, 255, 0))
						v81.Position = position14
						now3 = os.clock()
						v80:SetAttribute("_FadeToken", now3)
						v81:SetAttribute("_FadeToken", now3)
						task.delay(3, function()
							if v80 and v80.Parent and v80:GetAttribute("_FadeToken") == now3 then
								v80.Transparency = 1
							end

							if v81 and v81.Parent and v81:GetAttribute("_FadeToken") == now3 then
								v81.Transparency = 1
							end
						end)
					end

					if config2.OnPathingFailed then
						pcall(function()
							config2.OnPathingFailed(parent, instance)
						end)
					end

					if v34.Tracking and v76 and os.clock() - v76.time < 8 and v76.target == instance and #v76.waypoints > 1 and humanoid and humanoidRootPart then
						position10 = humanoidRootPart.Position
						v82 = 1e999
						v83 = 1

						for i = 1, #v76.waypoints do
							magnitude8 = (v76.waypoints[i].Position - position10).Magnitude

							if not (magnitude8 < v82) then
								continue
							end

							v83 = i
							v82 = magnitude8
						end

						v84 = v83 + 1

						if v84 <= #v76.waypoints then
							position11 = v76.waypoints[v84].Position

							if isDebugEnabled() then
								warn(string.format(
									"  fallback=CACHED_NEXT wp#%d (%.0f,%.0f,%.0f) closest=#%d dist=%.1f",
									v84,
									position11.X,
									position11.Y,
									position11.Z,
									v83,
									(position11 - position10).Magnitude
								))
							end

							_PathFailDebug = isDebugEnabled() and workspace:FindFirstChild("_PathFailDebug")

							if _PathFailDebug then
								name2 = parent.Name .. "_Fallback"
								v86 = _PathFailDebug:FindFirstChild(name2)

								if not v86 then
									v86 = Instance.new("Part")
									v86.Name = name2
									v86.Shape = Enum.PartType.Ball
									v86.Size = createVector(1.5, 1.5, 1.5)
									v86.Anchored = true
									v86.CanCollide = false
									v86.CanQuery = false
									v86.Material = Enum.Material.Neon
									v86.Color = Color3.fromRGB(0, 255, 0)
									v86.Parent = _PathFailDebug
								end

								v86.Position = position11
								v86.Transparency = 0.3
								now4 = os.clock()
								v86:SetAttribute("_FadeToken", now4)
								task.delay(3, function()
									if v86 and v86.Parent and v86:GetAttribute("_FadeToken") == now4 then
										v86.Transparency = 1
									end
								end)
							end

							humanoid:MoveTo(position11)
							v76.time = os.clock()
							return true
						end
					end

					humanoidRootPart13 = v34.ForcePathfinding and humanoid and instance and instance:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart13 then
						humanoid:MoveTo(humanoidRootPart13.Position)
						humanoid.MoveToFinished:Wait()
						return true
					else
						humanoidRootPart14 = v34.Tracking and humanoid and humanoidRootPart and instance and instance:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart14 then
							if Vector3.new(assemblyLinearVelocity2.X, 0, assemblyLinearVelocity2.Z).Magnitude < 1 then
								if not v22[parent] then
									v22[parent] = os.clock()
								end

								v87 = os.clock() - v22[parent]

								if v87 > 0.5 then
									v88 = humanoidRootPart14.Position - humanoidRootPart.Position
									vector7 = Vector3.new(v88.X, 0, v88.Z)

									if vector7.Magnitude > 0.1 then
										vector8 = Vector3.new(-vector7.Unit.Z, 0, vector7.Unit.X)
										raycastParams6 = RaycastParams.new()
										raycastParams6.FilterType = Enum.RaycastFilterType.Exclude
										raycastParams6.FilterDescendantsInstances = { parent }
										raycastResult7 = workspace:Raycast(
											humanoidRootPart.Position,
											vector8 * 5,
											raycastParams6
										)
										raycastResult8 = workspace:Raycast(
											humanoidRootPart.Position,
											-vector8 * 5,
											raycastParams6
										)
										v89 = (raycastResult7 and raycastResult7.Distance or 5) >= (raycastResult8 and raycastResult8.Distance or 5) and vector8 or -vector8
										v90 = humanoidRootPart.Position + v89 * 4 + vector7.Unit * 2

										if isDebugEnabled() then
											warn(string.format(
												"  fallback=NUDGE stuck=%.1fs nudge=(%.0f,%.0f,%.0f)",
												v87,
												v90.X,
												v90.Y,
												v90.Z
											))
										end

										humanoid:MoveTo(v90)
										v22[parent] = os.clock()
										return false
									end
								end
							else
								v22[parent] = nil
							end

							humanoid:MoveTo(humanoidRootPart14.Position)
						elseif not parent:GetAttribute("LostInterest") then
							parent:SetAttribute("LostInterest", true)

							if parent.PrimaryPart then
								AINew.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
							end

							task.delay(1, function()
								if parent and parent.Parent then
									parent:SetAttribute("LostInterest", false)
								end
							end)
						end

						return false
					end
				end
			else
				local position12 = instance:FindFirstChild("HumanoidRootPart").Position

				if not v13[parent] then
					v13[parent] = createVector(1e999, 1e999, 1e999)
				end

				local v91 = v13[parent]

				if v91.Magnitude < 1e999 and (position12 - v91).Magnitude < 2 then
					return
				end

				v13[parent] = position12

				if not (humanoidRootPart and humanoidRootPart.Parent) then
					return false
				end

				position2 = humanoidRootPart.Position

				if humanoid then
					v36 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
					position2 = humanoidRootPart.Position - Vector3.new(0, v36, 0)
				end

				if instance:FindFirstChild("Humanoid") and instance:FindFirstChild("HumanoidRootPart") then
					humanoid2 = instance:FindFirstChild("Humanoid")
					humanoidRootPart3 = instance:FindFirstChild("HumanoidRootPart")

					if humanoid2 and humanoidRootPart3 then
						playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

						if playerFromCharacter then
							userId = playerFromCharacter.UserId
						else
							local decoyTag = instance:GetAttribute("DecoyTag") or instance:FindFirstChildOfClass("AnimationController") or instance:GetAttribute("IsBotCharacter")
						end

						if not position then
							vector2 = Vector3.new(0, -(humanoidRootPart3.Size.Y / 2 + humanoid2.HipHeight), 0)
							position = humanoidRootPart3.Position + vector2
						end

						path:ComputeAsync(position2, position)
					else
						if not (humanoidRootPart2 and humanoidRootPart2.Parent) then
							return false
						end

						path:ComputeAsync(position2, humanoidRootPart2.Position)
					end
				else
					if humanoidRootPart2 and humanoidRootPart2.Parent then
						position = humanoidRootPart2.Position
					else
						if not (instance and instance:IsA("BasePart")) then
							return false
						end

						position = instance.Position
					end

					path:ComputeAsync(position2, position)
				end

				waypoints = path:GetWaypoints()

				if v[parent] == false then
					print(string.format(
						"[AINew] %s: discarded stale path computed across an interrupt (stopped) — no MoveTo issued",
						parent.Name
					))
					return
				end

				if v34.Tracking == true then
					if instance:FindFirstChild("BoxAbilityActive") or instance:FindFirstChild("NoDandy") then
						v38 = "stealth"
					elseif instance:FindFirstChild("NoTarget") and not v34.NoTargetOverride then
						v38 = "NoTarget (smoke bomb)"
					else
						stats = instance:FindFirstChild("Stats")
						v38 = stats and stats:FindFirstChild("InElevator") and stats.InElevator.Value and "elevator" or v37
					end

					if v38 then
						print(string.format(
							"[AINew] %s: discarded stale path computed across an interrupt (%s) — no MoveTo issued",
							parent.Name,
							v38
						))
						return
					end

					chasingValue2 = parent:FindFirstChild("ChasingValue")

					if not chasingValue2 or chasingValue2.Value ~= instance then
						return
					end
				end

				v39 = not v34.Tracking and 0 or config2.WaypointSkipCountTracking or 3

				if waypoints and v39 < #waypoints and v39 > 0 then
					v40 = waypoints[v39 + 1]
					flag = true

					if v40 and humanoidRootPart then
						raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						model = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

						if model and model:FindFirstChild("Monsters") then
							raycastParams.FilterDescendantsInstances = model.Monsters:GetChildren()
						end

						v41 = v40.Position - humanoidRootPart.Position
						raycastResult = workspace:Raycast(humanoidRootPart.Position, v41, raycastParams)

						if raycastResult and raycastResult.Instance then
							flag = false
						end
					end

					if flag then
						v42 = {}

						for i = v39 + 1, #waypoints do
							table.insert(v42, waypoints[i])
						end

						waypoints = v42
					end
				end

				if path.Status == Enum.PathStatus.Success then
					if path.Status == Enum.PathStatus.Success then
						v20[parent] = "Pathfind"

						if v34.Tracking then
							v21[parent] = {
								time = os.clock(),
								waypoints = waypoints,
								target = instance
							}
						end

						if v34.Tracking then
							v43 = 2

							if not config2.PathfindingLinkReached and #waypoints > 2 and humanoidRootPart then
								v44 = waypoints[3]

								if v44 and v44.Action ~= Enum.PathWaypointAction.Custom then
									raycastParams2 = RaycastParams.new()
									raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
									children = { parent }
									model2 = workspace:FindFirstChild("CurrentRoom") and workspace.CurrentRoom:FindFirstChildOfClass("Model")

									if model2 and model2:FindFirstChild("Monsters") then
										for i, child in ipairs(model2.Monsters:GetChildren()) do
											table.insert(children, child)
										end
									end

									raycastParams2.FilterDescendantsInstances = children
									v45 = v44.Position - humanoidRootPart.Position
									raycastResult2 = workspace:Raycast(humanoidRootPart.Position, v45, raycastParams2)

									if not (raycastResult2 and raycastResult2.Instance) then
										v43 = 3
									end
								end
							end

							v46 = waypoints[v43]

							if v46 and v46.Action == Enum.PathWaypointAction.Custom then
								v47 = v24[parent] and os.clock() - v24[parent] or 1e999
								v48 = not humanoidRootPart and 0 or (humanoidRootPart.Position - v46.Position).Magnitude or 0

								if v47 < 1 then
									print(string.format(
										"[HopDiag] %s: ON COOLDOWN (%.1fs ago) dist=%.1f to wp#%d — skipping hop",
										parent.Name,
										v47,
										v48,
										v43
									))
								elseif v48 > 35 then
									print(string.format(
										"[HopDiag] %s: TOO FAR (%.1f > %d) to wp#%d — skipping hop",
										parent.Name,
										v48,
										35,
										v43
									))
								else
									print(string.format(
										"[HopDiag] %s: HOPPING dist=%.1f to wp#%d pos=(%.0f,%.0f,%.0f)",
										parent.Name,
										v48,
										v43,
										v46.Position.X,
										v46.Position.Y,
										v46.Position.Z
									))

									if config2.OnMovingToWaypoint then
										pcall(function()
											config2.OnMovingToWaypoint(parent, v46, "PathfindingLink")
										end)
									end

									if config2.PathfindingLinkReached then
										success, result = pcall(config2.PathfindingLinkReached, parent, v46)

										if not success then
											pcall(function()
												parent:SetAttribute("_HopInProgress", nil)
											end)
										end

										if success and result then
											v24[parent] = os.clock()
											v22[parent] = nil
											print(string.format("[HopDiag] %s: HOP OK — landed", parent.Name))
											return
										elseif success then
											print(string.format("[HopDiag] %s: HOP RETURNED FALSE", parent.Name))
										else
											print(string.format(
												"[HopDiag] %s: HOP ERROR: %s",
												parent.Name,
												(tostring(result))
											))
										end
									else
										humanoidRootPart4 = parent:FindFirstChild("HumanoidRootPart")

										if humanoidRootPart4 then
											v49 = getGroundedPosition(v46.Position, { parent, instance }, 5)
											humanoidRootPart4.CFrame = CFrame.new(v49 + Vector3.new(
												0,
												humanoidRootPart4.Size.Y / 2 + humanoid.HipHeight,
												0
											))
										end
									end

									v24[parent] = os.clock()
								end

								v22[parent] = nil
							else
								if v46 then
									position3 = getGroundedPosition(v46.Position, { parent, instance }, 5)
								elseif #waypoints >= 2 and waypoints[2] then
									position3 = getGroundedPosition(waypoints[2].Position, { parent, instance }, 5)
								elseif instance and instance:FindFirstChild("HumanoidRootPart") then
									position3 = instance.HumanoidRootPart.Position
								end

								if humanoidRootPart and humanoid then
									assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
									magnitude = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude

									if magnitude < 1 then
										if not v22[parent] then
											v22[parent] = os.clock()
										end

										v50 = os.clock() - v22[parent]

										if v50 > 0.5 and position3 then
											v51 = position3 - humanoidRootPart.Position
											vector3 = Vector3.new(v51.X, 0, v51.Z)

											if vector3.Magnitude > 0.1 then
												vector4 = Vector3.new(-vector3.Unit.Z, 0, vector3.Unit.X)
												raycastParams3 = RaycastParams.new()
												raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
												raycastParams3.FilterDescendantsInstances = { parent }
												raycastResult3 = workspace:Raycast(
													humanoidRootPart.Position,
													vector4 * 5,
													raycastParams3
												)
												raycastResult4 = workspace:Raycast(
													humanoidRootPart.Position,
													-vector4 * 5,
													raycastParams3
												)
												v52 = (raycastResult3 and raycastResult3.Distance or 5) >= (raycastResult4 and raycastResult4.Distance or 5) and vector4 or -vector4
												position3 = humanoidRootPart.Position + v52 * 4 + vector3.Unit * 2

												if isDebugEnabled() then
													warn(string.format(
														"[AINew] %s: Pathfind STALL nudge stuck=%.1fs nudge=(%.0f,%.0f,%.0f)",
														parent.Name,
														v50,
														position3.X,
														position3.Y,
														position3.Z
													))
												end

												v22[parent] = os.clock()
											end
										end

										if magnitude < humanoid.WalkSpeed * 0.2 and isDebugEnabled() then
											humanoidRootPart5 = instance and instance:FindFirstChild("HumanoidRootPart")
											magnitude2 = humanoidRootPart5 and (humanoidRootPart.Position - humanoidRootPart5.Position).Magnitude or -1
											position4 = humanoidRootPart.Position
											warn(string.format(
												"[AINew STALL] %s: vel=%.1f wpCount=%d wpIdx=%d distToTarget=%.1f moveToPos=%s",
												parent.Name,
												magnitude,
												#waypoints,
												v43,
												magnitude2,
												not position3 and "nil" or string.format(
													"(%.0f,%.0f,%.0f)",
													position3.X,
													position3.Y,
													position3.Z
												) or "nil"
											))

											for i = 1, math.min(#waypoints, 8) do
												v53 = waypoints[i]
												magnitude3 = (v53.Position - position4).Magnitude
												warn(string.format(
													"  wp#%d (%.0f,%.0f,%.0f) dist=%.1f action=%s",
													i,
													v53.Position.X,
													v53.Position.Y,
													v53.Position.Z,
													magnitude3,
													(tostring(v53.Action))
												))
											end
										end
									else
										v22[parent] = nil
									end
								end

								if position3 then
									if config2.OnMovingToWaypoint and v46 then
										pcall(function()
											config2.OnMovingToWaypoint(parent, v46, "Pathfind")
										end)
									end

									if config2.TurnSpeedPenaltyEnabled and v34.Tracking and humanoidRootPart then
										v54 = position3 - humanoidRootPart.Position
										vector5 = Vector3.new(v54.X, 0, v54.Z)

										if vector5.Magnitude > 0.01 then
											unit = vector5.Unit
											now = os.clock()

											if not v27[parent] then
												v27[parent] = unit
												v28[parent] = now
											end

											v55 = unit:Dot(v27[parent])
											turnSpeedPenaltyThreshold = config2.TurnSpeedPenaltyThreshold or 0.7

											if v55 < turnSpeedPenaltyThreshold then
												v56 = 1 - math.clamp(
													(turnSpeedPenaltyThreshold - v55) / turnSpeedPenaltyThreshold,
													0,
													1
												) * (1 - (config2.TurnSpeedPenaltyMin or 0.6))
												v57 = v29[parent] or 1
												v29[parent] = math.min(v57, v56)
												turnSpeedPenaltyHoldTime = config2.TurnSpeedPenaltyHoldTime or 0.8
												v31[parent] = now + turnSpeedPenaltyHoldTime
											end

											if now - (v28[parent] or 0) >= 0.4 then
												v27[parent] = unit
												v28[parent] = now
											end
										end
									end

									if config2.TurnSpeedPenaltyEnabled and v34.Tracking then
										v58 = v30[parent]

										if v58 and v58 < 1 then
											humanoid.WalkSpeed /= v58
										end

										v59 = v29[parent] or 1

										if v59 < 1 then
											humanoid.WalkSpeed *= v59
										end

										v30[parent] = v59

										if v59 < 0.95 and isDebugEnabled() then
											print(string.format(
												"[AINew TurnPenalty] %s: Pathfind penalty=%.2f speed=%.1f",
												parent.Name,
												v59,
												humanoid.WalkSpeed
											))
										end
									end

									humanoid:MoveTo(position3)

									if shouldJump(parent, instance) then
										humanoid3 = parent:FindFirstChildOfClass("Humanoid")

										if not humanoid3 then
											return
										end

										jumpPower = humanoid3.JumpPower
										humanoid3.JumpPower = config2.UnstuckJumpPower or 10
										humanoid3.Jump = true
										task.defer(function()
											if humanoid3 and humanoid3.Parent then
												humanoid3.JumpPower = jumpPower
											end
										end)
									end
								end
							end
						else
							v60 = 1
							count2 += 1
							v61 = count2
							v[parent] = v61

							if p2.Visualize then
								folder = Instance.new("Folder")
								folder.Parent = parent
								folder.Name = "Waypoints"

								for k, waypoint in pairs(waypoints) do
									part = Instance.new("Part")
									part.Shape = Enum.PartType.Ball
									part.Color = Color3.new(0.384314, 0.341176, 1)
									part.Material = Enum.Material.Neon
									part.CFrame = CFrame.new(waypoint.Position)
									part.Parent = folder
									part.Name = k
									part.Anchored = true
									part.Size = createVector(1, 1, 1)
									part.CanCollide = false
								end
							end

							for i, waypoint in ipairs(waypoints) do
								if i > 1 then
									if humanoid.WalkSpeed == 0 then
										break
									end

									if #waypoints < v60 or v[parent] ~= v61 then
										if v[parent] ~= false then
											v62 = parent
											reset(v62) -- equivalent call inferred; original call site unknown
										end

										return
									else
										if waypoint.Action == Enum.PathWaypointAction.Jump and config2.JumpOnWaypoint then
											humanoid.Jump = true
										end

										if v34.Tracking == true and chasingValue.Value ~= instance then
											return
										end

										v63 = getGroundedPosition(waypoint.Position, { parent, instance }, 5)
										humanoidRootPart6 = parent:FindFirstChild("HumanoidRootPart")

										if not humanoidRootPart6 then
											break
										end

										if v34.Tracking and instance then
											humanoidRootPart7 = nil

											if typeof(instance) == "Instance" then
												if instance:IsA("Model") then
													humanoidRootPart7 = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
												elseif instance:IsA("BasePart") then
													humanoidRootPart7 = instance
												end
											end

											if humanoidRootPart7 then
												magnitude4 = (v63 - humanoidRootPart6.Position).Magnitude

												if (humanoidRootPart7.Position - humanoidRootPart6.Position).Magnitude < magnitude4 * 0.7 then
													break
												end

												if position then
													position5 = humanoidRootPart7.Position

													if (position5 - Vector3.new(position.X, position5.Y, position.Z)).Magnitude > 5 then
														break
													end
												end
											end
										end

										if waypoint.Action == Enum.PathWaypointAction.Custom then
											if config2.OnMovingToWaypoint then
												local v92 = waypoint
												pcall(function()
													config2.OnMovingToWaypoint(parent, v92, "PathfindingLink")
												end)
											end

											if config2.PathfindingLinkReached then
												humanoidRootPart8 = parent:FindFirstChild("HumanoidRootPart")
												v64 = not humanoidRootPart8 and 0 or (humanoidRootPart8.Position - waypoint.Position).Magnitude or 0

												if v64 > 35 then
													warn(string.format(
														"[AINew] %s: Skipping hop — waypoint too far (%.1f studs)",
														parent.Name,
														v64
													))
												else
													success2, result2 = pcall(
														config2.PathfindingLinkReached,
														parent,
														waypoint
													)

													if not (success2 and result2) and not success2 then
														warn(string.format(
															"[AINew] %s: PathfindingLinkReached error: %s",
															parent.Name,
															(tostring(result2))
														))
													end
												end
											else
												humanoidRootPart9 = parent:FindFirstChild("HumanoidRootPart")

												if humanoidRootPart9 then
													humanoidRootPart9.CFrame = CFrame.new(v63 + Vector3.new(
														0,
														humanoidRootPart9.Size.Y / 2 + humanoid.HipHeight,
														0
													))
												end
											end
										else
											humanoidRootPart10 = parent:FindFirstChild("HumanoidRootPart")

											if not humanoidRootPart10 then
												break
											end

											v65 = v63 - humanoidRootPart10.Position
											magnitude5 = v65.Magnitude

											if magnitude5 > 1 then
												raycastParams4 = RaycastParams.new()
												raycastParams4.FilterType = Enum.RaycastFilterType.Exclude
												raycastParams4.FilterDescendantsInstances = { parent, instance }
												v66 = math.min(magnitude5, 8)
												raycastResult5 = workspace:Raycast(
													humanoidRootPart10.Position + createVector(0, 2, 0),
													v65.Unit * v66,
													raycastParams4
												)
												instance2 = raycastResult5 and raycastResult5.Distance < v66 - 1 and raycastResult5.Instance

												if instance2 then
													v67 = instance2.Name:match("Generator") or instance2.Parent and instance2.Parent.Name:match("Generator")
													humanoid4 = instance2.Parent and instance2.Parent:FindFirstChild("Humanoid")

													if CollectionService:HasTag(instance2, "Wall") or CollectionService:HasTag(
														instance2,
														"Obstacle"
													) or instance2.CanCollide and not (v67 or humanoid4) then
														continue
													end
												end
											end

											if config2.OnMovingToWaypoint then
												local v92 = waypoint
												pcall(function()
													config2.OnMovingToWaypoint(parent, v92, "Pathfind")
												end)
											end

											humanoid:MoveTo(v63)
											humanoidRootPart11 = parent:FindFirstChild("HumanoidRootPart")

											if not humanoidRootPart11 then
												break
											end

											position6 = humanoidRootPart11.Position
											v68 = not v34.Tracking
											v69 = false

											if v68 then
												v69 = humanoid.MoveToFinished:Wait()
											else
												lastTime = tick()
												heartbeatConnection = nil
												count4 = 0
												position7 = humanoidRootPart11.Position
												moveToFinishedConnection = nil
												moveToFinishedConnection = humanoid.MoveToFinished:Connect(function(p3)
													v69 = p3

													if moveToFinishedConnection then
														moveToFinishedConnection:Disconnect()
													end

													if heartbeatConnection then
														heartbeatConnection:Disconnect()
													end
												end)
												RunService2 = game:GetService("RunService")
												local v92 = humanoidRootPart11
												local v93 = lastTime
												heartbeatConnection = RunService2.Heartbeat:Connect(function()
													count4 += 1

													if count4 % 9 == 0 then
														local position122 = v92.Position
														local assemblyLinearVelocity3 = v92.AssemblyLinearVelocity
														local magnitude9 = Vector3.new(
															assemblyLinearVelocity3.X,
															0,
															assemblyLinearVelocity3.Z
														).Magnitude
														local magnitude10 = (position122 - position7).Magnitude

														if not parent:GetAttribute("UsingAbility") and (not parent:FindFirstChild("Grabbing") or parent.Grabbing.Value ~= true) and magnitude9 < 0.5 and magnitude10 < 0.3 and tick() - v93 > 0.3 then
															v69 = false

															if moveToFinishedConnection then
																moveToFinishedConnection:Disconnect()
															end

															if heartbeatConnection then
																heartbeatConnection:Disconnect()
															end
														end

														position7 = position122
													end
												end)

												while not v69 and tick() - lastTime < 1.5 do
													task.wait(0.05)

													if parent:GetAttribute("UsingAbility") or not (not parent:FindFirstChild("Grabbing") or parent.Grabbing.Value ~= true) or not ((humanoidRootPart11.Position - position6).Magnitude < 0.1) then
														continue
													end

													if not (tick() - lastTime > 0.4) then
														continue
													end

													if moveToFinishedConnection then
														moveToFinishedConnection:Disconnect()
													end

													if not heartbeatConnection then
														break
													end

													heartbeatConnection:Disconnect()
													break
												end

												if moveToFinishedConnection then
													moveToFinishedConnection:Disconnect()
												end

												if heartbeatConnection then
													heartbeatConnection:Disconnect()
												end
											end

											if v69 and config2.OnWaypointReached then
												local v92 = waypoint
												pcall(function()
													config2.OnWaypointReached(parent, v92)
												end)
											end

											if v69 then
												onWaypointReached = parent:FindFirstChild("OnWaypointReached")

												if onWaypointReached and onWaypointReached:IsA("BindableEvent") then
													onWaypointReached:Fire(i, waypoint)
												end
											else
												v70 = false

												if config2.OnStuck then
													success3, result3 = pcall(function()
														return config2.OnStuck(parent, instance)
													end)
													v70 = success3 and result3 == true and true or false
												end

												if not v70 then
													humanoidRootPart12 = parent:FindFirstChild("HumanoidRootPart")

													if not humanoidRootPart12 then
														break
													end

													cFrame = humanoidRootPart12.CFrame
													v71 = false
													count5 = 0

													while not v71 and count5 < 3 do
														count5 += 1
														position8 = humanoidRootPart12.Position
														unit2 = nil
														raycastParams5 = RaycastParams.new()
														raycastParams5.FilterDescendantsInstances = { parent, instance }
														raycastParams5.FilterType = Enum.RaycastFilterType.Exclude

														if count5 == 1 then
															v72 = cFrame.RightVector * (math.random() > 0.5 and 1 or -1)
															v73 = -cFrame.LookVector
															unit2 = (v72 + v73 * 0.4).Unit
															raycastResult6 = workspace:Raycast(
																humanoidRootPart12.Position + createVector(0, 2, 0),
																unit2 * 5,
																raycastParams5
															)

															if raycastResult6 and raycastResult6.Distance < 2 then
																unit2 = (-v72 + v73 * 0.4).Unit
															end
														elseif count5 == 2 then
															unit2 = (cFrame.RightVector * (math.random() > 0.5 and -1 or 1) + cFrame.LookVector * 0.5).Unit
														elseif count5 == 3 then
															unit2 = (-cFrame.LookVector + cFrame.RightVector * (math.random() > 0.5 and 1 or -1) * 0.7).Unit
														end

														humanoid:MoveTo(cFrame.Position + unit2 * 3)
														task.wait(0.12)
														v71 = (humanoidRootPart12.Position - position8).Magnitude > 0.8 or v71
													end

													if not v71 then
														position9 = humanoidRootPart12.Position
														vector6 = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))

														if vector6.Magnitude > 0 then
															unit3 = vector6.Unit
															humanoid:MoveTo(humanoidRootPart12.Position + unit3 * 6)
															humanoid5 = parent:FindFirstChildOfClass("Humanoid")

															if humanoid5 then
																jumpPower2 = humanoid5.JumpPower
																humanoid5.JumpPower = config2.UnstuckJumpPower or 10
																humanoid5.Jump = true
																local v92 = humanoid5
																local jumpPower3 = jumpPower2
																task.defer(function()
																	if v92 and v92.Parent then
																		v92.JumpPower = jumpPower3
																	end
																end)
															end
														end

														task.wait(0.15)

														if not (parent and parent.Parent and humanoidRootPart12 and humanoidRootPart12.Parent) then
															break
														end

														if (humanoidRootPart12.Position - position9).Magnitude < 0.5 then
															now2 = tick()

															if not v32[parent] or now2 - v32[parent] > 5 then
																if isDebugEnabled() then
																	local v92 = humanoidRootPart12
																	local v93 = i
																	local v94 = waypoint
																	pcall(function()
																		warn(
																			parent.Name,
																			"gave up pathfinding - truly stuck at",
																			string.format(
																				"(%.1f, %.1f, %.1f)",
																				v92.Position.X,
																				v92.Position.Y,
																				v92.Position.Z
																			),
																			"trying to reach waypoint",
																			v93,
																			"at",
																			string.format(
																				"(%.1f, %.1f, %.1f)",
																				v94.Position.X,
																				v94.Position.Y,
																				v94.Position.Z
																			)
																		)
																	end)
																end

																v32[parent] = now2
															end

															task.wait(0.5)
														end
													end
												end
											end

											v60 += 1
										end
									end
								else
									v60 += 1
								end
							end

							if config2.OnGoalReached then
								pcall(function()
									config2.OnGoalReached(parent, instance)
								end)
							end
						end
					elseif not parent:GetAttribute("LostInterest") then
						parent:SetAttribute("LostInterest", true)
						AINew.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
						task.delay(1, function()
							parent:SetAttribute("LostInterest", false)
						end)
					end
				else
					assemblyLinearVelocity2 = humanoidRootPart and humanoidRootPart.AssemblyLinearVelocity or createVector(
						0,
						0,
						0
					)
					position13 = position2 or humanoidRootPart and humanoidRootPart.Position or createVector(0, 0, 0)
					position14 = position or createVector(0, 0, 0)
					v76 = v21[parent]

					if isDebugEnabled() then
						magnitude6 = position and humanoidRootPart and (humanoidRootPart.Position - position).Magnitude or -1
						magnitude7 = Vector3.new(assemblyLinearVelocity2.X, 0, assemblyLinearVelocity2.Z).Magnitude
						v77 = not v76 and "none" or string.format("%.1fs", os.clock() - v76.time) or "none"
						v78 = not v76 and 0 or #v76.waypoints or 0
						warn(string.format(
							"[AINew PATH_FAIL] %s: status=%s dist=%.1f vel=%.1f target=%s tracking=%s",
							parent.Name,
							tostring(path.Status),
							magnitude6,
							magnitude7,
							instance and instance.Name or "nil",
							(tostring(v34.Tracking))
						))
						warn(string.format(
							"  from=(%.0f,%.0f,%.0f) to=(%.0f,%.0f,%.0f) agent=%.1f/%.1f cache=%s(%dwp)",
							position13.X,
							position13.Y,
							position13.Z,
							position14.X,
							position14.Y,
							position14.Z,
							config2.AgentRadius,
							config2.AgentHeight,
							v77,
							v78
						))
					end

					if isDebugEnabled() then
						parent2 = workspace:FindFirstChild("_PathFailDebug")

						if not parent2 then
							parent2 = Instance.new("Folder")
							parent2.Name = "_PathFailDebug"
							parent2.Parent = workspace
						end

						getOrCreateMarker = function(name, color, p3)
							local v92 = parent2:FindFirstChild(name)

							if not v92 then
								v92 = Instance.new("Part")
								v92.Name = name
								v92.Shape = Enum.PartType.Ball
								v92.Size = p3 or createVector(2, 2, 2)
								v92.Anchored = true
								v92.CanCollide = false
								v92.CanQuery = false
								v92.Material = Enum.Material.Neon
								v92.Color = color
								v92.Parent = parent2
							end

							v92.Transparency = 0.3
							return v92
						end

						v80 = getOrCreateMarker(parent.Name .. "_FailStart", Color3.fromRGB(255, 0, 0))
						v80.Position = position13
						v81 = getOrCreateMarker(parent.Name .. "_FailTarget", Color3.fromRGB(255, 255, 0))
						v81.Position = position14
						now3 = os.clock()
						v80:SetAttribute("_FadeToken", now3)
						v81:SetAttribute("_FadeToken", now3)
						task.delay(3, function()
							if v80 and v80.Parent and v80:GetAttribute("_FadeToken") == now3 then
								v80.Transparency = 1
							end

							if v81 and v81.Parent and v81:GetAttribute("_FadeToken") == now3 then
								v81.Transparency = 1
							end
						end)
					end

					if config2.OnPathingFailed then
						pcall(function()
							config2.OnPathingFailed(parent, instance)
						end)
					end

					if v34.Tracking and v76 and os.clock() - v76.time < 8 and v76.target == instance and #v76.waypoints > 1 and humanoid and humanoidRootPart then
						position10 = humanoidRootPart.Position
						v82 = 1e999
						v83 = 1

						for i = 1, #v76.waypoints do
							magnitude8 = (v76.waypoints[i].Position - position10).Magnitude

							if not (magnitude8 < v82) then
								continue
							end

							v83 = i
							v82 = magnitude8
						end

						v84 = v83 + 1

						if v84 <= #v76.waypoints then
							position11 = v76.waypoints[v84].Position

							if isDebugEnabled() then
								warn(string.format(
									"  fallback=CACHED_NEXT wp#%d (%.0f,%.0f,%.0f) closest=#%d dist=%.1f",
									v84,
									position11.X,
									position11.Y,
									position11.Z,
									v83,
									(position11 - position10).Magnitude
								))
							end

							_PathFailDebug = isDebugEnabled() and workspace:FindFirstChild("_PathFailDebug")

							if _PathFailDebug then
								name2 = parent.Name .. "_Fallback"
								v86 = _PathFailDebug:FindFirstChild(name2)

								if not v86 then
									v86 = Instance.new("Part")
									v86.Name = name2
									v86.Shape = Enum.PartType.Ball
									v86.Size = createVector(1.5, 1.5, 1.5)
									v86.Anchored = true
									v86.CanCollide = false
									v86.CanQuery = false
									v86.Material = Enum.Material.Neon
									v86.Color = Color3.fromRGB(0, 255, 0)
									v86.Parent = _PathFailDebug
								end

								v86.Position = position11
								v86.Transparency = 0.3
								now4 = os.clock()
								v86:SetAttribute("_FadeToken", now4)
								task.delay(3, function()
									if v86 and v86.Parent and v86:GetAttribute("_FadeToken") == now4 then
										v86.Transparency = 1
									end
								end)
							end

							humanoid:MoveTo(position11)
							v76.time = os.clock()
							return true
						end
					end

					humanoidRootPart13 = v34.ForcePathfinding and humanoid and instance and instance:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart13 then
						humanoid:MoveTo(humanoidRootPart13.Position)
						humanoid.MoveToFinished:Wait()
						return true
					else
						humanoidRootPart14 = v34.Tracking and humanoid and humanoidRootPart and instance and instance:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart14 then
							if Vector3.new(assemblyLinearVelocity2.X, 0, assemblyLinearVelocity2.Z).Magnitude < 1 then
								if not v22[parent] then
									v22[parent] = os.clock()
								end

								v87 = os.clock() - v22[parent]

								if v87 > 0.5 then
									v88 = humanoidRootPart14.Position - humanoidRootPart.Position
									vector7 = Vector3.new(v88.X, 0, v88.Z)

									if vector7.Magnitude > 0.1 then
										vector8 = Vector3.new(-vector7.Unit.Z, 0, vector7.Unit.X)
										raycastParams6 = RaycastParams.new()
										raycastParams6.FilterType = Enum.RaycastFilterType.Exclude
										raycastParams6.FilterDescendantsInstances = { parent }
										raycastResult7 = workspace:Raycast(
											humanoidRootPart.Position,
											vector8 * 5,
											raycastParams6
										)
										raycastResult8 = workspace:Raycast(
											humanoidRootPart.Position,
											-vector8 * 5,
											raycastParams6
										)
										v89 = (raycastResult7 and raycastResult7.Distance or 5) >= (raycastResult8 and raycastResult8.Distance or 5) and vector8 or -vector8
										v90 = humanoidRootPart.Position + v89 * 4 + vector7.Unit * 2

										if isDebugEnabled() then
											warn(string.format(
												"  fallback=NUDGE stuck=%.1fs nudge=(%.0f,%.0f,%.0f)",
												v87,
												v90.X,
												v90.Y,
												v90.Z
											))
										end

										humanoid:MoveTo(v90)
										v22[parent] = os.clock()
										return false
									end
								end
							else
								v22[parent] = nil
							end

							humanoid:MoveTo(humanoidRootPart14.Position)
						elseif not parent:GetAttribute("LostInterest") then
							parent:SetAttribute("LostInterest", true)

							if parent.PrimaryPart then
								AINew.Stuck(parent:FindFirstChild("Humanoid"), parent.PrimaryPart)
							end

							task.delay(1, function()
								if parent and parent.Parent then
									parent:SetAttribute("LostInterest", false)
								end
							end)
						end

						return false
					end
				end
			end
		end
	end

	if p or p == nil then
		v[parent] = "starting"

		if parent and parent.PrimaryPart then
			pcall(function()
				parent.PrimaryPart:SetNetworkOwner(nil)
			end)
		end

		if v34.Tracking == true then
			local v36 = {}
			v19[parent] = v36

			while v[parent] ~= false do
				if v19[parent] == v36 then
					if parent and parent.Parent and parent:FindFirstChild("HumanoidRootPart") then
						local chasingValue = parent:FindFirstChild("ChasingValue")

						if chasingValue and chasingValue.Value ~= instance then
							v[parent] = false

							if v19[parent] ~= v36 then
								break
							end

							v19[parent] = nil
							break
						else
							if v34.Visualize then
								destroyWP()
							end

							if v17[parent] then
								local v37 = v18[parent] or 0
								local v38 = os.clock() - v37

								if v38 > 2 then
									local humanoidRootPart3 = instance and instance:FindFirstChild("HumanoidRootPart")
									local humanoidRootPart4 = parent:FindFirstChild("HumanoidRootPart")
									local magnitude = humanoidRootPart3 and humanoidRootPart4 and (humanoidRootPart4.Position - humanoidRootPart3.Position).Magnitude or -1
									warn(string.format(
										"[AINew MUTEX_RESET] %s: stuck %.2fs, dist=%.1f - resetting",
										parent.Name,
										v38,
										magnitude
									))
									v17[parent] = false
								end
							end

							if not v17[parent] then
								v17[parent] = true
								v18[parent] = os.clock()
								spawn(function()
									local success, result = pcall(pathfind)

									if not success then
										warn(parent.Name .. " pathfind error:", result)
									end

									v17[parent] = false
								end)
							end

							task.wait()
						end
					else
						v[parent] = false
						v19[parent] = nil
						break
					end
				else
					local chasingValue = parent:FindFirstChild("ChasingValue")

					if not chasingValue or chasingValue.Value ~= instance then
						break
					end

					print(string.format(
						"[AINew] %s: superseded tracking loop on same target (%s) — stale-loop revival prevented",
						parent.Name,
						(tostring(instance))
					))
					break
				end
			end
		end

		if v34.Tracking == nil or v34.Tracking == false then
			if v34.Visualize then
				destroyWP()
			end

			pathfind()
		end
	end

	if not p then
		spawn(function()
			v[parent] = "starting"

			if v34.Tracking == true then
				local v36 = {}
				v19[parent] = v36

				while v[parent] ~= false do
					if v19[parent] == v36 then
						if parent and parent.Parent and parent:FindFirstChild("HumanoidRootPart") then
							local chasingValue = parent:FindFirstChild("ChasingValue")

							if chasingValue and chasingValue.Value ~= instance then
								v[parent] = false

								if v19[parent] ~= v36 then
									break
								end

								v19[parent] = nil
								break
							else
								if v34.Visualize then
									destroyWP()
								end

								if v17[parent] then
									local v37 = v18[parent] or 0
									local v38 = os.clock() - v37

									if v38 > 2 then
										local humanoidRootPart3 = instance and instance:FindFirstChild("HumanoidRootPart")
										local humanoidRootPart4 = parent:FindFirstChild("HumanoidRootPart")
										local magnitude = humanoidRootPart3 and humanoidRootPart4 and (humanoidRootPart4.Position - humanoidRootPart3.Position).Magnitude or -1
										warn(string.format(
											"[AINew MUTEX_RESET] %s: stuck %.2fs, dist=%.1f - resetting",
											parent.Name,
											v38,
											magnitude
										))
										v17[parent] = false
									end
								end

								if not v17[parent] then
									v17[parent] = true
									v18[parent] = os.clock()
									spawn(function()
										local success, result = pcall(pathfind)

										if not success then
											warn(parent.Name .. " pathfind error:", result)
										end

										v17[parent] = false
									end)
								end

								task.wait()
							end
						else
							v[parent] = false
							v19[parent] = nil
							break
						end
					else
						local chasingValue = parent:FindFirstChild("ChasingValue")

						if not chasingValue or chasingValue.Value ~= instance then
							break
						end

						print(string.format(
							"[AINew] %s: superseded tracking loop on same target (%s) — stale-loop revival prevented",
							parent.Name,
							(tostring(instance))
						))
						break
					end
				end
			end

			if v34.Tracking == nil or v34.Tracking == false then
				if v34.Visualize then
					destroyWP()
				end

				spawn(function()
					pcall(pathfind)
				end)
			end
		end)
	end

	if v34.Visualize then
		destroyWP()
	end
end

return AINew