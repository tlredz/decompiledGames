local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local Traits = require(ReplicatedStorage.Datas.Traits)
local VFX = require(ReplicatedStorage.Shared.VFX)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Shared.EventTypes)
local honeyJar = script:WaitForChild("HoneyJar")
local beeBuzzing = ReplicatedStorage.Sounds.Sfx:WaitForChild("Bee Buzzing")
local rotation = honeyJar:GetPivot().Rotation
local remoteEvent = Net:RemoteEvent("EventService/Bee/SpawnBee")
local remoteEvent2 = Net:RemoteEvent("EventService/Bee/MoveBee")
local remoteEvent3 = Net:RemoteEvent("EventService/Bee/AttackBee")
local remoteEvent4 = Net:RemoteEvent("EventService/Bee/AttachBee")
local remoteEvent5 = Net:RemoteEvent("EventService/Bee/DespawnBee")
local remoteEvent6 = Net:RemoteEvent("EventService/Bee/SpawnHoney")
local remoteEvent7 = Net:RemoteEvent("EventService/Bee/ClaimHoney")
local remoteEvent8 = Net:RemoteEvent("EventService/Bee/DestroyHoney")
local remoteFunction = Net:RemoteFunction("EventService/Bee/GetState")
local maid = Trove.new()
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local flag = false
local flag2 = false
local count = 0

local function getHiveInstances()
	local beehive = workspace:FindFirstChild("Beehive")

	if not beehive then
		return nil, nil, nil
	end

	local beeHiveSpawnVFX = beehive:FindFirstChild("BeeHiveSpawnVFX")
	local active = beehive:FindFirstChild("Active")
	local activeNeon = active and active:FindFirstChild("ActiveNeon")

	if activeNeon and activeNeon:IsA("BasePart") then
		return beeHiveSpawnVFX, active, activeNeon
	end

	return beeHiveSpawnVFX, active, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setHiveActive(flag3: boolean)
	local _, v5, v6 = getHiveInstances()

	if not (v5 and v6) then
		return false
	end

	if flag3 then
		VFX.enable(v5)
		v6.Transparency = 0
	else
		VFX.disable(v5)
		v6.Transparency = 1
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function runOrQueue(fn)
	if flag then
		table.insert(v4, fn)
	elseif flag2 then
		fn()
	end
end

local function getInnerBeeTemplate(childName: string)
	local child = ReplicatedStorage.Models.Traits:FindFirstChild(childName)
	local part = child and child:FindFirstChild("Part")

	if not part then
		return nil
	end

	local model = part:FindFirstChild(childName)

	if model and model:IsA("Model") then
		return model
	end

	return part:FindFirstChildOfClass("Model")
end

local function getPredictedTraitCFrame(targetUid: string, trait: string)
	local success, result = pcall(ClientEventUtils.getAnimalModel, targetUid)

	if not (success and result) then
		return nil
	end

	local child = ReplicatedStorage.Models.Traits:FindFirstChild(trait)
	local part = child and child:FindFirstChild("Part")
	local innerBeeTemplate = getInnerBeeTemplate(trait)

	if not (part and part:IsA("BasePart") and innerBeeTemplate) then
		return nil
	end

	local attachment = part:FindFirstChildOfClass("Attachment")

	if not attachment then
		return nil
	end

	local attachment2 = result:FindFirstChild(attachment.Name, true)

	if attachment2 and attachment2:IsA("Attachment") then
		return attachment2.WorldCFrame * attachment.CFrame:Inverse() * part.CFrame:ToObjectSpace(innerBeeTemplate:GetPivot())
	end

	return nil
end

