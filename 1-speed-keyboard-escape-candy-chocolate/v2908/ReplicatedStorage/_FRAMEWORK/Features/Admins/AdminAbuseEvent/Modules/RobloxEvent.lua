local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local parentModule = require(script.Parent.Parent)
local Config = require(script.Config)
local AAEventWinAward = require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
local SoundFade = require(ReplicatedStorage.Utilities.Events.SoundFade)
require(script.Types)
local timer2 = Config.fallDurationSeconds + Config.blinkDurationSeconds

local function getAliveRoot(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function preparePart(p, anchored: boolean)
	p.Anchored = anchored
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
end

local function createSoundTemplate(soundId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.RollOffMinDistance = 40
	sound.RollOffMaxDistance = 250
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	return sound
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playClonedSound(instance, part, p: number)
	local clone = instance:Clone()
	clone.Parent = part
	clone:Play()
	Debris:AddItem(clone, p)
end

local function buildServerRuntime(data)
	local KeycapCache = require(ServerScriptService.Utilities.KeycapCache)
	local v2 = AAEventWinAward.create({
		source = Config.winSource
	})
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = 0
	local count = 0
	local v8 = 0
	local flag = true

	local function collectUprightKeycaps()
		local result = {}

		for _, v9 in KeycapCache.getAllKeycaps() do
			local dot = v9.CFrame.UpVector:Dot(createVector(0, 1, 0))

			if Config.uprightDotMin <= dot and dot <= Config.uprightDotMax then
				table.insert(result, v9)
			end
		end

		return result
	end

	local function pickKeycapNearPosition(position: Vector3)
		local v9 = Config.spawnRadiusMinStuds * Config.spawnRadiusMinStuds
		local v10 = Config.spawnRadiusMaxStuds * Config.spawnRadiusMaxStuds
		local v11 = {}

		for _, v12 in v6 do
			local v13 = v12.Position - position
			local v14 = v13.X * v13.X + v13.Z * v13.Z

			if v9 <= v14 and v14 <= v10 then
				table.insert(v11, v12)
			end
		end

		if #v11 > 0 then
			return v11[math.random(1, #v11)]
		end

		return nil
	end

	local function applySpawn(keycap)
		count += 1
		local v9 = {
			id = count,
			position = (keycap.CFrame * CFrame.new(0, keycap.Size.Y / 2 + Config.trophyHoverHeightStuds, 0)).Position,
			timer = timer2
		}
		v3[count] = v9
		v7 += 1
		data.FireServerEventToAll({
			kind = "spawn",
			id = v9.id,
			position = v9.position,
			timer = v9.timer
		})
	end

	local function explode(p)
		for _, v9 in Players:GetPlayers() do
			local character = v9.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				continue
			end

			if not ((humanoidRootPart.Position - p.position).Magnitude <= Config.explosionRadiusStuds) then
				continue
			end

			humanoid.Health = 0
		end
	end

	local function checkCollect(player, p)
		if type(p) ~= "table" then
			p = nil
		end

		local v9

		if p and p.kind == "collect" and type(p.id) == "number" then
			v9 = v3[p.id]
		end

		local v10 = v4[player]
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = nil
		end

		if not p or p.kind ~= "collect" or type(p.id) ~= "number" then
			return false, nil
		end

		if not v9 or v9.timer > 0 or v10 and os.clock() - v10 < Config.collectCooldownSeconds or not humanoidRootPart then
			return false, nil
		end

		if (humanoidRootPart.Position - v9.position).Magnitude > Config.collectMaxDistanceStuds then
			return false, nil
		end

		return true, v9
	end

	local function applyCollect(p, p2)
		v3[p2.id] = nil
		v7 -= 1
		v4[p] = os.clock()
		v2(p)
		data.FireServerEventToAll({
			kind = "collected",
			id = p2.id
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyExpire(p)
		v3[p.id] = nil
		v7 -= 1
		data.FireServerEventToAll({
			kind = "expired",
			id = p.id
		})
	end

	local function enqueueWave(serverTimeNow: number)
		local v9 = {}

		for _, v10 in Players:GetPlayers() do
			local humanoidRootPart = v10.Character and v10.Character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				continue
			end

			for _ = 1, math.random(Config.spawnPerPlayerMin, Config.spawnPerPlayerMax) do
				local v11 = pickKeycapNearPosition(humanoidRootPart.Position)

				if v7 + #v5 + #v9 < Config.maxActive and v11 then
					table.insert(v9, v11)
				end
			end
		end

		local count2 = #v9
		local v10 = not (count2 > 1) and 0 or Config.spawnStaggerWindowSeconds / (count2 - 1)

		for k, keycap in v9 do
			table.insert(v5, {
				keycap = keycap,
				spawnAt = serverTimeNow + (k - 1) * v10
			})
		end
	end

	local function flushPendingSpawns(serverTimeNow: number)
		local v9 = {}

		for _, v10 in v5 do
			if v10.spawnAt <= serverTimeNow then
				applySpawn(v10.keycap)
			else
				table.insert(v9, v10)
			end
		end

		v5 = v9
	end

	return {
		onStart = function()
			v8 = Workspace:GetServerTimeNow() + Config.firstWaveDelaySeconds
			v6 = collectUprightKeycaps()

			if #v6 == 0 then
				warn("[RobloxEvent] KeycapCache has no upright keycaps")
			end

			data.janitor:Add(Players.PlayerRemoving:Connect(function(player)
				v4[player] = nil
			end))
		end,
		onUpdate = function(p: number)
			if flag then
				local serverTimeNow = Workspace:GetServerTimeNow()

				if v8 <= serverTimeNow then
					v8 = serverTimeNow + Config.spawnWaveIntervalSeconds
					enqueueWave(serverTimeNow)
				end

				flushPendingSpawns(serverTimeNow)
				local v9 = {}

				for _, v10 in v3 do
					if v10.timer > 0 then
						v10.timer -= p

						if v10.timer <= 0 then
							v10.timer = 0
							v10.expireAt = serverTimeNow + Config.trophyLifetimeSeconds
							explode(v10)
						end
					elseif v10.expireAt and v10.expireAt <= serverTimeNow then
						table.insert(v9, v10)
					end
				end

				for _, v10 in v9 do
					applyExpire(v10) -- equivalent call inferred; original call site unknown
				end
			end
		end,
		onPlayerAdded = function(p)
			local drops = {}

			for _, v10 in v3 do
				table.insert(drops, {
					kind = "spawn",
					id = v10.id,
					position = v10.position,
					timer = v10.timer
				})
			end

			data.FireServerEventToPlayer(p, {
				kind = "snapshot",
				drops = drops
			})
		end,
		onClientEvent = function(p, p2)
			local v9, v10 = checkCollect(p, p2)

			if v9 then
				applyCollect(p, v10)
			end
		end,
		onStop = function(_)
			flag = false
			table.clear(v3)
			table.clear(v4)
			table.clear(v5)
		end
	}
end

local function buildClientRuntime(p)
	local robloxEvent = ReplicatedStorage.Assets.Events.RobloxEvent
	local rblxLogo = robloxEvent.RblxLogo
	local trophy = robloxEvent.Trophy
	local v2 = {}
	local v3 = {}
	local v4 = {}
	local tickSoundId = Config.tickSoundId
	local sound = Instance.new("Sound")
	sound.SoundId = tickSoundId
	sound.RollOffMinDistance = 40
	sound.RollOffMaxDistance = 250
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	local explosionSoundId = Config.explosionSoundId
	local sound2 = Instance.new("Sound")
	sound2.SoundId = explosionSoundId
	sound2.RollOffMinDistance = 40
	sound2.RollOffMaxDistance = 250
	sound2.RollOffMode = Enum.RollOffMode.InverseTapered
	local v5 = nil
	local flag = true
	local v6 = nil
	local v7 = nil
	local v8 = nil
	local v9 = false

	local function isMainSlotActive()
		for _, v10 in parentModule.getActiveStates() do
			if v10.slot == "main" then
				return true
			end
		end

		return false
	end

	local function isEventMusicLocked()
		if Players.LocalPlayer:GetAttribute("AdminAbuseEventMusicLocked") == true then
			return true
		else
			for _, v11 in parentModule.getActiveStates() do
				if v11.slot == "main" then
					return true
				end
			end

			return false
		end
	end

	local function applyMusicLock()
		local flag2

		if Players.LocalPlayer:GetAttribute("AdminAbuseEventMusicLocked") == true then
			flag2 = true
		else
			local flag3 = true

			for _, v10 in parentModule.getActiveStates() do
				if v10.slot ~= "main" then
					continue
				end

				flag2 = true
				flag3 = false
				break
			end

			if flag3 then
				flag2 = false
			end
		end

		if flag2 ~= v9 then
			v9 = flag2

			if v8 and v7 then
				if flag2 then
					v8:fadeOut()
				else
					v8:fadeIn()
				end
			end
		end
	end

	local function playNextTrack()
		local v10 = v7

		if v10 and #Config.musicSoundIds > 0 then
			local musicSoundId = Config.musicSoundIds[math.random(1, #Config.musicSoundIds)]

			if #Config.musicSoundIds > 1 then
				while musicSoundId == v6 do
					musicSoundId = Config.musicSoundIds[math.random(1, #Config.musicSoundIds)]
				end
			end

			v6 = musicSoundId
			v10.SoundId = musicSoundId
			v10.TimePosition = 0
			v10:Play()

			if not v9 then
				v8:fadeIn()
			end
		end
	end

	local function startPlaylist()
		if #Config.musicSoundIds > 0 then
			local sound3 = Instance.new("Sound")
			sound3.Name = "RobloxEventMusic"
			sound3.Volume = 0
			sound3.Looped = false
			sound3:SetAttribute("IsEventSound", true)
			sound3.Parent = SoundService
			v7 = sound3
			v8 = SoundFade.new(sound3, {
				fadeIn = 0.5,
				fadeOut = 1,
				volume = Config.musicVolume
			})
			local v10

			if Players.LocalPlayer:GetAttribute("AdminAbuseEventMusicLocked") == true then
				v10 = true
			else
				local flag2 = true

				for _, v11 in parentModule.getActiveStates() do
					if v11.slot ~= "main" then
						continue
					end

					v10 = true
					flag2 = false
					break
				end

				if flag2 then
					v10 = false
				end
			end

			v9 = v10
			playNextTrack()
		end
	end

	local function playExplosion(position: Vector3)
		local parent = v5

		if parent then
			local part = Instance.new("Part")
			part.Name = "LogoBombBurst"
			part.Shape = Enum.PartType.Ball
			part.Size = createVector(2, 2, 2)
			part.Position = position
			part.Color = Config.explosionColor
			part.Material = Enum.Material.Neon
			part.Transparency = 0.15
			preparePart(part, true) -- equivalent call inferred; original call site unknown
			part.Parent = parent
			local v11 = Config.explosionRadiusStuds * 2
			TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(v11, v11, v11),
				Transparency = 1
			}):Play()
			playClonedSound(sound2, part, 8) -- equivalent call inferred; original call site unknown
			Debris:AddItem(part, 8)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroyBomb(id: number)
		local v10 = v2[id]

		if v10 then
			v2[id] = nil

			if v10.tween then
				v10.tween:Cancel()
			end

			v10.part:Destroy()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroyTrophy(id: number)
		local v10 = v3[id]

		if v10 then
			v3[id] = nil
			v4[id] = nil
			v10.part:Destroy()
		end
	end

	local function spawnTrophy(p2: number, position: Vector3)
		local parent = v5

		if parent and flag and not v3[p2] then
			local clone = trophy:Clone()
			preparePart(clone, true) -- equivalent call inferred; original call site unknown
			clone.CFrame = CFrame.new(position)
			clone.Parent = parent
			v3[p2] = {
				part = clone,
				baseCFrame = clone.CFrame,
				phase = math.random() * 3.141592653589793 * 2
			}
		end
	end

	local function spawnBomb(p2: number, position: Vector3, p3: number)
		local parent = v5

		if parent and flag and not (v2[p2] or v3[p2]) then
			local explodeAt = Workspace:GetServerTimeNow() + p3
			local v12 = math.random() * 3.141592653589793 * 2
			local v13 = CFrame.new(position) * CFrame.Angles(0, v12, 0)
			local clone = rblxLogo:Clone()
			preparePart(clone, true) -- equivalent call inferred; original call site unknown
			clone.Parent = parent
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Config.blinkColor
			pointLight.Range = 20
			pointLight.Parent = clone
			local v14 = {
				part = clone,
				landCFrame = v13,
				explodeAt = explodeAt,
				originalColor = clone.Color,
				flashPhase = 0,
				flashOn = false,
				tween = nil,
				light = pointLight
			}
			v2[p2] = v14
			local v15 = p3 - Config.blinkDurationSeconds

			if v15 > 0 then
				clone.CFrame = v13 + Vector3.new(0, Config.fallHeightStuds, 0)
				local tween = TweenService:Create(
					clone,
					TweenInfo.new(v15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
					{
						CFrame = v13
					}
				)
				v14.tween = tween
				tween:Play()
			else
				clone.CFrame = v13
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function spawnDrop(id: number, position: Vector3, timer: number)
		if timer <= 0 then
			spawnTrophy(id, position)
		else
			spawnBomb(id, position, timer)
		end
	end

	return {
		onStart = function()
			local folder = Instance.new("Folder")
			folder.Name = "RobloxEventVisuals"
			folder.Parent = Workspace
			v5 = folder
			sound.Parent = folder
			sound2.Parent = folder
			local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
			NotificationSystem:ShowGeneralNotification(
				Config.notificationText,
				Config.notificationColor,
				Config.notificationDurationSeconds
			)
			startPlaylist()
			p.janitor:Add(folder)

			if v7 then
				p.janitor:Add(v7.Ended:Connect(function()
					if flag then
						playNextTrack()
					end
				end))
				p.janitor:Add(v7)
			end

			p.janitor:Add(parentModule.remotes.Activated:connect(applyMusicLock))
			p.janitor:Add(parentModule.remotes.Deactivated:connect(applyMusicLock))
			p.janitor:Add(Players.LocalPlayer:GetAttributeChangedSignal("AdminAbuseEventMusicLocked"):Connect(applyMusicLock))
			p.janitor:Add(function()
				table.clear(v2)
				table.clear(v3)
				table.clear(v4)
			end)
		end,
		onUpdate = function(p2: number)
			if flag then
				local serverTimeNow = Workspace:GetServerTimeNow()
				local v10 = {}

				for k, v11 in v2 do
					if v11.explodeAt <= serverTimeNow then
						table.insert(v10, {
							id = k,
							position = v11.landCFrame.Position
						})
					else
						local v12 = math.clamp(1 - (v11.explodeAt - serverTimeNow) / timer2, 0, 1)
						local v13 = Config.blinkRateMin + (Config.blinkRateMax - Config.blinkRateMin) * v12
						v11.flashPhase += p2 * v13 * 3.141592653589793 * 2
						local v14 = math.sin(v11.flashPhase) * 0.5 + 0.5
						local flashOn = v14 > 0.5
						v11.part.Color = v11.originalColor:Lerp(Config.blinkColor, v14)
						v11.light.Brightness = v14 * 6 + 1

						if flashOn and not v11.flashOn then
							playClonedSound(sound, v11.part, 2) -- equivalent call inferred; original call site unknown
						end

						v11.flashOn = flashOn
					end
				end

				for _, v11 in v10 do
					destroyBomb(v11.id) -- equivalent call inferred; original call site unknown
					playExplosion(v11.position)
					spawnTrophy(v11.id, v11.position)
				end

				for _, v11 in v3 do
					v11.part.CFrame = v11.baseCFrame * CFrame.new(
						0,
						math.sin(serverTimeNow * Config.trophyBobSpeed + v11.phase) * Config.trophyBobStuds,
						0
					) * CFrame.Angles(0, serverTimeNow * Config.trophySpinSpeed, 0)
				end

				local character = Players.LocalPlayer.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

				if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					humanoidRootPart = nil
				end

				if humanoidRootPart then
					local v11 = Config.collectRadiusStuds * Config.collectRadiusStuds

					for k, v12 in v3 do
						local vector2 = humanoidRootPart.Position - v12.part.Position

						if not (vector2:Dot(vector2) <= v11 and (v4[k] or 0) <= serverTimeNow) then
							continue
						end

						v4[k] = serverTimeNow + Config.collectRetrySeconds
						p.FireClientEvent({
							kind = "collect",
							id = k
						})
					end
				end
			end
		end,
		onServerEvent = function(data)
			if data.kind == "spawn" then
				spawnDrop(data.id, data.position, data.timer) -- equivalent call inferred; original call site unknown
			elseif data.kind == "collected" or data.kind == "expired" then
				destroyBomb(data.id) -- equivalent call inferred; original call site unknown
				destroyTrophy(data.id) -- equivalent call inferred; original call site unknown
			elseif data.kind == "snapshot" then
				for _, drop in data.drops do
					spawnDrop(drop.id, drop.position, drop.timer) -- equivalent call inferred; original call site unknown
				end
			end
		end,
		onStop = function(_)
			flag = false

			if v7 and v8 then
				v8:fadeOut(function()
					if v7 then
						v7:Stop()
					end
				end)
			end

			table.clear(v2)
			table.clear(v3)
			table.clear(v4)
		end
	}
end

parentModule.register(script.Name, {
	displayName = "Roblox Event",
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