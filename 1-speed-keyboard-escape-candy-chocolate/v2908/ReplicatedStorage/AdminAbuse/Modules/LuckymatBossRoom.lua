local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = nil
local v2 = nil
local v3 = nil
local LuckymatConfig = require(script.LuckymatConfig)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local LuckymatCutscenes = require(script.LuckymatCutscenes)
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local BossClientBase = require(ReplicatedStorage.AdminAbuse.Modules.Shared:WaitForChild("BossClientBase"))
local FakeAdminMessageUtil = require(ReplicatedStorage.Utilities.FakeAdminMessageUtil)
local luckymatBossRoom = ReplicatedStorage.AdminAbuse.LuckymatBossRoom
local assets = luckymatBossRoom.Assets
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = nil
local v8 = nil
local v9 = 1
local v10 = 0
local renderSteppedConnection = nil
local _ = {
	Warp = "rbxassetid://136081560081353",
	Summon = "rbxassetid://119573908217733",
	PortalOpen = "rbxassetid://111878775341423",
	SniperAim = "rbxassetid://100381484858434",
	SniperShot = "rbxassetid://124583632306554",
	FireballCast = "rbxassetid://80624479410185",
	FireballHit = "rbxassetid://135676461695962",
	Hit = "rbxassetid://136811265205147",
	Kill = "rbxassetid://139520673393967",
	MageTeleportStart = "rbxassetid://135640489101126",
	MageTeleportLand = "rbxassetid://136223034485147",
	KingElectricZap = "rbxassetid://118901970008718",
	KingThunder = "rbxassetid://128859265290061",
	Roar = "rbxassetid://140076040328382"
}
local v11 = nil
local v12 = nil
local visible = nil
local v13 = nil
local v14 = nil
local heartbeatConnection = nil
local v15 = nil
local v16 = nil

local function posKey(p: number, p2: number, p3: number)
	return string.format("%.1f_%.1f_%.1f", p, p2, p3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureNotificationSystem()
	if not v then
		local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
		v = NotificationSystem
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureClientState()
	if not v2 then
		local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
		v2 = ClientState
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureConfig()
	if not v3 then
		local Config = require(ReplicatedStorage:WaitForChild("Config"))
		v3 = Config
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerBaseSpeed()
	ensureClientState() -- equivalent call inferred; original call site unknown
	ensureConfig() -- equivalent call inferred; original call site unknown
	local v17 = v2:Get()

	if v17.CustomWalkSpeed and v17.CustomWalkSpeed > 0 then
		return v17.CustomWalkSpeed
	end

	return v3.CalculateMaxSpeed(v17.Level or 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopKingSlowEnforcer()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v9 = 1
	v10 = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureKingSlowEnforcer()
	if renderSteppedConnection then
		return
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local now = os.clock()

		if v10 <= now then
			v9 = 1
			return
		end

		if v9 >= 1 then
			return
		end

		local localPlayer = Players.LocalPlayer
		local luckymatKingSlowMult = localPlayer:GetAttribute("LuckymatKingSlowMult")
		local luckymatKingSlowUntil = localPlayer:GetAttribute("LuckymatKingSlowUntil")

		if type(luckymatKingSlowMult) ~= "number" or type(luckymatKingSlowUntil) ~= "number" or luckymatKingSlowUntil <= os.clock() then
			v9 = 1
			return
		end

		v9 = luckymatKingSlowMult
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local playerBaseSpeed = getPlayerBaseSpeed() -- equivalent call inferred; original call site unknown
			humanoid.WalkSpeed = playerBaseSpeed * v9
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyKingSlowDebuff(percent: number, duration: number)
	v9 = 1 - (percent or 0.45)
	v10 = os.clock() + (duration or 3.5)
	ensureKingSlowEnforcer() -- equivalent call inferred; original call site unknown
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		local playerBaseSpeed = getPlayerBaseSpeed() -- equivalent call inferred; original call site unknown
		humanoid.WalkSpeed = playerBaseSpeed * v9
	end
end

local function screenShakeNearby(p: number, p2: number, p3: number, p4: number)
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local magnitude = (humanoidRootPart.Position - Vector3.new(p, p2, p3)).Magnitude

	if p4 * 3 < magnitude then
		return
	end

	local v17 = math.clamp(1 - magnitude / (p4 * 3), 0.1, 1) * 0.6
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local total = 0
	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
		total += dt

		if total >= 0.4 then
			renderSteppedConnection2:Disconnect()
			return
		end

		local v18 = v17 * (1 - total / 0.4)
		currentCamera.CFrame *= CFrame.new((math.random() * 2 - 1) * v18, (math.random() * 2 - 1) * v18, 0)
	end)
end

local function posKey2(p: number, p2: number, p3: number)
	return string.format("%.1f_%.1f_%.1f", p, p2, p3)
end

local function setLaserBetween(p, vector2: Vector3, vector3: Vector3, p2: number, color: Color3)
	local v17 = vector3 - vector2
	local magnitude = v17.Magnitude

	if magnitude < 0.05 then
		p.Transparency = 1
		return
	end

	p.Transparency = 0
	p.Size = Vector3.new(p2, p2, magnitude)
	p.Color = color
	p.CFrame = CFrame.lookAt(vector2 + v17 * 0.5, vector3)
end

local function findNpcModel(p: string?)
	if not p then
		return nil
	end

	for _, v17 in CollectionService:GetTagged("AABossNpc") do
		if v17.Name == p then
			return v17
		end
	end

	return nil
end

local function findNpcRoot(p: string?)
	local v17

	if p then
		for _, v19 in CollectionService:GetTagged("AABossNpc") do
			if v19.Name ~= p then
				continue
			end

			v17 = v19
			break
		end
	end

	if v17 then
		return (v17:FindFirstChild("HumanoidRootPart"))
	end

	return nil
end

local function fxPlaySound(data)
	local id = data.id

	if type(id) ~= "string" or id == "" then
		return
	end

	local vol = data.vol or 1
	local pitch = data.pitch or 1
	local global = data.global == true
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = vol
	sound.PlaybackSpeed = pitch

	if global then
		sound.Parent = Players.LocalPlayer or workspace
	else
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Position = Vector3.new(data.x or 0, data.y or 0, data.z or 0)
		part.Parent = workspace

		if data.minDist then
			sound.RollOffMinDistance = data.minDist
		end

		if data.maxDist then
			sound.RollOffMaxDistance = data.maxDist
		end

		sound.Parent = part
		sound.Ended:Once(function()
			pcall(function()
				part:Destroy()
			end)
		end)
		Debris:AddItem(part, 12)
	end

	sound:Play()
	Debris:AddItem(sound, 12)
end

local function playSpatialSound(vector2: Vector3, id: string, value: number?, value2: number?, value3: number?, value4: number?)
	fxPlaySound({
		id = id,
		x = vector2.X,
		y = vector2.Y,
		z = vector2.Z,
		vol = value or 1,
		minDist = value2 or 20,
		maxDist = value3 or 700,
		pitch = value4 or 1
	})
end

local function fxNpcHitBlink(data, flag: boolean?)
	local npcId = data.npcId
	local parent

	if npcId then
		for _, v19 in CollectionService:GetTagged("AABossNpc") do
			if v19.Name ~= npcId then
				continue
			end

			parent = v19
			break
		end
	end

	if not (parent and parent.Parent) then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		if flag then
			local position = humanoidRootPart.Position
			fxPlaySound({
				id = "rbxassetid://139520673393967",
				x = position.X,
				y = position.Y,
				z = position.Z,
				vol = 1,
				minDist = 20,
				maxDist = 700,
				pitch = 1
			})
		else
			local position = humanoidRootPart.Position
			fxPlaySound({
				id = "rbxassetid://136811265205147",
				x = position.X,
				y = position.Y,
				z = position.Z,
				vol = 0.75,
				minDist = 20,
				maxDist = 700,
				pitch = 1
			})
		end
	end

	local v18 = parent:FindFirstChild("LuckymatHitFlash")

	if not (v18 and v18:IsA("Highlight")) then
		v18 = Instance.new("Highlight")
		v18.Name = "LuckymatHitFlash"
		v18.FillColor = Color3.fromRGB(255, 75, 75)
		v18.OutlineTransparency = 1
		v18.Parent = parent
	end

	v18.FillTransparency = 0.5
	TweenService:Create(v18, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		FillTransparency = 1
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fxSniperAim(data)
	task.spawn(function()
		local npcId = data.npcId
		local userId = data.userId
		local trackSec = data.trackSec or 1
		local lockSec = data.lockSec or 0.2
		local v17

		if npcId then
			for _, v19 in CollectionService:GetTagged("AABossNpc") do
				if v19.Name ~= npcId then
					continue
				end

				v17 = v19
				break
			end
		end

		local humanoidRootPart

		if v17 then
			humanoidRootPart = v17:FindFirstChild("HumanoidRootPart")
		end

		if humanoidRootPart then
			local position = humanoidRootPart.Position
			fxPlaySound({
				id = "rbxassetid://100381484858434",
				x = position.X,
				y = position.Y,
				z = position.Z,
				vol = 1,
				minDist = 20,
				maxDist = 700,
				pitch = 1
			})
		end

		local part = Instance.new("Part")
		part.Name = "SniperAimLaser"
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 50, 50)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Parent = workspace
		local total = 0
		local position = nil

		while total < trackSec and part.Parent do
			total += RunService.Heartbeat:Wait()
			local v18

			if npcId then
				for _, v20 in CollectionService:GetTagged("AABossNpc") do
					if v20.Name ~= npcId then
						continue
					end

					v18 = v20
					break
				end
			end

			local humanoidRootPart2

			if v18 then
				humanoidRootPart2 = v18:FindFirstChild("HumanoidRootPart")
			end

			local playerByUserId = Players:GetPlayerByUserId(userId)
			local humanoidRootPart3 = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart2 and humanoidRootPart3) then
				continue
			end

			position = humanoidRootPart3.Position
			local position2 = humanoidRootPart2.Position
			local color = Color3.fromRGB(255, 60, 60)
			local v19 = position - position2
			local magnitude = v19.Magnitude

			if magnitude < 0.05 then
				part.Transparency = 1
			else
				part.Transparency = 0
				part.Size = Vector3.new(0.22, 0.22, magnitude)
				part.Color = color
				part.CFrame = CFrame.lookAt(position2 + v19 * 0.5, position)
			end
		end

		if not (part.Parent and position) then
			pcall(function()
				part:Destroy()
			end)
			return
		end

		local total2 = 0

		while total2 < lockSec and part.Parent do
			total2 += RunService.Heartbeat:Wait()
			local v18

			if npcId then
				for _, v20 in CollectionService:GetTagged("AABossNpc") do
					if v20.Name ~= npcId then
						continue
					end

					v18 = v20
					break
				end
			end

			local humanoidRootPart2

			if v18 then
				humanoidRootPart2 = v18:FindFirstChild("HumanoidRootPart")
			end

			if not humanoidRootPart2 then
				continue
			end

			local v19 = math.sin(total2 * 40) * 0.06 + 0.22
			local position2 = humanoidRootPart2.Position
			local color = Color3.fromRGB(255, 164, 164)
			local v20 = position - position2
			local magnitude = v20.Magnitude

			if magnitude < 0.05 then
				part.Transparency = 1
			else
				part.Transparency = 0
				part.Size = Vector3.new(v19, v19, magnitude)
				part.Color = color
				part.CFrame = CFrame.lookAt(position2 + v20 * 0.5, position)
			end
		end

		TweenService:Create(part, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		task.delay(0.1, function()
			pcall(function()
				part:Destroy()
			end)
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenFireballArc(part, vector2: Vector3, vector3: Vector3, travelSec: number)
	local v17 = math.clamp((vector2 - vector3).Magnitude * 0.42, 14, 48)
	local v18 = (vector2 + vector3) * 0.5 + Vector3.new(0, v17, 0)
	local total = 0
	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
		total += dt
		local v19 = math.clamp(total / travelSec, 0, 1)
		local v20 = 1 - v19
		local v21 = v20 * v20 * vector2 + v20 * 2 * v19 * v18 + v19 * v19 * vector3
		part.CFrame = CFrame.new(v21)

		if v19 >= 1 then
			renderSteppedConnection2:Disconnect()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fxKingFireballArc(data)
	task.spawn(function()
		local vector2 = Vector3.new(data.px or 0, data.py or 0, data.pz or 0)
		local vector3 = Vector3.new(data.gx or 0, data.gy or 0, data.gz or 0)
		local travelSec = data.travelSec or 1
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(9.6, 9.6, 9.6)
		part.CFrame = CFrame.new(vector2)
		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 100, 20)
		part.Transparency = 0
		part.Parent = workspace
		table.insert(v6, part)
		local pointLight = Instance.new("PointLight", part)
		pointLight.Brightness = 8
		pointLight.Color = Color3.fromRGB(255, 120, 40)
		pointLight.Range = 44
		local fire = Instance.new("Fire")
		fire.Size = 14
		fire.Parent = part
		fxPlaySound({
			id = "rbxassetid://80624479410185",
			x = vector2.X,
			y = vector2.Y,
			z = vector2.Z,
			vol = 0.85,
			minDist = 20,
			maxDist = 700,
			pitch = 1
		})
		tweenFireballArc(part, vector2, vector3, travelSec) -- equivalent call inferred; original call site unknown
		task.wait(travelSec)
		local index = table.find(v6, part)

		if index then
			table.remove(v6, index)
		end

		pcall(function()
			part:Destroy()
		end)
	end)
end

local function fxKingThunderStormStart(data)
	local duration = data.duration or 1.5
	local v17 = Lighting:FindFirstChild("KingThunderCC")

	if not v17 then
		v17 = Instance.new("ColorCorrectionEffect")
		v17.Name = "KingThunderCC"
		v17.Parent = Lighting
	end

	TweenService:Create(v17, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TintColor = Color3.fromRGB(175, 195, 255),
		Saturation = -0.35,
		Contrast = 0.22,
		Brightness = 0.05
	}):Play()
	task.delay(duration, function()
		if v17.Parent then
			TweenService:Create(v17, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Saturation = 0,
				Contrast = 0,
				Brightness = 0
			}):Play()
			task.delay(0.8, function()
				pcall(function()
					v17:Destroy()
				end)
			end)
		end
	end)