local function createBeeModel(childName: string, position: Vector3)
	local innerBeeTemplate = getInnerBeeTemplate(childName)

	if not innerBeeTemplate then
		return nil
	end

	local clone = innerBeeTemplate:Clone()
	clone.Name = `Event Bee - {childName}`
	local rootPart = clone:FindFirstChild("RootPart", true)

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = part == rootPart
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end

	clone:PivotTo(CFrame.new(position))
	clone.Parent = workspace

	if rootPart and rootPart:IsA("BasePart") then
		local clone2 = beeBuzzing:Clone()
		local soundEffects = SoundService:FindFirstChild("Sound Effects")

		if soundEffects and soundEffects:IsA("SoundGroup") then
			clone2.SoundGroup = soundEffects
		end

		clone2.Parent = rootPart
		clone2:Play()
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local animation = ReplicatedStorage.Animations.Traits:FindFirstChild(childName)

	if animator and animation and animation:IsA("Animation") then
		local track = animator:LoadAnimation(animation)
		track.Looped = true
		track:Play()
	end

	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyBee(p: string)
	local v5 = v[p]

	if not v5 then
		return
	end

	v[p] = nil
	v5.Model:Destroy()
end

local function fadeDestroyBee(p: string)
	local v5 = v[p]

	if not v5 then
		return
	end

	v[p] = nil

	for _, part in ipairs(v5.Model:GetDescendants()) do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end
	end

	task.delay(0.25, v5.Model.Destroy, v5.Model)
end

local function findAttachedTraitVisual(p: string, childName: string)
	local success, result = pcall(ClientEventUtils.getAnimalModel, p)

	if not (success and result) then
		return nil, nil
	end

	local folder = result:FindFirstChild((`_Trait.{childName}`))

	if not folder then
		return nil, nil
	end

	local model = folder:FindFirstChild(childName, true)

	if not (model and model:IsA("Model")) then
		for _, model2 in ipairs(folder:GetDescendants()) do
			if not (model2:IsA("Model") and model2:FindFirstChild("RootPart", true)) then
				continue
			end

			model = model2
			break
		end
	end

	if not (model and model:IsA("Model")) then
		return nil, nil
	end

	local rootPart = model:FindFirstChild("RootPart", true)

	if rootPart and rootPart:IsA("BasePart") then
		return model, rootPart
	end

	return model, nil
end

local function playAttachedTraitBurst(p: string, p2: string, p3: number)
	local v5 = os.clock() + 3

	while count == p3 and flag2 do
		local _, v6 = findAttachedTraitVisual(p, p2)

		if not v6 then
			RunService.PostSimulation:Wait()

			if not (v5 <= os.clock()) then
				continue
			end
		end

		if count ~= p3 or not flag2 then
			break
		end

		local clone = script.Burst:Clone()
		local trait = Traits[p2]
		local beeIcons = clone:FindFirstChild("BeeIcons", true)

		if trait and beeIcons and beeIcons:IsA("ParticleEmitter") then
			beeIcons.Texture = trait.Icon
		end

		local v7 = { ReplicatedStorage.Sounds.Sfx["Bee Burst"] }

		if v6 then
			pcall(ClientEventUtils.playBurst, clone, v6, v7)
		else
			pcall(ClientEventUtils.playBurst, clone, p, v7)
		end

		clone:Destroy()
		break
	end
end

local function createBee(id: string, trait: string, vector2: Vector3, vector3: Vector3, moveStartedAt: number, moveDuration: number, value: string?, targetUid: string?)
	if v[id] then
		return
	end

	local beeModel = createBeeModel(trait, vector2)

	if not beeModel then
		return
	end

	v[id] = {
		Id = id,
		Trait = trait,
		Model = beeModel,
		Status = value or "Roaming",
		From = vector2,
		To = vector3,
		MoveStartedAt = moveStartedAt,
		MoveDuration = moveDuration,
		TargetUid = targetUid
	}
end

local function createHoneyModel()
	local clone = honeyJar:Clone()
	clone.Name = "Honey"
	clone:ScaleTo(clone:GetScale() * 2)
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
	assert(primaryPart, "HoneyJar needs a BasePart")
	clone.PrimaryPart = primaryPart

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end

	return clone
end

