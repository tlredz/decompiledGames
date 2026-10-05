local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Utils = require(ReplicatedStorage.Common.Utils)
local Replion = require(ReplicatedStorage.Packages.Replion)
local CoreCall = require(ReplicatedStorage.ClientGameModules.CoreCall)
local BattlepassDailyLoginRewards = require(ReplicatedStorage.Shared.Battlepass.BattlepassDailyLoginRewards)
local BattlepassFreeNotificationReward = require(ReplicatedStorage.Common.BattlepassFreeNotificationReward)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local December2025CalendarInfo = require(ReplicatedStorage.Shared.December2025CalendarInfo)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local ExperienceNotificationController = require(ReplicatedStorage.Controllers.ExperienceNotifications.ExperienceNotificationController)
local IndexController = require(ReplicatedStorage.Controllers.Trading.IndexController)
local BattlepassViewController = require(ReplicatedStorage.Controllers.Battlepass.BattlepassViewController)
local HoverInfoController = require(ReplicatedStorage.Controllers.HoverInfoController)
local BattlepassUIType = require(ReplicatedStorage.Shared.BattlepassUIType)
local module = require("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local _ = module.SeasonData.Currency.Icon
local v = {
	Normal = {
		Image = "rbxassetid://126874114171161",
		HoverImage = "rbxassetid://139033789557762"
	},
	Claimed = {
		Image = "rbxassetid://71870507830111",
		HoverImage = "rbxassetid://127531173131195"
	},
	Special = {
		Image = "rbxassetid://78359707810105",
		HoverImage = "rbxassetid://76553575882721"
	}
}
return {
	Binder = function(data)
		local maid = Utils.Maid.new()
		local parent = data.Parent
		local template = data.Frame.ScrollingFrame.Template
		template.Parent = nil
		local v2 = Replion.Client:WaitReplion("Data")
		local firstTime = v2:Get("firstTime")
		local close = data.Close
		GuiHandler:OnGuiOpen("BattlepassDailyLogin", function(p)
			local v3 = not p.Enabled
			CoreCall(Enum.CoreGuiType.PlayerList, v3)
		end)
		GuiHandler:OnGuiClose("BattlepassDailyLogin", function(p)
			local v3 = not p.Enabled
			CoreCall(Enum.CoreGuiType.PlayerList, v3)
		end)
		close:AddTag("UI_ButtonHoverAnimation2")
		close.Activated:Connect(function()
			if parent:GetAttribute("OpenBattlePass") then
				parent:SetAttribute("OpenBattlePass", nil)
				BattlepassViewController:OpenView("Battlepass")
			else
				GuiHandler:Close("BattlepassDailyLogin", true)
				parent.Enabled = false
			end
		end)
		local v3 = {}

		for k, battlepassDailyLoginReward in BattlepassDailyLoginRewards do
			local clone = template:Clone()
			clone.Vector.Image = battlepassDailyLoginReward.Icon
			clone.Day.Text = `Day {k}`

			if battlepassDailyLoginReward.RewardInfo and battlepassDailyLoginReward.RewardInfo.Type ~= "SeasonPassCurrency" then
				local special = v.Special
				clone.Image = special.Image
				clone.HoverImage = special.HoverImage
				clone.SpecialFrame.Visible = true
				clone.Reward.Visible = false
				clone:SetAttribute("Special", true)
			else
				clone.SpecialFrame.Visible = false
				clone.Reward.Text = `+{battlepassDailyLoginReward.Arguments[1] or ""}`
				clone.Reward.Visible = true
			end

			clone.Visible = true
			clone.Parent = data.Frame.ScrollingFrame
			local visible

			if battlepassDailyLoginReward.RewardInfo == nil then
				visible = false
			else
				visible = IndexController:CanPreview(battlepassDailyLoginReward.RewardInfo)
			end

			clone.Inspect.Visible = visible

			if visible then
				HoverInfoController:AddFromRewardInfo(clone, battlepassDailyLoginReward.RewardInfo)
				local v5 = battlepassDailyLoginReward
				clone.Inspect.Activated:Connect(function()
					local isOpen = GuiHandler:IsOpen("Battlepass")

					if isOpen then
						BattlepassViewController:Close()
					end

					parent.Enabled = false
					IndexController:PreviewReward(v5.RewardInfo, nil, function()
						if BattlepassUIType == "Window" then
							parent.Enabled = true
							return
						end

						if not isOpen then
							GuiHandler:Open(parent.Name)
							return
						end

						BattlepassViewController:Open()
						parent.Enabled = true
					end)
				end)
			else
				clone.Inspect:Destroy()
			end

			table.insert(v3, {
				Object = clone,
				Number = k
			})
		end

		table.sort(v3, function(a, b)
			return a.Number < b.Number
		end)

		local function TurnUIToClaimable(object)
			object:AddTag("UI_ButtonHoverAnimation2")
			object.Day.Visible = true
			object.Claim.Visible = true
			object.SpecialFrame.Visible = false
			object.Reward.Visible = false
			object.Claimed.Visible = false
			local special = object:GetAttribute("Special") and v.Special or v.Normal
			object.Image = special.Image
			object.HoverImage = special.HoverImage
		end

		local function TurnUIToClaimed(object)
			object:RemoveTag("UI_ButtonHoverAnimation2")
			object.Day.Visible = false
			object.Claim.Visible = false
			object.SpecialFrame.Visible = object:GetAttribute("Special")
			object.Reward.Visible = not object.SpecialFrame.Visible
			object.Claimed.Visible = true
			local claimed = v.Claimed
			object.Image = claimed.Image
			object.HoverImage = claimed.HoverImage
		end

		local function TurnUIToUnclaimable(object)
			object:RemoveTag("UI_ButtonHoverAnimation2")
			object.Day.Visible = true
			object.Claim.Visible = false
			object.SpecialFrame.Visible = object:GetAttribute("Special")
			object.Reward.Visible = not object.SpecialFrame.Visible
			object.Claimed.Visible = false
			local special = object:GetAttribute("Special") and v.Special or v.Normal
			object.Image = special.Image
			object.HoverImage = special.HoverImage
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local v4 = December2025CalendarInfo.StartTimestamp + December2025CalendarInfo.DayToEnd * 86400
		local v5 = firstTime or v2:Get("TotalStats.Wins") < 1 or ServerInfo.isAFKServer() or ServerInfo.isRhythmServer() or December2025CalendarInfo.StartTimestamp <= serverTimeNow and serverTimeNow <= v4 or not module.isEnabled()

		local function CheckStatesOfPages()
			local count = 0

			for i, v6 in ipairs(v3) do
				local newDailyLoginStreak = v2:Get("NewDailyLoginStreak") or 0
				local newDailyLoginAwardList = v2:Get("NewDailyLoginAwardList") or {}
				local v7

				if newDailyLoginStreak < v6.Number then
					v7 = "Unclaimable"
				elseif table.find(newDailyLoginAwardList, v6.Number) then
					count += 1
					v7 = "Claimed"
				else
					v7 = "Claimable"
				end

				if v6.Object:GetAttribute("State") == v7 then
					continue
				end

				v6.Object:SetAttribute("State", v7)
				local _ = BattlepassDailyLoginRewards[i]

				if v7 == "Claimable" then
					TurnUIToClaimable(v6.Object)

					if not v5 and not ServerInfo.isHuntPrivateServer() and v2:Get("TotalStats.Wins") >= 1 and localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Dead) and Utils.FFlag.GetFFlag(
						"BattlepassDailyLoginEnabled",
						false
					) then
						v5 = true

						if GuiService:IsTenFootInterface() then
							task.delay(6, function()
								GuiHandler:Open("BattlepassDailyLogin")
							end)
						else
							GuiHandler:Open("BattlepassDailyLogin")
						end
					end
				elseif v7 == "Claimed" then
					TurnUIToClaimed(v6.Object)
				elseif v7 == "Unclaimable" then
					TurnUIToUnclaimable(v6.Object)
				end
			end

			local v6 = count == #v3 and "71, 255, 71" or "255, 235, 133"
			data.Frame.ClaimedCounter.Label.Text = `<stroke color="rgb(0, 0, 0)" joins="round" thickness="2"><font color="rgb({v6})">{count}</font>/{#v3} Claimed</stroke>`
			local claimedNotificationReward = v2:Get("ClaimedNotificationReward")

			if claimedNotificationReward then
				local battlepassDailyLoginReward = BattlepassDailyLoginRewards[#BattlepassDailyLoginRewards]
				data.Frame.Day30Claimed.Vector.Image = battlepassDailyLoginReward.Icon
				data.Frame.Day30Unclaimed.Vector.Image = battlepassDailyLoginReward.Icon
			end

			data.Frame.FreeRewardUnclaimed.Vector.Image = BattlepassFreeNotificationReward.Icon
			data.Frame.FreeRewardUnclaimed.Claimed.Visible = claimedNotificationReward
			data.Frame.FreeRewardUnclaimed.Claim.Visible = not claimedNotificationReward
		end

		for _, v6 in ipairs(v3) do
			local v7 = v6

			local function claim()
				local v8, v9 = Utils.Network:Invoke("ClaimNewDailyLoginReward", v7.Number)

				if v8 then
					TurnUIToClaimed(v7.Object)
					Utils.Sounds:Play("questreward1")
				elseif v7.Object:GetAttribute("State") == "Claimable" then
					Utils.Sounds:Play("error")
					warn((`Failed to claim daily login reward: {v9}`))
				end
			end

			local v8 = v6
			local claim2 = claim
			v6.Object.Activated:Connect(function()
				v8.Object.Active = false
				claim2()
				v8.Object.Active = true
			end)
			local v9 = v6
			local claim3 = claim
			v6.Object.Claim.Activated:Connect(function()
				v9.Object.Claim.Active = false
				claim3()
				v9.Object.Claim.Active = true
			end)
		end

		CheckStatesOfPages()

		if not v2:Get("ClaimedNotificationReward") then
			local activatedConnection = nil
			activatedConnection = data.Frame.FreeRewardUnclaimed.Claim.Activated:Connect(function()
				if not ExperienceNotificationController then
					local ExperienceNotificationController2 = require(ReplicatedStorage.Controllers.ExperienceNotifications.ExperienceNotificationController)
					ExperienceNotificationController = ExperienceNotificationController2
				end

				ExperienceNotificationController:PromptOptIn():andThen(function(p)
					if p then
						activatedConnection:Disconnect()
					end
				end):catch(function(p)
					warn("[ExperienceNotificationController]", p)
				end)
			end)
		end

		maid:GiveTask(v2:OnChange("ClaimedNotificationReward", CheckStatesOfPages))
		maid:GiveTask(v2:OnChange("NewDailyLoginStreak", CheckStatesOfPages))
		maid:GiveTask(v2:OnArrayInsert("NewDailyLoginAwardList", CheckStatesOfPages))
		maid:GiveTask(v2:OnArrayRemove("NewDailyLoginAwardList", CheckStatesOfPages))
		return maid
	end
}