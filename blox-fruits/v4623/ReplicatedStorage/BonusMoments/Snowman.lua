local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local NPCInteractionConfig = require(game.ReplicatedStorage.NPCManager.NPCInteractionConfig)
local snowmanStackRemote = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SnowmanStackRemote")
local snowmanBallRemote = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SnowmanBallRemote")
local v = { "Brrr... I'm alive again! It's been quite a while since I last woke up. Thank you, friend!" }
local snowman_Placeholder = script:WaitForChild("Snowman_Placeholder")
local v2 = nil
local flag = false
local v3 = {}
local v4 = {}
local v5 = {}
local diameters = {}
local v6 = nil
local v7 = nil
local v8 = 0
local count = 0
local v9 = {}
local v10 = 0
local v11 = 0
local count2 = 0

local function sweepNamed(p: string)
	local nPCs = { workspace.NPCs, workspace.Terrain, game.ReplicatedStorage }
	local nPCs2 = game.ReplicatedStorage:FindFirstChild("NPCs")

	if nPCs2 then
		table.insert(nPCs, nPCs2)
	end

	for _, v12 in nPCs do
		for _, model in v12:GetChildren() do
			if model.Name == p and model:IsA("Model") then
				model:Destroy()
			end
		end
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true

local function snapToGround(cframe: CFrame)
	local children = {}

	for _, childName in { "NPCs", "Characters", "Enemies" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams.FilterDescendantsInstances = children
	local v12 = cframe.Position + createVector(0, 50, 0)
	local raycastResult = workspace:Raycast(v12, createVector(0, -300, 0), raycastParams)

	if raycastResult then
		return CFrame.new(raycastResult.Position) * cframe.Rotation, raycastResult.Normal
	end

	return cframe, createVector(0, 1, 0)
end

local function rayGroundY(vector2: Vector3, p: number)
	local children = {}

	for _, childName in { "NPCs", "Characters", "Enemies" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams.FilterDescendantsInstances = children
	local v12 = vector2 + createVector(0, 0.5, 0)
	local raycastResult = workspace:Raycast(v12, Vector3.new(0, -(p + 4 + 0.5), 0), raycastParams)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return nil
end

local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
raycastParams2.RespectCanCollide = true
raycastParams2.IgnoreWater = true

local function clampToObstruction(vector2: Vector3, vector3: Vector3, p: number)
	local children = {}

	for _, childName in { "NPCs", "Characters", "Enemies" } do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(children, child)
		end
	end

	raycastParams2.FilterDescendantsInstances = children
	local vector4 = Vector3.new(vector2.X, vector3.Y, vector2.Z)
	local vector5 = Vector3.new(vector3.X - vector4.X, 0, vector3.Z - vector4.Z)
	local magnitude = vector5.Magnitude

	if magnitude < 0.0001 then
		return vector3
	end

	local v12 = vector5 / magnitude
	local raycastResult = workspace:Raycast(vector4, v12 * (magnitude + p), raycastParams2)

	if raycastResult and math.abs(raycastResult.Normal.Y) < 0.5 then
		local v13 = vector4 + v12 * math.max(0, (raycastResult.Position - vector4).Magnitude - p)
		return (Vector3.new(v13.X, vector3.Y, v13.Z))
	else
		return vector3
	end
end

local v12 = nil
local Y = 1
local size = createVector(1, 1, 1)

local function getSnowballTemplate()
	if v12 then
		return v12
	end

	local snowball = script:FindFirstChild("Snowball")

	if snowball and snowball:IsA("BasePart") then
		local model = Instance.new("Model")
		model.Name = "PlacedSnowball"
		local clone = snowball:Clone()
		clone.Name = "Snowball"
		clone.Parent = model
		local snowballModel = script:FindFirstChild("SnowballModel")
		local snowball2

		if snowballModel then
			snowball2 = snowballModel:FindFirstChild("Snowball")
		end

		local emit

		if snowball2 then
			emit = snowball2:FindFirstChild("Emit")
		end

		if emit then
			local clone_2 = emit:Clone()
			clone_2.Parent = clone
		end

		model.PrimaryPart = clone
		v12 = model
		Y = clone.Size.Y
		size = clone.Size
		return v12
	else
		local snowballModel = script:FindFirstChild("SnowballModel")

		if snowballModel and snowballModel:IsA("Model") and snowballModel.PrimaryPart then
			v12 = snowballModel
			Y = snowballModel.PrimaryPart.Size.X
			size = snowballModel.PrimaryPart.Size
			return v12
		else
			local snowball1 = snowman_Placeholder:FindFirstChild("Snowball1")

			if not (snowball1 and snowball1:IsA("BasePart")) then
				return nil
			end

			local model = Instance.new("Model")
			model.Name = "PlacedSnowball"
			local clone = snowball1:Clone()
			clone.Name = "Snowball"
			clone.Size = Vector3.new(clone.Size.Y, clone.Size.Y, clone.Size.Y)
			clone.Parent = model
			model.PrimaryPart = clone
			v12 = model
			Y = clone.Size.X
			size = clone.Size
			return v12
		end
	end
end

local function prepFreeBall(folder)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyDiameter(instance, p: number)
	local primaryPart = instance.PrimaryPart

	if primaryPart then
		primaryPart.Size = size * (p / Y)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBallSize(p)
	applyDiameter(p.model, p.diameter) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function diameterOf(model)
	local primaryPart = model.PrimaryPart

	if primaryPart and not (size.Y <= 0) then
		return primaryPart.Size.Y / size.Y * Y
	end

	return 5
end

local function popEmit(folder)
	for _, attachment in folder:GetDescendants() do
		if not (attachment:IsA("Attachment") and attachment.Name == "Emit") then
			continue
		end

		local worldCFrame = attachment.WorldCFrame
		attachment.Parent = workspace.Terrain
		attachment.WorldCFrame = worldCFrame
		local v13 = 0

		for _, emitter in attachment:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			v13 = math.max(v13, emitter.Lifetime.Max)
		end

		task.delay(v13, attachment.Destroy, attachment)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sizeFor(p: number)
	return math.clamp(p / 300, 0, 1) * 10 + 5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flatDistance(vector2: Vector3, vector3: Vector3)
	return (Vector3.new(vector2.X, 0, vector2.Z) - Vector3.new(vector3.X, 0, vector3.Z)).Magnitude
end

-- equivalent calls inferred from this helper; original call sites unknown
local function anyActive()
	for _, v13 in v5 do
		if v13.active then
			return true
		end
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeBall(p)
	local index = table.find(v5, p)

	if index then
		table.remove(v5, index)
	end

	v11 = os.clock() + 1.5
end

local function getRootHumanoid()
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid then
		return humanoidRootPart, humanoid
	end

	return nil, nil
end

local function spawnFreeBall()
	if #v5 >= 2 then
		return
	end

	local snowballTemplate = getSnowballTemplate()
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid) then
		humanoidRootPart = nil
	end

	if not (snowballTemplate and humanoidRootPart) then
		return
	end

	local lookVector = humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local v13 = not (vector2.Magnitude > 0.0001) and createVector(0, 0, -1) or vector2.Unit
	local v14 = Vector3.new(humanoidRootPart.Position.X, 0, humanoidRootPart.Position.Z) + v13 * 5
	local v15 = snapToGround(CFrame.new(v14.X, humanoidRootPart.Position.Y, v14.Z))
	local vector3 = Vector3.new(v14.X, v15.Position.Y + 2.5, v14.Z)
	local center = clampToObstruction(humanoidRootPart.Position, vector3, 2.5)
	local clone = snowballTemplate:Clone()
	prepFreeBall(clone)
	clone.Parent = workspace.Terrain
	count += 1
	local v17 = {
		id = count,
		model = clone,
		center = center,
		diameter = 5,
		rolled = 0,
		rollCF = CFrame.identity,
		active = false,
		velocity = createVector(0, 0, 0),
		airTime = 0,
		idleTime = 0
	}
	setBallSize(v17) -- equivalent call inferred; original call site unknown
	clone:PivotTo(CFrame.new(center))
	table.insert(v5, v17)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendStack()
	if v6 then
		snowmanStackRemote:FireServer(diameters, v6)
	end
end

local function mergeFreeBalls(p, p2)
	local v13

	if p.diameter >= p2.diameter then
		v13 = p
	else
		v13 = p2
	end

	v6 = snapToGround(CFrame.new(v13.center))
	diameters = { math.max(p.diameter, p2.diameter), (math.min(p.diameter, p2.diameter)) }
	popEmit(p.model)
	popEmit(p2.model)
	p.model:Destroy()
	p2.model:Destroy()
	removeBall(p) -- equivalent call inferred; original call site unknown
	removeBall(p2) -- equivalent call inferred; original call site unknown
	sendStack() -- equivalent call inferred; original call site unknown
end

local function addTierToStack(p)
	table.insert(diameters, p.diameter)
	table.sort(diameters, function(a, b)
		return b < a
	end)
	popEmit(p.model)
	p.model:Destroy()
	removeBall(p) -- equivalent call inferred; original call site unknown
	sendStack() -- equivalent call inferred; original call site unknown
end

local function checkMerge(p)
	if v6 then
		local v13 = diameters[1] / 2

		if not (flatDistance(p.center, v6.Position) <= (p.diameter / 2 + v13) * 1) then
			return false
		end

		if p.diameter >= 9.95 then
			addTierToStack(p)
			return true
		else
			return false
		end
	else
		for _, v13 in v5 do
			if not (v13 ~= p and flatDistance(p.center, v13.center) <= (p.diameter / 2 + v13.diameter / 2) * 1) then
				continue
			end

			if math.min(p.diameter, v13.diameter) >= 9.95 then
				mergeFreeBalls(p, v13)
				return true
			else
				return false
			end
		end

		return false
	end
end

local function restBall(state)
	state.active = false
	state.velocity = createVector(0, 0, 0)
	state.airTime = 0
	local halfDiameter = state.diameter / 2
	local v14 = snapToGround(CFrame.new(state.center))
	state.center = Vector3.new(state.center.X, v14.Position.Y + halfDiameter, state.center.Z)
	state.model:PivotTo(CFrame.new(state.center) * state.rollCF)
end

local function crumbleBall(p)
	popEmit(p.model)
	p.model:Destroy()
	removeBall(p) -- equivalent call inferred; original call site unknown

	if v2 then
		v2:FireServer("BallLost")
	end
end

local function meltBall(p)
	removeBall(p) -- equivalent call inferred; original call site unknown

	if v2 then
		v2:FireServer("BallLost")
	end

	local v13 = {
		id = p.id,
		model = p.model
	}
	table.insert(v9, v13)
	local primaryPart = p.model.PrimaryPart

	if primaryPart then
		TweenService:Create(primaryPart, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Size = primaryPart.Size * 0.05,
			CFrame = primaryPart.CFrame - createVector(0, 1, 0) * (primaryPart.Size.Y * 0.475)
		}):Play()
	end

	task.delay(1.25, function()
		local index = table.find(v9, v13)

		if not index then
			return
		end

		table.remove(v9, index)
		v11 = os.clock() + 1.5
		popEmit(v13.model)
		v13.model:Destroy()
	end)
