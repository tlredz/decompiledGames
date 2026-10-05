local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Signal)
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
require3(ReplicatedStorage2.Shared.NewQuests.Quests)
local v2 = require3(ReplicatedStorage2.Shared.NewQuests.QuestUtility)
require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventItemData)
require3(ReplicatedStorage2.ServerInfo)
local v3 = nil
local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerGui
local quests = localPlayer.PlayerGui:WaitForChild("SinglePass").MainFrame.Main.Pages.Quests
local questTemplate = quests.QuestList.UIListLayout.QuestTemplate
questTemplate.Parent = nil
local clones = {}
local SinglePassQuestsController = {
	Start = function(_)
		v3 = v.Client:WaitReplion("Data")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onQuestChanged()
			local cNYEvent = v3:Get("CNYEvent")

			if not (cNYEvent and cNYEvent.Quests) then
				return
			end

			local quests2 = cNYEvent.Quests
			local questTier = cNYEvent.QuestTier
			OnQuestsChanged("Daily", quests2.Main.Daily, questTier)
		end

		v3:OnChange("CNYEvent.Quests.Main.Daily.Quests", onQuestChanged)
		v3:OnChange("CNYEvent.Quests.Main.Daily", onQuestChanged)
		v3:OnChange("CNYEvent.Quests.Main", onQuestChanged)
		v3:OnChange("CNYEvent.QuestTier", onQuestChanged)
		v3:OnChange("CNYEvent.Quests.XP", onQuestChanged)
		v3:OnChange("CNYEvent.Lanterns", onQuestChanged)
		onQuestChanged() -- equivalent call inferred; original call site unknown
	end
}

function UpdateQuestTile(p: string, data, _: number)
	local questData = v2:GetQuestData("CNYEvent", p, data.QuestId)

	if not questData then
		return
	end

	local value = questData.Arguments.value

	if typeof(value) == "function" then
		value = value(v3)
	end

	local formatted = `{p}_{data.QuestId}`
	local clone = clones[formatted]

	if not clone then
		clone = questTemplate:Clone()
		clone.Title.Text = questData.DisplayName
		clone.Reward.Reward.Text = `+{questData.Reward}`
		clone.Reward.Check.Visible = data.Redeemed

		if not data.Redeemed then
			local mouseButton1ClickConnection = nil
			mouseButton1ClickConnection = clone.Claim.MouseButton1Click:Connect(function()
				if v2.RedeemQuestsType:InvokeServer("CNYEvent", p, data.QuestId) and mouseButton1ClickConnection.Connected then
					mouseButton1ClickConnection:Disconnect()
				end
			end)
		end

		clone.Parent = quests.QuestList
		clones[formatted] = clone
	end

	if clone then
		local v4 = math.clamp(data.Progress, 0, value)
		local v5 = v4 / value
		clone.Claimed.Visible = data.Redeemed
		local claim = clone.Claim
		claim.Visible = v5 == 1 and not data.Redeemed
		clone.Reward.Check.Visible = data.Redeemed
		clone.Amount.Text = `Progress: {math.floor(v4 * 100) / 100}/{value}`
		clone.Progress.Fill.Size = UDim2.fromScale(v5, 1)
		clone.Progress.Fill.Visible = v5 >= 0.02
		local v7 = data.Redeemed and 100 or 0
		clone.LayoutOrder = data.QuestId + v7
		clone.Visible = true
	end
end

function OnQuestsChanged(p: string, p2, p3: number)
	for _, quest in ipairs(p2.Quests) do
		UpdateQuestTile(p, quest, p3)
	end
end

return SinglePassQuestsController