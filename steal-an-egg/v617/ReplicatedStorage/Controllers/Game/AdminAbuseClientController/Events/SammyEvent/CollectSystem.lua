local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local BulkPartMotion = require(ReplicatedStorage.Client.BulkPartMotion)
local GuardAreaGeometry = require(ReplicatedStorage.Shared.Util.GuardAreaGeometry)
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local SammyEvent = require(ReplicatedStorage.Data.SammyEvent)
local SammyEventFlags = require(ReplicatedStorage.Shared.Flags.SammyEventFlags)
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
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = nil
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = nil
local v7 = nil
local count = 0
local v8 = 0
local count2 = 0
local v9 = false
local count3 = 0
local transient = Workspace:WaitForChild("Transient")
local ringCollect = ReplicatedStorage.Assets.Particles:WaitForChild("LightVsDarknessVFX"):WaitForChild("RingCollect")
assert(ringCollect:IsA("Attachment"), "LightVsDarknessVFX.RingCollect must be an Attachment")
local v10 = {}
local dischargePulse = ReplicatedStorage.Assets:WaitForChild("SammyEventVisuals"):WaitForChild("DischargePulse")
assert(dischargePulse:IsA("BasePart"), "SammyEventVisuals.DischargePulse must be a BasePart")
local separationLine = Workspace:WaitForChild("World"):WaitForChild("Areas"):WaitForChild("SeparationLine")
assert(separationLine:IsA("BasePart"), "Workspace.World.Areas.SeparationLine must be a BasePart")
local v11 = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.RespectCanCollide = true

-- equivalent calls inferred from this helper; original call sites unknown
local function bucketOf(X: number)
	return (math.floor(X / 100))
end

local function pickupsFolder()
	local v12 = v6

	if v12 then
		return v12
	end

	local folder = Instance.new("Folder")
	folder.Name = "SammyEmpPickups"
	folder.Parent = Workspace
	v.AssetTrove:Add(folder)
	v.AssetTrove:Add(function()
		v6 = nil
	end)
	v6 = folder
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function forgetPickup(data)
	local v12 = v5[data.Zone]

	if v12 then
		v12.Pickups[data.Id] = nil
		local bucket = v12.Buckets[data.Bucket]

		if bucket then
			bucket[data] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyPickup(pickup)
	forgetPickup(pickup) -- equivalent call inferred; original call site unknown
	pickup.Handle:Destroy()
	pickup.Part:Destroy()
end

