local AdService = game:GetService("AdService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

-- equivalent calls inferred from this helper; original call sites unknown
local function dbg(p: string)
	print("[AdEggBoostClient]", p)
end

local adEggBoostRemotes = ReplicatedStorage:WaitForChild("AdEggBoostRemotes", 30)
assert(adEggBoostRemotes ~= nil, "AdEggBoostRemotes folder not found — is AdEggBoostServer running?")
local askAdGrowthBoost = adEggBoostRemotes:WaitForChild("AskAdGrowthBoost")
local adGrowthBoostResult = adEggBoostRemotes:WaitForChild("AdGrowthBoostResult")
local adEggBoostConfigResult = adEggBoostRemotes:WaitForChild("AdEggBoostConfigResult")
local AdEggBoostClient = {
	AdCompleted = Signal.new()
}
local v = false
adEggBoostConfigResult.OnClientEvent:Connect(function(p)
	if p and p.gated then
		v = true
	end
end)

function AdEggBoostClient.IsGated()
	return v
end

function AdEggBoostClient.CheckAdAvailable()
	dbg("CheckAdAvailable called") -- equivalent call inferred; original call site unknown
	local success, result = pcall(function()
		return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
	end)

	if success then
		local selected = result.AdAvailabilityResult == Enum.AdAvailabilityResult.IsAvailable
		dbg("CheckAdAvailable result: " .. tostring(result.AdAvailabilityResult) .. " -> " .. tostring(selected)) -- equivalent call inferred; original call site unknown
		return selected
	else
		dbg("CheckAdAvailable pcall failed: " .. tostring(result)) -- equivalent call inferred; original call site unknown
		return false
	end
end

function AdEggBoostClient.RequestAd()
	dbg("RequestAd called — invoking server") -- equivalent call inferred; original call site unknown
	local v2, v3 = askAdGrowthBoost:InvokeServer()
	dbg("RequestAd server returned: ok=" .. tostring(v2) .. ", err=" .. tostring(v3)) -- equivalent call inferred; original call site unknown
end

adGrowthBoostResult.OnClientEvent:Connect(function(p)
	dbg("AdGrowthBoostResult received: completed=" .. tostring(p.completed)) -- equivalent call inferred; original call site unknown
	AdEggBoostClient.AdCompleted:Fire(p.completed == true)
end)
return AdEggBoostClient