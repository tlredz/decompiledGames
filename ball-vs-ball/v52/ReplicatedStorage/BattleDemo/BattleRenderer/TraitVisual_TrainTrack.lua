local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local TweenService = game:GetService("TweenService")
local TraitVisualTrainTrack = {}
TraitVisualTrainTrack.__index = TraitVisualTrainTrack
local TrainTrackGeometry = require(script.Parent.Parent.TrainTrackGeometry)
local color = Color3.fromRGB(96, 96, 104)

function TraitVisualTrainTrack.new(ctx)
	local self = setmetatable({}, TraitVisualTrainTrack)
	self._ctx = ctx
	self._railParts = {}
	self._sleeperModels = {}
	self._carModels = {}
	self._trackPointCounts = {}
	self._trainDepartureSounds = {}
	self._trainTravelSounds = {}
	return self
end

function TraitVisualTrainTrack:_ensureRailPart(battleOwnerSlotId: string, p2: number)
	local _railPart = self._railParts[battleOwnerSlotId]

	if not _railPart then
		_railPart = {}
		self._railParts[battleOwnerSlotId] = _railPart
	end

	local v = _railPart[p2]

	if v then
		return v
	end

	local part = Instance.new("Part")
	part.Name = string.format("TrainRail_%s_%d", battleOwnerSlotId, p2)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Metal
	part.Color = color
	part:SetAttribute("BattleOwnerSlotId", battleOwnerSlotId)
	part.Parent = self._ctx.rootFolder
	_railPart[p2] = part
	return part
end

function TraitVisualTrainTrack:_ensureSleeperModel(p2: string, p3: number)
	local templateModels = self._sleeperModels[p2]

	if not templateModels then
		templateModels = {}
		self._sleeperModels[p2] = templateModels
	end

	local v = templateModels[p3]

	if v then
		return v
	end

	local _ctx = self._ctx
	local templateModel = _ctx.cloneTemplateModel(
		_ctx.trackSleeperTemplateBundle,
		string.format("TrainSleeper_%s_%d", p2, p3)
	)
	templateModel.Parent = _ctx.rootFolder
	templateModels[p3] = templateModel
	return templateModel
end

function TraitVisualTrainTrack:_ensureCarModel(p2: string, p3: number, flag: boolean)
	local templateModels = self._carModels[p2]

	if not templateModels then
		templateModels = {}
		self._carModels[p2] = templateModels
	end

	local v = templateModels[p3]

	if v then
		return v
	end

	local _ctx = self._ctx
	local v2

	if flag then
		v2 = _ctx.trainHeadTemplateBundle
	else
		v2 = _ctx.trainBodyTemplateBundle
	end

	local templateModel = _ctx.cloneTemplateModel(v2, string.format("TrainCar_%s_%d", p2, p3))
	templateModel.Parent = _ctx.rootFolder
	templateModels[p3] = templateModel
	return templateModel
end

function TraitVisualTrainTrack:_rebuildTrack(p: string, p2, p3: number)
	local _ctx = self._ctx
	local trainTrack = _ctx.config.traits.TrainTrack
	local trackPoints = p2.trackPoints or {}
	local lookVector = _ctx.arenaCFrame.LookVector
	local count = 0
	local count2 = 0

	if #trackPoints >= 2 then
		if p2.phase == "laying" then
			trackPoints = TrainTrackGeometry.smooth(trackPoints, trainTrack)
		end

		local cumulativeLengths = TrainTrackGeometry.buildCumulativeLengths(trackPoints)
		local rails = TrainTrackGeometry.buildRails(trackPoints, (trainTrack.railGauge or 0) * 0.5)
		local v = (trainTrack.railThickness or 0.15) * _ctx.arenaScale

		for _, rail in rails do
			local worldFromArena = _ctx.worldFromArena(rail.from, p3)
			local worldFromArena2 = _ctx.worldFromArena(rail.to, p3)
			local v2 = worldFromArena2 - worldFromArena

			if not (v2.Magnitude > 0.001) then
				continue
			end

			count += 1
			local _ensureRailPart = self:_ensureRailPart(p, count)
			_ensureRailPart.Size = Vector3.new(v, v, v2.Magnitude)
			_ensureRailPart.CFrame = CFrame.lookAt(
				(worldFromArena + worldFromArena2) * 0.5,
				worldFromArena2,
				lookVector
			)
			_ensureRailPart.Transparency = 0
		end

		local v2 = cumulativeLengths[#cumulativeLengths] or 0
		local v3 = math.max(0.1, trainTrack.sleeperSpacing or 1.5)
		local total = 0

		while total <= v2 do
			count2 += 1
			local sample, v4 = TrainTrackGeometry.sample(trackPoints, cumulativeLengths, total)
			local _ensureSleeperModel = self:_ensureSleeperModel(p, count2)
			local worldFromArena = _ctx.worldFromArena(sample, p3)
			local worldFromArena2 = _ctx.worldFromArena(sample + v4, p3)

			if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
				_ensureSleeperModel:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, lookVector) * _ctx.trackSleeperTemplateBundle.markerOffset:Inverse())
			end

			_ctx.setTemplateModelVisibility(_ensureSleeperModel, true)
			total += v3
		end
	end

	for k, v in self._railParts[p] or {} do
		if count < k then
			v.Transparency = 1
		end
	end

	for k, v in self._sleeperModels[p] or {} do
		if count2 < k then
			_ctx.setTemplateModelVisibility(v, false)
		end
	end
end

