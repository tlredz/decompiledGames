local createVector = vector.create
local YattaAbility = {}
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("PhysicsService")
game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local v = {
	{
		name = "SpeedCandy",
		weight = 1
	},
	{
		name = "StealthCandy",
		weight = 1
	},
	{
		name = "ExtractionSpeedCandy",
		weight = 1
	},
	{
		name = "StaminaCandy",
		weight = 1
	},
	{
		name = "SkillCheckCandy",
		weight = 1
	},
	{
		name = "Jawbreaker",
		weight = 1
	},
	{
		name = "Chocolate",
		weight = 1
	},
	{
		name = "ChocolateBox",
		weight = 0.5
	},
	{
		name = "Gumball",
		weight = 1
	}
}
local _ = {
	"SpeedCandy",
	"StealthCandy",
	"ExtractionSpeedCandy",
	"StaminaCandy",
	"SkillCheckCandy",
	"Jawbreaker",
	"Chocolate",
	"ChocolateBox"
}
local _ = {
	MACHINE_COMPLETE_COUNT = 2,
	INJURED_COUNT = 4,
	MIN_FORCE = 20,
	MAX_FORCE = 30,
	MAX_DISTANCE = 20,
	DROP_HEIGHT = 0.05,
	CURVE_INTENSITY = 2,
	TWEEN_TIME = 1.2,
	BURST_INTENSITY = 0.3,
	SPIN_INTENSITY = 8,
	MIN_SPIN = 3,
	MAX_SPIN = 8,
	MIN_CURVE = 1,
	MAX_CURVE = 3,
	WALL_CHECK_BUFFER = 0.5,
	FLOATING_CHECK_DISTANCE = 3
}
local v2 = {
	DURATION = 2,
	SOUND_IDS = { "rbxassetid://123425709463166", "rbxassetid://120250839291906" }
}

local function setupCandyParts(clone)
	local item = clone:FindFirstChild("Item")
	local prompt = clone:FindFirstChild("Prompt")

	if not (item and prompt) then
		warn("[YattaAbility] Candy model missing required parts!")
		return false
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = item
	weldConstraint.Part1 = prompt
	weldConstraint.Parent = item
	item.Anchored = true
	prompt.Anchored = true
	clone.PrimaryPart = item
	return true
end

local function spawnCandyItem(childName, model)
	local child = ReplicatedStorage.Items:FindFirstChild(childName)

	if not child then
		warn("[YattaAbility] Candy type not found:", childName)
		return nil
	end

	local clone = child:Clone()

	if not setupCandyParts(clone) then
		clone:Destroy()
		return nil
	end

	local clone_2 = ReplicatedStorage.Scripts.ItemScript:Clone()
	clone_2.Parent = clone

	if model and model:FindFirstChild("Items") then
		clone.Parent = model.Items
		return clone
	end

	clone.Parent = workspace
	return clone
end

local function findNearestItemSpawnPoint(p)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if not (model and model:FindFirstChild("ItemSpawnPoints")) then
		return nil
	end

	local children = model.ItemSpawnPoints:GetChildren()

	if #children == 0 then
		return nil
	end

	local v3 = 1e999
	local v4 = nil

	for _, v5 in ipairs(children) do
		local magnitude = (v5.Position - p).Magnitude

		if not (magnitude < v3) then
			continue
		end

		v4 = v5
		v3 = magnitude
	end

	return v4
end