end

local function tryGrabFromPiles(humanoidRootPart)
	local v13 = v2

	if not v13 or v13.Completed or (v8 > 0 or #v5 >= 2) then
		return
	end

	for k, v14 in v4 do
		if not v14.Parent then
			continue
		end

		local primaryPart = v14.PrimaryPart or v14:FindFirstChild("HumanoidRootPart")

		if not (primaryPart and primaryPart:IsA("BasePart") and flatDistance(
			humanoidRootPart.Position,
			primaryPart.Position
		) <= 12) then
			continue
		end

		v8 = 0.75
		v4[k] = nil
		v14:Destroy()
		spawnFreeBall()
		v13:FireServer("GrabSnowball", k)
		break
	end
end

local function updateFreeBalls(dt: number)
	local DISTANCE_EPSILON = 0.0001

	if flag then
		return
	end

	if v8 > 0 then
		v8 = math.max(0, v8 - dt)
	end

	if not v2 or v2.Completed then
		return
	end

	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid) then
		humanoidRootPart = nil
		humanoid = nil
	end

	if humanoidRootPart and humanoid then
		tryGrabFromPiles(humanoidRootPart)
		local position = humanoidRootPart.Position
		local v14 = v7
		v7 = position
		local v15 = not v14 and createVector(0, 0, 0) or position - v14
		local vector2 = Vector3.new(v15.X, 0, v15.Z)
		local magnitude = vector2.Magnitude
		local lookVector = humanoidRootPart.CFrame.LookVector
		local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local vector4 = not (vector3.Magnitude > DISTANCE_EPSILON) and createVector(0, 0, -1) or vector3.Unit
		local moveDirection = humanoid.MoveDirection
		local vector5 = Vector3.new(moveDirection.X, 0, moveDirection.Z)
		local v16 = vector5.Magnitude > 0.1
		local vector6 = not v16 and createVector(0, 0, 0) or vector5.Unit
		local v17 = v16 and vector6:Dot(vector4) > 0.3

		for _, v18 in v5 do
			if v18.active then
				v18.idleTime = 0
			else
				v18.idleTime += dt

				if v18.idleTime >= 120 then
					meltBall(v18)
					break
				end
			end

			if not v18.active then
				local vector7 = Vector3.new(v18.center.X - position.X, 0, v18.center.Z - position.Z)
				local magnitude2 = vector7.Magnitude
				local v19 = v18.diameter / 2 + 2.5
				local v20 = not (magnitude2 > 0.001) and -1 or vector4:Dot(vector7.Unit)

				if magnitude2 > 0.001 and magnitude2 < v19 and v20 >= 0.35 and v17 then
					-- equivalent call inferred; original call site unknown
					if not anyActive() then
						v18.active = true
					end
				end
			end

			if v18.active then
				if v17 then
					v18.rolled += magnitude
					v18.diameter = sizeFor(v18.rolled)
					local halfDiameter = v18.diameter / 2

					if magnitude > 0.001 and magnitude < 50 then
						local cross = (createVector(0, 1, 0)):Cross(vector2.Unit)

						if cross.Magnitude > DISTANCE_EPSILON then
							v18.rollCF = CFrame.fromAxisAngle(cross.Unit, magnitude / halfDiameter) * v18.rollCF
						end
					end

					local vector7 = Vector3.new(
						0,
						-(humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight) + halfDiameter,
						-(halfDiameter + 2.5)
					)
					local position2 = (humanoidRootPart.CFrame * CFrame.new(vector7)).Position
					local center = clampToObstruction(humanoidRootPart.Position, position2, halfDiameter)
					v18.velocity = vector6 * humanoid.WalkSpeed
					setBallSize(v18) -- equivalent call inferred; original call site unknown
					v18.center = center
					v18.model:PivotTo(CFrame.new(center) * v18.rollCF)

					if humanoid.FloorMaterial == Enum.Material.Air then
						v18.airTime += dt
					else
						v18.airTime = 0
					end

					if v18.airTime >= 1 then
						popEmit(v18.model)
						v18.model:Destroy()
						removeBall(v18) -- equivalent call inferred; original call site unknown

						if not v2 then
							break
						end

						v2:FireServer("BallLost")
						break
					elseif checkMerge(v18) then
						break
					end

					continue
				else
					v18.active = false
				end
			end

			local halfDiameter2 = v18.diameter / 2

			if rayGroundY(v18.center, halfDiameter2) then
				local magnitude2 = v18.velocity.Magnitude

				if magnitude2 <= 1 then
					if magnitude2 > 0 then
						restBall(v18)
					end
				else
					local v20 = magnitude2 - dt * 35

					if v20 <= 1 then
						restBall(v18)
					else
						local unit = v18.velocity.Unit
						v18.velocity = unit * v20
						local v21 = v20 * dt
						v18.rolled += v21
						v18.diameter = sizeFor(v18.rolled)
						local halfDiameter = v18.diameter / 2

						if v21 > 0.0001 then
							local cross = (createVector(0, 1, 0)):Cross(unit)

							if cross.Magnitude > DISTANCE_EPSILON then
								v18.rollCF = CFrame.fromAxisAngle(cross.Unit, v21 / halfDiameter) * v18.rollCF
							end
						end

						local vector7 = Vector3.new(
							v18.center.X + unit.X * v21,
							v18.center.Y,
							v18.center.Z + unit.Z * v21
						)
						local v23 = clampToObstruction(v18.center, vector7, halfDiameter)
						local X = v23.X
						local Z = v23.Z
						local v24 = rayGroundY(Vector3.new(X, v18.center.Y, Z), halfDiameter)

						if v24 then
							v18.center = Vector3.new(X, v24 + halfDiameter, Z)
							setBallSize(v18) -- equivalent call inferred; original call site unknown
							v18.model:PivotTo(CFrame.new(v18.center) * v18.rollCF)

							if checkMerge(v18) then
								break
							end
						else
							popEmit(v18.model)
							v18.model:Destroy()
							removeBall(v18) -- equivalent call inferred; original call site unknown

							if not v2 then
								break
							end

							v2:FireServer("BallLost")
							break
						end
					end
				end
			else
				popEmit(v18.model)
				v18.model:Destroy()
				removeBall(v18) -- equivalent call inferred; original call site unknown

				if not v2 then
					break
				end

				v2:FireServer("BallLost")
				break
			end
		end

		local character2 = game.Players.LocalPlayer.Character

		if character2 then
			local v19 = anyActive() -- equivalent call inferred; original call site unknown
			character2:SetAttribute("PushingSnowball", v19)
		end
	else
		for _, v14 in v5 do
			v14.active = false
			v14.velocity = createVector(0, 0, 0)
		end

		v7 = nil
		local character2 = game.Players.LocalPlayer.Character

		if character2 then
			character2:SetAttribute("PushingSnowball", false)
		end
	end