end

local function fxSniperShot(data)
	local from = data.from
	local to = data.to

	if typeof(from) ~= "Vector3" or typeof(to) ~= "Vector3" then
		return
	end

	local v17 = to - from
	local magnitude = v17.Magnitude

	if magnitude < 0.1 then
		return
	end

	local hit = data.hit == true
	fxPlaySound({
		id = "rbxassetid://124583632306554",
		x = from.X,
		y = from.Y,
		z = from.Z,
		vol = 1,
		minDist = 20,
		maxDist = 700,
		pitch = 1
	})
	local part = Instance.new("Part")
	part.Name = "SniperTracer"
	part.Size = Vector3.new(hit and 0.8 or 0.6, hit and 0.8 or 0.6, magnitude)
	part.CFrame = CFrame.lookAt(from + v17 * 0.5, to)
	local color

	if hit then
		color = Color3.fromRGB(255, 220, 80)
	else
		color = Color3.fromRGB(255, 140, 50)
	end

	part.Color = color
	part.Material = Enum.Material.Neon
	part.Transparency = 0
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Parent = workspace
	local part2 = Instance.new("Part")
	part2.Shape = Enum.PartType.Ball
	part2.Size = Vector3.new(hit and 3.5 or 2, hit and 3.5 or 2, hit and 3.5 or 2)
	part2.CFrame = CFrame.new(to)
	part2.Color = part.Color
	part2.Material = Enum.Material.Neon
	part2.Transparency = hit and 0.1 or 0.45
	part2.Anchored = true
	part2.CanCollide = false
	part2.CastShadow = false
	part2.Parent = workspace
	TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
		Transparency = 1
	}):Play()
	TweenService:Create(part2, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
		Size = part2.Size * (hit and 2.5 or 1.5),
		Transparency = 1
	}):Play()
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(part, 0.5)
	local Debris3 = game:GetService("Debris")
	Debris3:AddItem(part2, 0.4)
end

local function fxMageCast(data)
	local origin = data.origin
	local radius = data.radius

	if typeof(origin) ~= "Vector3" or type(radius) ~= "number" then
		return
	end

	local part = Instance.new("Part")
	part.Name = "MageCastIndicator"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.3, radius * 2, radius * 2)
	part.CFrame = CFrame.new(origin.X, origin.Y - 0.5, origin.Z) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Color = Color3.fromRGB(160, 0, 220)
	part.Material = Enum.Material.Neon
	part.Transparency = 0.35
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Parent = workspace
	TweenService:Create(part, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Transparency = 1
	}):Play()
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(part, 1.6)
end

