local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Maid = require(ReplicatedStorage.Util.Maid)
local FishmenBubbleMotion = require(ReplicatedStorage.Modules.World.FishmenBubbleMotion)
local _ = {
	BUBBLE_ASSET = "FishmenBubble",
	CONTAINER_NAME = "FishmenBubbles",
	GROW_START_SCALE = 0.05,
	GROW_TIME = 0.35,
	LOCATION_NAME = "Underwater City",
	POP_STAGGER = 0.45,
	POP_TIME = 0.3,
	RENDER_NAME = "IslandController.UnderwaterCity.FishmenBubbleVisuals",
	SMOOTH_TIME = 0.2,
	SUPPORT_ABOVE_MAX = 4,
	SUPPORT_ABOVE_MIN = 1,
	SUPPORT_BELOW_MAX = 3,
	SUPPORT_BELOW_MIN = 0,
	SUPPORT_BOB_AMP = 1.8,
	SUPPORT_GAP_MAX = 1.1,
	SUPPORT_GAP_MIN = 0.35,
	SUPPORT_JITTER = 5,
	SUPPORT_SCALE_MAX = 0.7,
	SUPPORT_SCALE_MIN = 0.12,
	SUPPORT_SWAY_AMP_MAX = 3.6,
	SUPPORT_SWAY_AMP_MIN = 1.2,
	SUPPORT_SWAY_FREQ_MAX = 2,
	SUPPORT_SWAY_FREQ_MIN = 0.8,
	SUPPORT_TRANSPARENCY_MAX = 0.6,
	SUPPORT_TRANSPARENCY_MIN = 0.3,
	VISUAL_FOLDER_NAME = "FishmenBubbleVisuals"
}
local v = {
	baseDiameter = 0,
	bubbleTemplate = nil,
	clusters = {},
	fadingClusters = {},
	entry = 0,
	moveCFrames = {},
	moveParts = {},
	renderBound = false,
	rng = Random.new(),
	visualFolder = nil
}
local FishmenBubbleVisuals = {
	LoadForLocations = { "Underwater City" },
	Maid = Maid.new()
}

local function growInPart(clone)
	local size = clone.Size
	clone.Size = size * 0.05
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = size
	}):Play()
end

local function buildSupports()
	local v2 = assert(v.bubbleTemplate)
	local parent = assert(v.visualFolder)
	local v4 = {}

	local function addSupport(p: number, p2: number)
		local clone = v2:Clone()
		local number = v.rng:NextNumber(0.12, 0.7)
		clone.Size = createVector(1, 1, 1) * v.baseDiameter * number
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Transparency = v.rng:NextNumber(0.3, 0.6)
		clone.Parent = parent
		growInPart(clone)
		table.insert(v4, {
			ampX = v.rng:NextNumber(1.2, 3.6),
			ampY = v.rng:NextNumber(0, 1.8),
			ampZ = v.rng:NextNumber(1.2, 3.6),
			freqX = v.rng:NextNumber(0.8, 2),
			freqY = v.rng:NextNumber(0.8, 2),
			freqZ = v.rng:NextNumber(0.8, 2),
			offset = Vector3.new(
				math.cos((v.rng:NextNumber(0, 6.283185307179586))) * v.rng:NextNumber(0, 5),
				p * p2,
				math.sin((v.rng:NextNumber(0, 6.283185307179586))) * v.rng:NextNumber(0, 5)
			),
			part = clone,
			phaseX = v.rng:NextNumber(0, 6.283185307179586),
			phaseY = v.rng:NextNumber(0, 6.283185307179586),
			phaseZ = v.rng:NextNumber(0, 6.283185307179586)
		})
	end

	local v5 = v.baseDiameter * 0.5

	for _ = 1, v.rng:NextInteger(1, 4) do
		v5 += v.baseDiameter * v.rng:NextNumber(0.35, 1.1)
		addSupport(1, v5)
	end

	local v6 = v.baseDiameter * 0.5

	for _ = 1, v.rng:NextInteger(0, 3) do
		v6 += v.baseDiameter * v.rng:NextNumber(0.35, 1.1)
		addSupport(-1, v6)
	end

	return v4
end

local function fadeAndClear(p)
	local cluster = v.clusters[p]

	if not cluster or cluster.faded then
		return
	end

	cluster.faded = true
	v.clusters[p] = nil
	v.fadingClusters[p] = cluster

	if cluster.connection then
		cluster.connection:Disconnect()
		cluster.connection = nil
	end

	TweenService:Create(cluster.visual, TweenInfo.new(0.3), {
		Size = cluster.visual.Size * 1.3,
		Transparency = 1
	}):Play()
	FishmenBubbleVisuals.Maid:GiveTask(task.delay(0.3, function()
		cluster.visual:Destroy()
		p.LocalTransparencyModifier = cluster.previousTransparency
		v.fadingClusters[p] = nil
	end))

	for _, support in cluster.supports do
		local part = support.part
		FishmenBubbleVisuals.Maid:GiveTask(task.delay(v.rng:NextNumber(0, 0.45), function()
			if not part.Parent then
				return
			end

			TweenService:Create(part, TweenInfo.new(0.3), {
				Size = part.Size * 1.3,
				Transparency = 1
			}):Play()
			task.wait(0.3)
			part:Destroy()
		end))
	end
end

