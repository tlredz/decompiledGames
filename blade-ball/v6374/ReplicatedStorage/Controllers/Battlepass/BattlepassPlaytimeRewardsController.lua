local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Shared.Battlepass.BattlepassPlaytimeRewardsData)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v6 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v7 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassViewController)
local v8 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v9 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local playerGui = Players.LocalPlayer.PlayerGui
local battlepass = playerGui:WaitForChild("Battlepass")
local battlepassCurrencyShop = playerGui:WaitForChild("BattlepassCurrencyShop")
local battlepassPlaytimeRewards = playerGui:WaitForChild("BattlepassPlaytimeRewards")
local v10 = nil
local _ = {
	Normal = "rbxassetid://17502403786",
	Claimed = "rbxassetid://17502403786",
	Special = "rbxassetid://17502403786"
}
local remoteFunction = v3:RemoteFunction("ClaimSeasonPlaytimeReward")
return {
	Start = function(_)
		v10 = v.Client:WaitReplion("Data")
		local template0 = battlepassPlaytimeRewards.PlaytimeRewards.MainFrame.Grid.Template0
		template0.Parent = nil
		local template1 = battlepassPlaytimeRewards.PlaytimeRewards.MainFrame.Grid.Template1
		template1.Parent = nil
		local clones = {}

		for k, v11 in v2 do
			local clone

			if k % 2 == 0 then
				clone = template0:Clone()
			else
				clone = template1:Clone()
			end

			clone.Name = k
			clone.LayoutOrder = k
			local v12 = v11

			local function updateReward()
				local reward = v12.Reward

				if reward.Type == "Sword" and #client:FindItems("Sword", reward.Value) > 0 then
					reward = v12.FallbackReward or reward
				end

				local reward2 = clone.Reward
				local text

				if reward.Type == "SeasonPassCurrency" then
					text = `+{reward.Value}`
				else
					text = reward.DisplayName
				end

				reward2.Text = text
				clone.Vector.Image = reward.Icon or v4.Icons:GetIcon("DEFAULT_MISSING")
				clone.Inspect.Visible = v6:CanPreview(reward)
			end

			task.spawn(updateReward)

			if v11.Reward.Type == "Sword" then
				client:OnChange("Sword", updateReward)
			end

			local now = 0
			local v14 = clone
			local v15 = k

			local function claim()
				if os.clock() - now < 0.1 then
					return
				end

				now = os.clock()

				if not v14.Claim.Visible then
					return
				end

				local v16 = remoteFunction:InvokeServer(v15)
				v4.Sounds:Play(v16 and "questreward1" or "error")
			end

			clone.Claim.Claim.Activated:Connect(claim)
			local v16 = v11
			clone.Inspect.Activated:Connect(function()
				battlepassPlaytimeRewards.Enabled = false
				v7:Close()
				v6:PreviewReward(v16.Reward, nil, function()
					v7:Open()

					if v8 == "Window" then
						v7:OpenView("Battlepass")
					end

					battlepassPlaytimeRewards.Enabled = true
				end)
			end)
			clone.Parent = battlepassPlaytimeRewards.PlaytimeRewards.MainFrame.Grid
			table.insert(clones, clone)
		end

		local timer = battlepassPlaytimeRewards.PlaytimeRewards.MainFrame.ClaimedCounter.Timer
		local freeGifts = battlepass.Main.Background.FreeGifts
		local tween = TweenService:Create(
			freeGifts.Vector,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Rotation = -20
			}
		)
		local tween2 = TweenService:Create(
			freeGifts.Vector,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true),
			{
				Rotation = 20
			}
		)
		local tween3 = TweenService:Create(
			freeGifts.Vector,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Rotation = 0
			}
		)
		task.spawn(function()
			while true do
				if freeGifts.Ready.Visible and battlepass.Enabled and freeGifts.Visible then
					tween:Play()
					tween.Completed:Wait()
					tween2:Play()
					tween2.Completed:Wait()
					tween3:Play()
					tween3.Completed:Wait()
				end

				task.wait(2)
			end
		end)

		local function update()
			local secondsPlayedToday = v10:Get("SecondsPlayedToday") or 0
			local v11 = nil

			for _, v13 in v2 do
				if not (secondsPlayedToday < v13.Seconds) then
					continue
				end

				v11 = v13
				break
			end

			if v11 then
				timer.Text = v4.ValueConvertor:FormatTimeWithDays(v11.Seconds - secondsPlayedToday)
			else
				local v13 = math.floor((v10:Get("NewDailyLogin") or 0) - workspace:GetServerTimeNow())
				timer.Text = v4.ValueConvertor:FormatTimeWithDays(v13)
			end

			for k, v13 in clones do
				local v14 = v2[k]
				local v15 = v10:Find("ClaimedPlaytimeRewards", k)
				local v16 = v14.Seconds <= secondsPlayedToday
				v13.Clock.Timer.Text = (v16 or v15) and "" or v4.ValueConvertor:FormatTimeWithDays(v14.Seconds - secondsPlayedToday)
				v13.Clock.Visible = not (v16 or v15)

				if v15 then
					v13.Claim.Visible = false
					v13.Claimed.Visible = true
				else
					if v16 then
						v13.Claim.Visible = true
					else
						v13.Claim.Visible = false
					end

					v13.Claimed.Visible = false
				end
			end
		end

		v10:OnChange("ClaimedPlaytimeRewards", update)
		task.spawn(function()
			while true do
				update()
				task.wait(1)
			end
		end)
		battlepassPlaytimeRewards.PlaytimeRewards.MainFrame.Close.Activated:Connect(function()
			battlepassPlaytimeRewards.Enabled = false
			v5:Close(battlepassPlaytimeRewards.Name, true)
		end)
		freeGifts.Activated:Connect(function()
			battlepassPlaytimeRewards.Enabled = true
		end)
		local counter = battlepassPlaytimeRewards.PlaytimeRewards.MainFrame:FindFirstChild("Counter")

		if counter and counter:FindFirstChild("Add") then
			counter.Add.Activated:Connect(function()
				if v8 == "ShowRoom" then
					battlepassCurrencyShop.Enabled = true
				else
					v5:Open(battlepassCurrencyShop.Name, nil, true)
				end
			end)
		end

		counter.Icon.Image = v9.SeasonData.Currency.Icon

		local function updateCurrency()
			local v11 = v10:Get("InfiniteBattlepass.Currency") or 0
			battlepassPlaytimeRewards.PlaytimeRewards.MainFrame.Counter.Amount.Text = v4.ValueConvertor:AddCommas(v11)
		end

		v10:OnChange("InfiniteBattlepass.Currency", updateCurrency)
		task.spawn(updateCurrency)
	end
}