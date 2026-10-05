local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local parentModule = require(script.Parent.Parent)
local BonusManager = require(ReplicatedStorage.BonusManager)
local Config = require(script.Config)
local HuntView = require(script.HuntView)
local SoundFade = require(ReplicatedStorage.Utilities.Events.SoundFade)

local function getNormalKeycaps()
	local parts = {}

	for _, part in ServerStorage.KeycapsStorage:GetDescendants() do
		if part:IsA("MeshPart") and part:GetAttribute("Type") ~= "Event" then
			table.insert(parts, part)
		end
	end

	return parts
end

local function getMultiplier(p: number)
	local multiplier = 1

	for _, milestone in Config.milestones do
		if milestone.progress <= p then
			multiplier = milestone.multiplier
		end
	end

	return multiplier
end

local function buildServerRuntime(data)
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = 0
	local progress = 0
	local multiplier2 = 1
	local count = 0
	local v7 = 0
	local v8 = 0

	local function getRemainingSeconds()
		return (math.max(1, (data.durationSeconds or Config.defaultDurationSeconds) - data.elapsedSeconds))
	end

	local function findSpawnKeycap()
		if #v == 0 then
			return nil
		end

		local players = Players:GetPlayers()
		local v9

		if #players > 0 then
			v9 = players[math.random(1, #players)]
		end

		local character = v9 and v9.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local v10 = Config.spawnRadiusMinStuds * Config.spawnRadiusMinStuds
		local v11 = Config.spawnRadiusMaxStuds * Config.spawnRadiusMaxStuds

		for _ = 1, 60 do
			local v12 = v[math.random(1, #v)]

			if v3[v12] then
				continue
			end

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				return v12
			end

			local v13 = v12.Position - humanoidRootPart.Position
			local v14 = v13.X * v13.X + v13.Z * v13.Z

			if v10 <= v14 and v14 <= v11 then
				return v12
			end
		end

		return nil
	end

	local function spawnCollectible()
		local spawnKeycap = findSpawnKeycap()

		if not spawnKeycap then
			return
		end

		count += 1
		local v9 = {
			id = count,
			cframe = spawnKeycap.CFrame * CFrame.new(0, spawnKeycap.Size.Y / 2 + Config.hoverHeightStuds, 0),
			keycap = spawnKeycap
		}
		v2[count] = v9
		v3[spawnKeycap] = true
		v4 += 1
		data.FireServerEventToAll({
			kind = "spawn",
			id = v9.id,
			cframe = v9.cframe
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyMultiplier(multiplier: number)
		if multiplier == multiplier2 then
			return
		end

		multiplier2 = multiplier
		BonusManager:StopBonus("server", "XP", nil, "ChocolateHunt")

		if multiplier2 > 1 then
			BonusManager:ActivateBonus(
				"server",
				"XP",
				multiplier2,
				math.max(1, (data.durationSeconds or Config.defaultDurationSeconds) - data.elapsedSeconds),
				nil,
				"ChocolateHunt"
			)
		end
	end

	local function collect(p, p2)
		v2[p.id] = nil
		v3[p.keycap] = nil
		v4 -= 1
		progress = math.min(Config.goal, progress + 1)
		local v9 = multiplier2
		local v10 = progress
		local multiplier = 1

		for _, milestone in Config.milestones do
			if milestone.progress <= v10 then
				multiplier = milestone.multiplier
			end
		end

		applyMultiplier(multiplier) -- equivalent call inferred; original call site unknown
		data.FireServerEventToAll({
			kind = "collected",
			id = p.id,
			progress = progress,
			multiplier = multiplier2,
			collectorUserId = p2.UserId,
			milestoneReached = v9 < multiplier2
		})
	end

	local function updateCollections()
		local v9 = Config.collectionRadiusStuds * Config.collectionRadiusStuds

		for _, v10 in Players:GetPlayers() do
			local character = v10.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				continue
			end

			for _, v12 in v2 do
				local vector2 = humanoidRootPart.Position - v12.cframe.Position

				if not (vector2:Dot(vector2) <= v9) then
					continue
				end

				collect(v12, v10)
				break
			end
		end
	end

	local function sendSnapshot(p)
		local collectibles = {}

		for _, v10 in v2 do
			table.insert(collectibles, {
				id = v10.id,
				cframe = v10.cframe
			})
		end

		data.FireServerEventToPlayer(p, {
			kind = "snapshot",
			progress = progress,
			multiplier = multiplier2,
			collectibles = collectibles
		})
	end

	return {
		onStart = function()
			v = getNormalKeycaps()
			local serverTimeNow = Workspace:GetServerTimeNow()
			v7 = serverTimeNow
			v8 = serverTimeNow

			if #v == 0 then
				warn("[ChocolateHunt] ServerStorage.KeycapsStorage contains no normal keycaps")
			end
		end,
		onUpdate = function(_: number)
			local serverTimeNow = Workspace:GetServerTimeNow()

			if progress < Config.goal and v4 < Config.maxActiveCollectibles and v7 <= serverTimeNow then
				v7 = serverTimeNow + Config.spawnIntervalSeconds
				spawnCollectible()

				if v4 < Config.initialCollectibles then
					spawnCollectible()
				end
			end

			if v8 <= serverTimeNow then
				v8 = serverTimeNow + Config.collectionCheckIntervalSeconds
				updateCollections()
			end
		end,
		onPlayerAdded = sendSnapshot,
		onStop = function(_)
			BonusManager:StopBonus("server", "XP", nil, "ChocolateHunt")

			if multiplier2 > 1 then
				BonusManager:ActivateBonus(
					"server",
					"XP",
					multiplier2,
					Config.postEventBoostDurationSeconds,
					nil,
					"ChocolateHunt"
				)
			end

			table.clear(v2)
			table.clear(v3)
		end
	}
end

local function createFallbackChocolate()
	local model = Instance.new("Model")
	model.Name = "ChocolateHuntCollectible"

	for i = -1, 1 do
		for i2 = -1, 1 do
			local part = Instance.new("Part")
			part.Name = "ChocolatePiece"
			part.Size = createVector(1.15, 0.5, 1.15)
			part.Position = Vector3.new(i2 * 1.08, 0, i * 1.08)
			part.Color = Color3.fromRGB(105, 55, 32)
			part.Material = Enum.Material.SmoothPlastic
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Parent = model
		end
	end

	return model
end

local function buildClientRuntime(data)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local v

	if playerGui then
		v = HuntView.mount(playerGui)
	else
		v = nil
	end

	local folder = Instance.new("Folder")
	folder.Name = "ChocolateHuntCollectibles"
	folder.Parent = Workspace
	data.janitor:Add(folder)
	local v2 = {}
	local v3 = true
	local v4 = nil
	local v5 = nil
	local v6 = nil
	local v7 = -1

	if v then
		data.janitor:Add(v.destroy)
	end

	local function playNextTrack()
		local v8 = v5

		if not v8 or #Config.musicSoundIds == 0 then
			return
		end

		local musicSoundId = Config.musicSoundIds[math.random(1, #Config.musicSoundIds)]

		if #Config.musicSoundIds > 1 then
			while musicSoundId == v4 do
				musicSoundId = Config.musicSoundIds[math.random(1, #Config.musicSoundIds)]
			end
		end

		v4 = musicSoundId
		v8.SoundId = musicSoundId
		v8.TimePosition = 0
		v8:Play()
		v6:fadeIn()
	end

	local function startPlaylist()
		if #Config.musicSoundIds == 0 then
			return
		end

		local sound = Instance.new("Sound")
		sound.Name = "ChocolateHuntMusic"
		sound.Volume = 0
		sound.Looped = false
		sound:SetAttribute("IsEventSound", true)
		sound.Parent = SoundService
		v5 = sound
		v6 = SoundFade.new(sound, {
			fadeIn = 0.5,
			fadeOut = 1,
			volume = Config.musicVolume
		})
		data.janitor:Add(sound.Ended:Connect(playNextTrack))
		data.janitor:Add(sound)
		playNextTrack()
	end

	local function prepareInstance(part)
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
		end

		for _, part2 in part:GetDescendants() do
			if not part2:IsA("BasePart") then
				continue
			end

			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
		end
	end

	local function setInstanceCFrame(instance, cFrame: CFrame)
		if instance:IsA("Model") then
			instance:PivotTo(cFrame)
		elseif instance:IsA("BasePart") then
			instance.CFrame = cFrame
		end
	end

	local function spawnVisual(id: number, cframe: CFrame)
		if v2[id] or not v3 then
			return
		end

		local events = ReplicatedStorage.Assets:FindFirstChild("Events")
		local chocolateHuntCollectible = events and events:FindFirstChild("ChocolateHuntCollectible")
		local clone

		if chocolateHuntCollectible and (chocolateHuntCollectible:IsA("Model") or chocolateHuntCollectible:IsA("BasePart")) then
			clone = chocolateHuntCollectible:Clone()
		else
			clone = createFallbackChocolate()
		end

		prepareInstance(clone)
		clone.Parent = folder

		if clone:IsA("Model") then
			clone:PivotTo(cframe)
		elseif clone:IsA("BasePart") then
			clone.CFrame = cframe
		end

		v2[id] = {
			instance = clone,
			baseCFrame = cframe,
			phase = math.random() * 3.141592653589793 * 2
		}
	end

	local function collectVisual(id: number)
		local v8 = v2[id]

		if not v8 then
			return
		end

		v2[id] = nil
		local pivot

		if v8.instance:IsA("Model") then
			pivot = v8.instance:GetPivot()
		else
			pivot = v8.instance.CFrame
		end

		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(1, 1, 1)
		part.CFrame = pivot
		part.Color = Color3.fromRGB(255, 190, 90)
		part.Material = Enum.Material.Neon
		part.Transparency = 0.15
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Parent = folder
		v8.instance:Destroy()
		TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(8, 8, 8),
			Transparency = 1
		}):Play()
		task.delay(0.35, function()
			part:Destroy()
		end)
	end

	return {
		onStart = startPlaylist,
		onUpdate = function(_: number)
			local serverTimeNow = Workspace:GetServerTimeNow()
			local v8 = math.max(
				0,
				(math.ceil((data.durationSeconds or Config.defaultDurationSeconds) - data.elapsedSeconds))
			)

			if v and v8 ~= v7 then
				v7 = v8
				v.updateTimer(v8)
			end

			for _, v9 in v2 do
				local v10 = math.sin(serverTimeNow * Config.bobSpeed + v9.phase) * Config.bobHeightStuds
				local instance = v9.instance
				local cFrame = v9.baseCFrame * CFrame.new(0, v10, 0) * CFrame.Angles(
					0,
					serverTimeNow * Config.rotationSpeed,
					0
				)

				if instance:IsA("Model") then
					instance:PivotTo(cFrame)
				elseif instance:IsA("BasePart") then
					instance.CFrame = cFrame
				end
			end
		end,
		onServerEvent = function(data2)
			if data2.kind == "spawn" then
				spawnVisual(data2.id, data2.cframe)
			elseif data2.kind == "collected" then
				collectVisual(data2.id)

				if v then
					v.update(data2.progress, data2.multiplier)
				end

				if data2.milestoneReached or data2.collectorUserId == Players.LocalPlayer.UserId then
					task.spawn(function()
						local NotificationSystem = require(ReplicatedStorage.NotificationSystem)

						if data2.milestoneReached then
							NotificationSystem:ShowGeneralNotification(
								`CHOCOLATE HUNT: x{data2.multiplier} XP UNLOCKED!`,
								Color3.fromRGB(255, 204, 85),
								5
							)
						else
							NotificationSystem:ShowGeneralNotification(
								`Chocolate collected! {data2.progress} / {Config.goal}`,
								Color3.fromRGB(190, 112, 65),
								2.5
							)
						end
					end)
				end
			elseif data2.kind == "snapshot" then
				if v then
					v.update(data2.progress, data2.multiplier)
				end

				for k, collectible in data2.collectibles do
					local v8 = collectible
					task.delay((k - 1) * 0.025, function()
						spawnVisual(v8.id, v8.cframe)
					end)
				end
			end
		end,
		onStop = function(_)
			v3 = false

			if v5 and v6 then
				v6:fadeOut(function()
					if v5 then
						v5:Stop()
					end
				end)
			end
		end
	}
end

parentModule.register(script.Name, {
	displayName = "Chocolate Hunt",
	slot = "event",
	needsDuration = true,
	defaultDurationSeconds = Config.defaultDurationSeconds,
	maxDurationSeconds = Config.maxDurationSeconds,
	load = function(p)
		if RunService:IsServer() then
			return (buildServerRuntime(p))
		end

		return (buildClientRuntime(p))
	end
})
return {}