end

local function clearFreeBalls()
	for _, v13 in v5 do
		v13.model:Destroy()
	end

	table.clear(v5)

	for _, v13 in v9 do
		v13.model:Destroy()
	end

	table.clear(v9)
	v11 = os.clock() + 1.5
	count2 += 1
	snowmanBallRemote:FireServer(count2, {})
	table.clear(diameters)
	v6 = nil
	v7 = nil
	local character = game.Players.LocalPlayer.Character

	if character then
		character:SetAttribute("PushingSnowball", false)
	end
end

local function streamBalls()
	local now = os.clock()

	if now - v10 < 0.06666666666666667 then
		return
	end

	local v13 = {}

	for _, v14 in v5 do
		table.insert(v13, {
			i = v14.id,
			c = v14.model:GetPivot(),
			d = v14.diameter
		})
	end

	for _, v14 in v9 do
		if not v14.model.Parent then
			continue
		end

		local v15 = {
			i = v14.id,
			c = v14.model:GetPivot(),
			d = diameterOf(v14.model)
		}
		table.insert(v13, v15)
	end

	if #v13 == 0 and v11 < now then
		return
	end

	v10 = now
	count2 += 1
	snowmanBallRemote:FireServer(count2, v13)
end

local v13 = nil

local function getPileTemplate()
	if v13 then
		return v13
	end

	local snowpile = script:FindFirstChild("Snowpile") or snowman_Placeholder:FindFirstChild("Snowball1")

	if not (snowpile and snowpile:IsA("BasePart")) then
		return nil
	end

	local model = Instance.new("Model")
	model.Name = "Snow Pile"
	local part = Instance.new("Part")
	part.Name = "HumanoidRootPart"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CFrame = CFrame.new()
	part.Parent = model
	local clone = part:Clone()
	clone.Name = "Head"
	clone.Parent = model
	local clone2 = snowpile:Clone()

	for _, surfaceAppearance in clone2:GetChildren() do
		if not surfaceAppearance:IsA("SurfaceAppearance") then
			surfaceAppearance:Destroy()
		end
	end

	clone2.Name = "Snow"

	if snowpile.Name ~= "Snowpile" then
		clone2.Size = createVector(8, 4, 8)
	end

	clone2.Anchored = true
	clone2.CanCollide = false
	clone2.CanQuery = false
	clone2.CanTouch = false
	clone2.CFrame = CFrame.new(0, clone2.Size.Y / 2 - 1 - 2.385, 0)
	clone2.Parent = model
	model.PrimaryPart = part
	v13 = model
	return model