local function fxCrateOpen(data)
	if data.userId ~= Players.LocalPlayer.UserId then
		return
	end

	SoundManager:Play("WIN")
	local weaponName = data.weaponName or "Weapon"
	ensureNotificationSystem() -- equivalent call inferred; original call site unknown
	v:ShowGeneralNotification("Picked up " .. weaponName .. "!", Color3.fromRGB(255, 215, 0), 2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fxHealCrateOpen(data)
	if data.userId ~= Players.LocalPlayer.UserId then
		return
	end

	SoundManager:Play("WIN")
	ensureNotificationSystem() -- equivalent call inferred; original call site unknown
	v:ShowGeneralNotification("Healed to full HP!", Color3.fromRGB(100, 255, 120), 2)
end

local function playBurstBall(p: number, p2: number, p3: number, p4: number, color: Color3?)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(2, 2, 2)
	part.CFrame = CFrame.new(p, p2, p3)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = color or Color3.fromRGB(255, 80, 30)
	part.Transparency = 0.2
	part.Parent = workspace
	TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(p4 * 2, p4 * 2, p4 * 2),
		Transparency = 1
	}):Play()
	task.delay(0.4, function()
		pcall(function()
			part:Destroy()
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playExplosionAt(p: number, p2: number, p3: number, p4: number)
	playBurstBall(p, p2, p3, p4, Color3.fromRGB(255, 80, 30))
end

local function spawnGroundWarnDisk(p: number, p2: number, p3: number, r: number, duration: number, color: Color3)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.35, r * 2, r * 2)
	part.CFrame = CFrame.new(p, p2, p3) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.45
	part.Parent = workspace
	task.delay(duration, function()
		if part.Parent then
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			task.delay(0.3, function()
				pcall(function()
					part:Destroy()
				end)
			end)
		end
	end)
end

local function spawnHeadAimHint(tx: number, ty: number, tz: number, r: number, t: number)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.1, r * 1.5, r * 1.5)
	part.CFrame = CFrame.new(tx, ty + 0.05, tz) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 175, 95)
	part.Transparency = 0.78
	part.Parent = workspace
	task.delay(t, function()
		if part.Parent then
			TweenService:Create(part, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			task.delay(0.15, function()
				pcall(function()
					part:Destroy()
				end)
			end)
		end
	end)
end

local function cloneThunderHitAt(position: Vector3)
	local VFX = luckymatBossRoom:FindFirstChild("VFX")
	local thunderHit = VFX and (VFX:FindFirstChild("ThunderHit") or VFX:FindFirstChild("HitParticles") or VFX:FindFirstChild("Thunder"))

	if not thunderHit then
		local child = ReplicatedStorage:FindFirstChild(EventsConfig.Lightning.LightningFolder)
		thunderHit = child and child:FindFirstChild("HitParticles")
	end

	if thunderHit then
		local clone = thunderHit:Clone()

		if clone:IsA("BasePart") then
			clone.CFrame = CFrame.new(position)
		elseif clone:IsA("Model") then
			clone:PivotTo(CFrame.new(position))
		elseif clone:IsA("Attachment") then
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.Size = createVector(1, 1, 1)
			part.CFrame = CFrame.new(position)
			part.Parent = workspace
			local clone_2 = clone:Clone()
			clone_2.Parent = part
			clone = part
		end

		clone.Parent = workspace
		Debris:AddItem(clone, 3)
		task.delay(0.35, function()
			if clone and clone.Parent then
				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
						descendant.Enabled = false
					end
				end
			end
		end)
	end
end

local function playThunderBolt(vector2: Vector3, vector3: Vector3, value: number?)
	local v17 = value or 0.35
	local magnitude = (vector3 - vector2).Magnitude

	if magnitude < 0.1 then
		return
	end

	local random = Random.new()
	local v18 = magnitude * 0.12
	local unit = (vector3 - vector2).Unit
	local unit2

	if math.abs((unit:Dot(createVector(1, 0, 0)))) < 0.99 then
		unit2 = unit:Cross(createVector(1, 0, 0)).Unit
	else
		unit2 = unit:Cross(createVector(0, 0, 1)).Unit
	end

	local unit3 = unit:Cross(unit2).Unit
	local v19 = { vector2 }

	for i = 1, 5 do
		local v20 = i / 6
		local lerped = vector2:Lerp(vector3, v20)
		local v21 = math.sin(v20 * 3.141592653589793)
		local v22 = random:NextNumber(-v18, v18) * v21
		local v23 = random:NextNumber(-v18 * 0.5, v18 * 0.5) * v21
		table.insert(v19, lerped + unit2 * v22 + unit3 * v23)
	end

	table.insert(v19, vector3)
	local v20 = {}

	for i = 1, #v19 - 1 do
		local v21 = v19[i]
		local v22 = v19[i + 1]
		local magnitude2 = (v22 - v21).Magnitude

		if not (magnitude2 >= 0.01) then
			continue
		end

		local part = Instance.new("Part")
		part.Name = "KingThunderBolt"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(180, 220, 255)
		part.Transparency = 0.15
		part.Size = Vector3.new(v17, v17, magnitude2)
		part.CFrame = CFrame.lookAt(v21 + (v22 - v21) * 0.5, v22)
		part.Parent = workspace
		table.insert(v20, part)
	end

	for _, v21 in v20 do
		TweenService:Create(v21, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		local v22 = v21
		task.delay(0.22, function()
			pcall(function()
				v22:Destroy()
			end)
		end)
	end
end

local function fxKingThunderStrike(data)
	local vector2 = Vector3.new(data.fx or 0, data.fy or 0, data.fz or 0)
	local vector3 = Vector3.new(data.tx or 0, data.ty or 0, data.tz or 0)
	playThunderBolt(vector2, vector3)
	cloneThunderHitAt(vector3)
	fxPlaySound({
		id = "rbxassetid://128859265290061",
		x = vector3.X,
		y = vector3.Y,
		z = vector3.Z,
		vol = 1.1,
		minDist = 20,
		maxDist = 700,
		pitch = 1
	})
	playBurstBall(vector3.X, vector3.Y, vector3.Z, data.r or 10, Color3.fromRGB(140, 200, 255))
	screenShakeNearby(vector3.X, vector3.Y, vector3.Z, (data.r or 10) * 2.5)
	local kingThunderCC = Lighting:FindFirstChild("KingThunderCC")

	if kingThunderCC and kingThunderCC:IsA("ColorCorrectionEffect") then
		TweenService:Create(kingThunderCC, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0.35,
			Contrast = 0.35,
			Saturation = -0.5
		}):Play()
		task.delay(0.06, function()
			if kingThunderCC.Parent then
				TweenService:Create(
					kingThunderCC,
					TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{
						Brightness = 0.05,
						Contrast = 0.22,
						Saturation = -0.35
					}
				):Play()
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fxKingElectricAim(data)
	task.spawn(function()
		local npcId = data.npcId
		local userId = data.userId
		local trackSec = data.trackSec or 0.85
		local lockSec = data.lockSec or 0.5
		local v17

		if npcId then
			for _, v19 in CollectionService:GetTagged("AABossNpc") do
				if v19.Name ~= npcId then
					continue
				end

				v17 = v19
				break
			end
		end

		local humanoidRootPart

		if v17 then
			humanoidRootPart = v17:FindFirstChild("HumanoidRootPart")
		end

		if humanoidRootPart then
			local position = humanoidRootPart.Position
			fxPlaySound({
				id = "rbxassetid://118901970008718",
				x = position.X,
				y = position.Y,
				z = position.Z,
				vol = 0.55,
				minDist = 20,
				maxDist = 700,
				pitch = 1
			})
		end

		local part = Instance.new("Part")
		part.Name = "KingElectricAimLaser"
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(120, 200, 255)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Parent = workspace
		local total = 0
		local position = nil

		while total < trackSec and part.Parent do
			total += RunService.Heartbeat:Wait()
			local v18

			if npcId then
				for _, v20 in CollectionService:GetTagged("AABossNpc") do
					if v20.Name ~= npcId then
						continue
					end

					v18 = v20
					break
				end
			end

			local humanoidRootPart2

			if v18 then
				humanoidRootPart2 = v18:FindFirstChild("HumanoidRootPart")
			end

			local playerByUserId = Players:GetPlayerByUserId(userId)
			local humanoidRootPart3 = playerByUserId and playerByUserId.Character and playerByUserId.Character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart2 and humanoidRootPart3) then
				continue
			end

			position = humanoidRootPart3.Position
			local v19 = humanoidRootPart2.Position + createVector(0, 4, 0)
			local color = Color3.fromRGB(100, 190, 255)
			local v20 = position - v19
			local magnitude = v20.Magnitude

			if magnitude < 0.05 then
				part.Transparency = 1
			else
				part.Transparency = 0
				part.Size = Vector3.new(1, 1, magnitude)
				part.Color = color
				part.CFrame = CFrame.lookAt(v19 + v20 * 0.5, position)
			end
		end

		if not (part.Parent and position) then
			pcall(function()
				part:Destroy()
			end)
			return
		end

		spawnGroundWarnDisk(position.X, position.Y, position.Z, data.r or 6, lockSec, Color3.fromRGB(90, 170, 255))
		local total2 = 0

		while total2 < lockSec and part.Parent do
			total2 += RunService.Heartbeat:Wait()
			local v18

			if npcId then
				for _, v20 in CollectionService:GetTagged("AABossNpc") do
					if v20.Name ~= npcId then
						continue
					end

					v18 = v20
					break
				end
			end

			local humanoidRootPart2

			if v18 then
				humanoidRootPart2 = v18:FindFirstChild("HumanoidRootPart")
			end

			if not humanoidRootPart2 then
				continue
			end

			local v19 = math.sin(total2 * 50) * 0.18 + 1
			local v20 = humanoidRootPart2.Position + createVector(0, 4, 0)
			local color = Color3.fromRGB(180, 230, 255)
			local v21 = position - v20
			local magnitude = v21.Magnitude

			if magnitude < 0.05 then
				part.Transparency = 1
			else
				part.Transparency = 0
				part.Size = Vector3.new(v19, v19, magnitude)
				part.Color = color
				part.CFrame = CFrame.lookAt(v20 + v21 * 0.5, position)
			end
		end

		TweenService:Create(part, TweenInfo.new(0.06, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		task.delay(0.08, function()
			pcall(function()
				part:Destroy()
			end)
		end)
	end)
end

local function fxKingElectricBurst(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local r = data.r or 22
	local vector2 = Vector3.new(x, y, z)
	fxPlaySound({
		id = "rbxassetid://118901970008718",
		x = vector2.X,
		y = vector2.Y,
		z = vector2.Z,
		vol = 1.15,
		minDist = 20,
		maxDist = 700,
		pitch = 1
	})
	screenShakeNearby(x, y, z, r * 1.5)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.2, r * 1.2, r * 1.2)
	part.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, 0, 1.5707963267948966)
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(100, 170, 255)
	part.Transparency = 0.35
	part.Parent = workspace
	TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.2, r * 2.4, r * 2.4),
		Transparency = 1
	}):Play()
	task.delay(0.4, function()
		pcall(function()
			part:Destroy()
		end)
	end)
	cloneThunderHitAt(Vector3.new(x, y + 2, z))
