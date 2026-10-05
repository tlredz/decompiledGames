local RecommendationService = game:GetService("RecommendationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Log = require(ReplicatedStorage.Packages.Log)
local RecommendationFlags = require(script.Parent.RecommendationFlags)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
local TreadmillMediaOverlay = require(ReplicatedStorage.Shared.Modules.TreadmillMediaOverlay)
require(script.Parent.Types.Interface)
local v = Log.new()
local v2 = nil
local v3 = {}
local mediaEntries = {}
local v4 = 0
local v5 = nil
local now = 0
local v6 = false
local v7 = 0
local RecommendationFeedSource = {}

local function buildMediaIndexMap(list)
	if v2 == list then
		return
	end

	v2 = list
	v3 = {}

	for i, v8 in ipairs(list) do
		local mediaKey = TreadmillMediaIdentity.GetMediaKey(v8)

		if v3[mediaKey] == nil then
			v3[mediaKey] = i
		end
	end
end

local function appendCurrentPage(object)
	local currentPage = object:GetCurrentPage()

	for _, v8 in ipairs(currentPage) do
		local mediaIndex = v3[v8.ReferenceId]

		if mediaIndex == nil or TreadmillMediaOverlay.IsExcluded(v8.ReferenceId) then
			continue
		end

		table.insert(mediaEntries, {
			MediaIndex = mediaIndex,
			MediaKey = v8.ReferenceId,
			ItemId = v8.ItemId,
			TracingId = v8.TracingId,
			ItemPosition = #mediaEntries + 1
		})
	end
end

local function generateListAsync()
	if Constants.IS_STUDIO or not RecommendationFlags.Enabled:Get() then
		return false
	end

	local success, result = pcall(function()
		local itemListAsync = RecommendationService:GenerateItemListAsync({
			ConfigName = RecommendationFlags.ConfigName:Get(),
			LocationId = "TreadmillFeed",
			PageSize = RecommendationFlags.PageSize:Get()
		})
		mediaEntries = {}
		v4 = 0
		v5 = itemListAsync
		now = os.clock()
		appendCurrentPage(itemListAsync)
	end)

	if success then
		v:AtTrace():Log((`Generated treadmill recommendation list: {#mediaEntries} items`))
		return #mediaEntries > 0
	end

	v:AtWarning():Log((`Failed to generate treadmill recommendation list: {result}`))
	return false
end

local function prefetchNextPageAsync()
	if Constants.IS_STUDIO or not RecommendationFlags.Enabled:Get() then
		return
	end

	if v6 or v5 == nil or v5.IsFinished or os.clock() < v7 then
		return
	end

	v6 = true
	task.spawn(function()
		local success, result = pcall(function()
			v5:AdvanceToNextPageAsync()
			appendCurrentPage(v5)
		end)
		v6 = false

		if not success then
			v7 = os.clock() + RecommendationFlags.FailureCooldownSeconds:Get()
			v:AtWarning():Log((`Failed to advance treadmill recommendation page: {result}`))
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function maybePrefetch()
	if #mediaEntries - v4 <= RecommendationFlags.PrefetchMargin:Get() then
		prefetchNextPageAsync()
	end
end

local function isSessionUsable()
	return #mediaEntries > 0 and os.clock() - now < RecommendationFlags.StaleSeconds:Get()
end

function RecommendationFeedSource.PrefetchFeed(p)
	buildMediaIndexMap(p)

	if Constants.IS_STUDIO or not RecommendationFlags.Enabled:Get() then
		return
	end

	local v8

	if #mediaEntries > 0 then
		v8 = os.clock() - now < RecommendationFlags.StaleSeconds:Get()
	else
		v8 = false
	end

	if v8 or v6 or os.clock() < v7 then
		return
	end

	v6 = true
	task.spawn(function()
		local v9 = generateListAsync()

		if not v9 then
			task.wait(RecommendationFlags.FetchRetryDelaySeconds:Get())
			v9 = generateListAsync()
		end

		v6 = false

		if not v9 then
			v7 = os.clock() + RecommendationFlags.FailureCooldownSeconds:Get()
		end
	end)
end

function RecommendationFeedSource.GetReadyItem()
	if Constants.IS_STUDIO or not RecommendationFlags.Enabled:Get() then
		return nil
	end

	local v8

	if #mediaEntries > 0 then
		v8 = os.clock() - now < RecommendationFlags.StaleSeconds:Get()
	else
		v8 = false
	end

	if not v8 then
		return nil
	end

	if v4 == 0 then
		v4 = 1
	end

	for i = v4, #mediaEntries do
		local v9 = mediaEntries[i]

		if v9 == nil or TreadmillMediaOverlay.IsExcluded(v9.MediaKey) then
			continue
		end

		v4 = i
		maybePrefetch() -- equivalent call inferred; original call site unknown
		return v9
	end

	maybePrefetch() -- equivalent call inferred; original call site unknown
	return nil
end

function RecommendationFeedSource.Next()
	if #mediaEntries == 0 then
		return nil
	end

	for _ = 1, #mediaEntries do
		v4 += 1

		if v4 > #mediaEntries then
			v4 = 1
		end

		local v8 = mediaEntries[v4]

		if v8 == nil or TreadmillMediaOverlay.IsExcluded(v8.MediaKey) then
			continue
		end

		maybePrefetch() -- equivalent call inferred; original call site unknown
		return v8
	end

	maybePrefetch() -- equivalent call inferred; original call site unknown
	return nil
end

function RecommendationFeedSource.Previous()
	if #mediaEntries == 0 then
		return nil, false
	end

	for i = v4 - 1, 1, -1 do
		local v8 = mediaEntries[i]

		if v8 == nil or TreadmillMediaOverlay.IsExcluded(v8.MediaKey) then
			continue
		end

		v4 = i
		return v8, true
	end

	v4 = math.clamp(v4, 1, #mediaEntries)
	return mediaEntries[v4], false
end

function RecommendationFeedSource.PeekAhead(p: number)
	local mediaIndexes = {}
	local count = 0

	while #mediaIndexes < p do
		count += 1
		local v8 = mediaEntries[v4 + count]

		if v8 == nil then
			break
		end

		if not TreadmillMediaOverlay.IsExcluded(v8.MediaKey) then
			table.insert(mediaIndexes, v8.MediaIndex)
		end
	end

	return mediaIndexes
end

TreadmillMediaOverlay.Changed:Connect(function()
	v2 = nil
end)
RecommendationFlags.Enabled.Changed:Connect(function()
	if RecommendationFlags.Enabled:Get() then
		return
	end

	mediaEntries = {}
	v4 = 0
	v5 = nil
	now = 0
end)
RecommendationFlags.ConfigName.Changed:Connect(function()
	now = 0
	task.delay(math.random() * RecommendationFlags.ConfigSwapSpreadSeconds:Get(), function()
		local v8 = v2

		if v8 ~= nil then
			RecommendationFeedSource.PrefetchFeed(v8)
		end
	end)
end)
return RecommendationFeedSource