local function onMainAdded(part)
	if not part:IsA("BasePart") or v.clusters[part] or not v.visualFolder or part:GetAttribute("Popped") then
		return
	end

	local clone = part:Clone()
	clone.Name = "BubbleVisual"
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.LocalTransparencyModifier = 0

	for _, tag in clone:GetTags() do
		clone:RemoveTag(tag)
	end

	clone.Parent = v.visualFolder
	local v2 = {
		connection = nil,
		drift = FishmenBubbleMotion.read(part),
		faded = false,
		previousTransparency = part.LocalTransparencyModifier,
		render = part.CFrame,
		supports = buildSupports(),
		visual = clone
	}
	part.LocalTransparencyModifier = 1
	v.clusters[part] = v2
	v2.connection = part:GetAttributeChangedSignal("Popped"):Connect(function()
		if part:GetAttribute("Popped") then
			fadeAndClear(part)
		end
	end)
end

local function renderStep(p: number)
	local now = os.clock()
	local serverTimeNow = Workspace:GetServerTimeNow()
	table.clear(v.moveParts)
	table.clear(v.moveCFrames)

	for k, cluster in v.clusters do
		if k.Parent then
			cluster.drift = cluster.drift or FishmenBubbleMotion.read(k)

			if k:GetAttribute("Claimed") or not cluster.drift then
				local riderUserId = k:GetAttribute("RiderUserId")
				local playerByUserId

				if typeof(riderUserId) == "number" then
					playerByUserId = Players:GetPlayerByUserId(riderUserId)
				end

				local humanoidRootPart = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")
				local render

				if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
					render = CFrame.new(humanoidRootPart.Position)
				else
					render = cluster.render:Lerp(k.CFrame, 1 - math.exp(-p / 0.2))
				end

				cluster.render = render
			else
				cluster.render = FishmenBubbleMotion.getCFrame(cluster.drift, serverTimeNow)
			end

			cluster.visual.Size = k.Size
			cluster.visual.Transparency = k.Transparency
			table.insert(v.moveParts, cluster.visual)
			table.insert(v.moveCFrames, cluster.render)
			local position = cluster.render.Position

			for _, support in cluster.supports do
				local vector2 = Vector3.new(
					math.sin(now * support.freqX + support.phaseX) * support.ampX,
					math.sin(now * support.freqY + support.phaseY) * support.ampY,
					math.sin(now * support.freqZ + support.phaseZ) * support.ampZ
				)
				table.insert(v.moveParts, support.part)
				table.insert(v.moveCFrames, CFrame.new(position + support.offset + vector2))
			end
		else
			fadeAndClear(k)
		end
	end

	if #v.moveParts > 0 then
		Workspace:BulkMoveTo(v.moveParts, v.moveCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end
end

local function cleanupVisuals()
	if v.renderBound then
		RunService:UnbindFromRenderStep("IslandController.UnderwaterCity.FishmenBubbleVisuals")
		v.renderBound = false
	end

	for _, list in { v.clusters, v.fadingClusters } do
		for k, v2 in list do
			k.LocalTransparencyModifier = v2.previousTransparency

			if v2.connection then
				v2.connection:Disconnect()
			end
		end

		table.clear(list)
	end

	table.clear(v.moveParts)
	table.clear(v.moveCFrames)

	if v.visualFolder then
		v.visualFolder:Destroy()
		v.visualFolder = nil
	end

	v.bubbleTemplate = nil
	v.baseDiameter = 0
end

local function startVisuals(entry: number)
	local fishmenBubble = ReplicatedStorage:WaitForChild("FishmenBubble", 30)
	local fishmenBubbles = Workspace:WaitForChild("FishmenBubbles", 30)

	if v.entry ~= entry then
		return
	end

	if not (fishmenBubble and fishmenBubble:IsA("BasePart")) then
		warn("[IslandController] ReplicatedStorage.FishmenBubble must be a BasePart")
		return
	end

	if not (fishmenBubbles and fishmenBubbles:IsA("Folder")) then
		warn("[IslandController] Workspace.FishmenBubbles must be a Folder")
		return
	end

	v.bubbleTemplate = fishmenBubble
	v.baseDiameter = math.max(fishmenBubble.Size.X, fishmenBubble.Size.Y, fishmenBubble.Size.Z)
	local folder = Instance.new("Folder")
	folder.Name = "FishmenBubbleVisuals"
	folder.Parent = Workspace
	v.visualFolder = folder
	FishmenBubbleVisuals.Maid:GiveTask(folder)

	for _, child in fishmenBubbles:GetChildren() do
		onMainAdded(child)
	end

	FishmenBubbleVisuals.Maid:GiveTask(fishmenBubbles.ChildAdded:Connect(onMainAdded))
	FishmenBubbleVisuals.Maid:GiveTask(fishmenBubbles.ChildRemoved:Connect(function(part)
		if part:IsA("BasePart") then
			fadeAndClear(part)
		end
	end))
	RunService:BindToRenderStep(
		"IslandController.UnderwaterCity.FishmenBubbleVisuals",
		Enum.RenderPriority.Camera.Value + 1,
		renderStep
	)
	v.renderBound = true
	FishmenBubbleVisuals.Maid:GiveTask(function()
		if v.renderBound then
			RunService:UnbindFromRenderStep("IslandController.UnderwaterCity.FishmenBubbleVisuals")
			v.renderBound = false
		end
	end)
end

function FishmenBubbleVisuals.RegionEntered(p)
	v.entry += 1
	local entry = v.entry
	p.Maid:GiveTask(cleanupVisuals)
	p.Maid:GiveTask(task.spawn(function()
		startVisuals(entry)
	end))
end

function FishmenBubbleVisuals.RegionLeaving(_)
	v.entry += 1
	cleanupVisuals()
end

return FishmenBubbleVisuals