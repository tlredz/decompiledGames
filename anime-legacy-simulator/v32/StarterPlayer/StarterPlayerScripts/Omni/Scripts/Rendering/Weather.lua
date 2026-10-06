local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local WeatherEffects = require(ReplicatedStorage.Omni.Shared.WeatherEffects)
local weather = module.Assets:WaitForChild("Effects"):WaitForChild("Weather")
local sounds = module.Assets:WaitForChild("Sounds")
local cache = workspace:WaitForChild("Cache")
local localPlayer = Players.LocalPlayer
local flag = false
local v = nil
local v2 = nil
local v3 = nil
local height = nil
local clone = nil
local v5 = nil
local thread = nil
local v6 = nil
local thread2 = nil
local raycastParams = nil
local v7 = nil
local v8 = 0
local random = Random.new()
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}
local v14 = {}
local Weather = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function IsLowMode()
	return module.Data.Settings["Low Mode"] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsHidden()
	return module.Data.Settings["Hide Weather Effects"] == true
end

local function IsMuted()
	local timeChamber = module.Scripts.Interface and module.Scripts.Interface.TimeChamber
	return timeChamber ~= nil and timeChamber.IsActive()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RandomBetween(minimumRadius: number, maximumRadius: number)
	return minimumRadius + random:NextNumber() * (maximumRadius - minimumRadius)
end

local function GetLifetime(folder)
	if v12[folder] then
		return v12[folder]
	end

	local v15 = 0

	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			v15 = math.max(v15, effect.Lifetime.Max)
		elseif effect:IsA("Trail") then
			v15 = math.max(v15, effect.Lifetime)
		end
	end

	v12[folder] = v15
	return v15
end

local function SetEmitting(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Retire(instance, p: number)
	SetEmitting(instance, false)
	v11[instance] = task.delay(p + WeatherEffects.FadePadding, function()
		v11[instance] = nil
		instance:Destroy()
	end)
end

local function GetAnchor()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart and humanoid then
		return humanoidRootPart.Position - Vector3.new(0, humanoid.HipHeight + humanoidRootPart.Size.Y / 2, 0)
	end

	return workspace.CurrentCamera.CFrame.Position
end

local function GetRaycastParams()
	local now = os.clock()
	local character = localPlayer.Character

	if raycastParams and character == v7 and now - v8 < WeatherEffects.FilterRefreshInterval then
		return raycastParams
	end

	local characters = { cache }

	for _, v15 in Players:GetPlayers() do
		if v15.Character then
			table.insert(characters, v15.Character)
		end
	end

	if not raycastParams then
		raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.RespectCanCollide = true
	end

	raycastParams.FilterDescendantsInstances = characters
	v7 = character
	v8 = now
	return raycastParams
end

local function GetGround(position: Vector3)
	local v15 = position + createVector(0, 1, 0) * WeatherEffects.RaycastHeight
	local raycastResult = workspace:Raycast(
		v15,
		createVector(0, 1, 0) * -WeatherEffects.RaycastDepth,
		(GetRaycastParams())
	)

	if raycastResult then
		position = raycastResult.Position or position
	end

	return position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetPlayerGround()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position,
		createVector(0, 1, 0) * -WeatherEffects.RaycastDepth,
		(GetRaycastParams())
	)
	return raycastResult and raycastResult.Position.Y
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateGround(p: number)
	local playerGround = GetPlayerGround() -- equivalent call inferred; original call site unknown

	if not playerGround then
		return
	end

	if height and not (math.abs(playerGround - height) > WeatherEffects.GroundSnapDistance) then
		height += (playerGround - height) * math.min(p * WeatherEffects.GroundSmoothing, 1)
	else
		height = playerGround
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCellDistance(vector2: Vector3, vector3: Vector3)
	local v15 = math.max(math.abs(vector2.X - vector3.X) - v3.X / 2, 0)
	local v16 = math.max(math.abs(vector2.Z - vector3.Z) - v3.Y / 2, 0)
	return (math.sqrt(v15 * v15 + v16 * v16))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTileKey(p: number, p2: number)
	return p * WeatherEffects.TileKeyStride + p2
end

local function CreateTile(p: number, vector2: Vector3)
	local height2 = height or vector2.Y
	local clone2 = v2:Clone()
	clone2:PivotTo(CFrame.new(vector2.X, height2, vector2.Z))
	clone2.Parent = cache
	v9[p] = {
		Instance = clone2,
		Center = vector2,
		Height = height2
	}
