local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PolicyService = game:GetService("PolicyService")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = { "rbxassetid://120929612806626" }
local v2 = {}
local v3 = {}
local backfillads = false
local videoads = false
local imagerotationtimeseconds = 60
local fn = nil
local count = 0
local v4 = {}

local function loadAd(instance)
	while not instance:FindFirstChildOfClass("AdGui") do
		task.wait()
	end

	local adGui = instance:FindFirstChildOfClass("AdGui")

	if not adGui:IsA("AdGui") then
		warn("Instance is tagged with AdInsertion tag but does not contain an AdGui!")
	elseif not (backfillads or videoads) then
		adGui:Destroy()
	elseif videoads then
		v3[instance] = adGui
		fn(adGui)
	else
		adGui:Destroy()
		local decal = Instance.new("Decal", instance)
		decal.Face = Enum.NormalId.Back
		v3[instance] = decal
		fn(decal)
	end
end

local function removeAd(p)
	v3[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startBackfillImageRotation()
	local v5 = 0
	RunService.Heartbeat:Connect(function(dt)
		v5 += dt

		if v5 < imagerotationtimeseconds then
			return
		end

		v5 -= imagerotationtimeseconds
		count += 1

		for _, v6 in pairs(v3) do
			fn(v6)
		end
	end)
end

local function setFallbackImageDecal(p)
	if #v4 > 0 then
		p.Texture = v4[count % #v4 + 1]
	end
end

local function setFallbackImageAdGui(p)
	if #v4 > 0 then
		p.FallbackImage = v4[count % #v4 + 1]
	end
end

local BusStopAdsController = {
	GetCurrentImage = function()
		if #v4 == 0 then
			return nil
		end

		return v4[count % #v4 + 1]
	end,
	FrameworkInit = function() end
}

local function StripOutActualAds()
	local v5 = 1

	while v5 <= #v do
		if v2[v[v5]] then
			table.remove(v, v5)
		else
			v5 += 1
		end
	end
end

function BusStopAdsController.FrameworkStart()
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(game.Players.LocalPlayer)
	end)

	if success and result then
		if not result.AreAdsAllowed then
			StripOutActualAds()
		end
	else
		StripOutActualAds()
	end

	for i = #v, 2, -1 do
		local v5 = math.random(i)
		local v6 = v
		local v7 = v
		local v8 = v[v5]
		local v9 = v[i]
		v6[i] = v8
		v7[v5] = v9
	end

	for _, v5 in pairs(v) do
		table.insert(v4, v5)
	end

	local v5, v6 = ABTest.GetExperimentVariables("bus-stop-ads", "backfills-ads"):timeout(3):await()

	if v5 then
		backfillads = v6["backfill-ads"] or false
		videoads = v6["video-ads"] or false
		imagerotationtimeseconds = v6["image-rotation-time-seconds"] or 60
	end

	if backfillads then
		if videoads then
			fn = setFallbackImageAdGui
		else
			fn = setFallbackImageDecal
		end
	else
		fn = function(_) end
	end

	CollectionService:GetInstanceAddedSignal("AdInsertion"):Connect(loadAd)
	CollectionService:GetInstanceRemovedSignal("AdInsertion"):Connect(removeAd)

	for _, v7 in pairs(CollectionService:GetTagged("AdInsertion")) do
		loadAd(v7)
	end

	if backfillads then
		startBackfillImageRotation() -- equivalent call inferred; original call site unknown
	end

	PlayerLocalizationController.CountryRegionChanged:Connect(function()
		for _, v7 in pairs(CollectionService:GetTagged("AdInsertion")) do
			loadAd(v7)
		end
	end)
end

return BusStopAdsController