local function findLandingSpot(p, value, instance, i, p2, data)
	findNearestItemSpawnPoint(p)
	local v3 = not (instance and instance.PrimaryPart) and 0 or instance.PrimaryPart.Size.Y / 2
	local CollectionService = game:GetService("CollectionService")
	local tagged = CollectionService:GetTagged("Generator")
	local v4 = false
	local v5 = nil
	local cframe = nil
	local count = 0
	local v6 = nil
	local unit = nil

	for _, model in ipairs(tagged) do
		if not (model:IsA("Model") and model.PrimaryPart and (model.PrimaryPart.Position - p).Magnitude < 10) then
			continue
		end

		unit = (model.PrimaryPart.Position - p).Unit
		v6 = model
		break
	end

	local v8 = i / p2 * 3.141592653589793 * 2

	if p2 == 1 then
		v8 = math.random() * 3.141592653589793 * 2
	end

	if data then
		v8 = math.atan2(data.direction.Z, data.direction.X) + (p2 == 1 and 0 or ((i - 0.5) / p2 - 0.5) * data.spread)
	elseif v6 and unit then
		v8 = math.atan2(unit.Z, unit.X) + 3.141592653589793 + (i / p2 - 0.5) * 3.141592653589793 + (math.random() - 0.5) * 0.2
	end

	local v9 = v8 + (math.random() - 0.5) * 0.5
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { instance }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true

	if #tagged > 0 then
		for _, v10 in ipairs(tagged) do
			table.insert(raycastParams.FilterDescendantsInstances, v10)
		end
	end

	if data and data.ignore then
		local filterDescendantsInstances = raycastParams.FilterDescendantsInstances

		for _, v10 in ipairs(data.ignore) do
			table.insert(filterDescendantsInstances, v10)
		end

		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	end

	local function isValidFloor(instance2)
		if instance2:GetAttribute("NoClip") or instance2:HasTag("NoClip") or not instance2.CanCollide then
			return false
		end

		if CollectionService:HasTag(instance2, "Generator") or instance2.Parent and CollectionService:HasTag(
			instance2.Parent,
			"Generator"
		) then
			return false
		end

		return true
	end

	local v10 = (data or not v6) and 5 or 10
	local v11 = v6 and 15 or 10
	local raycastParams2

	if data then
		raycastParams2 = RaycastParams.new()
		raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams2.IgnoreWater = true
		local filterDescendantsInstances = { instance }

		for _, v13 in ipairs(data.ignore or {}) do
			table.insert(filterDescendantsInstances, v13)
		end

		raycastParams2.FilterDescendantsInstances = filterDescendantsInstances
	end

	while not v4 and count < v11 do
		local v12 = math.random(v10, (math.max(v10, value)))
		local v13 = p + Vector3.new(math.cos(v9) * v12, 0, math.sin(v9) * v12)

		if raycastParams2 then
			local v14 = p + createVector(0, 1.5, 0)
			local raycastResult = Workspace:Raycast(v14, v13 + createVector(0, 1.5, 0) - v14, raycastParams2)

			if raycastResult then
				value = math.floor(raycastResult.Distance - 1)
				v13 = nil
			end
		end

		local raycastResult = v13 and Workspace:Raycast(
			v13 + createVector(0, 10, 0),
			createVector(0, -20, 0),
			raycastParams
		)

		if raycastResult and raycastResult.Instance and isValidFloor(raycastResult.Instance) then
			local v14 = raycastResult.Position + Vector3.new(0, v3 + 0.05, 0)
			local v15 = {
				createVector(1, 0, 0),
				createVector(-1, 0, 0),
				createVector(0, 0, 1),
				createVector(0, 0, -1),
				(createVector(1, 0, 1)).Unit,
				(createVector(1, 0, -1)).Unit,
				(createVector(-1, 0, 1)).Unit,
				(createVector(-1, 0, -1)).Unit
			}
			local v16 = false

			for _, v18 in ipairs(v15) do
				if not Workspace:Raycast(v14, v18 * 0.5, raycastParams) then
					continue
				end

				v16 = true
				break
			end

			if not v16 then
				local normal = raycastResult.Normal

				if normal:Cross(createVector(0, 0, 1)).Magnitude < 0.01 then
					normal:Cross(createVector(1, 0, 0))
				end

				local v18 = math.random() * 3.141592653589793 * 2
				cframe = CFrame.fromMatrix(
					v14,
					Vector3.new(math.cos(v18), 0, (math.sin(v18))),
					createVector(0, 1, 0),
					(Vector3.new(-math.sin(v18), 0, (math.cos(v18))))
				)
				v5 = v14
				v4 = true
			end
		end

		count += 1
	end

	if v5 then
		return v5, cframe, v9
	end

	local v12 = not data and 5 or math.clamp(value, 1, 5)
	v5 = p + Vector3.new(math.cos(v9) * v12, 0, math.sin(v9) * v12)
	local v13 = math.random() * 3.141592653589793 * 2
	cframe = CFrame.new(v5) * CFrame.Angles(0, v13, 0)
	return v5, cframe, v9