end

local function spawnPile(_, p: number, cframe: CFrame)
	local pileTemplate = getPileTemplate()

	if not pileTemplate then
		return
	end

	local v14, v15 = snapToGround(cframe)
	local clone = pileTemplate:Clone()
	clone:PivotTo(v14 * CFrame.new(0, 2.385, 0))
	clone:SetAttribute("SnowpileGrounded", true)
	clone:SetAttribute("FloorNormal", v15)
	clone.Parent = workspace.Terrain
	v4[p] = clone
end

local function spawnPiles(p, items)
	for k, item in items do
		local v14 = v4[k]

		if not (not v14 or not v14.Parent or v3[k] ~= item) then
			continue
		end

		if v14 then
			v14:Destroy()
			v4[k] = nil
		end

		v3[k] = item
		spawnPile(p, k, item)
	end
end

local function cleanupAll()
	sweepNamed("Snow Pile")

	for _, v14 in v4 do
		if v14 and v14.Parent then
			v14:Destroy()
		end
	end

	clearFreeBalls()
	table.clear(v3)
	table.clear(v4)
	v8 = 0
end

local function playDialogue(title: string, text)
	local total = 0

	while DialogueController.Active and total < 3 do
		total += task.wait(0.1)
	end

	if DialogueController.Active then
		return
	end

	DialogueController.start({
		Title = title,
		Get = function()
			return {
				Text = text
			}
		end
	})
