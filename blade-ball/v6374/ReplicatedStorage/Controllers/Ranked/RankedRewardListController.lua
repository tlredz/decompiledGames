local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Shared.RankData)
local v3 = require3(ReplicatedStorage2.Shared.RankedSeasonData)
require3(ReplicatedStorage2.Common.RewardInfo)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v8 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v9 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local playerGui = Players.LocalPlayer.PlayerGui
local rankedRewardList = playerGui.RankedRewardList
local rankedSelection = playerGui.RankedSelection
local info = rankedRewardList.Main.Info
local RankedRewardListController = {}
RankedRewardListController._rewardTrove = v4.new()

function RankedRewardListController:_setupRankInfo()
	for childName, rank in pairs(v2.Ranks) do
		local child = info.Ranks:FindFirstChild(childName)

		if not child then
			continue
		end

		child.Image = rank.Icon
		local eloRange = child.EloRange
		local text

		if rank.MaximumElo == "inf" then
			text = `{rank.MinimumElo}+ ELO`
		else
			text = `{rank.MinimumElo} - {rank.MaximumElo} ELO`
		end

		eloRange.Text = text
	end
end

function RankedRewardListController:_updateRewards()
	local rankedType = v3.GetRankedType()
	local currentSeason = v3.GetCurrentSeason(rankedType)
	self._rewardTrove:Clean()

	for _, rank in pairs(v2.Ranks) do
		local child = info.Rewards:FindFirstChild(rank.Name)

		if not child then
			continue
		end

		local v10 = nil

		if rank.Reward then
			v10 = rank.Reward[rankedType]
		elseif rank.Rewards then
			v10 = rank.Rewards[rankedType][tostring(currentSeason)]
		end

		local v11 = v10 or {}

		for i = #v11 + 1, 3 do
			local child2 = child:FindFirstChild(i)

			if child2 then
				child2.Visible = false
			end
		end

		for childName, v12 in v11 do
			local child2 = child:FindFirstChild(childName)

			if not child2 then
				continue
			end

			child2.Vector.Image = v12.Icon or v5.Icons:GetIcon("DEFAULT_MISSING")
			child2.TextLabel.Text = v12.DisplayName

			if v8:CanShowRewardInfo(v12) then
				v8:AddFromRewardInfo(child2, v12)
			else
				v8:Remove(info)
			end

			local inspect = child2:FindFirstChild("Inspect")

			if not inspect then
				continue
			end

			local canPreview = v7:CanPreview(v12)
			inspect.Visible = canPreview

			if not canPreview then
				continue
			end

			local v13 = v12
			self._rewardTrove:Add(inspect.Activated:Connect(function()
				v:Close(rankedRewardList.Name)
				v7:PreviewReward(v13, rankedRewardList.Name)
			end))
		end
	end
end

function RankedRewardListController:Start()
	rankedRewardList.Main.Exit.Close.Activated:Connect(function()
		v:Close(rankedRewardList.Name)
		rankedSelection.Enabled = true
	end)
	self:_setupRankInfo()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateSeason()
		local currentSeason = v3.GetCurrentSeason(v3.GetRankedType())
		info.ChampionTitle.Text = `Finish the season as Champion to recieve “<font color="#24a0ff">Season {currentSeason} Champion</font>” Title!`
		self:_updateRewards()
	end

	v3.SeasonChanged:Connect(updateSeason)
	updateSeason() -- equivalent call inferred; original call site unknown
	rankedRewardList:GetPropertyChangedSignal("Enabled"):Connect(function()
		if rankedRewardList.Enabled then
			v9:Hide(rankedRewardList.Name)
			rankedSelection.Enabled = false
		else
			v9:Show(rankedRewardList.Name)
		end

		local v10 = not rankedRewardList.Enabled
		v6(Enum.CoreGuiType.PlayerList, v10)
		v6(Enum.CoreGuiType.Chat, v10)
	end)
end

return RankedRewardListController