end

local function PlaceTiles()
	if not height then
		return
	end

	for _, v15 in v9 do
		if math.abs(v15.Height - height) < 0.01 then
			continue
		end

		v15.Height = height
		v15.Instance:PivotTo(CFrame.new(v15.Center.X, height, v15.Center.Z))
	end
end

local function RefreshTiles()
	if not v2 then
		return
	end

	local anchor = GetAnchor()
	local v16 = math.floor(anchor.X / v3.X)
	local v17 = math.floor(anchor.Z / v3.Y)

	for i = -1, 1 do
		for i2 = -1, 1 do
			local tileKey = GetTileKey(v16 + i, v17 + i2) -- equivalent call inferred; original call site unknown

			if v9[tileKey] then
				continue
			end

			local vector2 = Vector3.new((v16 + i + 0.5) * v3.X, anchor.Y, (v17 + i2 + 0.5) * v3.Y)

			if GetCellDistance(anchor, vector2) <= WeatherEffects.TileMargin then
				CreateTile(tileKey, vector2)
			end
		end
	end

	for k, v18 in v9 do
		if not (GetCellDistance(anchor, v18.Center) > WeatherEffects.RemoveMargin) then
			continue
		end

		Retire(v18.Instance, GetLifetime(v2)) -- equivalent call inferred; original call site unknown
		v9[k] = nil
	end
end

local function StartEffect(name: string)
	local child = weather:FindFirstChild(name)

	if not child then
		return
	end

	local effect = child:FindFirstChild("Effect")
	local tileSize = effect and effect:GetAttribute("TileSize")

	if typeof(tileSize) == "Vector2" and tileSize.X > 0 and tileSize.Y > 0 then
		v2 = effect
		v3 = tileSize
		UpdateGround(0) -- equivalent call inferred; original call site unknown
		RefreshTiles()
	end

	local celestial = child:FindFirstChild("Celestial")

	if celestial then
		v5 = celestial
		clone = celestial:Clone()
		clone:PivotTo(CFrame.new((GetAnchor())))
		clone.Parent = cache
	end
end

local function StopEffect()
	for _, v15 in v9 do
		Retire(v15.Instance, GetLifetime(v2)) -- equivalent call inferred; original call site unknown
	end

	table.clear(v9)
	v2 = nil
	v3 = nil
	height = nil

	if clone then
		Retire(clone, GetLifetime(v5)) -- equivalent call inferred; original call site unknown
		clone = nil
		v5 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FollowCelestial()
	if not clone then
		return
	end

	clone:PivotTo(CFrame.new((GetAnchor())))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetAmbientVolume()
	return module.Sound:GetSettingVolume("Effects Volume") * module.Sound:GetSettingVolume("Weather Volume")
end

local function GetSoundTemplate(childName: string)
	local weather2 = sounds:FindFirstChild("Weather")
	local sound = weather2 and weather2:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		return sound
	end

	return nil
end

local function PlaySound(childName: string, p)
	local timeChamber = module.Scripts.Interface and module.Scripts.Interface.TimeChamber
	local v15

	if timeChamber == nil then
		v15 = false
	else
		v15 = timeChamber.IsActive()
	end

	if v15 then
		return
	end

	local weather2 = sounds:FindFirstChild("Weather")
	local sound = weather2 and weather2:FindFirstChild(childName)

	if not (sound and sound:IsA("Sound")) then
		sound = nil
	end

	if not sound then
		return
	end

	local settingVolume = module.Sound:GetSettingVolume("Weather Volume")

	if settingVolume <= 0 then
		return
	end

	module.Sound:Play(sound, p, false, {
		VolumeMultiplier = settingVolume
	})
end

local function FadeSound(p, volume: number, callback)
	if v13[p] then
		v13[p]:Cancel()
	end

	local tween = TweenService:Create(p, TweenInfo.new(WeatherEffects.Sounds.FadeTime, Enum.EasingStyle.Linear), {
		Volume = volume
	})
	v13[p] = tween
	tween.Completed:Connect(function(p3)
		if v13[p] ~= tween then
			return
		end

		v13[p] = nil

		if p3 == Enum.PlaybackState.Completed and callback then
			callback()
		end
	end)
	tween:Play()
end