end

local function makeSnowmanAnchor(vector2: Vector3, p: number)
	local model = Instance.new("Model")
	model.Name = "SnowmanDialogueAnchor"
	local part = Instance.new("Part")
	part.Name = "Head"
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CFrame = CFrame.new(vector2 + createVector(0, 1, 0) * p)
	part.Parent = model
	model.PrimaryPart = part
	model.Parent = workspace.Terrain
	return model
end

local function startDialogueCamera(snowmanAnchor)
	local currentCamera = workspace.CurrentCamera
	local character = Players.LocalPlayer.Character

	if not (currentCamera and character) then
		return {
			stop = function() end
		}
	end

	local v14 = CameraController.new()
	local head = snowmanAnchor:FindFirstChild("Head")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function npcLookPoint()
		if head and head:IsA("BasePart") then
			return head.Position
		end

		return snowmanAnchor:GetPivot().Position
	end

	local function npcToPlayer()
		local character2 = Players.LocalPlayer.Character
		local v15

		if character2 then
			v15 = character2:GetPivot().Position
		else
			v15 = snowmanAnchor:GetPivot().Position
		end

		local v16 = (v15 - snowmanAnchor:GetPivot().Position) * createVector(1, 0, 1)
		local magnitude = v16.Magnitude

		if magnitude < 0.05 then
			return snowmanAnchor:GetPivot().LookVector * createVector(1, 0, 1), 0
		end

		return v16 / magnitude, magnitude
	end

	local v15 = (currentCamera.CFrame.Position - snowmanAnchor:GetPivot().Position) * createVector(1, 0, 1)
	local unit

	if v15.Magnitude > 0.05 then
		unit = v15.Unit
	else
		unit = npcToPlayer()
	end

	local total = 0
	local v16 = 0

	local function dialogueGoal(p: number)
		local character2 = Players.LocalPlayer.Character
		local v17 = npcLookPoint() -- equivalent call inferred; original call site unknown
		local v18

		if character2 then
			v18 = character2:GetPivot().Position
		else
			v18 = v17
		end

		local v19 = v18 + createVector(0, 1.5, 0)
		local vector2, v20 = npcToPlayer()
		local v21 = math.deg((math.atan2(vector2:Cross(unit).Y, (math.clamp(vector2:Dot(unit), -1, 1)))))
		local v22 = 0

		if math.abs(v21) < NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE then
			if v16 == 0 then
				v16 = v21 >= 0 and 1 or -1
			end

			v22 = v16 * NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE - v21
		elseif math.abs(v21) > NPCInteractionConfig.DIALOGUE_CAMERA_ANGLE + NPCInteractionConfig.DIALOGUE_CAMERA_SIDE_RESET then
			v16 = 0
		end

		local v23 = NPCInteractionConfig.DIALOGUE_CAMERA_SWING_SPEED * p
		total += math.clamp(v22 - total, -v23, v23)
		local vector3 = CFrame.fromAxisAngle(createVector(0, 1, 0), (math.rad(total))) * unit
		local v24 = NPCInteractionConfig.DIALOGUE_CAMERA_BASE_DISTANCE + v20 * NPCInteractionConfig.DIALOGUE_CAMERA_PULLBACK
		local v25 = v20 * vector3:Dot(vector2)
		local v26 = math.sqrt((math.max(v20 ^ 2 - v25 ^ 2, 0)))

		if v26 < NPCInteractionConfig.DIALOGUE_CAMERA_PLAYER_GAP then
			v24 = math.max(v24, v25 + math.sqrt(NPCInteractionConfig.DIALOGUE_CAMERA_PLAYER_GAP ^ 2 - v26 ^ 2))
		end

		local v27 = v17 + vector3 * v24 + Vector3.new(0, NPCInteractionConfig.DIALOGUE_CAMERA_HEIGHT, 0)
		return CFrame.lookAt(v27, v17:Lerp(v19, 0.5))
	end

	local v17 = true
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop(flag3: boolean?)
		if flag2 then
			return
		end

		flag2 = true
		v17 = false

		if flag3 then
			v14:FadeOut(0.25)
		else
			v14:Destroy()
		end
	end

	task.spawn(function()
		local v18 = 0.016666666666666666

		while v17 and snowmanAnchor.Parent and Players.LocalPlayer.Character do
			local _, v19 = npcToPlayer()

			if v19 > 30 then
				if not DialogueController.Active then
					break
				end

				DialogueController.close()
				break
			else
				v14.Animations:AnimateTo(dialogueGoal(v18), 1, NPCInteractionConfig.DIALOGUE_CAMERA_FREQUENCY)
				v18 = task.wait()
			end
		end

		stop(true) -- equivalent call inferred; original call site unknown
	end)
	return {
		stop = stop
	}
