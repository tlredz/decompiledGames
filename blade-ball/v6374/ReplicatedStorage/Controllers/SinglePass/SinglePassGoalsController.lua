local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Shared.NewQuests.Quests)
require3(ReplicatedStorage2.Shared.NewQuests.QuestUtility)
local v4 = require3(ReplicatedStorage2.Shared.CNYEvent.CNYEventItemData)
local remoteFunction = v2:RemoteFunction("CNYEvent_ClaimMilestone")
local v5 = nil
local milestone = Players.LocalPlayer.PlayerGui:WaitForChild("SinglePass").MainFrame.Main.Pages.Milestone
local template = milestone.Rewards.UIListLayout.Template
return {
	Start = function(_)
		v5 = v.Client:WaitReplion("Data")
		local v6 = v.Client:WaitReplion("GlobalNumbers")

		for k, milestone2 in v4.Milestones do
			local clone = template:Clone()
			clone.Label.Text = milestone2.Reward.DisplayName
			clone.Vector.Image = milestone2.Reward.Icon or v3.Icons:GetIcon("DEFAULT_MISSING")
			clone.Visible = true
			local v7 = k

			local function updateTile()
				local milestoneXP = v4.GetMilestoneXP(v7)

				if not milestoneXP then
					return
				end

				local v9 = v5:Get("CNYEvent.ClaimedMilestones") or {}
				local v10 = v6:Get("Loaded") == true and v6:Get({ "Values", v4.GlobalNumberKey }) or 0
				local v11 = v5:Get("CNYEvent.TotalContributed") or 0
				local v12 = math.clamp(v10 / milestoneXP.Global, 0, 1)
				local v13 = math.clamp(v11 / milestoneXP.Local, 0, 1)
				local visible = v9[v7] == true
				local visible2

				if v12 >= 1 and v13 >= 1 then
					visible2 = not visible
				else
					visible2 = false
				end

				clone.ProgressBar.Fill.Size = UDim2.fromScale(v12, 0.944)
				clone.ProgressBar.Fill.Visible = v12 >= 0.02
				local label = clone.ProgressBar.Label
				local text

				if v12 >= 1 or visible then
					text = v3.ValueConvertor:ShrinkNumber(milestoneXP.Global)
				else
					text = `{v3.ValueConvertor:ShrinkNumber(v10)}/{v3.ValueConvertor:ShrinkNumber(milestoneXP.Global)}`
				end

				label.Text = text
				local locked = clone.Locked
				locked.Visible = v11 < milestoneXP.Local and v12 >= 1
				clone.Locked.ProgressBar.Fill.Size = UDim2.fromScale(v13, 0.944)
				clone.Locked.ProgressBar.Fill.Visible = v13 >= 0.02
				clone.Locked.ProgressBar.Label.Text = `{v3.ValueConvertor:ShrinkNumber(v11)}/{v3.ValueConvertor:ShrinkNumber(milestoneXP.Local)}`
				clone.Claimed.Visible = visible
				clone.Claim.Visible = visible2
				clone.ProgressBar.Visible = not visible2

				if v7 == 1 then
					local v18 = nil

					for k2 in v4.Milestones do
						local milestoneXP2 = v4.GetMilestoneXP(k2)

						if milestoneXP2 and v11 < milestoneXP2.Local then
							v18 = milestoneXP2.Local
						end
					end

					milestone.ContributeInfo.Visible = v18 ~= nil
					milestone.ContributeInfo.Amount.Text = not v18 and "" or v3.ValueConvertor:AddCommas(v18 - v11)
				end
			end

			v6:OnChange("Values", updateTile)
			v6:OnChange("Loaded", updateTile)
			v5:OnChange("CNYEvent.ClaimedMilestones", updateTile)
			v5:OnChange("CNYEvent.TotalContributed", updateTile)
			v3.FFlag.OnChange(updateTile)
			task.spawn(updateTile)
			clone.Parent = milestone.Rewards
			local v9 = k
			clone.Claim.Activated:Connect(function()
				local milestoneXP = v4.GetMilestoneXP(v9)

				if not milestoneXP or milestoneXP.Local - (v5:Get("CNYEvent.TotalContributed") or 0) > 0 then
					return
				end

				if not remoteFunction:InvokeServer(v9) then
					ReplicatedStorage2.Misc.error:Play()
				end
			end)
		end
	end
}