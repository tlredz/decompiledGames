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
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Reliever)
local v4 = require3(ReplicatedStorage2.Common.Utils)
require3(clientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.Shared.Statable)
local v6 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v7 = require3(ReplicatedStorage2.Shared.PlayerData.CountryIcons)
local v8 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventTopRewards)
local v9 = require3(ReplicatedStorage2.Controllers.Tournaments.Event.TournamentEventController)
local v10 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v11 = nil
local scrollingFrame = Players.LocalPlayer.PlayerGui.TournamentEvent.MainFrame.Frame.Views.Leaderboard.List.ScrollingFrame
local reward = scrollingFrame.UIListLayout.Reward
return {
	Start = function(_)
		local v12 = 0
		local state = v5.State({})
		v5.Computed(function(callback)
			if callback(v9.CurrentPage) ~= "Leaderboard" then
				return nil
			end

			local serverTimeNow = workspace:GetServerTimeNow()

			if not (serverTimeNow - v12 > 300) then
				return nil
			end

			v12 = serverTimeNow
			local v13, v14 = v2:Invoke("GetTournamentEventTopPlayers")

			if not v13 then
				return nil
			end

			local v15 = buffer.readu8(v14, 0)
			local v16 = table.create(v15)
			local v17 = 1

			for _ = 1, v15 do
				local userId = buffer.readf64(v14, v17)
				local v19 = v17 + 8
				local score = buffer.readu32(v14, v19)
				local v21 = v19 + 4
				local country = buffer.readstring(v14, v21, 2)
				v17 = v21 + 2
				table.insert(v16, {
					userId = userId,
					score = score,
					country = country
				})
			end

			state:Set(v16)
			return nil
		end)
		local count = 0

		local function renderLeaderboard(list, p: number)
			for i = 1, 50 do
				if p ~= count then
					return
				end

				v3.relieve()
				local v13 = list[i] or {
					userId = 0,
					score = 0,
					country = nil
				}
				local clone = scrollingFrame:FindFirstChild((tostring(i)))

				if not clone then
					clone = scrollingFrame.UIListLayout:FindFirstChild((`Template{math.clamp(i, 1, 4)}`)):Clone()
					clone.RankLabel.Text = `#{i}`
					clone.Name = tostring(i)
					clone.Visible = true
					clone.Parent = scrollingFrame

					for _, v14 in v8 do
						if v14.Top < i then
							continue
						end

						local clone2 = reward:Clone()
						clone2.Icon.Image = v14.Reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
						clone2.LayoutOrder = v14.Top
						v10:AddFromRewardInfo(clone2, v14.Reward)
						clone2.Parent = clone.Rewards
					end
				end

				clone.Kills.Amount.Text = v13.score

				if v13.userId == 0 then
					clone.PlayerName.Text = "???"
					clone.ProfilePicture.Visible = false
				else
					local v14

					if v13.country then
						v14 = v7[v13.country]
					else
						v14 = nil
					end

					clone.PlayerName.Text = "???"
					v6:GetUsername(v13.userId):andThen(function(p2)
						clone.PlayerName.Text = `@{p2}{not v14 and "" or " " .. v14.Emoji}`
					end)
					v6:GetPlayerHeadshot(v13.userId):andThen(function(image)
						clone.ProfilePicture.Visible = true
						clone.ProfilePicture.PlaceHolder.Image = image
					end)
				end
			end

			scrollingFrame.CanvasSize = UDim2.fromOffset(0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y + 80)
		end

		v5.Computed(function(callback)
			local v13 = callback(state)

			if callback(v9.CurrentPage) ~= "Leaderboard" then
				return nil
			end

			count += 1
			task.spawn(renderLeaderboard, v13, count)
			return nil
		end)
		v11 = v.Client:WaitReplion("Data")
	end
}