end

local function fxKingSlowCast(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local r = data.r or 110
	local vector2 = Vector3.new(x, y, z)
	fxPlaySound({
		id = "rbxassetid://118901970008718",
		x = vector2.X,
		y = vector2.Y,
		z = vector2.Z,
		vol = 0.85,
		minDist = 20,
		maxDist = 700,
		pitch = 1
	})
	playBurstBall(x, y, z, math.min(r * 0.25, 18), Color3.fromRGB(80, 130, 255))

	for i = 1, 3 do
		task.delay((i - 1) * 0.12, function()
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Cylinder
			part.Size = createVector(0.25, 8, 8)
			part.CFrame = CFrame.new(x, y + 0.2, z) * CFrame.Angles(0, 0, 1.5707963267948966)
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(90, 150, 255)
			part.Transparency = 0.35
			part.Parent = workspace
			local vector3 = Vector3.new(0.25, r * 2, r * 2)
			TweenService:Create(part, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = vector3,
				Transparency = 1
			}):Play()
			Debris:AddItem(part, 0.7)
		end)
	end
end

local function fxKingSlow(data)
	local userIds = data.userIds

	if type(userIds) ~= "table" then
		return
	end

	local userId = Players.LocalPlayer.UserId
	local flag = false

	for _, userId2 in userIds do
		if userId2 ~= userId then
			continue
		end

		flag = true
		break
	end

	if flag then
		local percent = data.percent or 0.45
		local duration = data.duration or 3.5
		applyKingSlowDebuff(percent, duration) -- equivalent call inferred; original call site unknown
		ensureNotificationSystem() -- equivalent call inferred; original call site unknown
		v:ShowMessage(string.format("Slowed by %.0f%%!", (data.percent or 0.45) * 100), Color3.fromRGB(120, 180, 255))
	end

	for _, userId2 in userIds do
		if userId2 ~= userId then
			continue
		end

		local character = Players.LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			break
		end

		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(4, 4, 4)
		part.CFrame = humanoidRootPart.CFrame
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(90, 140, 255)
		part.Transparency = 0.65
		part.Parent = workspace
		local duration = data.duration or 3.5
		local total = 0
		local renderSteppedConnection2 = nil
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			total += dt

			if duration <= total or not humanoidRootPart.Parent then
				renderSteppedConnection2:Disconnect()
				pcall(function()
					part:Destroy()
				end)
			else
				part.CFrame = humanoidRootPart.CFrame
			end
		end)
		break
	end
end

local function fxStatueSpawnBeam(x: number, y: number, z: number)
	local color = Color3.fromRGB(255, 235, 160)
	local color2 = Color3.fromRGB(255, 255, 220)

	local function spawnBeamLayer(p: number, p2: number, p3: number, transparency: number, color3: Color3)
		local part = Instance.new("Part")
		part.Name = "StatueSpawnBeam"
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(p3, p * 2, p * 2)
		part.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, 0, 1.5707963267948966)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = color3
		part.Transparency = transparency
		part.Parent = workspace
		TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(p3, p2 * 2, p2 * 2)
		}):Play()
		task.delay(0.55, function()
			if part.Parent then
				TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = Vector3.new(p3, p * 2, p * 2),
					Transparency = 1
				}):Play()
				task.delay(0.4, function()
					pcall(function()
						part:Destroy()
					end)
				end)
			end
		end)
	end

	spawnBeamLayer(0.15, 4.5, 200, 0.35, color)
	spawnBeamLayer(0.09, 2.025, 200, 0.15, color2)
	local part = Instance.new("Part")
	part.Size = createVector(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(x, y, z)
	part.Parent = workspace
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 3
	pointLight.Range = 120
	pointLight.Color = color
	pointLight.Parent = part
	TweenService:Create(pointLight, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Brightness = 0
	}):Play()
	Debris:AddItem(part, 1)
	local vector2 = Vector3.new(x, y, z)
	fxPlaySound({
		id = "rbxassetid://119573908217733",
		x = vector2.X,
		y = vector2.Y,
		z = vector2.Z,
		vol = 0.85,
		minDist = 40,
		maxDist = 700,
		pitch = 1
	})
end

local function fxNpcSummon(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0

	if data.archetypeId == "Statue" then
		fxStatueSpawnBeam(x, y, z)
		return
	end

	playBurstBall(x, y, z, 5, Color3.fromRGB(150, 110, 255))
	local vector2 = Vector3.new(x, y, z)
	fxPlaySound({
		id = "rbxassetid://136081560081353",
		x = vector2.X,
		y = vector2.Y,
		z = vector2.Z,
		vol = 1.2,
		minDist = 20,
		maxDist = 700,
		pitch = 1
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fxMageTeleport(data)
	task.spawn(function()
		local vector2 = Vector3.new(data.fx or 0, data.fy or 0, data.fz or 0)
		local vector3 = Vector3.new(data.tx or 0, data.ty or 0, data.tz or 0)
		local color = Color3.fromRGB(150, 110, 255)
		local v17 = 1 + ((data.index or 1) - 1) * 0.07
		playBurstBall(vector2.X, vector2.Y, vector2.Z, 5, color)
		fxPlaySound({
			id = "rbxassetid://135640489101126",
			x = vector2.X,
			y = vector2.Y,
			z = vector2.Z,
			vol = 1,
			minDist = 20,
			maxDist = 700,
			pitch = v17 or 1
		})
		task.wait(0.08)
		playBurstBall(vector3.X, vector3.Y, vector3.Z, 5, color)
		fxPlaySound({
			id = "rbxassetid://136223034485147",
			x = vector3.X,
			y = vector3.Y,
			z = vector3.Z,
			vol = 1,
			minDist = 20,
			maxDist = 700,
			pitch = v17 or 1
		})
		local part = Instance.new("Part")
		part.Name = "MageTeleportTrail"
		part.Material = Enum.Material.Neon
		part.Color = color
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Transparency = 0.25
		part.Parent = workspace
		local v18 = vector3 - vector2
		local magnitude = v18.Magnitude

		if magnitude < 0.05 then
			part.Transparency = 1
		else
			part.Transparency = 0
			part.Size = Vector3.new(0.55, 0.55, magnitude)
			part.Color = color
			part.CFrame = CFrame.lookAt(vector2 + v18 * 0.5, vector3)
		end

		TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		task.delay(0.4, function()
			pcall(function()
				part:Destroy()
			end)
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function portalCFrameAt(position: Vector3, vector2: Vector3?)
	if vector2 and (vector2 - position).Magnitude > 0.05 then
		return CFrame.lookAt(position, vector2)
	end

	return CFrame.new(position)
end

local function spawnPortalCosmetic(vector2: Vector3, vector3: Vector3?)
	local VFX = luckymatBossRoom:FindFirstChild("VFX")

	if not VFX then
		warn("[LuckymatClient] Assets.VFX folder missing")
		return nil
	end

	local portalVFX = VFX:FindFirstChild("PortalVFX")

	if not portalVFX then
		warn("[LuckymatClient] No PortalVFX found inside Assets.VFX")
		return nil
	end

	local clone = portalVFX:Clone()
	local cFrame = portalCFrameAt(vector2, vector3) -- equivalent call inferred; original call site unknown
	clone.CFrame = cFrame
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Anchored = true
	clone.Parent = workspace
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function orientPortalToward(p, vector2: Vector3, vector3: Vector3)
	if (vector3 - vector2).Magnitude > 0.05 then
		local cFrame = portalCFrameAt(p.Position, vector3) -- equivalent call inferred; original call site unknown
		p.CFrame = cFrame
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closePortalByKey(p: string)
	local v17 = v5[p]

	if v17 and v17.Parent then
		pcall(function()
			v17:Destroy()
		end)
	end

	v5[p] = nil
end

local function attachHeadTrail(clone)
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(0, 0.15, 0)
	attachment.Parent = clone
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(0, -0.35, 0)
	attachment2.Parent = clone
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 70)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 70, 25))
	})
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1) })
	trail.Lifetime = 0.28
	trail.MinLength = 0.05
	trail.LightEmission = 0.6
	trail.Parent = clone
