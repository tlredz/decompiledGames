local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local BulkPartMotion = require(ReplicatedStorage.Client.BulkPartMotion)
local FallenPowerUp = require(ReplicatedStorage.Data.FallenPowerUp)
local LightVsDarkness = require(ReplicatedStorage.Data.LightVsDarkness)
local LightVsDarknessEventFlags = require(ReplicatedStorage.Shared.Flags.LightVsDarknessEventFlags)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
require(ReplicatedStorage.Packages.Trove)
local UISystem = require(script.Parent.UISystem)
local lightVsDarknessSounds = ReplicatedStorage.Assets.Sounds:WaitForChild("LightVsDarknessSounds")
local color = Color3.fromRGB(255, 214, 89)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.35),
	NumberSequenceKeypoint.new(0.7, 0.6),
	NumberSequenceKeypoint.new(1, 1)
})
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local quad = Enum.EasingStyle.Quad
local inOut = Enum.EasingDirection.InOut
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = nil
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = nil
local v7 = nil
local v8 = {}
local count = 0
local v9 = 0
local count2 = 0
local v10 = false
local count3 = 0
local transient = Workspace:WaitForChild("Transient")
local ringCollect = ReplicatedStorage.Assets.Particles:WaitForChild("LightVsDarknessVFX"):WaitForChild("RingCollect")
assert(ringCollect:IsA("Attachment"), "LightVsDarknessVFX.RingCollect must be an Attachment")
local v11 = {}
local v12 = nil
local v13 = 0
local v14 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function bucketOf(X: number)
	return (math.floor(X / 100))
end

local function ringsFolder()
	local v15 = v6

	if v15 then
		return v15
	end

	local folder = Instance.new("Folder")
	folder.Name = "LightVsDarknessRings"
	folder.Parent = Workspace
	v.AssetTrove:Add(folder)
	v.AssetTrove:Add(function()
		v6 = nil
	end)
	v6 = folder
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLoop(p)
	local v15 = v8[p]

	if v15 then
		v8[p] = nil
		v15:Stop()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forgetRing(data)
	local v15 = v5[data.Zone]

	if v15 then
		v15.Rings[data.Id] = nil
		local bucket = v15.Buckets[data.Bucket]

		if bucket then
			bucket[data] = nil
		end
	end

	stopLoop(data) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyRing(ring)
	forgetRing(ring) -- equivalent call inferred; original call site unknown
	ring.Handle:Destroy()
	ring.Part:Destroy()
end

local function stopRingVfx(folder)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light")) then
			continue
		end

		descendant.Enabled = false
	end
end