local function createHoney(id: string, position: Vector3, vector2: Vector3, spawnTime: number, fallTime: number)
	if v2[id] then
		return
	end

	local honeyModel = createHoneyModel()
	honeyModel:PivotTo(CFrame.new(position) * rotation)
	honeyModel.Parent = workspace
	local v5 = tonumber(string.sub(id, 1, 8), 16) or 0
	local random = Random.new(v5)
	v2[id] = {
		Id = id,
		Model = honeyModel,
		SpawnPosition = position,
		Position = vector2,
		SpawnTime = spawnTime,
		FallTime = fallTime,
		LastClaimRequest = 0,
		Claimed = false,
		ClaimPlayer = nil,
		ClaimAmount = nil,
		ClaimStartedAt = nil,
		ClaimFrom = nil,
		ClaimRotation = nil,
		FloatPhase = random:NextNumber(0, 6.283185307179586),
		FloatSpeed = random:NextNumber(3.3, 4.7),
		SpinSpeed = 0.7853981633974483 * random:NextNumber(0.8, 1.2)
	}
end

local function playReward(claimPlayer, claimAmount: number)
	local character = claimPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local now = os.clock()
	local v5 = v3[claimPlayer]

	if v5 and v5.Billboard.Parent and now - v5.LastCollectedAt <= 1.6 then
		v5.Amount += claimAmount
		v5.TextLabel.Text = `+{v5.Amount}`
	else
		local clone = script.Reward:Clone()
		clone.CurrencyHoney.Text = `+{claimAmount}`
		clone.Parent = humanoidRootPart
		local v6 = {
			Billboard = clone,
			TextLabel = clone.CurrencyHoney,
			Amount = claimAmount,
			LastCollectedAt = now
		}
		v3[claimPlayer] = v6
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			StudsOffset = createVector(0, 2.5, 2.2)
		}):Play()
		TweenService:Create(
			clone.ImageLabel.ImageLabel,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				ImageTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone.CurrencyHoney,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				TextTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone.CurrencyHoney.UIStroke,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				Transparency = 1
			}
		):Play()
		task.delay(5, function()
			if v3[claimPlayer] == v6 then
				v3[claimPlayer] = nil
			end

			clone:Destroy()
		end)
	end
end

local function clearVisuals()
	for k in pairs(v) do
		fadeDestroyBee(k)
	end

	for k, v5 in pairs(v2) do
		v5.Model:Destroy()
		v2[k] = nil
	end
end