end

local function createPinataAnimation(folder, position, landingSpot, _, _, _, endCFrame)
	if not (folder and folder:FindFirstChild("Item")) then
		return
	end

	for _, proximityPrompt in ipairs(folder:GetDescendants()) do
		if proximityPrompt:IsA("ProximityPrompt") then
			proximityPrompt.Enabled = false
		end
	end

	local _ = (landingSpot - position).Magnitude
	local height = math.random(5, 10)
	local spinIntensity = math.random(3, 8)
	local curveIntensity = math.random(1, 3) / 10
	local initialRotY = math.random() * 3.141592653589793 * 2
	folder:PivotTo(CFrame.new(position) * CFrame.Angles(0, initialRotY, 0))
	local v7 = {
		startPos = position,
		endPos = landingSpot,
		startTime = tick(),
		duration = 1.2,
		height = height,
		direction = (landingSpot - position).Unit,
		rotAxis = Vector3.new(math.random(), math.random(), math.random()).Unit,
		spinIntensity = spinIntensity,
		curveIntensity = curveIntensity,
		endCFrame = endCFrame,
		initialRotY = initialRotY,
		uniqueOffset = Vector3.new(math.random(-5, 5) / 10, math.random(-5, 5) / 10, math.random(-5, 5) / 10)
	}
	task.spawn(function()
		local heartbeatConnection = nil
		local RunService = game:GetService("RunService")
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if folder and folder.Parent and folder:FindFirstChild("Item") and folder.Item.Parent then
				local v8 = math.min((tick() - v7.startTime) / v7.duration, 1)
				local v9 = 1 - (1 - v8) ^ 3

				if v8 >= 1 then
					heartbeatConnection:Disconnect()

					if v7.endCFrame then
						folder:PivotTo(v7.endCFrame)
						return
					end

					folder:PivotTo(CFrame.new(landingSpot) * CFrame.Angles(0, v7.initialRotY, 0))
				else
					local v10 = v7.height * math.sin(v8 * 3.141592653589793)
					local vector2 = Vector3.new(
						math.sin(v8 * 3.141592653589793 * 3) * v7.curveIntensity,
						0,
						math.cos(v8 * 3.141592653589793 * 2) * v7.curveIntensity
					)
					local vector3 = Vector3.new(
						math.sin(v8 * 3.141592653589793) * v7.curveIntensity * 2,
						0,
						math.cos(v8 * 3.141592653589793) * v7.curveIntensity
					)
					local v11 = v7.startPos:Lerp(v7.endPos, v9) + Vector3.new(0, v10, 0) + vector2 + vector3 + v7.uniqueOffset * (1 - v8)
					local cframe = CFrame.Angles(0, v7.initialRotY + v8 * v7.spinIntensity, 0)
					folder:PivotTo(CFrame.new(v11) * cframe)
				end
			elseif heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end)
	end)
end

local function selectRandomCandyWithRarity()
	local total = 0

	for _, v3 in ipairs(v) do
		total += v3.weight
	end

	local v3 = math.random() * total
	local total2 = 0

	for _, v4 in ipairs(v) do
		total2 += v4.weight

		if v3 <= total2 then
			return v4.name
		end
	end

	return v[1].name
end

local function createConfettiEffect(instance)
	if not (instance and instance:FindFirstChild("HumanoidRootPart")) then
		warn("[YattaAbility] Cannot create confetti effect: character or HumanoidRootPart not found")
		return
	end

	local _ = instance.HumanoidRootPart
	local v3 = { instance, v2.DURATION }

	if ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("RenderObject") then
		local confettiEffect = script.Parent.Parent.Parts.RenderModules.ConfettiEffect
		ReplicatedStorage.Events.RenderObject:FireAllClients(confettiEffect, v3)
	else
		warn("[YattaAbility] Cannot fire RenderObject event: Event not found")
	end
end