end

local function playThanks(position: Vector3, p: number)
	task.wait(0.7)
	local snowmanAnchor = makeSnowmanAnchor(position, math.max(p * 0.7, 10))
	local v14 = startDialogueCamera(snowmanAnchor)
	local success, result = pcall(playDialogue, "Snowman", v)

	if not success then
		warn("[Snowman] gratitude dialogue error:", result)
	end

	v14.stop(true)
	snowmanAnchor:Destroy()
	task.wait(0.7)
end

local function runThanks(cframe: CFrame, p: number)
	if flag then
		return
	end

	flag = true

	if v2 and not v2.Completed then
		playThanks(cframe.Position, p)
	end

	flag = false

	if v2 then
		v2:FireServer("Finished")
	end
end

local v14 = {}
local v15 = {}
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function removeGhost(k: string, flag2: boolean)
	local v16 = v14[k]

	if not v16 then
		return
	end

	v14[k] = nil

	if flag2 then
		popEmit(v16.model)
	end

	v16.model:Destroy()

	if not next(v14) and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function stepGhosts(p: number)
	local now = os.clock()
	local v16 = 1 - math.exp(p * -12)

	for k, v17 in v14 do
		if now - v17.lastAt > 5 then
			removeGhost(k, false) -- equivalent call inferred; original call site unknown
		else
			local v18 = v17.velocity * 0.15

			if v18.Magnitude > 4 then
				v18 = v18.Unit * 4
			end

			local v19 = v17.target + v18
			local pivot = v17.model:GetPivot()

			if not ((pivot.Position - v19.Position).Magnitude > 50) then
				v19 = pivot:Lerp(v19, v16)
			end

			v17.diameter += (v17.targetDiameter - v17.diameter) * v16
			setBallSize(v17) -- equivalent call inferred; original call site unknown
			v17.model:PivotTo(v19)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureGhostLoop()
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(stepGhosts)
	end