end

local function fxKingElectricZap(data)
	local vector2 = Vector3.new(data.fx or 0, data.fy or 0, data.fz or 0)
	local vector3 = Vector3.new(data.tx or 0, data.ty or 0, data.tz or 0)
	playThunderBolt(vector2, vector3, 1.75)
	cloneThunderHitAt(vector3)
	fxPlaySound({
		id = "rbxassetid://118901970008718",
		x = vector3.X,
		y = vector3.Y,
		z = vector3.Z,
		vol = 1,
		minDist = 20,
		maxDist = 700,
		pitch = 1
	})
	playBurstBall(vector3.X, vector3.Y, vector3.Z, 7, Color3.fromRGB(140, 210, 255))
end

local function spawnHeadCosmetic(hid: string, portalId: string?, hx: number, hy: number, hz: number, tx: number, ty: number, tz: number, travelSec: number, r: number, scale: number?)
	local noobExplosiveHead = assets:FindFirstChild("NoobExplosiveHead")

	if not (noobExplosiveHead and noobExplosiveHead:IsA("BasePart")) then
		warn("[LuckymatClient] Assets.NoobExplosiveHead BasePart missing")
		return
	end

	local vector2 = Vector3.new(tx, ty, tz)
	local clone = noobExplosiveHead:Clone()

	if scale and scale ~= 1 then
		clone.Size = noobExplosiveHead.Size * scale
	end

	clone.CFrame = CFrame.new(hx, hy, hz)
	clone.CanCollide = false
	clone.CanQuery = false
	clone.Anchored = true
	clone.Parent = workspace
	v4[hid] = clone
	attachHeadTrail(clone)
	local vector3 = Vector3.new(hx, hy, hz)
	fxPlaySound({
		id = "rbxassetid://119573908217733",
		x = vector3.X,
		y = vector3.Y,
		z = vector3.Z,
		vol = 1.2,
		minDist = 20,
		maxDist = 700,
		pitch = 1
	})
	local tween = TweenService:Create(clone, TweenInfo.new(travelSec, Enum.EasingStyle.Linear), {
		CFrame = CFrame.new(vector2)
	})
	tween.Completed:Connect(function()
		v4[hid] = nil
		pcall(function()
			clone:Destroy()
		end)
		playExplosionAt(tx, ty, tz, r) -- equivalent call inferred; original call site unknown
		screenShakeNearby(tx, ty, tz, r)

		if portalId then
			closePortalByKey(portalId) -- equivalent call inferred; original call site unknown
		end
	end)
	tween:Play()
end

local function getBoostFrame()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local speedGameUI = playerGui and playerGui:FindFirstChild("SpeedGameUI")
	local frames = speedGameUI and speedGameUI:FindFirstChild("Frames")
	local boostFrame = frames and frames:FindFirstChild("BoostFrame")

	if not (boostFrame and boostFrame:IsA("Frame") and boostFrame) then
		boostFrame = nil
	end

	return boostFrame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideBoostFrame()
	local boostFrame = getBoostFrame()

	if boostFrame then
		visible = boostFrame.Visible
		boostFrame.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreBoostFrame()
	local boostFrame = getBoostFrame()

	if boostFrame and visible ~= nil then
		boostFrame.Visible = visible
	end

	visible = nil
end

local function cleanupCosmetics()
	for k, v17 in v5 do
		local v18 = v17
		pcall(function()
			v18:Destroy()
		end)
		v5[k] = nil
	end

	for k, v17 in v4 do
		local v18 = v17
		pcall(function()
			v18:Destroy()
		end)
		v4[k] = nil
	end

	for i = #v6, 1, -1 do
		local v17 = i
		pcall(function()
			v6[v17]:Destroy()
		end)
		v6[i] = nil
	end

	if v7 then
		v7:Stop()
		v7 = nil
	end

	if v8 then
		v8:Stop()
		v8 = nil
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v14 then
		pcall(function()
			v14:Destroy()
		end)
		v14 = nil
	end

	if v13 then
		pcall(function()
			v13:Destroy()
		end)
		v13 = nil
	end

	if v15 then
		v15:Stop()
		v15 = nil
	end

	if v16 then
		v16:Stop()
		v16 = nil
	end

	if v11 then
		pcall(function()
			v11:Destroy()
		end)
		v11 = nil
	end

	if v12 then
		pcall(function()
			v12:Destroy()
		end)
		v12 = nil
	end

	local kingThunderCC = Lighting:FindFirstChild("KingThunderCC")

	if kingThunderCC then
		pcall(function()
			kingThunderCC:Destroy()
		end)
	end

	stopKingSlowEnforcer() -- equivalent call inferred; original call site unknown
	LuckymatCutscenes.stopAll()
end

local function preloadSenderThumbs()
	local v17 = {}
	local v18 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(value)
		if type(value) == "number" and not v18[value] then
			v18[value] = true
			table.insert(v17, value)
		end
	end

	add(LuckymatConfig.DefaultSenderId) -- equivalent call inferred; original call site unknown

	if LuckymatConfig.MessageConfigByPhase then
		for _, v19 in LuckymatConfig.MessageConfigByPhase do
			add(v19.SenderId) -- equivalent call inferred; original call site unknown
		end
	end

	if LuckymatConfig.TimelineCues then
		for _, timelineCue in LuckymatConfig.TimelineCues do
			add(timelineCue.SenderId) -- equivalent call inferred; original call site unknown
		end
	end

	if #v17 > 0 then
		FakeAdminMessageUtil.preload(v17)
	end
end