local function StartAmbient(childName: string)
	local timeChamber = module.Scripts.Interface and module.Scripts.Interface.TimeChamber
	local v15

	if timeChamber == nil then
		v15 = false
	else
		v15 = timeChamber.IsActive()
	end

	if v15 then
		return
	end

	local weather2 = sounds:FindFirstChild("Weather")
	local sound = weather2 and weather2:FindFirstChild(childName)

	if not (sound and sound:IsA("Sound")) then
		sound = nil
	end

	if not sound then
		return
	end

	local clone2 = sound:Clone()
	clone2:SetAttribute("BaseVolume", sound.Volume)
	clone2.Looped = true
	clone2.Volume = 0
	clone2.Parent = SoundService
	clone2:Play()
	v6 = clone2
	FadeSound(clone2, sound.Volume * GetAmbientVolume())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopAmbient()
	local v15 = v6

	if not v15 then
		return
	end

	v6 = nil
	FadeSound(v15, 0, function()
		v15:Destroy()
	end)
end

local function RefreshAmbientVolume()
	if not v6 then
		return
	end

	local volume = (v6:GetAttribute("BaseVolume") or 0) * GetAmbientVolume()

	if v13[v6] then
		FadeSound(v6, volume)
	else
		v6.Volume = volume
	end
end