end

local function applyGhostPacket(owner, value2, items)
	if type(owner) ~= "number" or type(value2) ~= "number" or type(items) ~= "table" or owner == Players.LocalPlayer.UserId then
		return
	end

	local v16 = v15[owner]

	if v16 and value2 <= v16 then
		return
	end

	v15[owner] = value2
	local v17 = {}

	for _, item in items do
		if type(item) ~= "table" then
			continue
		end

		local i = item.i
		local c = item.c
		local d = item.d

		if not (type(i) == "number" and typeof(c) == "CFrame" and type(d) == "number") then
			continue
		end

		local v18 = owner .. ":" .. i
		v17[v18] = true
		local v19 = v14[v18]

		if v19 then
			local now = os.clock()
			local v20 = now - v19.lastAt

			if v20 > 0.001 and v20 < 1 then
				local v21 = (c.Position - v19.target.Position) / v20
				local v22 = v21.Magnitude > 200 and createVector(0, 0, 0) or v21
				v19.velocity = v19.velocity:Lerp(v22, 0.5)
			else
				v19.velocity = createVector(0, 0, 0)
			end

			v19.target = c
			v19.targetDiameter = d
			v19.lastAt = now
		else
			local snowballTemplate = getSnowballTemplate()

			if snowballTemplate then
				local clone = snowballTemplate:Clone()
				clone.Name = "SnowballGhost"
				prepFreeBall(clone)
				applyDiameter(clone, d) -- equivalent call inferred; original call site unknown
				clone:PivotTo(c)
				clone.Parent = workspace.Terrain
				v14[v18] = {
					model = clone,
					owner = owner,
					target = c,
					targetDiameter = d,
					diameter = d,
					velocity = createVector(0, 0, 0),
					lastAt = os.clock()
				}
				ensureGhostLoop() -- equivalent call inferred; original call site unknown
			end
		end
	end

	for k, v18 in v14 do
		if v18.owner ~= owner or v17[k] then
			continue
		end

		removeGhost(k, true) -- equivalent call inferred; original call site unknown
	end