local function burstEmitters(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDuration = emitter:GetAttribute("EmitDuration")
		local emitDelay = emitter:GetAttribute("EmitDelay")
		local v16 = emitter

		local function fire()
			if type(emitCount) == "number" and emitCount > 0 then
				v16:Emit((math.max(1, (math.floor(emitCount + 0.5)))))
			end

			if type(emitDuration) == "number" and emitDuration > 0 then
				v16.Enabled = true
				task.delay(emitDuration, function()
					v16.Enabled = false
				end)
			end
		end

		if type(emitDelay) == "number" and emitDelay > 0 then
			task.delay(emitDelay, fire)
		else
			fire()
		end
	end
end

local function playCollectVfx(position: Vector3)
	local part = Instance.new("Part")
	part.Name = "RingCollect"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	local clone = ringCollect:Clone()
	clone.Parent = part
	part.Parent = transient
	burstEmitters(clone)
	Debris:AddItem(part, 2)
end

local function fadeRing(data)
	forgetRing(data) -- equivalent call inferred; original call site unknown
	data.Handle:Destroy()
	local part = data.Part

	if part.Parent == nil then
		return
	end

	stopRingVfx(part)
	TweenService:Create(part, tweenInfo2, {
		CFrame = part.CFrame + createVector(0, 5, 0),
		Transparency = 1
	}):Play()

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") then
			TweenService:Create(part2, tweenInfo2, {
				Transparency = 1
			}):Play()
		end
	end

	Debris:AddItem(part, 0.2)
end

local function fadeLoosePart(folder)
	TweenService:Create(folder, tweenInfo2, {
		CFrame = folder.CFrame + createVector(0, 5, 0),
		Transparency = 1
	}):Play()

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			TweenService:Create(part, tweenInfo2, {
				Transparency = 1
			}):Play()
		end
	end

	Debris:AddItem(folder, 0.2)
end

local function pullRing(data, parent, mine: boolean)
	forgetRing(data) -- equivalent call inferred; original call site unknown
	data.Handle:Destroy()
	local part = data.Part

	if part.Parent == nil then
		return
	end

	stopRingVfx(part)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = parent
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.FaceCamera = true
	beam.Width0 = math.max(LightVsDarkness.RARITIES[data.Ring.Rarity].Radius * 0.5, 0.8)
	beam.Width1 = 0.25
	beam.Color = ColorSequence.new(color)
	beam.Transparency = numberSequence
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Parent = part
	v11[part] = {
		Part = part,
		From = part.Position,
		StartedAt = os.clock(),
		Target = parent,
		Phase = data.Phase,
		Fading = false,
		Rarity = data.Ring.Rarity,
		Mine = mine,
		Beam = beam,
		TargetAttachment = attachment2
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropPullBeam(state)
	local beam = state.Beam

	if beam then
		state.Beam = nil
		beam:Destroy()
	end

	local targetAttachment = state.TargetAttachment

	if targetAttachment then
		state.TargetAttachment = nil
		targetAttachment:Destroy()
	end
end

local function stepPulls(now: number)
	for folder, v15 in v11 do
		local target = v15.Target

		if folder.Parent == nil then
			v11[folder] = nil
			dropPullBeam(v15) -- equivalent call inferred; original call site unknown
		elseif target.Parent == nil then
			v11[folder] = nil
			dropPullBeam(v15) -- equivalent call inferred; original call site unknown
			playCollectVfx(folder.Position)
			fadeLoosePart(folder)
		else
			local v16 = (now - v15.StartedAt) / FallenPowerUp.MagnetPullSeconds

			if v16 >= 1 then
				v11[folder] = nil
				dropPullBeam(v15) -- equivalent call inferred; original call site unknown
				playCollectVfx(folder.Position)

				if v15.Mine then
					UISystem.RingArrived(v15.Rarity, folder.Position)
				end

				folder:Destroy()
			else
				local v17 = v16 * v16
				local v18 = v15.From:Lerp(target.Position, v17) + Vector3.new(
					0,
					math.sin(v16 * 3.141592653589793) * 1.5,
					0
				)
				folder.CFrame = CFrame.new(v18) * CFrame.Angles(
					0,
					now * FallenPowerUp.MagnetPullSpinSpeed + v15.Phase,
					1.5707963267948966
				)

				if v16 > 0.7 and not v15.Fading then
					v15.Fading = true

					for _, part in folder:GetDescendants() do
						if part:IsA("BasePart") then
							TweenService:Create(part, tweenInfo2, {
								Transparency = 1
							}):Play()
						end
					end

					TweenService:Create(folder, tweenInfo2, {
						Transparency = 1
					}):Play()
				end
			end
		end
	end
end

local function buildRing(zone: number, p2, id: number, ring)
	local v15 = LightVsDarkness.RARITIES[ring.Rarity]
	local clone = LightVsDarkness.Template(ring.Rarity):Clone()
	clone.Name = v15.Id
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	clone.CFrame = CFrame.new(ring.X, ring.Y - v14, ring.Z) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = ringsFolder()
	local v16 = {
		Part = clone,
		Handle = BulkPartMotion.Register(clone),
		Ring = ring,
		Zone = zone,
		Id = id,
		Bucket = math.floor(ring.X / 100),
		Phase = id % 7,
		Pending = false
	}
	p2.Rings[id] = v16
	local bucket = p2.Buckets[v16.Bucket]

	if bucket == nil then
		bucket = {}
		p2.Buckets[v16.Bucket] = bucket
	end

	bucket[v16] = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyZone(k: number)
	local v15 = v5[k]

	if v15 == nil then
		return
	end

	v5[k] = nil

	for _, ring in v15.Rings do
		destroyRing(ring) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopClearing()
	count3 += 1
	v10 = false
end

local function clearRings()
	stopClearing() -- equivalent call inferred; original call site unknown

	for k in v5 do
		destroyZone(k) -- equivalent call inferred; original call site unknown
	end

	for k in v8 do
		stopLoop(k) -- equivalent call inferred; original call site unknown
	end

	v2 = nil
	v3 = {}
	v4 = {}
	v7 = nil
	v12 = nil
	v13 = 0
	v14 = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spawnPoint()
	local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
	assert(spawnLocation and spawnLocation:IsA("BasePart"), "Workspace.SpawnLocation must be a BasePart")
	return spawnLocation.Position
end

local function fadeOutWave()
	local rings = {}

	for _, v15 in v5 do
		for _, ring in v15.Rings do
			table.insert(rings, ring)
		end
	end

	v2 = nil
	v3 = {}
	v4 = {}
	v7 = nil
	v12 = nil

	if #rings == 0 then
		clearRings()
		return
	end

	local position = spawnPoint() -- equivalent call inferred; original call site unknown
	table.sort(rings, function(a, b)
		local vector2 = Vector3.new(a.Ring.X, a.Ring.Y, a.Ring.Z)
		local vector3 = Vector3.new(b.Ring.X, b.Ring.Y, b.Ring.Z)
		return (vector2 - position).Magnitude > (vector3 - position).Magnitude
	end)
	count3 += 1
	v10 = true
	local v16 = count3

	for k, v17 in rings do
		local v18 = v17
		task.delay((k - 1) / #rings * 5, function()
			if count3 == v16 then
				fadeRing(v18)
			end
		end)
	end

	task.delay(5.2, function()
		if count3 == v16 then
			clearRings()
		end
	end)
end

local function retireBuilt(p: number)
	stopClearing() -- equivalent call inferred; original call site unknown

	for k, v15 in v5 do
		v5[k] = nil

		for _, ring in v15.Rings do
			stopLoop(ring) -- equivalent call inferred; original call site unknown
			ring.Handle:Destroy()
			local part = ring.Part

			if part.Parent == nil then
				continue
			end

			stopRingVfx(part)
			TweenService:Create(part, tweenInfo, {
				CFrame = part.CFrame + Vector3.new(0, p * 16, 0),
				Transparency = 1
			}):Play()

			for _, part2 in part:GetDescendants() do
				if part2:IsA("BasePart") then
					TweenService:Create(part2, tweenInfo, {
						Transparency = 1
					}):Play()
				end
			end

			Debris:AddItem(part, 0.45)
		end
	end

	for k in v8 do
		stopLoop(k) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateRenderLift(now: number)
	if v13 <= 0 then
		v14 = 0
		return
	end

	local v15 = (now - v13) / 1.5

	if v15 >= 1 then
		v13 = 0
		v14 = 0
	else
		v14 = LightVsDarknessEventFlags.FlyHeightStuds:Get() * (1 - TweenService:GetValue(math.max(v15, 0), quad, inOut))
	end
end

local function adoptWave(p: number, p2: string, p3, items)
	local v15 = v12
	retireBuilt(v15 == "Sky" and p2 == "Ground" and -1 or 1)
	v2 = p
	v3 = p3
	v4 = {}
	v7 = nil
	v12 = p2
	v13 = (p2 ~= "Sky" or v15 ~= "Ground") and 0 or os.clock()
	local now = os.clock()

	if v13 <= 0 then
		v14 = 0
	else
		local v16 = (now - v13) / 1.5

		if v16 >= 1 then
			v13 = 0
			v14 = 0
		else
			v14 = LightVsDarknessEventFlags.FlyHeightStuds:Get() * (1 - TweenService:GetValue(
				math.max(v16, 0),
				quad,
				inOut
			))
		end
	end

	if items then
		for k, item in items do
			local v16 = {}

			for _, v17 in item do
				v16[v17] = true
			end

			v4[k] = v16
		end
	end
end

local function syncZones(primaryPart)
	local zoneIndexAt = LightVsDarkness.ZoneIndexAt(primaryPart.Position)

	if zoneIndexAt == v7 then
		return
	end

	v7 = zoneIndexAt

	for k in v5 do
		if not (math.abs(k - zoneIndexAt) > 3) then
			continue
		end

		destroyZone(k) -- equivalent call inferred; original call site unknown
	end

	for i = zoneIndexAt - 3, zoneIndexAt + 3 do
		local v15 = v3[i]

		if v15 ~= nil and v5[i] == nil then
			v5[i] = {
				Source = LightVsDarkness.DecodeRings(v15),
				NextId = 1,
				Rings = {},
				Buckets = {}
			}
		end
	end
end

local function continueBuilds()
	local v15 = 400

	for k, v16 in v5 do
		local v17 = v4[k]

		while v15 > 0 and v16.NextId <= #v16.Source do
			local nextId = v16.NextId
			v16.NextId = nextId + 1

			if not (v17 == nil or not v17[nextId]) then
				continue
			end

			buildRing(k, v16, nextId, v16.Source[nextId])
			v15 -= 1
		end

		if v15 <= 0 then
			break
		end
	end
end

local function spin(primaryPart, now: number)
	for _, v15 in v5 do
		for k, bucket in v15.Buckets do
			local v16 = math.abs((k + 0.5) * 100 - primaryPart.Position.X)

			if v16 > 800 or not (not (v16 > 250) or (count2 + k) % 4 == 0) then
				continue
			end

			for k2 in bucket do
				local ring = k2.Ring
				local spinSpeed = LightVsDarkness.RARITIES[ring.Rarity].SpinSpeed
				k2.Handle:SetCFrame(CFrame.new(ring.X, ring.Y - v14, ring.Z) * CFrame.Angles(
					0,
					now * spinSpeed + k2.Phase,
					1.5707963267948966
				))
			end
		end
	end
end

local function nearbyBuilt(p, p2: number)
	local v15 = bucketOf(p.Position.X) -- equivalent call inferred; original call site unknown
	local result = {}

	for _, v16 in v5 do
		for i = v15 - 1, v15 + 1 do
			local bucket = v16.Buckets[i]

			if bucket == nil then
				continue
			end

			for k in bucket do
				local ring = k.Ring

				if not ((Vector3.new(ring.X, ring.Y, ring.Z) - p.Position).Magnitude <= p2) then
					continue
				end

				table.insert(result, k)
			end
		end
	end

	return result
end

local function playCollectSound(rarity: number, _)
	local now = os.clock()

	if now - v9 > 1.5 then
		count = 0
	end

	count += 1
	v9 = now
	local v15 = math.min(count - 1, 12)
	local child = lightVsDarknessSounds:FindFirstChild((`Collect{LightVsDarkness.RARITIES[rarity].Id}Ring`))

	if child then
		local clone = child:Clone()
		clone.Parent = child.Parent
		clone.PlayOnRemove = true
		clone.PlaybackSpeed = v15 * 0.06 + 1
		task.defer(function()
			clone:Destroy()
		end)
	end
end

local function collect(primaryPart, _: number)
	local v15 = v2

	if not (v15 ~= nil and type(localPlayer:GetAttribute("LvdTeam")) == "string") then
		return
	end

	local v16 = LightVsDarknessEventFlags.CollectRadiusPadding:Get()
	local v17 = LightVsDarknessEventFlags.MagnetRadiusStuds:Get() * (FallenPowerUp.IsActive(
		localPlayer,
		"Magnet",
		Workspace:GetServerTimeNow()
	) and 1 or 0.25)

	for _, v18 in nearbyBuilt(primaryPart, math.max(40, v17)) do
		if v18.Pending then
			continue
		end

		local ring = v18.Ring
		local v19 = LightVsDarkness.RARITIES[ring.Rarity].Radius + v16
		local magnitude = (Vector3.new(ring.X, ring.Y, ring.Z) - primaryPart.Position).Magnitude

		if v19 < magnitude and v17 < magnitude then
			continue
		end

		v18.Pending = true
		Remotes.LightVsDarkness.AskCollectRing:FireServer(v15, v18.Zone, v18.Id)
		playCollectSound(v18.Ring.Rarity, primaryPart)
		pullRing(v18, primaryPart, true)
	end
end

local function playSound(childName: string, part, p)
	local sound = lightVsDarknessSounds:FindFirstChild(childName)
	assert(sound and sound:IsA("Sound"), (`LightVsDarknessSounds.{childName} must be a Sound`))
	local v15 = not p and {} or table.clone(p)
	v15.Volume = v15.Volume or sound.Volume
	v15.MaxDistance = v15.MaxDistance or sound.RollOffMaxDistance
	v15.SoundGroup = v15.SoundGroup or "SFX"
	return Audio.Play(sound, part, v15)
end

local function updateNearby(primaryPart)
	local v15 = {}

	for _, v16 in nearbyBuilt(primaryPart, 40) do
		if not (v16.Ring.Rarity > 1) or v16.Pending then
			continue
		end

		table.insert(v15, v16)
	end

	table.sort(v15, function(a, b)
		local ring = a.Ring
		local ring2 = b.Ring
		return (Vector3.new(ring.X, ring.Y, ring.Z) - primaryPart.Position).Magnitude < (Vector3.new(
			ring2.X,
			ring2.Y,
			ring2.Z
		) - primaryPart.Position).Magnitude
	end)
	local v16 = {}

	for i = 1, math.min(#v15, 3) do
		v16[v15[i]] = true
	end

	for k in v8 do
		if v16[k] then
			continue
		end

		stopLoop(k) -- equivalent call inferred; original call site unknown
	end

	for k in v16 do
		if v8[k] ~= nil then
			continue
		end

		local v18 = playSound(`Nearby{LightVsDarkness.RARITIES[k.Ring.Rarity].Id}RingLooped`, k.Part, {
			Looped = true
		})

		if v18 then
			v8[k] = v18
		end
	end
end

local function onRingCollected(p: number, p2: number, p3: number, p4: number)
	if p ~= v2 then
		return
	end

	local v15 = v4[p2]

	if v15 == nil then
		v15 = {}
		v4[p2] = v15
	end

	v15[p3] = true
	local v16 = v5[p2]
	local v17

	if v16 then
		v17 = v16.Rings[p3]
	end

	if v17 then
		local playerByUserId = Players:GetPlayerByUserId(p4)
		local part

		if playerByUserId ~= nil then
			part = Player.FindRootPart(playerByUserId)
		end

		if part == nil or not part:IsA("BasePart") then
			playCollectVfx(Vector3.new(v17.Ring.X, v17.Ring.Y, v17.Ring.Z))
			fadeRing(v17)
		else
			pullRing(v17, part, false)
		end
	end
end

local function onRingRespawned(p: number, zone: number, id: number)
	if p ~= v2 then
		return
	end

	local v15 = v4[zone]

	if v15 then
		v15[id] = nil
	end

	local v16 = v5[zone]

	if v16 and v16.Rings[id] == nil and id < v16.NextId then
		buildRing(zone, v16, id, v16.Source[id])
	end
end

local function step()
	stepPulls(os.clock())

	if v2 == nil and not v10 then
		return
	end

	local primaryPart = Player.FindPrimaryPart(localPlayer)

	if primaryPart == nil then
		return
	end

	count2 += 1
	local now = os.clock()

	if v13 <= 0 then
		v14 = 0
	else
		local v15 = (now - v13) / 1.5

		if v15 >= 1 then
			v13 = 0
			v14 = 0
		else
			v14 = LightVsDarknessEventFlags.FlyHeightStuds:Get() * (1 - TweenService:GetValue(
				math.max(v15, 0),
				quad,
				inOut
			))
		end
	end

	spin(primaryPart, now)

	if v2 == nil then
		return
	end

	syncZones(primaryPart)
	continueBuilds()
	collect(primaryPart, now)

	if count2 % 10 == 0 then
		updateNearby(primaryPart)
	end
end

local function start()
	local assetTrove = v.AssetTrove
	clearRings()
	assetTrove:Connect(Remotes.LightVsDarkness.RingsSpawned.OnClientEvent, function(p: number, p2: string, p3)
		local v15 = v12
		retireBuilt(v15 == "Sky" and p2 == "Ground" and -1 or 1)
		v2 = p
		v3 = p3
		v4 = {}
		v7 = nil
		v12 = p2
		v13 = (p2 ~= "Sky" or v15 ~= "Ground") and 0 or os.clock()
		updateRenderLift(os.clock()) -- equivalent call inferred; original call site unknown
	end)
	assetTrove:Connect(Remotes.LightVsDarkness.RingsCleared.OnClientEvent, function(p: number)
		if p == v2 then
			fadeOutWave()
		end
	end)
	assetTrove:Connect(Remotes.LightVsDarkness.RingCollected.OnClientEvent, onRingCollected)
	assetTrove:Connect(Remotes.LightVsDarkness.RingRespawned.OnClientEvent, onRingRespawned)
	assetTrove:Connect(RunService.Heartbeat, step)
	assetTrove:Add(function()
		clearRings()

		for _, v15 in v11 do
			dropPullBeam(v15) -- equivalent call inferred; original call site unknown
		end

		table.clear(v11)
		count = 0
	end)
	assetTrove:Add(task.spawn(function()
		local v15, v16, v17, v18 = Remotes.LightVsDarkness.FetchRings:InvokeServer()

		if type(v15) == "number" and v.IsEventActive() and v2 == nil then
			adoptWave(v15, v16, v17, v18)
		end
	end))
end

return function(p)
	v = p
	return {
		Start = start,
		Clear = clearRings
	}
end