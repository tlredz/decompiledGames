local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Common.PlaytimeRewardsInfo)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(script.Parent.TopBarController)
local remoteFunction = v2:RemoteFunction("ClaimPlaytimeReward")

local function setFrameStyle(state, p: string)
	state.Rayburst.ImageColor3 = p == "Blue" and Color3.fromRGB(70, 113, 255) or p == "Orange" and Color3.fromRGB(
		255,
		170,
		0
	) or Color3.fromRGB(81, 255, 0)
	state.UIStroke.Color = p == "Blue" and Color3.fromRGB(107, 165, 255) or p == "Orange" and Color3.fromRGB(
		255,
		202,
		117
	) or Color3.fromRGB(183, 255, 88)
	state.ItemName.UIStroke.Color = p == "Blue" and Color3.fromRGB(28, 43, 66) or p == "Orange" and Color3.fromRGB(
		66,
		39,
		0
	) or Color3.fromRGB(20, 66, 0)
	state.ItemNameShadow.UIStroke.Color = p == "Blue" and Color3.fromRGB(28, 43, 66) or p == "Orange" and Color3.fromRGB(
		255,
		206,
		121
	) or Color3.fromRGB(85, 255, 127)
	state.Label.TextColor3 = p == "Orange" and Color3.fromRGB(255, 218, 155) or Color3.fromRGB(164, 255, 107)
	state.Label.UIStroke.Color = p == "Orange" and Color3.fromRGB(98, 31, 0) or Color3.fromRGB(20, 66, 0)
	state.Label.Visible = p ~= "Blue"
	state.Active = p == "Orange"
end

local v7 = nil
return {
	Start = function(_)
		v7 = v.Client:WaitReplion("Data")
		local playtimeRewards = playerGui:WaitForChild("PlaytimeRewards")
		local v8 = v6:Create("Rewards"):setImage(14523330057):setLabel("PLAYTIME AWARDS"):setCaption("Playtime Awards"):modifyTheme({
			{ "Notice", "BackgroundColor3", Color3.fromRGB(255, 55, 55) },
			{ "NoticeLabel", "TextColor3", Color3.fromRGB(255, 255, 255) },
			{ "NoticeUIStroke", "Color", Color3.fromRGB(255, 255, 255) }
		})
		v8.toggled:Connect(function(flag: boolean, p)
			if p ~= "User" then
				return
			end

			if flag then
				v5:Open("PlaytimeRewards")
			else
				v5:Close("PlaytimeRewards")
			end
		end)
		v6:AddDropdown("Extra", v8)
		v5:OnClose(function(p)
			if p == playtimeRewards then
				v8:deselect()
			end
		end)
		local playtimeRewards2 = playtimeRewards.PlaytimeRewards
		local page = playtimeRewards2.Page
		local list = page.List
		local _ = list.DailyTimerTitle.Main.Timer
		page.CloseButton.Activated:Connect(function()
			v5:Close("PlaytimeRewards")
		end)

		for k, reward in v4.Rewards do
			local v9 = list.RewardsList[tostring(k)]
			v9.Top.Text.Text = `{math.round(reward.Duration / 60 * 100) * 0.01} Mins`
			local reward2 = reward.Reward
			v9.ItemName.Text = reward2.DisplayName
			v9.ItemNameShadow.Text = reward2.DisplayName
			v9.Icon.Image = reward2.Icon or "rbxassetid://0"
			local v10 = reward
			local v11 = k

			local function claim()
				local v12 = v7:Get("PlaytimeRewardsData.TimerStart")
				local v13 = v7:Get("PlaytimeRewardsData.ClaimedRewards")
				local serverTimeNow = workspace:GetServerTimeNow()
				local v14 = v12 + v10.Duration

				if not v13[tostring(v11)] and v14 <= serverTimeNow then
					if remoteFunction:InvokeServer(v11) then
						ReplicatedStorage2.Misc.reward:Play()
					else
						ReplicatedStorage2.Misc.error:Play()
					end
				end
			end

			v9.Activated:Connect(claim)
			v9.ClaimButton.Activated:Connect(claim)
		end

		local fill = playtimeRewards2.Progress.Fill
		local dots = playtimeRewards2.Progress.Dots
		local timer = list.DailyTimerTitle.Main.Timer
		local v9 = false

		local function updateRewards(p)
			local v10 = v7:Get("PlaytimeRewardsData.TimerStart")
			local v11 = v7:Get("PlaytimeRewardsData.ClaimedRewards")
			local serverTimeNow = workspace:GetServerTimeNow()
			local count = 0
			local flag = false
			local flag2 = true
			local v12 = 0

			for k, reward in v4.Rewards do
				local v13 = v10 + reward.Duration
				local v14 = v11[tostring(k)] ~= nil
				local v15 = v13 <= serverTimeNow
				local v16 = list.RewardsList[tostring(k)]
				local dot = dots[tostring(k)]

				if v13 <= serverTimeNow then
					dot.BackgroundColor3 = Color3.fromRGB(255, 179, 0)
					dot.Gold.Enabled = true
					dot.Grey.Enabled = false
				else
					dot.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
					dot.Gold.Enabled = false
					dot.Grey.Enabled = true
				end

				v16.ClaimButton.Visible = v15 and not v14

				if v14 then
					setFrameStyle(v16, "Green")
					v16.Label.Text = "Claimed"
					v12 = k
				else
					flag2 = false
					setFrameStyle(v16, v15 and "Orange" or "Blue")

					if v13 <= serverTimeNow then
						v16.Label.Text = "Claim"
						count += 1
						flag = true
					end
				end
			end

			if v9 ~= flag then
				v9 = flag

				if flag then
					v6:Notify("Rewards")
				end
			end

			if flag2 then
				fill.Size = UDim2.fromScale(1, 1)
			else
				fill.Size = UDim2.fromScale(math.clamp(v12 * 0.17 + -0.095, 0, 1), 1)
			end

			if p == true and flag then
				task.delay(3, function()
					v5:CloseCurrent()
					v5:Open("PlaytimeRewards")
				end)
			end

			local text = ""

			if flag2 then
				text = "Come back another time!"
			elseif flag then
				text = "You can claim now!"
			else
				for k, reward in v4.Rewards do
					local v15 = v10 + reward.Duration

					if v11[tostring(k)] then
						continue
					end

					text = `Next reward: {v3.ValueConvertor:FormatTime(v15 - serverTimeNow)}`
					break
				end
			end

			timer.Text = text
		end

		updateRewards(true)
		v7:OnChange("PlaytimeRewardsData.TimerStart", updateRewards)
		v7:OnDescendantChange("PlaytimeRewardsData.ClaimedRewards", updateRewards)
		v3.Thread.Every(1, updateRewards)
	end
}