end

snowmanBallRemote.OnClientEvent:Connect(applyGhostPacket)
Players.PlayerRemoving:Connect(function(player)
	v15[player.UserId] = nil

	for k, v16 in v14 do
		if v16.owner ~= player.UserId then
			continue
		end

		removeGhost(k, false) -- equivalent call inferred; original call site unknown
	end
end)
local Snowman = {}
Snowman.DataName = script.Name
Snowman.Repeatable = true

function Snowman.OnLoad(maid)
	v2 = maid
	flag = false
	cleanupAll()
	maid:FireServer("Init")
	maid:GiveTask(RunService.RenderStepped:Connect(function(dt: number)
		updateFreeBalls(dt)
		streamBalls()
	end))
	task.delay(4, function()
		if v2 == maid and not maid.Completed and next(v4) == nil then
			maid:FireServer("Init")
		end
	end)
end

Snowman.RemoteEvents = {
	Setup = function(p, p2)
		if p2 then
			spawnPiles(p, p2)
		end
	end,
	Despawn = function(_)
		cleanupAll()
	end,
	Alive = function(_, p, value)
		if typeof(p) ~= "CFrame" then
			return
		end

		task.spawn(runThanks, p, typeof(value) ~= "number" and 24 or value)
	end,
	PileTaken = function(_, p: number)
		local v16 = v4[p]
		v4[p] = nil

		if v16 then
			v16:Destroy()
		end
	end,
	PileRestored = function(p, p2: number, p3)
		if typeof(p3) == "CFrame" then
			v3[p2] = p3
		end

		local v16 = v3[p2]

		if not v16 then
			return
		end

		local v17 = v4[p2]

		if v17 then
			v17:Destroy()
			v4[p2] = nil
		end

		spawnPile(p, p2, v16)
	end
}

function Snowman.OnComplete(_, _, _)
	cleanupAll()
end

return Snowman