local function handleFx(p: string, data)
	if p == "SniperAim" then
		fxSniperAim(data) -- equivalent call inferred; original call site unknown
	elseif p == "SniperShot" then
		fxSniperShot(data)
	elseif p == "MageCast" then
		fxMageCast(data)
	elseif p == "CrateOpen" then
		fxCrateOpen(data)
	elseif p == "HealCrateOpen" then
		fxHealCrateOpen(data) -- equivalent call inferred; original call site unknown
	elseif p == "MagePortalOpen" then
		local portalId = data.portalId or data.npcId

		if portalId and not (v5[portalId] and v5[portalId].Parent) then
			local vector2 = Vector3.new(data.mx, data.my, data.mz)
			local v17

			if data.tx then
				v17 = Vector3.new(data.tx, data.ty, data.tz)
			end

			local v18 = spawnPortalCosmetic(vector2, v17)

			if v18 then
				v5[portalId] = v18
				fxPlaySound({
					id = "rbxassetid://111878775341423",
					x = vector2.X,
					y = vector2.Y,
					z = vector2.Z,
					vol = 1,
					minDist = 20,
					maxDist = 700,
					pitch = 1
				})
			end
		end

		if data.t and data.tx then
			task.spawn(function()
				spawnHeadAimHint(data.tx, data.ty, data.tz, data.r or 12, data.t)
			end)
		end
	elseif p == "NpcSummonFx" then
		fxNpcSummon(data)
	elseif p == "MageTeleport" then
		fxMageTeleport(data) -- equivalent call inferred; original call site unknown
	elseif p == "NoobHeadSpawn" then
		local vector2 = Vector3.new(data.hx, data.hy, data.hz)
		local vector3 = Vector3.new(data.tx, data.ty, data.tz)

		if data.portalId then
			local v17 = v5[data.portalId]

			if v17 and v17.Parent and (vector3 - vector2).Magnitude > 0.05 then
				local cFrame = portalCFrameAt(v17.Position, vector3) -- equivalent call inferred; original call site unknown
				v17.CFrame = cFrame
			end
		end

		spawnHeadCosmetic(
			data.hid,
			data.portalId,
			data.hx,
			data.hy,
			data.hz,
			data.tx,
			data.ty,
			data.tz,
			data.travelSec,
			data.r,
			data.scale
		)
	elseif p == "PlaySound" then
		fxPlaySound(data)
	elseif p == "NpcHitBlink" then
		fxNpcHitBlink(data, false)
	elseif p == "NpcDied" then
		fxNpcHitBlink(data, true)
	elseif p == "PFWarn" then
		task.spawn(function()
			local px = data.px
			local py = data.py
			local pz = data.pz
			local gx = data.gx
			local gy = data.gy
			local gz = data.gz
			local t = data.t or 2.5
			local r = data.r or 14
			local vector2 = Vector3.new(px, py, pz)
			local vector3

			if data.tx then
				vector3 = Vector3.new(data.tx, data.ty, data.tz)
			else
				vector3 = Vector3.new(gx, gy, gz)
			end

			local v17 = string.format("%.1f_%.1f_%.1f", px, py, pz)
			local flag = false

			if v5[v17] and v5[v17].Parent then
				if v5[v17] and not data.rx then
					orientPortalToward(v5[v17], vector2, vector3) -- equivalent call inferred; original call site unknown
				end
			else
				local v18 = spawnPortalCosmetic(vector2, vector3)

				if v18 then
					if data.rx then
						v18.CFrame = CFrame.new(px, py, pz) * CFrame.fromEulerAnglesXYZ(
							data.rx or 0,
							data.ry or 0,
							data.rz or 0
						)
					else
						v18.CFrame = CFrame.new(px, py, pz) * CFrame.Angles(1.5707963267948966, data.ry or 0, 0)
					end

					v5[v17] = v18
					flag = true
				end
			end

			if flag then
				fxPlaySound({
					id = "rbxassetid://111878775341423",
					x = vector2.X,
					y = vector2.Y,
					z = vector2.Z,
					vol = 1,
					minDist = 20,
					maxDist = 700,
					pitch = 1
				})
				fxPlaySound({
					id = "rbxassetid://80624479410185",
					x = vector2.X,
					y = vector2.Y,
					z = vector2.Z,
					vol = 1,
					minDist = 20,
					maxDist = 700,
					pitch = 1
				})
			end

			spawnGroundWarnDisk(gx, gy, gz, r, t, Color3.fromRGB(255, 80, 30))
		end)
	elseif p == "PFDrop" then
		task.spawn(function()
			local px = data.px
			local py = data.py
			local pz = data.pz
			local gx = data.gx
			local gy = data.gy
			local gz = data.gz
			local fallSec = data.fallSec or 1.2
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.Size = createVector(9.6, 9.6, 9.6)
			part.CFrame = CFrame.new(px, py, pz)
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 100, 20)
			part.Transparency = 0
			part.Parent = workspace
			table.insert(v6, part)
			local pointLight = Instance.new("PointLight", part)
			pointLight.Brightness = 8
			pointLight.Color = Color3.fromRGB(255, 120, 40)
			pointLight.Range = 44
			local fire = Instance.new("Fire")
			fire.Size = 14
			fire.Parent = part
			TweenService:Create(part, TweenInfo.new(fallSec, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = CFrame.new(gx, gy, gz)
			}):Play()
			task.wait(fallSec)
			local index = table.find(v6, part)

			if index then
				table.remove(v6, index)
			end

			pcall(function()
				part:Destroy()
			end)
		end)
	elseif p == "PFImpact" then
		task.spawn(function()
			local px = data.px
			local py = data.py
			local pz = data.pz
			local gx = data.gx
			local gy = data.gy
			local gz = data.gz
			local r = data.r or 14
			playExplosionAt(gx, gy, gz, r * 2) -- equivalent call inferred; original call site unknown
			local vector2 = Vector3.new(gx, gy, gz)
			fxPlaySound({
				id = "rbxassetid://135676461695962",
				x = vector2.X,
				y = vector2.Y,
				z = vector2.Z,
				vol = 1,
				minDist = 20,
				maxDist = 700,
				pitch = 1
			})
			screenShakeNearby(gx, gy, gz, r * 2)

			if data.closePortal then
				local v18 = string.format("%.1f_%.1f_%.1f", px, py, pz)
				local v19 = v5[v18]

				if v19 and v19.Parent then
					pcall(function()
						v19:Destroy()
					end)
				end

				v5[v18] = nil
			end
		end)
	elseif p == "SuperSpinWarn" then
		task.spawn(function()
			local x = data.x
			local y = data.y
			local z = data.z
			local r = data.r or 20
			local t = data.t or 2.5
			local animId = data.animId or "rbxassetid://TODO"
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Cylinder
			part.Size = Vector3.new(0.35, r * 2, r * 2) * 2
			part.CFrame = CFrame.new(x, y - 28, z) * CFrame.Angles(0, 0, 1.5707963267948966)
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 20, 20)
			part.Transparency = 0.3
			part.Parent = workspace
			local total = 0
			local v17 = false

			while total < t and part.Parent do
				task.wait(0.2)
				total += 0.2
				v17 = not v17
				part.Transparency = v17 and 0.65 or 0.1
			end

			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			task.wait(0.25)
			pcall(function()
				part:Destroy()
			end)
			local v18 = animId:match("rbxassetid://(%d+)") and CollectionService:GetTagged("LuckymatBossNPC")[1]

			if v18 then
				local humanoid = v18:FindFirstChildOfClass("Humanoid")
				local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

				if animator then
					local animation = Instance.new("Animation")
					animation.AnimationId = animId
					local track = animator:LoadAnimation(animation)
					track.Looped = true
					track:Play(0.2)
					v7 = track
				end
			end
		end)
	elseif p == "SuperSpinEnd" then
		if v7 then
			v7:Stop(0.3)
			v7 = nil
		end
	elseif p == "StompWarn" then
		task.spawn(function()
			local x = data.x
			local y = data.y
			local z = data.z
			local r = data.r or 18
			local t = data.t or 2
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Cylinder
			part.Size = Vector3.new(0.4, r * 2, r * 2)
			part.CFrame = CFrame.new(x, y - 3, z) * CFrame.Angles(0, 0, 1.5707963267948966)
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 140, 0)
			part.Transparency = 0.35
			part.Parent = workspace
			local total = 0
			local v17 = false

			while total < t and part.Parent do
				task.wait(0.2)
				total += 0.2
				v17 = not v17
				part.Transparency = v17 and 0.7 or 0.1
			end

			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			task.wait(0.25)
			pcall(function()
				part:Destroy()
			end)
		end)
		task.spawn(function()
			local animId = data.animId or "rbxassetid://TODO"

			if not animId:match("rbxassetid://(%d+)") then
				return
			end

			local v17 = CollectionService:GetTagged("LuckymatBossNPC")[1]

			if not v17 then
				return
			end

			local humanoid = v17:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

			if not animator then
				return
			end

			local animation = Instance.new("Animation")
			animation.AnimationId = animId
			local track = animator:LoadAnimation(animation)
			track.Looped = false
			track:Play(0.15)
			v8 = track
		end)
	elseif p == "StompImpact" then
		task.spawn(function()
			local x = data.x
			local y = data.y
			local z = data.z
			local r = data.r or 18
			playExplosionAt(x, y - 3, z, r * 1.5) -- equivalent call inferred; original call site unknown
			screenShakeNearby(x, y, z, r * 2.5)

			if v8 then
				v8:Stop(0.2)
				v8 = nil
			end
		end)
	elseif p == "KingThunderWarn" then
		task.spawn(function()
			spawnGroundWarnDisk(
				data.x or 0,
				data.y or 0,
				data.z or 0,
				data.r or 10,
				data.t or 1.1,
				Color3.fromRGB(120, 180, 255)
			)
		end)
	elseif p == "KingElectricAim" then
		fxKingElectricAim(data) -- equivalent call inferred; original call site unknown
	elseif p == "KingElectricZap" then
		fxKingElectricZap(data)
	elseif p == "KingFireballArc" then
		fxKingFireballArc(data) -- equivalent call inferred; original call site unknown
	elseif p == "KingThunderStormStart" then
		fxKingThunderStormStart(data)
	elseif p == "KingThunderStrike" then
		fxKingThunderStrike(data)
	elseif p == "KingElectricBurst" then
		fxKingElectricBurst(data)
	elseif p == "KingSlowCast" then
		fxKingSlowCast(data)
	elseif p == "KingSlow" then
		fxKingSlow(data)
	elseif p == "PillarCarry" then
		task.spawn(function()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			if v14 then
				pcall(function()
					v14:Destroy()
				end)
				v14 = nil
			end

			if v13 then
				pcall(function()
					v13:Destroy()
				end)
				v13 = nil
			end

			if v15 then
				v15:Stop(0)
				v15 = nil
			end

			if v16 then
				v16:Stop(0)
				v16 = nil
			end

			local animId = data.animId or "rbxassetid://TODO"
			local v17 = CollectionService:GetTagged("LuckymatBossNPC")[1]

			if not v17 then
				return
			end

			local humanoidRootPart = v17:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local pillar = assets:FindFirstChild("Pillar")

			if not pillar then
				warn("[LuckymatClient] Assets.Pillar not found in RSAAAssetsLuckymat")
				return
			end

			local clone = pillar:Clone()
			local primaryPart = nil

			if clone:IsA("BasePart") then
				primaryPart = clone
			elseif clone:IsA("Model") then
				primaryPart = clone.PrimaryPart

				if not primaryPart then
					for _, part in clone:GetDescendants() do
						if not part:IsA("BasePart") then
							continue
						end

						primaryPart = part
						break
					end
				end
			end

			if primaryPart then
				if clone:IsA("Model") then
					for _, part in clone:GetDescendants() do
						if not part:IsA("BasePart") then
							continue
						end

						part.CanCollide = false
						part.CanQuery = false
						part.CastShadow = false
						part.Anchored = part ~= primaryPart
					end
				end

				primaryPart.CanCollide = false
				primaryPart.CanQuery = false
				primaryPart.CastShadow = false
				primaryPart.Anchored = false

				if clone:IsA("Model") then
					for _, part in clone:GetDescendants() do
						if not (part:IsA("BasePart") and part ~= primaryPart) then
							continue
						end

						part.Anchored = false
						local weldConstraint = Instance.new("WeldConstraint")
						weldConstraint.Part0 = primaryPart
						weldConstraint.Part1 = part
						weldConstraint.Parent = primaryPart
					end
				end

				clone.Parent = workspace
				v13 = clone
				local cframe = CFrame.new(2, 1, -1)
				local motor6D = Instance.new("Motor6D")
				motor6D.Name = "PillarJoint"
				motor6D.Part0 = humanoidRootPart
				motor6D.Part1 = primaryPart
				motor6D.C0 = cframe
				motor6D.C1 = CFrame.identity
				motor6D.Parent = humanoidRootPart
				v14 = motor6D

				if animId:match("rbxassetid://(%d+)") then
					local humanoid = v17:FindFirstChildOfClass("Humanoid")
					local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

					if animator then
						local animation = Instance.new("Animation")
						animation.AnimationId = animId
						local track = animator:LoadAnimation(animation)
						track.Looped = true
						track:Play(0.2)
						v15 = track
					end
				end
			else
				warn("[LuckymatClient] Pillar has no usable BasePart root")
				pcall(function()
					clone:Destroy()
				end)
			end
		end)
	elseif p == "PillarThrowWarn" then
		task.spawn(function()
			local tx = data.tx
			local ty = data.ty
			local tz = data.tz
			local r = data.r or 14
			local t = data.t or 2.5
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Cylinder
			part.Size = Vector3.new(0.35, r * 2, r * 2)
			part.CFrame = CFrame.new(tx, ty, tz) * CFrame.Angles(0, 0, 1.5707963267948966)
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(160, 100, 60)
			part.Transparency = 0.35
			part.Parent = workspace
			local total = 0
			local v17 = false

			while total < t and part.Parent do
				task.wait(0.2)
				total += 0.2
				v17 = not v17
				part.Transparency = v17 and 0.7 or 0.1
			end

			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			task.wait(0.25)
			pcall(function()
				part:Destroy()
			end)
		end)
	elseif p == "PillarThrowLaunch" then
		task.spawn(function()
			if v15 then
				v15:Stop(0.1)
				v15 = nil
			end

			if v14 then
				pcall(function()
					v14:Destroy()
				end)
				v14 = nil
			end

			local throwAnimId = data.throwAnimId or "rbxassetid://TODO"
			local v17 = throwAnimId:match("rbxassetid://(%d+)") and CollectionService:GetTagged("LuckymatBossNPC")[1]

			if v17 then
				local humanoid = v17:FindFirstChildOfClass("Humanoid")
				local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

				if animator then
					local animation = Instance.new("Animation")
					animation.AnimationId = throwAnimId
					local track = animator:LoadAnimation(animation)
					track.Looped = false
					track:Play(0.15)
					v16 = track
				end
			end

			local instance = v13

			if not (instance and instance.Parent) then
				return
			end

			if instance:IsA("Model") then
				for _, part in instance:GetDescendants() do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end
			elseif instance:IsA("BasePart") then
				instance.Anchored = true
			end

			local vector2 = Vector3.new(data.bx, data.by, data.bz)
			local vector3 = Vector3.new(data.tx, data.ty, data.tz)
			local travelSec = data.travelSec or 1.8
			local v18 = (vector2 + vector3) * 0.5
			local vector4 = Vector3.new(v18.X, math.max(vector2.Y, vector3.Y) + 28, v18.Z)
			local total = 0

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				if instance and instance.Parent then
					total += dt
					local v19 = math.min(total / travelSec, 1)
					local v20 = 1 - v19
					local v21 = v20 * v20 * vector2 + v20 * 2 * v19 * vector4 + v19 * v19 * vector3
					local cFrame = CFrame.new(v21) * CFrame.Angles(
						v19 * 3.141592653589793 * 2,
						v19 * 3.141592653589793 * 0.4,
						0
					)

					if instance:IsA("Model") then
						instance:PivotTo(cFrame)
					else
						instance.CFrame = cFrame
					end

					if v19 >= 1 then
						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end

						pcall(function()
							instance:Destroy()
						end)

						if v13 == instance then
							v13 = nil
						end
					end
				elseif heartbeatConnection then
					heartbeatConnection:Disconnect()
					heartbeatConnection = nil
				end
			end)
		end)
	elseif p == "PillarThrowImpact" then
		task.spawn(function()
			local x = data.x
			local y = data.y
			local z = data.z
			local r = data.r or 16

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			if v13 and v13.Parent then
				pcall(function()
					v13:Destroy()
				end)
				v13 = nil
			end

			if v16 then
				v16:Stop(0.2)
				v16 = nil
			end

			playExplosionAt(x, y, z, r * 1.5) -- equivalent call inferred; original call site unknown
			screenShakeNearby(x, y, z, r * 2)
		end)
	elseif p == "FirePillarSurgeWarn" then
		task.spawn(function()
			local x = data.x
			local y = data.y
			local z = data.z
			local r = data.r or 8
			local t = data.t or 2
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Cylinder
			part.Size = Vector3.new(0.35, r * 2, r * 2)
			part.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, 0, 1.5707963267948966)
			part.Anchored = true
			part.CanCollide = false
			part.CastShadow = false
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 40, 0)
			part.Transparency = 0.35
			part.Parent = workspace
			local total = 0
			local v17 = false

			while total < t and part.Parent do
				task.wait(0.2)
				total += 0.2
				v17 = not v17
				part.Transparency = v17 and 0.7 or 0.1
			end

			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			task.wait(0.25)
			pcall(function()
				part:Destroy()
			end)
		end)
	elseif p == "FirePillarSurgeImpact" then
		task.spawn(function()
			local x = data.x
			local y = data.y
			local z = data.z
			local r = data.r or 8
			local riseSec = data.riseSec or 0.35

			if v11 and v11.Parent then
				pcall(function()
					v11:Destroy()
				end)
			end

			v11 = nil
			local firePillar = assets:FindFirstChild("FirePillar")

			if firePillar then
				local clone = firePillar:Clone()
				local primaryPart = nil

				if clone:IsA("BasePart") then
					primaryPart = clone
				elseif clone:IsA("Model") then
					primaryPart = clone.PrimaryPart

					if not primaryPart then
						for _, part in clone:GetDescendants() do
							if not part:IsA("BasePart") then
								continue
							end

							primaryPart = part
							break
						end
					end
				end

				if primaryPart then
					-- equivalent calls inferred from this helper; original call sites unknown
					local function setPillarPart(p2)
						p2.Anchored = true
						p2.CanCollide = false
						p2.CanQuery = false
						p2.CastShadow = false
					end

					setPillarPart(primaryPart) -- equivalent call inferred; original call site unknown

					if clone:IsA("Model") then
						for _, part in clone:GetDescendants() do
							if not part:IsA("BasePart") then
								continue
							end

							setPillarPart(part) -- equivalent call inferred; original call site unknown
						end
					end

					local v17 = y - primaryPart.Size.Y / 2 - 2
					local v18 = y + 4

					if clone:IsA("Model") then
						clone:PivotTo(CFrame.new(x, v17, z))
					else
						primaryPart.CFrame = CFrame.new(x, v17, z)
					end

					clone.Parent = workspace
					v11 = clone
					local total = 0
					local heartbeatConnection2 = nil
					heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
						if not (clone and clone.Parent) then
							heartbeatConnection2:Disconnect()
							return
						end

						total += dt
						local v19 = math.min(total / riseSec, 1)
						local v20 = v19 - 1
						local v21 = v20 * v20 * (v20 * 2.70158 + 1.70158) + 1
						local v22 = v17 + (v18 - v17) * v21

						if clone:IsA("Model") then
							clone:PivotTo(CFrame.new(x, v22, z))
						else
							primaryPart.CFrame = CFrame.new(x, v22, z)
						end

						if v19 >= 1 then
							heartbeatConnection2:Disconnect()
						end
					end)
					screenShakeNearby(x, y, z, r * 2.5)
					task.wait(riseSec + 0.8)

					if clone and clone.Parent then
						local v19 = {}

						if clone:IsA("BasePart") then
							table.insert(v19, clone)
						elseif clone:IsA("Model") then
							for _, part in clone:GetDescendants() do
								if part:IsA("BasePart") then
									table.insert(v19, part)
								end
							end
						end

						for _, v20 in v19 do
							TweenService:Create(
								v20,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Transparency = 1
								}
							):Play()
						end

						task.wait(0.45)
						pcall(function()
							clone:Destroy()
						end)

						if v11 == clone then
							v11 = nil
						end
					end
				else
					warn("[LuckymatClient] FirePillar has no usable BasePart root")
					pcall(function()
						clone:Destroy()
					end)
					screenShakeNearby(x, y, z, r * 2.5)
				end
			else
				warn("[LuckymatClient] Assets.FirePillar not found in RSAAAssetsLuckymat")
				screenShakeNearby(x, y, z, r * 2.5)
			end
		end)
	elseif p == "GravitySmashLift" then
		task.spawn(function()
			local liftSec = data.liftSec or 0.7
			local v17 = liftSec + (data.holdSec or 1)
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
			colorCorrectionEffect.Brightness = 0
			colorCorrectionEffect.Saturation = 0
			colorCorrectionEffect.Parent = game:GetService("Lighting")
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(liftSec * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					TintColor = Color3.fromRGB(140, 70, 220),
					Brightness = -0.06,
					Saturation = 0.25
				}
			):Play()
			task.wait(v17 - 0.35)
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Saturation = 0
				}
			):Play()
			task.wait(0.55)
			pcall(function()
				colorCorrectionEffect:Destroy()
			end)
		end)
	elseif p == "GravitySmashCrash" then
		task.spawn(function()
			local character = Players.LocalPlayer.Character

			if not character then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local position = humanoidRootPart.Position
			playExplosionAt(position.X, position.Y - 3, position.Z, 12) -- equivalent call inferred; original call site unknown
			screenShakeNearby(position.X, position.Y, position.Z, 60)
		end)
	elseif p == "OpeningCutscene" then
		task.spawn(function()
			local child = workspace:FindFirstChild(data.mapName, true)

			if child then
				LuckymatCutscenes.init(child)
				LuckymatCutscenes.playOpening()
			end
		end)
	elseif p == "EndingCutscene" then
		task.spawn(function()
			if workspace:FindFirstChild(data.mapName, true) then
				LuckymatCutscenes.playEnding()
			end
		end)
	elseif p == "PhaseRoar" then
		task.spawn(function()
			local x = data.x or 0
			local y = data.y or 0
			local z = data.z or 0
			local vector2 = Vector3.new(x, y, z)
			fxPlaySound({
				id = "rbxassetid://140076040328382",
				x = vector2.X,
				y = vector2.Y,
				z = vector2.Z,
				vol = 1.2,
				minDist = 40,
				maxDist = 1200,
				pitch = 1
			})
			screenShakeNearby(x, y, z, 100)
		end)
	elseif p == "PhaseMobExplode" then
		task.spawn(function()
			local x = data.x or 0
			local y = data.y or 0
			local z = data.z or 0
			local r = data.r or 14
			local vector2 = Vector3.new(x, y, z)
			cloneThunderHitAt(vector2)
			playExplosionAt(x, y, z, r * 1.75) -- equivalent call inferred; original call site unknown
			fxPlaySound({
				id = "rbxassetid://135676461695962",
				x = vector2.X,
				y = vector2.Y,
				z = vector2.Z,
				vol = 1,
				minDist = 20,
				maxDist = 700,
				pitch = 1
			})
			fxPlaySound({
				id = "rbxassetid://139520673393967",
				x = vector2.X,
				y = vector2.Y,
				z = vector2.Z,
				vol = 0.65,
				minDist = 20,
				maxDist = 700,
				pitch = 1
			})
			screenShakeNearby(x, y, z, r * 2.5)
		end)
	elseif p == "PhaseChange" then
		local phase = data.phase or 0

		if phase >= 4 then
			LuckymatCutscenes.stopBossIdle()
		end

		if phase == 5 and not v12 then
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
			colorCorrectionEffect.Brightness = 0
			colorCorrectionEffect.Saturation = 0
			colorCorrectionEffect.Parent = game:GetService("Lighting")
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					TintColor = Color3.fromRGB(255, 200, 200),
					Brightness = -0.04,
					Saturation = 0.12
				}
			):Play()
			v12 = colorCorrectionEffect
		end
	elseif p == "ShowBossMessage" then
		local message = data.message

		if type(message) ~= "string" or message == "" then
			return
		end

		local senderId = data.senderId or LuckymatConfig.DefaultSenderId
		local voiceline = data.voiceline
		local duration = data.duration or 8
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetNameFromUserIdAsync(senderId)
			end)
			FakeAdminMessageUtil.show({
				message = message,
				senderName = success and result or "User" .. senderId,
				senderUserId = senderId,
				preloadedThumb = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(senderId),
				duration = duration
			})
		end)

		if voiceline and LuckymatConfig.VoicelineSoundIds then
			local voicelineSoundId = LuckymatConfig.VoicelineSoundIds[voiceline]

			if type(voicelineSoundId) == "string" and voicelineSoundId ~= "" then
				fxPlaySound({
					id = voicelineSoundId,
					global = true,
					vol = 1
				})
			end
		end
	end
