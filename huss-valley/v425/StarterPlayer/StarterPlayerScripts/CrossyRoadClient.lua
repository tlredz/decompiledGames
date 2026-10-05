local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local game2 = chickenOrHero:WaitForChild("Game")
local crossyRoadEvent = game2:WaitForChild("CrossyRoadEvent")
local CrossyRoadMotion = require(game2:WaitForChild("CrossyRoadMotion"))
local AnimationConfig = require(chickenOrHero.Animation.AnimationConfig)
local crossyRoadChaserTemplate = game2:WaitForChild("CrossyRoadChaserTemplate")
local v = {
	Color3.fromRGB(237, 205, 174),
	Color3.fromRGB(221, 180, 145),
	Color3.fromRGB(170, 120, 87),
	Color3.fromRGB(116, 79, 59)
}
local v2 = {
	Color3.fromRGB(58, 102, 145),
	Color3.fromRGB(154, 63, 55),
	Color3.fromRGB(76, 117, 89),
	Color3.fromRGB(141, 104, 160)
}
local v3 = { Color3.fromRGB(39, 47, 63), Color3.fromRGB(60, 49, 43), Color3.fromRGB(44, 57, 68) }

local function recolor(clone, id)
	local v4 = v[(id - 1) % #v + 1]
	local torsoColor = v2[math.floor((id - 1) / #v) % #v2 + 1]
	local v6 = v3[(id - 1) % #v3 + 1]
	local bodyColors = clone:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")
	bodyColors.HeadColor3 = v4
	bodyColors.LeftArmColor3 = v4
	bodyColors.RightArmColor3 = v4
	bodyColors.TorsoColor3 = torsoColor
	bodyColors.LeftLegColor3 = v6
	bodyColors.RightLegColor3 = v6
	bodyColors.Parent = clone

	for _, childName in {
		"Head",
		"Left Arm",
		"Right Arm",
		"Torso",
		"Left Leg",
		"Right Leg"
	} do
		local part = clone:FindFirstChild(childName)

		if part and part:IsA("BasePart") then
			part.Color = childName == "Torso" and torsoColor or (childName == "Left Leg" or childName == "Right Leg") and v6 or v4
		end
	end
end

local v4 = nil

local function clear()
	if not v4 then
		return
	end

	for _, bot in v4.bots do
		if bot.track then
			bot.track:Destroy()
		end
	end

	v4.folder:Destroy()
	v4 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clock()
	return v4.clock + (v4.paused and 0 or math.max(0, workspace:GetServerTimeNow() - v4.serverAt))
end

local function spawn(bot)
	if v4.bots[bot.id] then
		return
	end

	local lane = v4.lanes[bot.lane]

	if not lane or clock() > bot.expires then
		return
	end

	local clone = crossyRoadChaserTemplate:Clone()
	clone.Name = "Chaser_" .. bot.id
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if not (humanoidRootPart and humanoid) then
		clone:Destroy()
		return
	end

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = descendant == humanoidRootPart
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("LuaSourceContainer") or descendant:IsA("Highlight") or descendant:IsA("BillboardGui") then
			descendant:Destroy()
		end
	end

	recolor(clone, bot.id)
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local position = CrossyRoadMotion.position(lane, bot, clock(), v4.width, v4.lateral)
	clone:PivotTo(CFrame.lookAt(position, position + v4.lateral * lane.direction) * humanoidRootPart.CFrame:Inverse() * clone:GetPivot())
	clone.Parent = v4.chasers
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid
	local animation = Instance.new("Animation")
	animation.AnimationId = AnimationConfig.PublishedIds.Walk
	animation.Parent = clone
	local success, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	local rate = math.clamp(lane.speed / AnimationConfig.WalkReferenceSpeed, 1, 5)

	if success then
		result.Looped = true
		result.Priority = Enum.AnimationPriority.Movement
		result:Play(0.1, 1, v4.paused and 0 or rate)
	else
		result = nil
	end

	v4.bots[bot.id] = {
		data = bot,
		model = clone,
		root = humanoidRootPart,
		track = result,
		rate = rate
	}
end

local function syncClock(data)
	v4.clock = data.clock
	v4.serverAt = data.serverAt

	if data.paused ~= nil then
		v4.paused = data.paused
	end

	for _, bot in v4.bots do
		if bot.track then
			bot.track:AdjustSpeed(v4.paused and 0 or bot.rate)
		end
	end
end

local onClientEventConnection = crossyRoadEvent.OnClientEvent:Connect(function(p, data)
	if p == "Clear" then
		if v4 and data == v4.id then
			clear()
		end
	else
		if type(data) ~= "table" then
			return
		end

		if p == "Begin" then
			clear()
			local folder = Instance.new("Folder")
			folder.Name = "CrossyRoadLocal"
			folder.Parent = workspace
			local model = Instance.new("Model")
			model.Name = "Chasers"
			model.Parent = folder
			local highlight = Instance.new("Highlight")
			highlight.Name = "RedHighlight"
			highlight.Adornee = model
			highlight.FillColor = Color3.fromRGB(255, 40, 40)
			highlight.OutlineColor = highlight.FillColor
			highlight.FillTransparency = 0.85
			highlight.OutlineTransparency = 0.3
			highlight.Parent = model
			v4 = {
				id = data.id,
				lanes = data.lanes,
				width = data.width,
				lateral = data.lateral,
				bots = {},
				folder = folder,
				chasers = model,
				clock = data.clock,
				serverAt = data.serverAt,
				paused = data.paused,
				lastReport = 0
			}

			for _, lane in data.lanes do
				local part = Instance.new("Part")
				part.Name = "Lane" .. lane.index
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Size = Vector3.new(data.width * 2, 0.04, 0.12)
				part.CFrame = CFrame.fromMatrix(
					lane.samples[11] + createVector(0, 0.07, 0),
					data.lateral,
					createVector(0, 1, 0),
					-data.across
				)
				part.Material = Enum.Material.Neon
				part.Color = Color3.fromRGB(255, 100, 100)
				part.Transparency = 0.8
				part.Parent = folder
			end

			for _, bot in data.bots do
				spawn(bot)
			end
		elseif v4 and data.id == v4.id then
			if p == "Spawn" then
				syncClock(data)
				spawn(data.bot)
			elseif p == "Clock" then
				syncClock(data)
			end
		end
	end
end)
local renderSteppedConnection = RunService.RenderStepped:Connect(function()
	if not v4 then
		return
	end

	local v5 = clock() -- equivalent call inferred; original call site unknown
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local v6 = not v4.paused

	if v6 then
		if game2.Session:GetAttribute("Phase") == "GroupRun" and localPlayer:GetAttribute("InMatch") == true and localPlayer:GetAttribute("GameRole") == "Runner" and localPlayer:GetAttribute("RunState") == "Active" then
			v6 = humanoidRootPart and humanoid and humanoid.Health > 0
		else
			v6 = false
		end
	end

	local previous = v4.previous
	local v7

	if v6 then
		if previous then
			if previous.character == character and previous.reset == character:GetAttribute("MovementReset") and previous.at <= v5 and v5 - previous.at <= 0.12 then
				v7 = (humanoidRootPart.Position - previous.position).Magnitude <= 16
			else
				v7 = false
			end
		else
			v7 = previous
		end
	else
		v7 = v6
	end

	for k, bot in v4.bots do
		local lane = v4.lanes[bot.data.lane]

		if bot.data.expires < v5 then
			if bot.track then
				bot.track:Destroy()
			end

			bot.model:Destroy()
			v4.bots[k] = nil
		else
			local position = CrossyRoadMotion.position(lane, bot.data, v5, v4.width, v4.lateral)
			bot.model:PivotTo(CFrame.lookAt(position, position + v4.lateral * lane.direction) * bot.root.CFrame:Inverse() * bot.model:GetPivot())

			if v6 and v5 - v4.lastReport > 0.18 then
				local v8

				if v7 then
					v8 = math.max(previous.at, bot.data.born) or v5
				else
					v8 = v5
				end

				local position2 = CrossyRoadMotion.position(lane, bot.data, v8, v4.width, v4.lateral)
				local position3 = v7 and previous.position or humanoidRootPart.Position

				if CrossyRoadMotion.contact(position3, humanoidRootPart.Position, position2, position, 2.8) then
					v4.lastReport = v5
					crossyRoadEvent:FireServer("Hit", {
						id = v4.id,
						bot = k,
						at = v5,
						span = v5 - v8,
						before = position3,
						position = humanoidRootPart.Position
					})
				end
			end
		end
	end

	v4.previous = v6 and {
		at = v5,
		position = humanoidRootPart.Position,
		character = character,
		reset = character:GetAttribute("MovementReset")
	} or nil
end)
local adminMatchModeChangedConnection = game2.Session:GetAttributeChangedSignal("AdminMatchMode"):Connect(function()
	if game2.Session:GetAttribute("AdminMatchMode") == "CrossyRoad" then
		crossyRoadEvent:FireServer("Sync")
	else
		clear()
	end
end)
script.Destroying:Connect(function()
	onClientEventConnection:Disconnect()
	renderSteppedConnection:Disconnect()
	adminMatchModeChangedConnection:Disconnect()
	clear()
end)
crossyRoadEvent:FireServer("Sync")