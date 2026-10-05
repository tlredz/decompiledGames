require(game.ReplicatedStorage.ServerInfo)
local RankedSeasonData = require(game.ReplicatedStorage.Shared.RankedSeasonData)
local localPlayer = game.Players.LocalPlayer
local Replion = require(game.ReplicatedStorage.Packages.Replion)
local StatsManager = require(script.Parent.StatsManager)
local RankedSignalController = require(game.ReplicatedStorage.Controllers.Ranked.RankedSignalController)
local updateRankedMenuSignal = RankedSignalController:GetUpdateRankedMenuSignal()
local Trove = require(game.ReplicatedStorage.Packages.Trove)
local v = "Normal"
local maid = Trove.new()
local v2 = nil
StatsManager.PrepareAbilityStats()
local v3 = "RankedAbilityUsage"
local v4 = "RankedStats"
Replion.Client:AwaitReplion("Data", function(object)
	v2 = object
	local rankedType = RankedSeasonData.GetRankedType()
	local currentSeason = RankedSeasonData.GetCurrentSeason(rankedType)
	local v5 = string.format("Season%s", currentSeason)
	local v6 = {
		Normal = {},
		NoAbility = {}
	}

	local function loadAllStats()
		local v7 = (object:Get(v4) or v6)[rankedType][v5] or {}
		StatsManager.LoadPersonalStats(v7)
		local v8 = (object:Get(v3) or v6)[rankedType][v5] or {}
		StatsManager.LoadAbilityStats(v8)
	end

	loadAllStats()
	maid:Add(object:OnChange(v4, function(p)
		local v7 = p[rankedType][v5]

		if not v7 then
			return
		end

		StatsManager.LoadPersonalStats(v7)
	end))
	maid:Add(object:OnChange(v3, function(p)
		local v7 = p[rankedType][v5]

		if not v7 then
			return
		end

		StatsManager.LoadAbilityStats(v7)
	end))
	local seasonSelect = localPlayer.PlayerGui.RankedSelection.Page.Windows.Statistics.SeasonSelect
	local currentSeason2 = RankedSeasonData.GetCurrentSeason(RankedSeasonData.GetRankedType())

	local function increasePage(p: number)
		local currentSeason3 = RankedSeasonData.GetCurrentSeason(RankedSeasonData.GetRankedType())
		currentSeason2 += p

		if currentSeason2 < 1 then
			currentSeason2 = currentSeason3
		elseif currentSeason3 < currentSeason2 then
			currentSeason2 = 1
		end

		v5 = string.format("Season%s", currentSeason2)
		seasonSelect.Season.Text.Text = `Season {currentSeason2}`
		loadAllStats()
	end

	seasonSelect.Back.Activated:Connect(function()
		increasePage(-1)
	end)
	seasonSelect.Next.Activated:Connect(function()
		increasePage(1)
	end)
	increasePage(0)
	maid:Add(RankedSeasonData.SeasonChanged:Connect(function(_)
		currentSeason = RankedSeasonData.GetCurrentSeason(rankedType)
		v5 = string.format("Season%s", (tostring(currentSeason)))
		local rankedStats = object:Get("RankedStats")

		if not rankedStats then
			return
		end

		StatsManager.LoadPersonalStats(rankedStats)
		StatsManager.LoadAbilityStats(rankedStats)
		StatsManager.LoadAbilityStats(rankedStats)
	end))
end)
updateRankedMenuSignal:Connect(function(p)
	v = p
	maid:Clean()
	local currentSeason = RankedSeasonData.GetCurrentSeason(v)
	local v5 = string.format("Season%s", currentSeason)
	v3 = "RankedAbilityUsage"
	v4 = "RankedStats"
	local v6 = v2:Get(v4)

	if not v6 then
		return
	end

	local v7 = v6[v][v5]

	if not v7 then
		return
	end

	StatsManager.LoadPersonalStats(v7)
	local v8 = v2:Get(v3)

	if not v8 then
		return
	end

	local v9 = v8[v][v5]
	StatsManager.LoadAbilityStats(v9)
	maid:Add(v2:OnChange(v4, function(p2)
		local v10 = p2[v][v5]

		if not v10 then
			return
		end

		StatsManager.LoadPersonalStats(v10)
	end))
	maid:Add(v2:OnChange(v3, function(p2)
		local v10 = p2[v][v5]

		if not v10 then
			return
		end

		StatsManager.LoadAbilityStats(v10)
	end))
	maid:Add(RankedSeasonData.SeasonChanged:Connect(function(_)
		currentSeason = RankedSeasonData.GetCurrentSeason(v)
		v5 = string.format("Season%s", (tostring(currentSeason)))
		local rankedStats = v2:Get("RankedStats")

		if not rankedStats then
			return
		end

		StatsManager.LoadPersonalStats(rankedStats)
		StatsManager.LoadAbilityStats(rankedStats)
		StatsManager.LoadAbilityStats(rankedStats)
	end))
end)
return nil