end

local v17 = nil
local LuckymatBossRoom = {}
LuckymatBossRoom.IsAdminAbuse = true
LuckymatBossRoom.NeedsDuration = false
LuckymatBossRoom.SkipDoorTransition = LuckymatConfig.SkipDoorTransition
LuckymatBossRoom.SkipDoorCamera = LuckymatConfig.SkipDoorCamera

function LuckymatBossRoom.Fire(_)
	if v17 then
		v17:stop()
	end

	cleanupCosmetics()
	hideBoostFrame() -- equivalent call inferred; original call site unknown
	ensureKingSlowEnforcer() -- equivalent call inferred; original call site unknown
	preloadSenderThumbs()
	local flag = false
	local flag2 = false
	v17 = BossClientBase.new({
		sseChannelName = "LuckymatBossRoom",
		bossDisplayName = "LuckyMat",
		bossIcon = LuckymatConfig.bossIcon,
		phaseThresholds = LuckymatConfig.PHASE_THRESHOLDS,
		onFx = function(p, p2)
			if p == "OpeningCutscene" then
				if flag then
					return
				else
					flag = true
				end
			elseif p == "EndingCutscene" then
				if flag2 then
					return
				else
					flag2 = true
				end
			end

			handleFx(p, p2)
		end
	})
	v17:fire()
	local _sse = v17._sse

	if _sse then
		_sse:onChange("OpeningCutscene", function(p)
			if type(p) == "table" and p.mapName and not flag then
				local mapName = p.mapName
				task.delay(5, function()
					if not flag then
						flag = true
						local v18 = {
							mapName = mapName
						}
						task.spawn(function()
							local child = workspace:FindFirstChild(v18.mapName, true)

							if child then
								LuckymatCutscenes.init(child)
								LuckymatCutscenes.playOpening()
							end
						end)
					end
				end)
			end
		end)
	end
end

function LuckymatBossRoom.Stop()
	if v17 then
		v17:stop()
		v17 = nil
	end

	cleanupCosmetics()
	restoreBoostFrame() -- equivalent call inferred; original call site unknown
end

LuckymatBossRoom.Hidden = true
return LuckymatBossRoom