local function stopPickupVfx(folder)
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
		local v13 = emitter

		local function fire()
			if type(emitCount) == "number" and emitCount > 0 then
				v13:Emit((math.max(1, (math.floor(emitCount + 0.5)))))
			end

			if type(emitDuration) == "number" and emitDuration > 0 then
				v13.Enabled = true
				task.delay(emitDuration, function()
					v13.Enabled = false
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

local function fadePickup(data)
	forgetPickup(data) -- equivalent call inferred; original call site unknown
	data.Handle:Destroy()
	local part = data.Part

	if part.Parent == nil then
		return
	end

	stopPickupVfx(part)
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

local function pullPickup(data, parent, mine: boolean)
	forgetPickup(data) -- equivalent call inferred; original call site unknown
	data.Handle:Destroy()
	local part = data.Part

	if part.Parent == nil then
		return
	end

	stopPickupVfx(part)
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = parent
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment
	beam.Attachment1 = attachment2
	beam.FaceCamera = true
	beam.Width0 = math.max(SammyEvent.PickupRadius * 0.5, 0.8)
	beam.Width1 = 0.25
	beam.Color = ColorSequence.new(color)
	beam.Transparency = numberSequence
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Parent = part
	v10[part] = {
		Part = part,
		From = part.Position,
		StartedAt = os.clock(),
		Target = parent,
		Phase = data.Phase,
		Fading = false,
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
	for folder, v12 in v10 do
		local target = v12.Target

		if folder.Parent == nil then
			v10[folder] = nil
			dropPullBeam(v12) -- equivalent call inferred; original call site unknown
		elseif target.Parent == nil then
			v10[folder] = nil
			dropPullBeam(v12) -- equivalent call inferred; original call site unknown
			playCollectVfx(folder.Position)
			fadeLoosePart(folder)
		else
			local v13 = (now - v12.StartedAt) / 0.35

			if v13 >= 1 then
				v10[folder] = nil
				dropPullBeam(v12) -- equivalent call inferred; original call site unknown
				playCollectVfx(folder.Position)

				if v12.Mine then
					UISystem.PickupArrived(folder.Position)
				end

				folder:Destroy()
			else
				local v14 = v13 * v13
				local v15 = v12.From:Lerp(target.Position, v14) + Vector3.new(
					0,
					math.sin(v13 * 3.141592653589793) * 1.5,
					0
				)
				folder.CFrame = CFrame.new(v15) * CFrame.Angles(0, now * 12 + v12.Phase, 1.5707963267948966)

				if v13 > 0.7 and not v12.Fading then
					v12.Fading = true

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

local function buildPickup(zone: number, p2, id: number, pickup)
	local clone = SammyEvent.PickupTemplate():Clone()
	clone.Name = "EmpCharge"
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

	clone.CFrame = CFrame.new(pickup.X, pickup.Y, pickup.Z) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = pickupsFolder()
	local v12 = {
		Part = clone,
		Handle = BulkPartMotion.Register(clone),
		Pickup = pickup,
		Zone = zone,
		Id = id,
		Bucket = math.floor(pickup.X / 100),
		Phase = id % 7,
		Pending = false
	}
	p2.Pickups[id] = v12
	local bucket = p2.Buckets[v12.Bucket]

	if bucket == nil then
		bucket = {}
		p2.Buckets[v12.Bucket] = bucket
	end

	bucket[v12] = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyZone(k: number)
	local v12 = v5[k]

	if v12 == nil then
		return
	end

	v5[k] = nil

	for _, pickup in v12.Pickups do
		destroyPickup(pickup) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopClearing()
	count3 += 1
	v9 = false
end

local function clearPickups()
	stopClearing() -- equivalent call inferred; original call site unknown

	for k in v5 do
		destroyZone(k) -- equivalent call inferred; original call site unknown
	end

	v2 = nil
	v3 = {}
	v4 = {}
	v7 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spawnPoint()
	local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
	assert(spawnLocation and spawnLocation:IsA("BasePart"), "Workspace.SpawnLocation must be a BasePart")
	return spawnLocation.Position
end

local function fadeOutWave()
	local pickups = {}

	for _, v12 in v5 do
		for _, pickup in v12.Pickups do
			table.insert(pickups, pickup)
		end
	end

	v2 = nil
	v3 = {}
	v4 = {}
	v7 = nil

	if #pickups == 0 then
		clearPickups()
		return
	end

	local position = spawnPoint() -- equivalent call inferred; original call site unknown
	table.sort(pickups, function(a, b)
		local vector2 = Vector3.new(a.Pickup.X, a.Pickup.Y, a.Pickup.Z)
		local vector3 = Vector3.new(b.Pickup.X, b.Pickup.Y, b.Pickup.Z)
		return (vector2 - position).Magnitude > (vector3 - position).Magnitude
	end)
	count3 += 1
	v9 = true
	local v13 = count3

	for k, v14 in pickups do
		local v15 = v14
		task.delay((k - 1) / #pickups * 5, function()
			if count3 == v13 then
				fadePickup(v15)
			end
		end)
	end

	task.delay(5.2, function()
		if count3 == v13 then
			clearPickups()
		end
	end)
end

local function retireBuilt()
	stopClearing() -- equivalent call inferred; original call site unknown

	for k, v12 in v5 do
		v5[k] = nil

		for _, pickup in v12.Pickups do
			pickup.Handle:Destroy()
			local part = pickup.Part

			if part.Parent == nil then
				continue
			end

			stopPickupVfx(part)
			TweenService:Create(part, tweenInfo, {
				CFrame = part.CFrame + createVector(0, 16, 0),
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
end

-- equivalent calls inferred from this helper; original call sites unknown
local function adoptWave(p: number, p2, items)
	retireBuilt()
	v2 = p
	v3 = p2
	v4 = {}
	v7 = nil

	if items then
		for k, item in items do
			local v12 = {}

			for _, v13 in item do
				v12[v13] = true
			end

			v4[k] = v12
		end
	end
end

local function syncZones(primaryPart)
	local zoneIndexAt = SammyEvent.ZoneIndexAt(primaryPart.Position)

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
		local v12 = v3[i]

		if v12 ~= nil and v5[i] == nil then
			v5[i] = {
				Source = SammyEvent.DecodePickups(v12),
				NextId = 1,
				Pickups = {},
				Buckets = {}
			}
		end
	end
end

local function continueBuilds()
	local v12 = 400

	for k, v13 in v5 do
		local v14 = v4[k]

		while v12 > 0 and v13.NextId <= #v13.Source do
			local nextId = v13.NextId
			v13.NextId = nextId + 1

			if not (v14 == nil or not v14[nextId]) then
				continue
			end

			buildPickup(k, v13, nextId, v13.Source[nextId])
			v12 -= 1
		end

		if v12 <= 0 then
			break
		end
	end
end

local function spin(primaryPart, now: number)
	local spinSpeed = SammyEvent.SpinSpeed

	for _, v12 in v5 do
		for k, bucket in v12.Buckets do
			local v13 = math.abs((k + 0.5) * 100 - primaryPart.Position.X)

			if v13 > 800 or not (not (v13 > 250) or (count2 + k) % 4 == 0) then
				continue
			end

			for k2 in bucket do
				local pickup = k2.Pickup
				k2.Handle:SetCFrame(CFrame.new(pickup.X, pickup.Y, pickup.Z) * CFrame.Angles(
					0,
					now * spinSpeed + k2.Phase,
					1.5707963267948966
				))
			end
		end
	end
end

local function nearbyBuilt(p, p2: number)
	local v12 = bucketOf(p.Position.X) -- equivalent call inferred; original call site unknown
	local result = {}

	for _, v13 in v5 do
		for i = v12 - 1, v12 + 1 do
			local bucket = v13.Buckets[i]

			if bucket == nil then
				continue
			end

			for k in bucket do
				local pickup = k.Pickup

				if not ((Vector3.new(pickup.X, pickup.Y, pickup.Z) - p.Position).Magnitude <= p2) then
					continue
				end

				table.insert(result, k)
			end
		end
	end

	return result
end

local function playCollectSound()
	local now = os.clock()

	if now - v8 > 1.5 then
		count = 0
	end

	count += 1
	v8 = now
	local v12 = math.min(count - 1, 12)
	local collectNormalRing = lightVsDarknessSounds:FindFirstChild("CollectNormalRing")
	assert(
		collectNormalRing and collectNormalRing:IsA("Sound"),
		"LightVsDarknessSounds.CollectNormalRing must be a Sound"
	)
	local clone = collectNormalRing:Clone()
	clone.Parent = collectNormalRing.Parent
	clone.PlayOnRemove = true
	clone.PlaybackSpeed = v12 * 0.06 + 1
	task.defer(function()
		clone:Destroy()
	end)
end

local function collect(primaryPart)
	local v12 = v2

	if v12 == nil then
		return
	end

	local v13 = SammyEvent.PickupRadius + SammyEventFlags.CollectRadiusPadding:Get()
	local v14 = SammyEventFlags.MagnetRadiusStuds:Get()

	for _, v15 in nearbyBuilt(primaryPart, math.max(v13, v14)) do
		if v15.Pending then
			continue
		end

		local pickup = v15.Pickup
		local magnitude = (Vector3.new(pickup.X, pickup.Y, pickup.Z) - primaryPart.Position).Magnitude

		if v13 < magnitude and v14 < magnitude then
			continue
		end

		v15.Pending = true
		Remotes.SammyEvent.AskCollectPickup:FireServer(v12, v15.Zone, v15.Id)
		playCollectSound()
		pullPickup(v15, primaryPart, true)
	end
end

local function onPickupCollected(p: number, p2: number, p3: number, p4: number)
	if p ~= v2 then
		return
	end

	local v12 = v4[p2]

	if v12 == nil then
		v12 = {}
		v4[p2] = v12
	end

	v12[p3] = true
	local v13 = v5[p2]
	local v14

	if v13 then
		v14 = v13.Pickups[p3]
	end

	if v14 then
		local playerByUserId = Players:GetPlayerByUserId(p4)
		local part

		if playerByUserId ~= nil then
			part = Player.FindRootPart(playerByUserId)
		end

		if part == nil or not part:IsA("BasePart") then
			playCollectVfx(Vector3.new(v14.Pickup.X, v14.Pickup.Y, v14.Pickup.Z))
			fadePickup(v14)
		else
			pullPickup(v14, part, false)
		end
	end
end

local function onPickupRespawned(p: number, zone: number, id: number)
	if p ~= v2 then
		return
	end

	local v12 = v4[zone]

	if v12 then
		v12[id] = nil
	end

	local v13 = v5[zone]

	if v13 and v13.Pickups[id] == nil and id < v13.NextId then
		buildPickup(zone, v13, id, v13.Source[id])
	end
end

local function step()
	stepPulls(os.clock())

	if v2 == nil and not v9 then
		return
	end

	local primaryPart = Player.FindPrimaryPart(localPlayer)

	if primaryPart == nil then
		return
	end

	count2 += 1
	spin(primaryPart, os.clock())

	if v2 == nil then
		return
	end

	syncZones(primaryPart)
	continueBuilds()
	collect(primaryPart)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dischargeGround(vector2: Vector3)
	local raycastResult = Workspace:Raycast(vector2 + createVector(0, 60, 0), createVector(0, -200, 0), raycastParams)

	if raycastResult == nil then
		return nil
	end

	return raycastResult.Position.Y
end

local function sweepDischarge(maid, position: Vector3, p: number)
	local zones = SammyEvent.Zones()
	local bounds = zones[1].Bounds
	local bounds2 = zones[#zones].Bounds
	local v12

	if p < 0 then
		v12 = bounds.Position.X - bounds.Size.X * 0.5
	else
		v12 = bounds2.Position.X + bounds2.Size.X * 0.5
	end

	local rotation = dischargePulse.CFrame.Rotation
	local X = position.X
	local Y = position.Y
	local Z = position.Z
	local v13 = maid:Add(dischargePulse:Clone())
	v13.CFrame = CFrame.new(X, Y, Z) * rotation
	v13.Parent = transient
	local v14 = nil
	v14 = maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		X += p * 350 * dt

		if (v12 - X) * p <= 0 then
			maid:Remove(v13)
			maid:Remove(v14)
		else
			local bounds3 = zones[SammyEvent.ZoneIndexAt((Vector3.new(X, Y, Z)))].Bounds
			local v15 = dischargeGround(Vector3.new(X, bounds3.Position.Y, bounds3.Position.Z)) -- equivalent call inferred; original call site unknown
			local v16 = v15 or bounds3.Position.Y
			local v17 = math.min(1, dt * 10)
			Y += (v16 - Y) * v17
			Z += (bounds3.Position.Z - Z) * v17
			v13.CFrame = CFrame.new(X, Y, Z) * rotation
		end
	end))
end

local function discharge(assetTrove)
	local part = Player.FindRootPart(localPlayer)

	if part == nil or not part:IsA("BasePart") then
		return
	end

	local clone = dischargePulse:Clone()
	clone.CFrame = CFrame.new(part.Position) * dischargePulse.CFrame.Rotation
	clone.Parent = transient
	Debris:AddItem(clone, 1)

	if not GuardAreaGeometry.IsPastLine(separationLine, part.Position) then
		return
	end

	script.DischargeSFX:Play()
	local sABMaps = { Workspace.World.Build, Workspace.Terrain }
	local sABMap = Workspace:FindFirstChild("SABMap")

	if sABMap ~= nil then
		table.insert(sABMaps, sABMap)
	end

	raycastParams.FilterDescendantsInstances = sABMaps
	sweepDischarge(assetTrove, part.Position, -1)
	sweepDischarge(assetTrove, part.Position, 1)
end

local function start()
	local assetTrove = v.AssetTrove
	clearPickups()
	assetTrove:Connect(Remotes.SammyEvent.PickupsSpawned.OnClientEvent, function(p: number, p2)
		adoptWave(p, p2) -- equivalent call inferred; original call site unknown
	end)
	assetTrove:Connect(Remotes.SammyEvent.PickupsCleared.OnClientEvent, function(p: number)
		if p == v2 then
			fadeOutWave()
		end
	end)
	assetTrove:Connect(Remotes.SammyEvent.PickupCollected.OnClientEvent, onPickupCollected)
	assetTrove:Connect(Remotes.SammyEvent.PickupRespawned.OnClientEvent, onPickupRespawned)
	local sammyEmpCharge = Workspace:GetAttribute("SammyEmpCharge")
	v11 = type(sammyEmpCharge) == "number" and sammyEmpCharge < SammyEvent.ChargeMax
	assetTrove:Connect(Workspace:GetAttributeChangedSignal("SammyEmpCharge"), function()
		local sammyEmpCharge2 = Workspace:GetAttribute("SammyEmpCharge")

		if type(sammyEmpCharge2) ~= "number" then
			return
		end

		if sammyEmpCharge2 < SammyEvent.ChargeMax then
			v11 = true
		elseif v11 then
			v11 = false
			discharge(assetTrove)
		end
	end)
	assetTrove:Connect(RunService.Heartbeat, step)
	assetTrove:Add(function()
		clearPickups()

		for _, v13 in v10 do
			dropPullBeam(v13) -- equivalent call inferred; original call site unknown
		end

		table.clear(v10)
		count = 0
	end)
	assetTrove:Add(task.spawn(function()
		local v13, v14, v15 = Remotes.SammyEvent.FetchPickups:InvokeServer()

		if type(v13) == "number" and v.IsEventActive() and v2 == nil then
			adoptWave(v13, v14, v15)
		end
	end))
end

return function(p)
	v = p
	return {
		Start = start,
		Clear = clearPickups
	}
end