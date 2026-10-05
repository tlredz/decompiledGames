local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("LocalizationService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local DailyLoginInfo = require(ReplicatedStorage.Common.DailyLoginInfo)
local rewards = DailyLoginInfo.Legacy.Rewards
require(ReplicatedStorage.Shared.ReplicatedInstances.Swords)
local Replion = require(ReplicatedStorage.Packages.Replion)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local TopBarController = require(ReplicatedStorage.Controllers.UI.TopBarController)
local DailyLoginController = require(ReplicatedStorage.Controllers.UI.DailyLoginController)
require(ReplicatedStorage.Shared.ItemInfo)
local RewardInfo = require(ReplicatedStorage.Common.RewardInfo)
local localPlayer = Players.LocalPlayer
return Observers.observeTagNoAncestry("UI_SGDailyLogin", function(instance)
	local maid = Utils.Maid.new()
	local frame = instance:WaitForChild("Frame", 1000000)
	Replion.Client:AwaitReplion("Data", function(object)
		local fn
		local dailyLogin = object:Get("DailyLogin") or 0
		local dailyLoginStreak = object:Get("DailyLoginStreak") or 0
		local dailyLogin2 = TopBarController:WaitForIcon("DailyLogin")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateIcon()
			dailyLogin2:setEnabled(object:Get("CurrentDailyLoginType") ~= "Longterm")
		end

		object:OnChange("CurrentDailyLoginType", updateIcon)
		updateIcon() -- equivalent call inferred; original call site unknown
		maid.Close = frame.CloseButton.MouseButton1Click:Connect(function()
			GuiHandler:Close(instance.Name)
		end)

		local function UpdateTimer()
			if dailyLoginStreak >= #rewards then
				return
			end

			local v = dailyLoginStreak % #rewards + 1

			for _, frame2 in pairs(frame.Content:GetChildren()) do
				if not frame2:IsA("Frame") then
					continue
				end

				local name = tonumber(frame2.Name)

				if name == v then
					local child = frame.Bar:FindFirstChild(frame2.Name)
					local v2 = frame2
					local connection = Utils.Thread.Every(1, function()
						local v3 = dailyLogin - workspace:GetServerTimeNow()

						if v3 < 0 then
							v2.BottomBar.TomorrowTextLabel.Visible = false
							v2.ClaimButton.Visible = true
							DailyLoginController:_notify()
						else
							v2.BottomBar.TomorrowTextLabel.Visible = true
							v2.BottomBar.TomorrowTextLabel.Text = Utils.ValueConvertor:FormatTime(v3)
						end
					end)
					local v3 = frame2
					local v4 = name

					function maid.ClearLastClaimButton()
						connection:Disconnect()
						v3.ClaimButton.Visible = false
						v3.UIStroke.Color = Color3.fromRGB(12, 46, 75)
						v3.UIStroke:SetAttribute("StrokeThickness", 3)

						if v4 ~= 5 then
							v3.TopBar.BackgroundColor3 = Color3.fromRGB(118, 162, 248)
						end

						if child then
							child.ImageColor3 = Color3.fromRGB(255, 255, 255)
						end
					end

					frame2.UIStroke.Color = Color3.fromRGB(118, 213, 66)
					frame2.UIStroke:SetAttribute("StrokeThickness", 4)

					if name ~= 5 then
						frame2.TopBar.BackgroundColor3 = Color3.fromRGB(137, 244, 27)
					end

					if child then
						child.ImageColor3 = Color3.fromRGB(163, 255, 87)
					end
				else
					if name < v then
						frame2.BottomBar.TomorrowTextLabel.Visible = true
						frame2.BottomBar.TomorrowTextLabel.Text = "CLAIMED"
					else
						frame2.BottomBar.TomorrowTextLabel.Visible = false
					end

					frame2.ClaimButton.Visible = false
					frame2.UIStroke.Color = Color3.fromRGB(12, 46, 75)
					frame2.UIStroke:SetAttribute("StrokeThickness", 3)

					if name ~= 5 then
						frame2.TopBar.BackgroundColor3 = Color3.fromRGB(118, 162, 248)
					end
				end
			end
		end

		maid.DailyLoginStreakChanged = object:OnChange("DailyLoginStreak", function(value)
			dailyLoginStreak = value or 0
			UpdateTimer()
			fn()
		end)
		maid.DailyLoginChanged = object:OnChange("DailyLogin", function(value)
			dailyLogin = value or 1e999
			UpdateTimer()
		end)
		UpdateTimer()

		local function updateRewardFrame(p, p2)
			if p2.Credits then
				p.ItemIcon.ImageLabel.Image = Utils.Icons:GetIcon("Credits")
				p.AmountTextLabel.Text = Utils.ValueConvertor:AddCommas(p2.Credits)
			elseif p2.SwordSkins then
				local _, text = next(p2.SwordSkins)

				if text then
					local swordIcon = Utils.Icons:GetSwordIcon(text)

					if swordIcon then
						p.ItemIcon.ImageLabel.Image = swordIcon
					else
						Utils.Icons:SetSwordIconAsViewportByName(p.ItemIcon.ImageLabel, text)
					end

					p.AmountTextLabel.Text = text
				end
			end
		end

		if not instance.Parent then
			return
		end

		for _, frame2 in pairs(frame.Content:GetChildren()) do
			if not frame2:IsA("Frame") then
				continue
			end

			updateRewardFrame(frame2, rewards[tonumber(frame2.Name)])
			maid:GiveTask(frame2.ClaimButton.MouseButton1Down:Connect(function()
				Utils.Network:Fire("ClaimLoginReward")
			end))
		end

		fn = function()
			local hasFreezeDailyLoginReward = localPlayer:GetAttribute("HasFreezeDailyLoginReward")
			local abilityReward = RewardInfo.createAbilityReward("Freeze")
			local _2 = frame.Content:FindFirstChild("2")

			if hasFreezeDailyLoginReward and (dailyLoginStreak >= 2 or not Utils.RewardInfo.playerOwnsItem(
				localPlayer,
				abilityReward
			)) then
				_2.ItemIcon.ImageLabel.Image = abilityReward.Icon
				_2.AmountTextLabel.Text = abilityReward.DisplayName
			else
				updateRewardFrame(_2, rewards[2])
			end
		end

		fn()
		localPlayer:GetAttributeChangedSignal("HasFreezeDailyLoginReward", fn)
		object:OnChange({ "Abilities", "Unlocked" }, fn)
		object:OnChange("DailyLoginStreak", fn)
	end)
	return function()
		maid:Destroy()
	end
end)