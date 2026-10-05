local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Checksum = require(ReplicatedStorage.Shared.Utils.Checksum)
local Log = require(ReplicatedStorage.Packages.Log)
local Numeric = require(ReplicatedStorage.Shared.Utils.Numeric)
local shuffle = Numeric.Shuffle
local TreadmillMediaCatalog = require(ReplicatedStorage.Data.TreadmillMediaCatalog)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
require(script.Parent.Types.Interface)
local v = {
	"Funny",
	"Brainrot",
	"Satisfying",
	"Funny",
	"Satisfying",
	"WeirdOrHorror",
	"Funny",
	"Brainrot",
	"Satisfying",
	"Funny",
	"Music"
}
local count = #v
local v2 = Log.new()
local FeedSequencer = {}
local pathSeed = Checksum.PathSeed

local function createEmptyBucketIndices()
	return {
		Brainrot = {},
		Funny = {},
		Satisfying = {},
		WeirdOrHorror = {},
		Music = {}
	}
end

local function normalizeFeedIndex(p: number)
	return (math.max(0, (math.floor(p))))
end

local function normalizeReleaseVersion(p: number)
	return (math.max(0, (math.floor(p))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function normalizeSeed(p: number, p2: number)
	if p > 0 then
		return (math.floor(p))
	end

	return pathSeed("TreadmillMediaFeed", p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bucketForFeedIndex(p: number)
	return v[(p - 1) % count + 1] or v[1]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createBucketOrder(p, p2: number, p3, p4: string)
	return shuffle(table.clone(p), (Random.new(pathSeed(p4, p2, p3))))
end

local function createBucketOrders(data, p: number, p2: string)
	return {
		Brainrot = createBucketOrder(data.Brainrot, p, "Brainrot", p2),
		Funny = createBucketOrder(data.Funny, p, "Funny", p2),
		Satisfying = createBucketOrder(data.Satisfying, p, "Satisfying", p2),
		WeirdOrHorror = createBucketOrder(data.WeirdOrHorror, p, "WeirdOrHorror", p2),
		Music = createBucketOrder(data.Music, p, "Music", p2)
	}
end

local function takeNextFromBucket(p, p2, p3)
	local v3 = p2[p3]
	local v4 = p[p3][v3]

	if v4 == nil then
		return nil
	end

	p2[p3] = v3 + 1
	return v4
end

local function takeNextFromFallbackBucket(p, p2, p3, p4)
	if p4 == p3 then
		return nil
	end

	local v3 = p2[p4]
	local v4 = p[p4][v3]

	if v4 == nil then
		return nil
	end

	p2[p4] = v3 + 1
	return v4
end

local function takeNextPatternMedia(bucketOrders, state, p)
	local v3 = state[p]
	local v4 = bucketOrders[p][v3]

	if v4 == nil then
		v4 = nil
	else
		state[p] = v3 + 1
	end

	if not v4 then
		if p == "Brainrot" then
			v4 = nil
		else
			local brainrot = state.Brainrot
			v4 = bucketOrders.Brainrot[brainrot]

			if v4 == nil then
				v4 = nil
			else
				state.Brainrot = brainrot + 1
			end
		end

		if not v4 then
			if p == "Funny" then
				v4 = nil
			else
				local funny = state.Funny
				v4 = bucketOrders.Funny[funny]

				if v4 == nil then
					v4 = nil
				else
					state.Funny = funny + 1
				end
			end

			if not v4 then
				if p == "Satisfying" then
					v4 = nil
				else
					local satisfying = state.Satisfying
					v4 = bucketOrders.Satisfying[satisfying]

					if v4 == nil then
						v4 = nil
					else
						state.Satisfying = satisfying + 1
					end
				end

				if not v4 then
					if p == "WeirdOrHorror" then
						v4 = nil
					else
						local weirdOrHorror = state.WeirdOrHorror
						v4 = bucketOrders.WeirdOrHorror[weirdOrHorror]

						if v4 == nil then
							v4 = nil
						else
							state.WeirdOrHorror = weirdOrHorror + 1
						end
					end

					if not v4 then
						if p == "Music" then
							v4 = nil
						else
							local music = state.Music
							v4 = bucketOrders.Music[music]

							if v4 == nil then
								v4 = nil
							else
								state.Music = music + 1
							end
						end
					end
				end
			end
		end
	end

	assert(v4 ~= nil, "Expected unseen treadmill media while sequence is incomplete")
	return v4
end

local function generatePatternOrder(p, p2: number, p3: number, p4: string, p5: number)
	local bucketOrders = createBucketOrders(p, p3, p4)
	local result = table.create(p2)
	local v3 = {
		Brainrot = 1,
		Funny = 1,
		Satisfying = 1,
		WeirdOrHorror = 1,
		Music = 1
	}

	for i = 1, p2 do
		local v4 = bucketForFeedIndex(p5 + i - 1) -- equivalent call inferred; original call site unknown
		result[i] = takeNextPatternMedia(bucketOrders, v3, v4)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function generateFullPass(data, p: number)
	local v3 = pathSeed("TreadmillMediaPass", data.Seed, p)
	local v4 = p * data.TotalMediaCount + 1
	return (generatePatternOrder(data.BucketIndices, data.TotalMediaCount, v3, "TreadmillMediaPassBucket", v4))
end

local function resolveFullMediaIndex(state, p: number)
	local cachedPassNumber = math.floor((p - 1) / state.TotalMediaCount)

	if state.CachedPassNumber ~= cachedPassNumber then
		state.CachedPassOrder = generateFullPass(state, cachedPassNumber)
		state.CachedPassNumber = cachedPassNumber
	end

	local v4 = (p - 1) % state.TotalMediaCount + 1
	return state.CachedPassOrder[v4]
end

local function exportState(data)
	return {
		Seed = data.Seed,
		CurrentIndex = data.CurrentIndex,
		AlgorithmVersion = 5,
		HasSwappedRight = data.HasSwappedRight,
		ReleaseTrackingInitialized = data.ReleaseTrackingInitialized,
		FullFeedReleaseVersion = data.FullFeedReleaseVersion,
		CompletedReleaseVersion = data.CompletedReleaseVersion,
		PendingReleaseVersion = data.PendingReleaseVersion,
		PendingCurrentMediaKey = data.PendingCurrentMediaKey,
		SeenPendingMediaKeys = table.clone(data.SeenPendingMediaKeys)
	}
end

local function statesEqual(data, data2)
	if data.Seed ~= data2.Seed or data.CurrentIndex ~= data2.CurrentIndex or data.AlgorithmVersion ~= data2.AlgorithmVersion or data.HasSwappedRight ~= data2.HasSwappedRight or data.ReleaseTrackingInitialized ~= data2.ReleaseTrackingInitialized or data.FullFeedReleaseVersion ~= data2.FullFeedReleaseVersion or data.CompletedReleaseVersion ~= data2.CompletedReleaseVersion or data.PendingReleaseVersion ~= data2.PendingReleaseVersion or data.PendingCurrentMediaKey ~= data2.PendingCurrentMediaKey then
		return false
	end

	for k, seenPendingMediaKey in pairs(data.SeenPendingMediaKeys) do
		if seenPendingMediaKey ~= data2.SeenPendingMediaKeys[k] then
			return false
		end
	end

	for k, seenPendingMediaKey in pairs(data2.SeenPendingMediaKeys) do
		if seenPendingMediaKey ~= data.SeenPendingMediaKeys[k] then
			return false
		end
	end

	return true
end

local function rebuildFullFeedCatalog(p, fullFeedReleaseVersion: number)
	local emptyBucketIndices = createEmptyBucketIndices()
	local count2 = 0

	for i, mediaEntry in ipairs(p.MediaEntries) do
		if not (mediaEntry.ReleaseVersion <= fullFeedReleaseVersion) then
			continue
		end

		table.insert(emptyBucketIndices[mediaEntry.BucketType], i)
		count2 += 1
	end

	assert(count2 > 0, (`Treadmill full feed release {fullFeedReleaseVersion} must not be empty`))
	p.BucketIndices = emptyBucketIndices
	p.TotalMediaCount = count2
	p.CachedPassNumber = nil
	p.CachedPassOrder = {}
end

local function buildDeltaOrder(state)
	local emptyBucketIndices = createEmptyBucketIndices()
	local deltaMediaIndexByKey = {}
	local count2 = 0

	for i, mediaEntry in ipairs(state.MediaEntries) do
		if not (mediaEntry.ReleaseVersion > state.CompletedReleaseVersion and mediaEntry.ReleaseVersion <= state.PendingReleaseVersion) then
			continue
		end

		deltaMediaIndexByKey[TreadmillMediaIdentity.GetMediaKey(mediaEntry)] = i
		table.insert(emptyBucketIndices[mediaEntry.BucketType], i)
		count2 += 1
	end

	state.DeltaMediaIndexByKey = deltaMediaIndexByKey
	state.DeltaPosition = 0
	state.DeltaCurrentMediaIndex = nil

	if count2 == 0 then
		state.DeltaOrder = {}
		return
	end

	state.DeltaOrder = generatePatternOrder(
		emptyBucketIndices,
		count2,
		pathSeed("TreadmillMediaDelta", state.Seed, state.PendingReleaseVersion),
		"TreadmillMediaDeltaBucket",
		1
	)
	local pendingCurrentMediaKey = state.PendingCurrentMediaKey

	if pendingCurrentMediaKey ~= nil then
		local deltaCurrentMediaIndex = deltaMediaIndexByKey[pendingCurrentMediaKey]

		if deltaCurrentMediaIndex == nil then
			state.PendingCurrentMediaKey = nil
		else
			state.DeltaCurrentMediaIndex = deltaCurrentMediaIndex

			for i, v6 in ipairs(state.DeltaOrder) do
				if v6 ~= deltaCurrentMediaIndex then
					continue
				end

				state.DeltaPosition = i
				return
			end
		end
	end
end

local function completeDelta(state)
	state.CompletedReleaseVersion = state.PendingReleaseVersion
	state.PendingReleaseVersion = 0
	state.PendingCurrentMediaKey = nil
	state.SeenPendingMediaKeys = {}
	state.DeltaOrder = {}
	state.DeltaMediaIndexByKey = {}
	state.DeltaCurrentMediaIndex = nil
	state.DeltaPosition = 0
	state.CurrentIndex = 0
	state.FullFeedReleaseVersion = state.CurrentReleaseVersion
	rebuildFullFeedCatalog(state, state.FullFeedReleaseVersion)
end

local function takeNextDeltaMedia(state)
	local v3 = #state.DeltaOrder
	local deltaPosition = state.DeltaPosition + 1

	if state.DeltaCurrentMediaIndex == nil then
		deltaPosition = 0

		for i, v6 in ipairs(state.DeltaOrder) do
			local mediaKey = TreadmillMediaIdentity.GetMediaKey(state.MediaEntries[v6])

			if state.SeenPendingMediaKeys[mediaKey] then
				continue
			end

			deltaPosition = i
			break
		end
	end

	if deltaPosition < 1 or v3 < deltaPosition then
		return nil
	end

	local deltaCurrentMediaIndex = state.DeltaOrder[deltaPosition]
	local mediaKey = TreadmillMediaIdentity.GetMediaKey(state.MediaEntries[deltaCurrentMediaIndex])
	state.DeltaPosition = deltaPosition
	state.DeltaCurrentMediaIndex = deltaCurrentMediaIndex
	state.PendingCurrentMediaKey = mediaKey
	state.SeenPendingMediaKeys[mediaKey] = true
	return deltaCurrentMediaIndex
end

local function takePreviousDeltaMedia(state)
	for i = state.DeltaPosition - 1, 1, -1 do
		local deltaCurrentMediaIndex = state.DeltaOrder[i]
		local mediaKey = TreadmillMediaIdentity.GetMediaKey(state.MediaEntries[deltaCurrentMediaIndex])

		if not state.SeenPendingMediaKeys[mediaKey] then
			continue
		end

		state.DeltaPosition = i
		state.DeltaCurrentMediaIndex = deltaCurrentMediaIndex
		state.PendingCurrentMediaKey = mediaKey
		return deltaCurrentMediaIndex
	end

	return nil
end

local function startDelta(state)
	state.PendingReleaseVersion = state.CurrentReleaseVersion
	state.PendingCurrentMediaKey = nil
	state.SeenPendingMediaKeys = {}
	buildDeltaOrder(state)
	local v3 = takeNextDeltaMedia(state)

	if v3 == nil then
		completeDelta(state)
	end

	return v3
end

local function takeNextFullMedia(state)
	state.CurrentIndex += 1

	if state.FullFeedReleaseVersion == state.CurrentReleaseVersion and state.CurrentIndex >= state.TotalMediaCount then
		state.CompletedReleaseVersion = math.max(state.CompletedReleaseVersion, state.FullFeedReleaseVersion)
	end

	local currentIndex = state.CurrentIndex
	local cachedPassNumber = math.floor((currentIndex - 1) / state.TotalMediaCount)

	if state.CachedPassNumber ~= cachedPassNumber then
		state.CachedPassOrder = generateFullPass(state, cachedPassNumber)
		state.CachedPassNumber = cachedPassNumber
	end

	local v4 = (currentIndex - 1) % state.TotalMediaCount + 1
	return state.CachedPassOrder[v4]
end

function FeedSequencer.IsReleaseTrackingStateCurrent(data)
	return data.Seed > 0 and data.AlgorithmVersion == 5 and data.HasSwappedRight ~= nil and data.ReleaseTrackingInitialized
end

function FeedSequencer.ResolveReleaseTrackingState(data, p: number, hasSwappedRight: boolean)
	if FeedSequencer.IsReleaseTrackingStateCurrent(data) then
		return data
	end

	local v3 = math.max(0, (math.floor(data.CurrentIndex)))
	local v4

	if data.Seed > 0 then
		v4 = data.AlgorithmVersion == 5
	else
		v4 = false
	end

	local completedReleaseVersion = not (v4 and TreadmillMediaCatalog.BASELINE_MEDIA_COUNT <= v3) and 0 or TreadmillMediaCatalog.BASELINE_RELEASE_VERSION
	local seed = normalizeSeed(not v4 and 0 or data.Seed, p) -- equivalent call inferred; original call site unknown
	local v6 = {
		Seed = seed,
		CurrentIndex = not (completedReleaseVersion > 0) and 0 or v3,
		AlgorithmVersion = 5,
		HasSwappedRight = hasSwappedRight,
		ReleaseTrackingInitialized = true,
		FullFeedReleaseVersion = 0,
		CompletedReleaseVersion = 0,
		PendingReleaseVersion = 0,
		PendingCurrentMediaKey = nil,
		SeenPendingMediaKeys = 0
	}
	local fullFeedReleaseVersion

	if completedReleaseVersion > 0 then
		fullFeedReleaseVersion = TreadmillMediaCatalog.BASELINE_RELEASE_VERSION
	else
		fullFeedReleaseVersion = TreadmillMediaCatalog.CURRENT_RELEASE_VERSION
	end

	v6.FullFeedReleaseVersion = fullFeedReleaseVersion
	v6.CompletedReleaseVersion = completedReleaseVersion
	v6.SeenPendingMediaKeys = {}
	return v6
end

function FeedSequencer.CreateRuntime(mediaEntries, data, p: number)
	assert(#mediaEntries > 0, "Treadmill media catalog must not be empty")
	local emptyBucketIndices = createEmptyBucketIndices()
	local CURRENT_RELEASE_VERSION = TreadmillMediaCatalog.CURRENT_RELEASE_VERSION
	local v3 = {}

	for i, v4 in ipairs(mediaEntries) do
		CURRENT_RELEASE_VERSION = math.max(
			CURRENT_RELEASE_VERSION,
			(TreadmillMediaCatalog.ResolveEntryReleaseVersion(v4.ReleaseVersion))
		)
		local mediaKey = TreadmillMediaIdentity.GetMediaKey(v4)
		assert(not v3[mediaKey], (`Duplicate treadmill media key "{mediaKey}"`))
		v3[mediaKey] = true
		table.insert(emptyBucketIndices[v4.BucketType], i)
	end

	local v4 = {
		BucketIndices = emptyBucketIndices,
		CachedPassNumber = nil,
		CachedPassOrder = {},
		CompletedReleaseVersion = 0,
		CurrentIndex = 0,
		CurrentReleaseVersion = CURRENT_RELEASE_VERSION,
		DeltaCurrentMediaIndex = nil,
		DeltaMediaIndexByKey = {},
		DeltaOrder = {},
		DeltaPosition = 0,
		FullFeedReleaseVersion = CURRENT_RELEASE_VERSION,
		HasSwappedRight = data.HasSwappedRight == true,
		MediaEntries = mediaEntries,
		PendingCurrentMediaKey = nil,
		PendingReleaseVersion = 0,
		ReleaseTrackingInitialized = true,
		Seed = 0,
		SeenPendingMediaKeys = 0,
		TotalMediaCount = 0
	}
	local seed2 = normalizeSeed(data.Seed, p) -- equivalent call inferred; original call site unknown
	v4.Seed = seed2
	v4.SeenPendingMediaKeys = {}
	v4.TotalMediaCount = #mediaEntries

	if data.AlgorithmVersion == 5 then
		v4.CurrentIndex = math.max(0, (math.floor(data.CurrentIndex)))

		if data.ReleaseTrackingInitialized then
			v4.FullFeedReleaseVersion = math.max(0, (math.floor(data.FullFeedReleaseVersion)))
			v4.CompletedReleaseVersion = math.min(
				math.max(0, (math.floor(data.CompletedReleaseVersion))),
				CURRENT_RELEASE_VERSION
			)
			v4.PendingReleaseVersion = math.max(0, (math.floor(data.PendingReleaseVersion)))
			v4.PendingCurrentMediaKey = data.PendingCurrentMediaKey
			v4.SeenPendingMediaKeys = table.clone(data.SeenPendingMediaKeys)
		end

		if v4.CompletedReleaseVersion == 0 and v4.FullFeedReleaseVersion ~= CURRENT_RELEASE_VERSION then
			v4.CurrentIndex = 0
			v4.FullFeedReleaseVersion = CURRENT_RELEASE_VERSION
			v4.PendingReleaseVersion = 0
			v4.PendingCurrentMediaKey = nil
			v4.SeenPendingMediaKeys = {}
		end

		if v4.CompletedReleaseVersion > 0 and v4.FullFeedReleaseVersion == 0 then
			v4.FullFeedReleaseVersion = v4.CompletedReleaseVersion
		end

		if v4.PendingReleaseVersion <= v4.CompletedReleaseVersion or CURRENT_RELEASE_VERSION < v4.PendingReleaseVersion then
			v4.PendingReleaseVersion = 0
			v4.PendingCurrentMediaKey = nil
			v4.SeenPendingMediaKeys = {}
		else
			buildDeltaOrder(v4)
		end
	else
		v2:AtTrace():Log("Resetting treadmill media feed state for algorithm version change")
	end

	rebuildFullFeedCatalog(v4, v4.FullFeedReleaseVersion)
	return v4
end

function FeedSequencer:Next()
	self.HasSwappedRight = true

	if self.PendingReleaseVersion > self.CompletedReleaseVersion then
		local v3 = takeNextDeltaMedia(self)

		if v3 ~= nil then
			return v3, (exportState(self))
		end

		completeDelta(self)
	end

	if self.CompletedReleaseVersion > 0 and self.CompletedReleaseVersion < self.CurrentReleaseVersion then
		local v3 = startDelta(self)

		if v3 ~= nil then
			return v3, (exportState(self))
		end
	end

	self.CurrentIndex += 1

	if self.FullFeedReleaseVersion == self.CurrentReleaseVersion and self.CurrentIndex >= self.TotalMediaCount then
		self.CompletedReleaseVersion = math.max(self.CompletedReleaseVersion, self.FullFeedReleaseVersion)
	end

	local currentIndex = self.CurrentIndex
	local cachedPassNumber = math.floor((currentIndex - 1) / self.TotalMediaCount)

	if self.CachedPassNumber ~= cachedPassNumber then
		self.CachedPassOrder = generateFullPass(self, cachedPassNumber)
		self.CachedPassNumber = cachedPassNumber
	end

	local v4 = (currentIndex - 1) % self.TotalMediaCount + 1
	return self.CachedPassOrder[v4], (exportState(self))
end

function FeedSequencer:Current()
	if self.PendingReleaseVersion > self.CompletedReleaseVersion then
		local deltaCurrentMediaIndex = self.DeltaCurrentMediaIndex

		if deltaCurrentMediaIndex ~= nil then
			return deltaCurrentMediaIndex, (exportState(self))
		end

		local v3 = takeNextDeltaMedia(self)

		if v3 ~= nil then
			return v3, (exportState(self))
		end

		completeDelta(self)
	end

	local currentIndex = math.max(self.CurrentIndex, 1)
	self.CurrentIndex = currentIndex
	local cachedPassNumber = math.floor((currentIndex - 1) / self.TotalMediaCount)

	if self.CachedPassNumber ~= cachedPassNumber then
		self.CachedPassOrder = generateFullPass(self, cachedPassNumber)
		self.CachedPassNumber = cachedPassNumber
	end

	local v5 = (currentIndex - 1) % self.TotalMediaCount + 1
	return self.CachedPassOrder[v5], (exportState(self))
end

function FeedSequencer:Previous()
	if self.PendingReleaseVersion > self.CompletedReleaseVersion then
		local deltaCurrentMediaIndex = self.DeltaCurrentMediaIndex
		assert(deltaCurrentMediaIndex ~= nil, "Pending treadmill media delta must have a current media entry")
		local v3 = takePreviousDeltaMedia(self)

		if v3 == nil then
			return deltaCurrentMediaIndex, exportState(self), false
		end

		return v3, exportState(self), true
	else
		local currentIndex = math.max(self.CurrentIndex - 1, 1)
		local v4 = currentIndex ~= self.CurrentIndex
		self.CurrentIndex = currentIndex
		local cachedPassNumber = math.floor((currentIndex - 1) / self.TotalMediaCount)

		if self.CachedPassNumber ~= cachedPassNumber then
			self.CachedPassOrder = generateFullPass(self, cachedPassNumber)
			self.CachedPassNumber = cachedPassNumber
		end

		local v6 = (currentIndex - 1) % self.TotalMediaCount + 1
		return self.CachedPassOrder[v6], exportState(self), v4
	end
end

function FeedSequencer.ExportState(p)
	return (exportState(p))
end

function FeedSequencer.StatesEqual(p, p2)
	return (statesEqual(p, p2))
end

function FeedSequencer.IsLegalTransition(p, data, p2, p3: number)
	if statesEqual(data, p2) then
		return true
	end

	local runtime = FeedSequencer.CreateRuntime(p, data, p3)
	local _, v3 = FeedSequencer.Current(runtime)

	if statesEqual(v3, p2) then
		return true
	end

	if data.PendingReleaseVersion > data.CompletedReleaseVersion then
		local runtime2 = FeedSequencer.CreateRuntime(p, data, p3)
		local _, v4, v5 = FeedSequencer.Previous(runtime2)

		if v5 and statesEqual(v4, p2) then
			return true
		end

		local runtime3 = FeedSequencer.CreateRuntime(p, data, p3)
		local _, v6 = FeedSequencer.Next(runtime3)
		return (statesEqual(v6, p2))
	else
		local runtime2 = FeedSequencer.CreateRuntime(p, data, p3)
		local v4

		if data.PendingReleaseVersion ~= 0 or p2.PendingReleaseVersion ~= 0 or not (p2.CurrentIndex < data.CurrentIndex) then
			local v5
			v5, v4 = FeedSequencer.Next(runtime2)
			return (statesEqual(v4, p2))
		end

		local v5, v6
		v5, v4, v6 = FeedSequencer.Previous(runtime2)

		if v6 then
			return (statesEqual(v4, p2))
		end

		return false
	end
end

return FeedSequencer