local function updateVisuals(p: number)
	local serverTimeNow = workspace:GetServerTimeNow()
	local character = Players.LocalPlayer.Character
	local position = character and character:GetPivot().Position

	for _, v5 in pairs(v) do
		if not v5.Model.Parent then
			continue
		end

		local value = TweenService:GetValue(
			math.clamp((serverTimeNow - v5.MoveStartedAt) / v5.MoveDuration, 0, 1),
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)
		local rotation2 = nil
		local v7 = 0
		local v8, v9

		if v5.Status == "Attacking" and v5.TargetUid then
			local predictedTraitCFrame = getPredictedTraitCFrame(v5.TargetUid, v5.Trait)
			local position2

			if predictedTraitCFrame then
				position2 = predictedTraitCFrame.Position
			else
				position2 = v5.To
			end

			local v10 = (v5.From + position2) * 0.5 + createVector(0, 6, 0)
			v8 = MathUtils.quadBezier(value, v5.From, v10, position2)
			v9 = (v10 - v5.From) * (1 - value) + (position2 - v10) * value
			rotation2 = predictedTraitCFrame and predictedTraitCFrame.Rotation or nil

			if rotation2 then
				local v11 = 1 - math.clamp((position2 - v8).Magnitude / 12, 0, 1)
				v7 = v11 * v11 * (3 - v11 * 2)
			end
		else
			v8 = v5.From:Lerp(v5.To, value) + Vector3.new(
				0,
				math.sin((serverTimeNow + tonumber(string.sub(v5.Id, 1, 2), 16)) * 2.5) * 0.2,
				0
			)
			v9 = v5.To - v5.From
		end

		local rotation3 = v5.Model:GetPivot().Rotation
		local rotation4

		if v9.Magnitude > 0.01 then
			rotation4 = CFrame.lookAlong(createVector(0, 0, 0), v9.Unit).Rotation
		else
			rotation4 = rotation3
		end

		if rotation2 then
			rotation4 = rotation4:Lerp(rotation2, v7)
		end

		local lerped = rotation3:Lerp(rotation4, 1 - math.exp(p * -3.5))

		if rotation2 then
			lerped = lerped:Lerp(rotation2, v7 ^ 2)
		end

		v5.Model:PivotTo(CFrame.new(v8) * lerped)
	end

	for k, v5 in pairs(v2) do
		if v5.Model.Parent then
			if v5.Claimed then
				local claimPlayer = v5.ClaimPlayer
				local character2 = claimPlayer and claimPlayer.Character
				local position2 = character2 and character2:GetPivot().Position

				if position2 and v5.ClaimStartedAt and v5.ClaimFrom then
					local v6 = math.clamp((serverTimeNow - v5.ClaimStartedAt) / 0.4, 0, 1)
					local v7 = (v5.ClaimFrom + position2) * 0.5 + createVector(0, 10, 0)
					local quadBezier = MathUtils.quadBezier(v6, v5.ClaimFrom, v7, position2)
					v5.Model:PivotTo(CFrame.new(quadBezier) * (v5.ClaimRotation or rotation))

					if v6 >= 1 then
						v5.Model:Destroy()
						v2[k] = nil
						playReward(claimPlayer, v5.ClaimAmount or 1)

						if claimPlayer == Players.LocalPlayer then
							SoundController:PlaySound("Sounds.Sfx.Collecting Honey", nil, false)
						end
					end
				end
			else
				local value = TweenService:GetValue(
					math.clamp((serverTimeNow - v5.SpawnTime) / v5.FallTime, 0, 1),
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out
				)
				local v7 = v5.SpawnPosition + createVector(0, 8, 0)
				local v8 = MathUtils.quadBezier(value, v5.SpawnPosition, v7, v5.Position) + Vector3.new(
					0,
					math.sin(serverTimeNow * v5.FloatSpeed + v5.FloatPhase) * 0.35 + 3,
					0
				)
				v5.Model:PivotTo(CFrame.new(v8) * CFrame.Angles(0, serverTimeNow * v5.SpinSpeed, 0) * rotation)

				if value >= 1 and position and (v5.Position - position).Magnitude <= 12 and serverTimeNow - v5.LastClaimRequest > 0.1 then
					v5.LastClaimRequest = serverTimeNow
					remoteEvent7:FireServer(k)
				end
			end
		else
			v2[k] = nil
		end
	end
end

local Bee = {}

function Bee.OnStart(_)
	count += 1
	local v5 = count
	flag2 = true
	flag = true
	table.clear(v4)
	maid:Clean()
	clearVisuals()
	maid:Add(task.spawn(function()
		while flag2 do
			-- equivalent call inferred; original call site unknown
			if setHiveActive(true) then
				break
			else
				task.wait(0.1)
			end
		end
	end))
	maid:Add(RunService.PostSimulation:Connect(updateVisuals))
	local success, result = pcall(function()
		return remoteFunction:InvokeServer()
	end)

	if count ~= v5 then
		return
	end

	if success and typeof(result) == "table" and result.Active then
		for _, bee in ipairs(result.Bees) do
			createBee(
				bee.Id,
				bee.Trait,
				bee.From,
				bee.To,
				bee.MoveStartedAt,
				bee.MoveDuration,
				bee.Status,
				bee.TargetUid
			)
		end

		for _, v6 in ipairs(result.Honey) do
			createHoney(v6.Id, v6.SpawnPosition, v6.Position, v6.SpawnTime, v6.FallTime)
		end

		flag = false
		local clone = table.clone(v4)
		table.clear(v4)

		for _, v6 in ipairs(clone) do
			v6()
		end
	else
		flag2 = false
		flag = false
		table.clear(v4)
	end
end

function Bee.OnStop(_)
	EffectController:Activate("Blink")
	local _, v5, v6 = getHiveInstances()

	if v5 and v6 then
		VFX.disable(v5)
		v6.Transparency = 1
	end

	count += 1
	flag2 = false
	flag = false
	table.clear(v4)
	maid:Clean()
	clearVisuals()
