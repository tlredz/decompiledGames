local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyEvent = require(script.Parent.Parent.PartyEvent)
local SharedSyncedEvent = require(script.Parent.Parent.SharedSyncedEvent)
local CCPulse = require(ReplicatedStorage.Utilities.Events.CCPulse)
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local oGParty = EventsConfig.OGParty
local color = Color3.fromRGB(245, 205, 48)
local color2 = Color3.fromRGB(13, 105, 172)
local color3 = Color3.fromRGB(75, 151, 75)
local v = { "rbxassetid://182435998", "rbxassetid://182491037", "rbxassetid://182491065" }
local v2 = CCPulse.new({
	name = "OGParty",
	colors = { color, color3, color2 },
	colorSpeed = 0.3,
	tintStrength = 0.55,
	contrast = 0.08,
	satCenter = 0.14,
	bloomIntensity = 0.55
})

local function playClassicDance(clone)
	local animationController = clone:FindFirstChildOfClass("AnimationController")

	if not animationController then
		return
	end

	local animator = animationController:FindFirstChildOfClass("Animator") or Instance.new(
		"Animator",
		animationController
	)
	local animation = Instance.new("Animation")
	animation.AnimationId = v[math.random(1, #v)]
	local success, result = pcall(animator.LoadAnimation, animator, animation)
	animation:Destroy()

	if not success then
		warn("[OGParty] Failed to load a classic R6 dance")
		return
	end

	result.Looped = true
	result.Priority = Enum.AnimationPriority.Action
	result:Play(0.2, 1, 1)
end

local function createGiantNoob()
	local humanoidDescription = Instance.new("HumanoidDescription")
	humanoidDescription.HeadColor = color
	humanoidDescription.LeftArmColor = color
	humanoidDescription.RightArmColor = color
	humanoidDescription.TorsoColor = color2
	humanoidDescription.LeftLegColor = color3
	humanoidDescription.RightLegColor = color3
	local success, result = pcall(
		Players.CreateHumanoidModelFromDescription,
		Players,
		humanoidDescription,
		Enum.HumanoidRigType.R6
	)
	humanoidDescription:Destroy()

	if not success then
		warn("[OGParty] Failed to create the classic R6 noob rig")
		return nil
	end

	result.Name = "GiantDancingNoob"
	result:ScaleTo(oGParty.GiantScale)
	local humanoidRootPart = result:FindFirstChild("HumanoidRootPart")
	local humanoid = result:FindFirstChildOfClass("Humanoid")
	local animationController = Instance.new("AnimationController")
	animationController.Name = "AnimationController"
	animationController.Parent = result

	if humanoid then
		humanoid:Destroy()
	end

	for _, part in result:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = part == humanoidRootPart
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
	end

	result.PrimaryPart = humanoidRootPart
	return result
end

local function createNoobStreamer(p, giantNoob)
	local folder = Instance.new("Folder")
	folder.Name = "OGPartyStreamedNoobs"
	folder.Parent = workspace
	p.janitor:Add(folder)
	local v3 = {}
	local v4 = {}
	local v5 = -1e999

	local function spawnNoob(index: number)
		local clone = giantNoob:Clone()
		clone:PivotTo(v3[index] * CFrame.Angles(0, math.rad((math.random(0, 359))), 0))
		clone.Parent = folder
		playClassicDance(clone)
		v4[index] = clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeNoob(p2: number)
		local v6 = v4[p2]

		if v6 then
			v6:Destroy()
			v4[p2] = nil
		end
	end

	return {
		setPositions = function(p2)
			v3 = p2
		end,
		update = function(p2: number, vector: Vector3)
			if p2 - v5 < oGParty.NoobStreamUpdateSeconds then
				return
			end

			v5 = p2
			local v6 = {}

			for k, v7 in v3 do
				local magnitude = (v7.Position - vector).Magnitude
				local v8

				if v4[k] then
					v8 = oGParty.NoobUnloadRadiusStuds
				else
					v8 = oGParty.NoobLoadRadiusStuds
				end

				if magnitude <= v8 then
					table.insert(v6, {
						index = k,
						distance = magnitude
					})
				end
			end

			table.sort(v6, function(a, b)
				return a.distance < b.distance
			end)
			local v7 = {}

			for i = 1, math.min(#v6, oGParty.MaxActiveNoobs) do
				v7[v6[i].index] = true
			end

			local v8 = {}

			for k in v4 do
				if not v7[k] then
					table.insert(v8, k)
				end
			end

			for _, v9 in v8 do
				removeNoob(v9) -- equivalent call inferred; original call site unknown
			end

			local count = 0

			for i = 1, math.min(#v6, oGParty.MaxActiveNoobs) do
				local index = v6[i].index

				if v4[index] or not (count < oGParty.MaxNoobSpawnsPerUpdate) then
					continue
				end

				spawnNoob(index)
				count += 1
			end
		end
	}
end

local function spawnHappyHomes(p, items)
	if type(items) ~= "table" then
		return
	end

	local happyHome = ReplicatedStorage.Assets.Events:FindFirstChild("HappyHome")

	if not (happyHome and happyHome:IsA("Model")) then
		warn("[OGParty] ReplicatedStorage.Assets.Events.HappyHome must be a Model")
		return
	end

	local v3 = false
	p.janitor:Add(function()
		v3 = true
	end)

	for k, item in items do
		local v4 = item
		task.delay((k - 1) * oGParty.HappyHomeSpawnStaggerSeconds, function()
			if not v3 then
				local folder = p.janitor:Add(happyHome:Clone())

				for i, part in folder:GetDescendants() do
					if not part:IsA("BasePart") then
						continue
					end

					part.Anchored = true
					part.CanCollide = false
					part.CanTouch = false
					part.CanQuery = false
				end

				local v5 = v4 * CFrame.Angles(0, math.rad(math.random(0, 3) * 90), 0)
				folder:PivotTo(v5)
				local boundingBox, v6 = folder:GetBoundingBox()
				local v7 = boundingBox.Position.Y - v6.Y / 2
				folder:PivotTo(folder:GetPivot() + Vector3.new(0, v5.Position.Y - v7, 0))
				folder.Parent = workspace
			end
		end)
	end
end

local v3 = PartyEvent.new({
	DisplayName = "OG Party",
	RequiresRespawnRefire = false,
	Sounds = {}
})

function v3.OnStart(_, p, _, _, _)
	v2:setup(p.janitor)
	local giantNoob = createGiantNoob()

	if not giantNoob then
		return
	end

	p.janitor:Add(giantNoob)
	local noobStreamer = createNoobStreamer(p, giantNoob)
	p.noobStreamer = noobStreamer
	local v4 = SharedSyncedEvent.new(oGParty.SyncChannelName)
	p.janitor:Add(v4, "destroy")
	local v5 = false
	local v6 = false

	local function trySpawn(positions)
		if v5 or type(positions) ~= "table" or not (#positions > 0) then
			if not v5 and type(positions) == "table" and #positions == 0 then
				warn("[OGParty] No dancing-noob positions were received")
			end
		else
			v5 = true
			noobStreamer.setPositions(positions)
			local character = Players.LocalPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				noobStreamer.update(os.clock(), humanoidRootPart.Position)
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function trySpawnHomes(happyHomePositions)
		if not v6 and type(happyHomePositions) == "table" and #happyHomePositions > 0 then
			v6 = true
			spawnHappyHomes(p, happyHomePositions)
		end
	end

	v4:onChange("Positions", trySpawn)
	v4:onChange("HappyHomePositions", trySpawnHomes)
	trySpawn(v4:get("Positions"))
	trySpawnHomes(v4:get("HappyHomePositions")) -- equivalent call inferred; original call site unknown
end

function v3.OnRender(_, p, p2, _, p3, _)
	v2:update(p2)

	if p.noobStreamer and p3 then
		p.noobStreamer.update(p2, p3.Position)
	end
end

return v3