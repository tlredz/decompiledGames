local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local clientGameModules = ReplicatedStorage2.ClientGameModules
local _ = ReplicatedStorage2.Common
local _ = ReplicatedStorage2.Packages
local v = require3("@game/ReplicatedStorage/Packages/Charm")
local v2 = require3("@game/ReplicatedStorage/Packages/Promise")
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.Packages.Reliever)
local v6 = require3(ReplicatedStorage2.Common.Utils)
local v7 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v8 = require3(clientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.Statable)
local v9 = require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.Shared.PlayerData.CountryIcons)
local v10 = require3(ReplicatedStorage2.Shared.InfiniteBattlepass.InfiniteBattlepassData)
local v11 = require3(ReplicatedStorage2.Shared.InfiniteBattlepass.InfiniteBattlepassTopTiersRewards)
local v12 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local v13 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v14 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v15 = nil
local playerGui = Players.LocalPlayer.PlayerGui
local battlepassTopTierLeaderboard = playerGui.BattlepassTopTierLeaderboard
local list = battlepassTopTierLeaderboard.Frame.List
local topTiersRewards = playerGui.TopTiersRewards
local page = topTiersRewards.Page
local promisify = v2.promisify(function()
	return v4:Invoke("InfiniteBattlepass/GetTierLeaderboard")
end)
return {
	Start = function(_)
		v15 = v3.Client:WaitReplion("Data")
		local v16 = 0
		local atom = v.atom({})
		local atom2 = v.atom(false)
		local atom3 = v7.atom(v15, "InfiniteBattlepass.Quests.XP")
		v7.atom(v15, "InfiniteBattlepass.Claimed")
		v7.atom(v15, "InfiniteBattlepass.Premium")
		local atom4 = v7.atom(v15, "InfiniteBattlepassTopTiers")
		local computed = v.computed(function()
			local v17 = atom3() or 0
			return v10.SeasonData.Rewards.getTierFromXP(v17)
		end)
		v12:OnViewOpen("TopTiers"):Connect(function()
			atom2(true)
		end)
		v12:OnViewClosed("TopTiers"):Connect(function()
			atom2(false)
		end)
		battlepassTopTierLeaderboard.Frame.CloseButton.Activated:Connect(function()
			v12:OpenView("TopTiersRewards")
		end)
		page.ViewRanksButton.Activated:Connect(function()
			v12:OpenView("TopTiers")
		end)
		page.CloseButton.Activated:Connect(function()
			v12:CloseView("TopTiersRewards")
		end)
		local v17 = nil
		v.effect(function()
			if not atom2() then
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()

			if not (serverTimeNow - v16 > 300) or v17 then
				return
			end

			v16 = serverTimeNow
			v17 = promisify():andThen(function(p, buf)
				if not p then
					return
				end

				local v18 = buffer.readu8(buf, 0)
				local v19 = table.create(v18)
				local v20 = 1

				for _ = 1, v18 do
					local userId = buffer.readf64(buf, v20)
					local v22 = v20 + 8
					local score = buffer.readu32(buf, v22)
					v20 = v22 + 4
					table.insert(v19, {
						userId = userId,
						score = score
					})
				end

				atom(v19)
			end):finally(function()
				v17 = nil
			end)
		end)
		local count = 0

		local function renderLeaderboard(list2, p: number)
			for i = 1, 100 do
				if p ~= count then
					return
				end

				v5.relieve()
				local v18 = list2[i] or {
					userId = 0,
					score = 0
				}
				local clone = list:FindFirstChild((tostring(i)))

				if not clone then
					clone = list.UIListLayout:FindFirstChild((`Rank{math.clamp(i, 1, 4)}`)):Clone()
					clone.Title.Text = `#{i}`
					clone.Name = tostring(i)
					clone.LayoutOrder = i
					clone.Visible = true
					clone.Parent = list
				end

				clone.Points.Text = `Tier {v6.ValueConvertor:AddCommas(v18.score)}`

				if v18.userId == 0 then
					clone.Username.Text = "???"
					clone.PlayerPortrait.Visible = false
				else
					clone.Username.Text = "???"
					v9:GetUsername(v18.userId):andThen(function(p2)
						clone.Username.Text = `@{p2}`
					end)
					clone.PlayerPortrait.Visible = true
					clone.PlayerPortrait.Image = `rbxthumb://type=AvatarHeadShot&id={v18.userId}&w=150&h=150`
				end
			end

			list.CanvasSize = UDim2.fromOffset(0, list.UIListLayout.AbsoluteContentSize.Y + 80)
		end

		v.effect(function()
			local v18 = atom()

			if not atom2() then
				return nil
			end

			count += 1
			task.spawn(renderLeaderboard, v18, count)
			return nil
		end)
		v.effect(function()
			topTiersRewards.Page.MyTier.Text = `My tier: {computed()}`
		end)
		task.defer(function()
			while true do
				local serverTimeNow = workspace:GetServerTimeNow()
				local timestamps = v10.getTimestamps()

				if math.max(0, timestamps.endTimestamp - serverTimeNow) > 0 then
					topTiersRewards.Page.TimeUntil.Title.Text = `Battlepass ends in {v6.ValueConvertor:FormatTimeHHMMSS(timestamps.endTimestamp - serverTimeNow)}`
				else
					topTiersRewards.Page.TimeUntil.Title.Text = "Battlepass ended!"
				end

				task.wait(1)
			end
		end)
		local season = v10.Season
		local v18 = v11[season]

		if v18 then
			for k, v19 in v18 do
				local child = page:FindFirstChild(`Reward{k}`, true)

				if not child then
					continue
				end

				local reward = v19.Reward
				local rewardIcon = child:FindFirstChild("RewardIcon", true)
				rewardIcon.Image = reward.Icon or "rbxassetid://0"
				local label = rewardIcon.Label
				local text

				if k == 1 then
					text = reward.DisplayName:upper()
				else
					text = reward.DisplayName
				end

				label.Text = text
				local canPreview = v14:CanPreview(reward)
				child.Inspect.Visible = canPreview

				if canPreview then
					local reward2 = reward
					child.Inspect.Activated:Connect(function()
						v8:Close("TopTiersRewards")
						v14:PreviewReward(reward2, "TopTiersRewards")
					end)
				end

				if v13:CanShowRewardInfo(reward) then
					v13:AddFromRewardInfo(child, reward)
				else
					v13:Remove(child)
				end

				local v21 = child
				v.effect(function()
					local v22 = atom4()
					local v23

					if v10.isEnabled() then
						v23 = season - 1
					else
						v23 = season
					end

					if not v22 then
						return
					end

					local v24 = v22[tostring(v23)]

					if not v24 then
						return
					end

					local v25 = v23 == season
					local visible = v25 and v24.Claimed == true
					v21.ClaimButton.Label.Text = v25 and "Claim" or "Claim Past"
					v21.ClaimButton.Visible = v24.Claimed == false
					v21.Claimed.Visible = visible
				end)
				child.ClaimButton.Activated:Connect(function()
					if v4:Invoke("InfiniteBattlepass/ClaimTopTiersRewards") then
					end
				end)
			end
		end
	end
}