local function GetThunderNames()
	local weather2 = sounds:FindFirstChild("Weather")
	local names = {}

	if not weather2 then
		return names
	end

	for _, sound in weather2:GetChildren() do
		if not (sound:IsA("Sound") and string.match(sound.Name, "^Thunder%d+$")) then
			continue
		end

		table.insert(names, sound.Name)
	end

	return names
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartThunder()
	thread2 = task.spawn(function()
		while true do
			local minimumThunderInterval = WeatherEffects.Sounds.MinimumThunderInterval
			local maximumThunderInterval = WeatherEffects.Sounds.MaximumThunderInterval
			task.wait(minimumThunderInterval + random:NextNumber() * (maximumThunderInterval - minimumThunderInterval))
			local thunderNames = GetThunderNames()

			if #thunderNames > 0 then
				PlaySound(thunderNames[random:NextInteger(1, #thunderNames)])
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopThunder()
	if not thread2 then
		return
	end

	task.cancel(thread2)
	thread2 = nil
end

local function Impact(instance, p)
	v10[instance] = nil
	local meteorShower = weather["Meteor Shower"]
	instance.Transparency = 1
	Retire(instance, GetLifetime(meteorShower.Meteor)) -- equivalent call inferred; original call site unknown
	local clone2 = meteorShower.Explosion:Clone()
	clone2.CFrame = CFrame.new(p.Target)
	clone2.Parent = cache
	module.Utils.Particles:Emit(clone2)
	Retire(clone2, GetLifetime(meteorShower.Explosion)) -- equivalent call inferred; original call site unknown
	PlaySound("MeteorImpact", clone2)
end

local function UpdateMeteors(p: number)
	for k, v15 in v10 do
		v15.Elapsed += p
		local v16 = math.min(v15.Elapsed / v15.Duration, 1)
		k.CFrame = v15.Rotation + v15.Start:Lerp(v15.Target, v16)

		if v16 == 1 then
			Impact(k, v15)
		end
	end
end

local function SpawnMeteor()
	local meteor = WeatherEffects.Meteor
	local count = 0

	for _ in v10 do
		count += 1
	end

	if meteor.MaximumActive <= count then
		return
	end

	local anchor = GetAnchor()
	local v16 = random:NextNumber() * 3.141592653589793 * 2
	local randomBetween = RandomBetween(meteor.MinimumRadius, meteor.MaximumRadius) -- equivalent call inferred; original call site unknown
	local position = anchor + Vector3.new(math.cos(v16) * randomBetween, 0, math.sin(v16) * randomBetween)
	local v18 = position + createVector(0, 1, 0) * WeatherEffects.RaycastHeight
	local raycastResult = workspace:Raycast(
		v18,
		createVector(0, 1, 0) * -WeatherEffects.RaycastDepth,
		(GetRaycastParams())
	)

	if raycastResult then
		position = raycastResult.Position or position
	end

	local v19 = random:NextNumber() * 3.141592653589793 * 2
	local start = position + Vector3.new(
		math.cos(v19) * meteor.StartDistance,
		meteor.StartHeight,
		math.sin(v19) * meteor.StartDistance
	)
	local clone2 = weather["Meteor Shower"].Meteor:Clone()
	local rotation = CFrame.lookAt(start, position).Rotation
	clone2.CFrame = rotation + start
	clone2.Parent = cache
	local v21 = v10
	local minimumTravelTime = meteor.MinimumTravelTime
	local maximumTravelTime = meteor.MaximumTravelTime
	v21[clone2] = {
		Start = start,
		Target = position,
		Rotation = rotation,
		Elapsed = 0,
		Duration = minimumTravelTime + random:NextNumber() * (maximumTravelTime - minimumTravelTime)
	}
	PlaySound("MeteorFall", clone2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartMeteors()
	thread = task.spawn(function()
		while true do
			local minimumInterval = WeatherEffects.Meteor.MinimumInterval
			local maximumInterval = WeatherEffects.Meteor.MaximumInterval
			task.wait(minimumInterval + random:NextNumber() * (maximumInterval - minimumInterval))
			SpawnMeteor()
		end
	end)
end

local function StopMeteors()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	for k in v10 do
		k.Transparency = 1
		Retire(k, GetLifetime(weather["Meteor Shower"].Meteor)) -- equivalent call inferred; original call site unknown
	end

	table.clear(v10)
end

function Weather.RefreshWeather()
	if not (flag and module.Data) then
		return
	end

	local state = module.Shared.Weather.GetState()
	local name = state and state.Name or "Clear"

	if IsLowMode() then
		name = nil
	elseif IsHidden() then
		name = nil
	end

	if name == v then
		return
	end

	StopMeteors()
	StopThunder() -- equivalent call inferred; original call site unknown
	StopEffect()
	StopAmbient() -- equivalent call inferred; original call site unknown
	v = name

	if not name then
		return
	end

	StartEffect(name)
	StartAmbient(name)

	if name == "Meteor Shower" then
		StartMeteors() -- equivalent call inferred; original call site unknown
	elseif name == "Thunderstorm" then
		StartThunder() -- equivalent call inferred; original call site unknown
	end
end

function Weather.RefreshSounds()
	if not flag then
		return
	end

	local timeChamber = module.Scripts.Interface and module.Scripts.Interface.TimeChamber
	local v15

	if timeChamber == nil then
		v15 = false
	else
		v15 = timeChamber.IsActive()
	end

	if v15 then
		StopAmbient() -- equivalent call inferred; original call site unknown
	elseif v and not v6 then
		StartAmbient(v)
	end
end

function Weather.Update(p: number)
	if not v2 and not clone and next(v10) == nil then
		return
	end

	if v2 then
		UpdateGround(p) -- equivalent call inferred; original call site unknown
	end

	RefreshTiles()
	PlaceTiles()
	FollowCelestial() -- equivalent call inferred; original call site unknown
	UpdateMeteors(p)
end

function Weather.Destroy()
	flag = false

	for _, connection in v14 do
		connection:Disconnect()
	end

	table.clear(v14)
	StopMeteors()
	StopThunder() -- equivalent call inferred; original call site unknown

	for k, v15 in v13 do
		v15:Cancel()
		k:Destroy()
	end

	table.clear(v13)

	if v6 then
		v6:Destroy()
		v6 = nil
	end

	for _, v15 in v9 do
		v15.Instance:Destroy()
	end

	table.clear(v9)
	v2 = nil
	v3 = nil

	if clone then
		clone:Destroy()
		clone = nil
		v5 = nil
	end

	for k, v15 in v11 do
		task.cancel(v15)
		k:Destroy()
	end

	table.clear(v11)
	table.clear(v12)
	v = nil
	height = nil
	raycastParams = nil
	v7 = nil
	v8 = 0
end

function Weather.Init()
	if flag then
		return
	end

	flag = true
	v14.Weather = ReplicatedStorage:GetAttributeChangedSignal(module.Shared.Weather.AttributeName):Connect(Weather.RefreshWeather)
	v14.LowMode = module:OnDataChanged({ "Settings", "Low Mode" }, Weather.RefreshWeather)
	v14.Hidden = module:OnDataChanged({ "Settings", "Hide Weather Effects" }, Weather.RefreshWeather)
	v14.Volume = module:OnDataChanged({ "Settings", "Effects Volume" }, RefreshAmbientVolume)
	v14.WeatherVolume = module:OnDataChanged({ "Settings", "Weather Volume" }, RefreshAmbientVolume)
	v14.Update = RunService.Heartbeat:Connect(Weather.Update)
	v14.Destroying = script.Destroying:Connect(Weather.Destroy)
	Weather.RefreshWeather()
end

return Weather