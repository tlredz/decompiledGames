local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local Replion = require(ReplicatedStorage.Packages.Replion)
return Observers.observeTagNoAncestry("UI_WindowWeeklySpins", function(instance)
	local maid = Utils.Maid.new()
	maid.OnDataLoaded = Replion.Client:AwaitReplion("Data", function(object)
		local function UpdateAvailableRewards(weeklySpinsRewardTier: number?)
			local weeklySpins = object:Get("WeeklySpins") or 0
			local v = weeklySpinsRewardTier or 0

			for _, frame in pairs(instance.Bar.List:GetChildren()) do
				if not frame:IsA("Frame") then
					continue
				end

				local name = tonumber(frame.Name)
				local v2

				if name == 0 and weeklySpins >= 10 or name == 1 and weeklySpins >= 25 then
					v2 = true
				elseif name == 2 then
					v2 = weeklySpins >= 50
				else
					v2 = false
				end

				frame.Button.ClaimNow.Visible = v2 and v == name
			end
		end

		local function UpdateWeeklyRolls()
			local weeklySpins = object:Get("WeeklySpins") or 0
			instance.TotalWeeklySpinsAmount.Text = "Total Weekly Spins: " .. weeklySpins
			local v = weeklySpins < 25 and Utils.ValueConvertor:GetPercentageFromNumbers(weeklySpins, 10, 25) / 2 or Utils.ValueConvertor:GetPercentageFromNumbers(
				weeklySpins,
				25,
				50
			) / 2 + 0.5
			instance.Bar.BarProgress.Size = UDim2.new(1, 0, v, 0)
			UpdateAvailableRewards(object:Get("WeeklySpinsRewardTier"))
		end

		UpdateWeeklyRolls()
		maid.OnWeeklySpinsChanged = object:OnChange("WeeklySpins", UpdateWeeklyRolls)
		maid.OnWeeklySpinsIDChanged = object:OnChange("WeeklySpinsID", UpdateWeeklyRolls)
		maid.OnWeeklySpinsRewardTierChanged = object:OnChange("WeeklySpinsRewardTier", UpdateAvailableRewards)
		maid.Reset = Utils.Thread.Every(1, function()
			local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")

			if instance.Visible and layerCollector and layerCollector.Enabled then
				instance.ResetTimer.Text = Utils.ValueConvertor:FormatTimeWithDays(Utils.Settings.WEEK_TIME - (os.time() - Utils.Settings.WEEKLY_SPIN_START) % Utils.Settings.WEEK_TIME)
			end
		end)

		for _, frame in pairs(instance.Bar.List:GetChildren()) do
			if frame:IsA("Frame") then
				maid:GiveTask(frame.Button.Activated:Connect(function()
					Utils.Network:Fire("ClaimWeeklySpinReward")
				end))
			end
		end
	end)
	return function()
		maid:Destroy()
	end
end)