end

function Bee.OnLoad(_)
	local _, v5, v6 = getHiveInstances()

	if v5 and v6 then
		VFX.disable(v5)
		v6.Transparency = 1
	end

	remoteEvent.OnClientEvent:Connect(function(id: string, trait: string, vector2: Vector3, vector3: Vector3, moveStartedAt: number, moveDuration: number)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn()
			createBee(id, trait, vector2, vector3, moveStartedAt, moveDuration, "Roaming", nil)
		end

		runOrQueue(fn) -- equivalent call inferred; original call site unknown
	end)
	remoteEvent2.OnClientEvent:Connect(function(p: string, from: Vector3, to: Vector3, moveStartedAt: number, moveDuration: number)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn()
			local v7 = v[p]

			if not v7 then
				return
			end

			v7.Status = "Roaming"
			v7.From = from
			v7.To = to
			v7.MoveStartedAt = moveStartedAt
			v7.MoveDuration = moveDuration
			v7.TargetUid = nil
		end

		runOrQueue(fn) -- equivalent call inferred; original call site unknown
	end)
	remoteEvent3.OnClientEvent:Connect(function(p: string, targetUid: string, _: string, from: Vector3, to: Vector3, moveStartedAt: number, moveDuration: number)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn()
			local v7 = v[p]

			if not v7 then
				return
			end

			v7.Status = "Attacking"
			v7.From = from
			v7.To = to
			v7.MoveStartedAt = moveStartedAt
			v7.MoveDuration = moveDuration
			v7.TargetUid = targetUid
		end

		runOrQueue(fn) -- equivalent call inferred; original call site unknown
	end)
	remoteEvent4.OnClientEvent:Connect(function(p: string, p2: string, p3: string, flag3: boolean)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn()
			if flag3 then
				maid:Add(task.spawn(playAttachedTraitBurst, p2, p3, count))
			else
				fadeDestroyBee(p)
			end
		end

		runOrQueue(fn) -- equivalent call inferred; original call site unknown
	end)
	remoteEvent5.OnClientEvent:Connect(function(p: string, flag3: boolean?)
		local function fn()
			if not flag3 then
				fadeDestroyBee(p)
				return
			end

			destroyBee(p) -- equivalent call inferred; original call site unknown
		end

		if flag then
			table.insert(v4, fn)
		elseif flag2 then
			if flag3 then
				destroyBee(p) -- equivalent call inferred; original call site unknown
			else
				fadeDestroyBee(p)
			end
		end
	end)
	remoteEvent6.OnClientEvent:Connect(function(id: string, vector2: Vector3, vector3: Vector3, spawnTime: number, fallTime: number)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn()
			createHoney(id, vector2, vector3, spawnTime, fallTime)
		end

		runOrQueue(fn) -- equivalent call inferred; original call site unknown
	end)
	remoteEvent7.OnClientEvent:Connect(function(p: string, claimPlayer, claimAmount: number)
		local function fn()
			local v7 = v2[p]

			if not v7 or v7.Claimed then
				return
			end

			v7.Claimed = true
			v7.ClaimPlayer = claimPlayer
			v7.ClaimAmount = claimAmount
			v7.ClaimStartedAt = workspace:GetServerTimeNow()
			v7.ClaimFrom = v7.Model:GetPivot().Position
			v7.ClaimRotation = v7.Model:GetPivot().Rotation
		end

		runOrQueue(fn) -- equivalent call inferred; original call site unknown
	end)
	remoteEvent8.OnClientEvent:Connect(function(p: string)
		local function fn()
			local v7 = v2[p]

			if v7 and not v7.Claimed then
				v7.Model:Destroy()
				v2[p] = nil
			end
		end

		if flag then
			table.insert(v4, fn)
			return
		end

		local v7 = flag2 and v2[p]

		if v7 then
			if v7.Claimed then
				return
			end

			v7.Model:Destroy()
			v2[p] = nil
		end
	end)
end

return Bee