local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Config = require(script.Parent.Config)
local remo = require(ReplicatedStorage.Packages.remo)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local HuntReward = {
	remotes = remo.createRemotes({
		huntReward = remo.namespace({
			showBadge = remo.remote()
		})
	}).huntReward
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getDataManager()
	return require(ServerScriptService.DataManager)
end

local function tryAwardNewBadge(instance)
	local success, result = pcall(BadgeService.UserHasBadgeAsync, BadgeService, instance.UserId, Config.huntBadgeId)

	if success and result ~= true then
		local success2, result2 = pcall(BadgeService.AwardBadgeAsync, BadgeService, instance.UserId, Config.huntBadgeId)

		if success2 and result2 == true then
			return true
		end

		if not success2 then
			logger:warn(string.format(
				"20th Anniversary badge award failed for %s: %s",
				instance.Name,
				(tostring(result2))
			))
		end

		return false
	else
		if not success then
			logger:warn(string.format(
				"20th Anniversary badge check failed for %s: %s",
				instance.Name,
				(tostring(result))
			))
		end

		return false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function presentBadge(p)
	HuntReward.remotes.showBadge:fire(p, Config.huntBadgeId)
end

local function reconcilePlayer(instance)
	local dataManager = getDataManager() -- equivalent call inferred; original call site unknown
	local store = dataManager:GetStore(instance, Config.huntBadgeProfileKey)

	if store and store:Get(false) == true and instance.Parent == Players then
		task.spawn(function()
			if instance.Parent == Players and tryAwardNewBadge(instance) then
				presentBadge(instance) -- equivalent call inferred; original call site unknown
			end
		end)
	elseif not store then
		logger:warn(string.format("20th Anniversary badge profile store missing for %s", instance.Name))
	end
end

function HuntReward.grant(instance)
	assert(RunService:IsServer(), "HuntReward.grant is server-only")
	local dataManager = getDataManager() -- equivalent call inferred; original call site unknown
	local store = dataManager:GetStore(instance, Config.huntBadgeProfileKey)

	if instance.Parent == Players and store then
		store:Set(true)
		task.spawn(function()
			if instance.Parent == Players and tryAwardNewBadge(instance) then
				presentBadge(instance) -- equivalent call inferred; original call site unknown
			end
		end)
	elseif not store then
		logger:warn(string.format("20th Anniversary badge profile store missing for %s", instance.Name))
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not RunService:IsServer() then
			HuntReward.remotes.showBadge:connect(function(p: number)
				task.spawn(function()
					local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

					while playerGui:FindFirstChild("Loading") do
						task.wait(0.2)
					end

					task.wait(0.3)
					local ItemRewardUISystem = require(ReplicatedStorage.ItemRewardUISystem)
					ItemRewardUISystem.playForBadge(p)
				end)
			end)
			return
		end

		local dataManager = getDataManager() -- equivalent call inferred; original call site unknown
		dataManager.profileLoaded:Connect(reconcilePlayer)

		for _, v in Players:GetPlayers() do
			reconcilePlayer(v)
		end
	end
})
return HuntReward