function YattaAbility.Init(instance)
	return {
		maxHealth = instance.Humanoid.MaxHealth,
		currentHealth = instance.Humanoid.Health,
		maxSpeedStars = 5,
		speedStat = 0,
		baseScaleMultiplier = 1,
		minScale = 0.6,
		maxScale = 1,
		currentScaleMultiplier = 1,
		healthSpeedMultiplier = 1
	}
end

function YattaAbility.DropCandy(instance, p, value, p2)
	local v4 = p or instance.PrimaryPart.Position
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if not model then
		warn("[YattaAbility] No map found for candy spawning!")
		return
	end

	local v5 = {}

	for _ = 1, value or 2 do
		local v7 = spawnCandyItem(selectRandomCandyWithRarity(), model)

		if v7 then
			table.insert(v5, v7)
		end
	end

	for i, v6 in ipairs(v5) do
		local v7 = instance.PrimaryPart.Size.Y / 2 + instance.Humanoid.HipHeight
		local v8 = v6.PrimaryPart.Size.Y / 2
		local startPos = instance.PrimaryPart.Position - Vector3.new(0, v7, 0) + Vector3.new(0, v8, 0)
		local v10 = math.random() * 3.141592653589793 * 2
		v6:PivotTo(CFrame.new(startPos) * CFrame.Angles(0, v10, 0))
		local landingSpot, endCFrame, v12 = findLandingSpot(v4, 20, v6, i, #v5, p2)
		createPinataAnimation(v6, startPos, landingSpot, v12, i, #v5, endCFrame)
		local folder = v6
		task.delay(1.3, function()
			if folder and folder:FindFirstChild("Item") and folder.Parent then
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { folder }
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.IgnoreWater = true

				-- equivalent calls inferred from this helper; original call sites unknown
				local function isValidFloor(instance2)
					if instance2:GetAttribute("NoClip") or instance2:HasTag("NoClip") then
						return false
					end

					if instance2.CanCollide then
						return true
					end

					return false
				end

				local position = folder.Item.Position
				local raycastResult = Workspace:Raycast(position, createVector(0, -3, 0), raycastParams)
				local v13 = false

				if raycastResult then
					if raycastResult then
						local validFloor = isValidFloor(raycastResult.Instance) -- equivalent call inferred; original call site unknown
						v13 = not validFloor or (position - raycastResult.Position).Magnitude > folder.Item.Size.Y + 0.1
					end
				else
					v13 = true
				end

				if v13 then
					local raycastResult2 = Workspace:Raycast(
						position + createVector(0, 1, 0),
						createVector(0, -20, 0),
						raycastParams
					)

					if raycastResult2 then
						-- equivalent call inferred; original call site unknown
						if isValidFloor(raycastResult2.Instance) then
							local v15 = raycastResult2.Position + Vector3.new(0, folder.Item.Size.Y / 2 + 0.05, 0)
							local Y = folder:GetPivot().Rotation.Y
							folder:PivotTo(CFrame.new(v15) * CFrame.Angles(0, Y, 0))
						end
					end
				end

				for i2, proximityPrompt in ipairs(folder:GetDescendants()) do
					if not proximityPrompt:IsA("ProximityPrompt") then
						continue
					end

					proximityPrompt.Enabled = true
					proximityPrompt.MaxActivationDistance = 12
				end
			end
		end)
	end

	createConfettiEffect(instance)

	if instance:FindFirstChild("Audio") and instance.Audio:FindFirstChild("CandyBurst") then
		instance.Audio.CandyBurst:Play()
	end
end

function YattaAbility.OnDamaged(instance, state, p)
	if p >= 0 then
		return state
	end

	if TowerLUT:HasPassive(instance, "Yatta") then
		YattaAbility.DropCandy(instance, instance.PrimaryPart.Position, 4)
	end

	local currentScaleMultiplier = math.clamp(
		state.baseScaleMultiplier * (1 - (state.maxHealth - state.currentHealth) / state.maxHealth * 0.3),
		state.minScale,
		state.maxScale
	)

	if currentScaleMultiplier ~= state.currentScaleMultiplier then
		state.currentScaleMultiplier = currentScaleMultiplier
	end

	return state
end

function YattaAbility.OnGeneratorComplete(instance)
	YattaAbility.DropCandy(instance, instance.PrimaryPart.Position, 2)
end

return YattaAbility