local function getEmbeddedTrainSound(instance, childName: string)
	local sound = instance:FindFirstChild(childName)

	if sound and sound:IsA("Sound") then
		return sound
	end

	warn(string.format("列车长球碰撞箱缺少内嵌音效 %s，已跳过播放", childName))
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreSoundVolume(sound)
	local trainTrackBaseVolume = sound:GetAttribute("TrainTrackBaseVolume")

	if typeof(trainTrackBaseVolume) ~= "number" then
		trainTrackBaseVolume = sound.Volume
		sound:SetAttribute("TrainTrackBaseVolume", trainTrackBaseVolume)
	end

	sound.Volume = trainTrackBaseVolume
end

function TraitVisualTrainTrack:playSpawnAudio(p: string)
	local ballPart = self._ctx.getBallPart(p)

	if not ballPart then
		warn(string.format("列车长球 %s 的模型尚未创建，已跳过本次音效播放", p))
		return
	end

	local sound = ballPart:FindFirstChild("火车出发音效")

	if not (sound and sound:IsA("Sound")) then
		warn(string.format("列车长球碰撞箱缺少内嵌音效 %s，已跳过播放", "火车出发音效"))
		sound = nil
	end

	self._trainDepartureSounds[p] = sound

	if sound then
		sound:Stop()
		sound.TimePosition = 0
		DuelAudioController.prepare(sound)
		sound:Play()
	end

	local sound2 = ballPart:FindFirstChild("火车行驶音效")

	if not (sound2 and sound2:IsA("Sound")) then
		warn(string.format("列车长球碰撞箱缺少内嵌音效 %s，已跳过播放", "火车行驶音效"))
		sound2 = nil
	end

	self._trainTravelSounds[p] = sound2

	if sound2 then
		restoreSoundVolume(sound2) -- equivalent call inferred; original call site unknown
		sound2.Looped = true
		sound2:Stop()
		sound2.TimePosition = 0
		DuelAudioController.prepare(sound2)
		sound2:Play()
	end
end

function TraitVisualTrainTrack:stopTrainAudio(p2: string)
	local _trainDepartureSound = self._trainDepartureSounds[p2]

	if _trainDepartureSound then
		_trainDepartureSound:Stop()
		_trainDepartureSound.TimePosition = 0
	end

	self._trainDepartureSounds[p2] = nil
	local _trainTravelSound = self._trainTravelSounds[p2]
	self._trainTravelSounds[p2] = nil

	if _trainTravelSound then
		_trainTravelSound.Looped = false
		local tween = TweenService:Create(_trainTravelSound, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
			Volume = 0
		})
		tween.Completed:Connect(function()
			if _trainTravelSound.Parent then
				_trainTravelSound:Stop()
				_trainTravelSound.TimePosition = 0
			end
		end)
		tween:Play()
	end
end

function TraitVisualTrainTrack:update(p)
	local _ctx = self._ctx
	local trainTrack = p.traits and p.traits.TrainTrack

	if not trainTrack then
		return
	end

	local id = p.id
	local ballMarkerHeight = _ctx.getBallMarkerHeight(id)
	local count = #(trainTrack.trackPoints or {})

	if self._trackPointCounts[id] ~= count then
		self._trackPointCounts[id] = count
		self:_rebuildTrack(id, trainTrack, ballMarkerHeight)
	end

	local lookVector = _ctx.arenaCFrame.LookVector
	local v = {}

	for _, v2 in trainTrack.cars or {} do
		v[v2.carIndex] = true
		local _ensureCarModel = self:_ensureCarModel(id, v2.carIndex, v2.isHead)

		if v2.isVisible then
			local worldFromArena = _ctx.worldFromArena(v2.position, ballMarkerHeight)
			local worldFromArena2 = _ctx.worldFromArena(v2.position + v2.direction, ballMarkerHeight)

			if (worldFromArena2 - worldFromArena).Magnitude > 0.001 then
				local v3

				if v2.isHead then
					v3 = _ctx.trainHeadTemplateBundle
				else
					v3 = _ctx.trainBodyTemplateBundle
				end

				_ensureCarModel:PivotTo(CFrame.lookAt(worldFromArena, worldFromArena2, lookVector) * v3.markerOffset:Inverse())
			end

			_ctx.setTemplateModelVisibility(_ensureCarModel, true)
		else
			_ctx.setTemplateModelVisibility(_ensureCarModel, false)
		end
	end

	for k, v2 in self._carModels[id] or {} do
		if not v[k] then
			_ctx.setTemplateModelVisibility(v2, false)
		end
	end
end

function TraitVisualTrainTrack:cleanupBall(p: string)
	self:stopTrainAudio(p)

	for _, v in self._railParts[p] or {} do
		v:Destroy()
	end

	for _, v in self._sleeperModels[p] or {} do
		v:Destroy()
	end

	for _, v in self._carModels[p] or {} do
		v:Destroy()
	end

	self._railParts[p] = nil
	self._sleeperModels[p] = nil
	self._carModels[p] = nil
	self._trackPointCounts[p] = nil
end

function TraitVisualTrainTrack:reset()
	local v = {}

	for k in self._railParts do
		v[k] = true
	end

	for k in self._sleeperModels do
		v[k] = true
	end

	for k in self._carModels do
		v[k] = true
	end

	for k in self._trainDepartureSounds do
		v[k] = true
	end

	for k in self._trainTravelSounds do
		v[k] = true
	end

	for k in v do
		self:cleanupBall(k)
	end
end

return TraitVisualTrainTrack