local RankedSeasonData = require(game.ReplicatedStorage.Shared.RankedSeasonData)
local localPlayer = game.Players.LocalPlayer
local Replion = require(game.ReplicatedStorage.Packages.Replion)
local HistoryManager = require(script.Parent.HistoryManager)
local RankedSignalController = require(game.ReplicatedStorage.Controllers.Ranked.RankedSignalController)
local rankedType = RankedSeasonData.GetRankedType()
local updateRankedMenuSignal = RankedSignalController:GetUpdateRankedMenuSignal()

local function load(rankedType2: string, p: number?)
	local v = Replion.Client:WaitReplion("Data")
	local rankedMatchHistory = v:Get("RankedMatchHistory")

	if not rankedMatchHistory then
		return
	end

	local v2 = string.format("Season%s", (tostring(p or RankedSeasonData.GetCurrentSeason(rankedType2))))
	local v3 = rankedMatchHistory[rankedType2][v2] or {}
	HistoryManager.LoadPlacements(v3, localPlayer)
	v:OnChange("RankedMatchHistory", function(p2)
		local v4 = string.format("Season%s", (tostring(p or RankedSeasonData.GetCurrentSeason(rankedType2))))
		local v5 = p2[rankedType2][v4] or {}
		HistoryManager.LoadPlacements(v5, localPlayer)
	end)
end

Replion.Client:AwaitReplion("Data", function(_)
	local seasonSelect = localPlayer.PlayerGui.RankedSelection.Page.Windows.History.SeasonSelect
	local currentSeason = RankedSeasonData.GetCurrentSeason(RankedSeasonData.GetRankedType())

	-- equivalent calls inferred from this helper; original call sites unknown
	local function increasePage(p: number)
		local currentSeason2 = RankedSeasonData.GetCurrentSeason(RankedSeasonData.GetRankedType())
		currentSeason += p

		if currentSeason < 1 then
			currentSeason = currentSeason2
		elseif currentSeason2 < currentSeason then
			currentSeason = 1
		end

		seasonSelect.Season.Text.Text = `Season {currentSeason}`
		load(rankedType, currentSeason)
	end

	seasonSelect.Back.Activated:Connect(function()
		increasePage(-1) -- equivalent call inferred; original call site unknown
	end)
	seasonSelect.Next.Activated:Connect(function()
		increasePage(1) -- equivalent call inferred; original call site unknown
	end)
	increasePage(0) -- equivalent call inferred; original call site unknown
end)
updateRankedMenuSignal:Connect(function(p: string)
	rankedType = p
	load(rankedType)
end)
return nil