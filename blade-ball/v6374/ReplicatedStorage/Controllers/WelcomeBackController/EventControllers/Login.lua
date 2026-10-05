local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v4 = require3(ReplicatedStorage2.Shared.WelcomeBackData)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v5 = nil
local v6 = nil
local welcomeBackDailyRewards = v4.WelcomeBackDailyRewards
local getSelectionCrateRewards = v4.GetSelectionCrateRewards
local remoteFunction = v2:RemoteFunction("ClaimWelcomeBackDailyReward")
local remoteFunction2 = v2:RemoteFunction("RedeemWelcomeBackSelectionCrate")
local newWelcomeBack = playerGui:WaitForChild("NewWelcomeBack")
local changeFinalQuest = newWelcomeBack.ChangeFinalQuest
local rewardSelectionCrate = newWelcomeBack.RewardSelectionCrate
local frame = newWelcomeBack.Frame
local login = frame.Views.Login
local _ = login.Day7
local dayTemplate = login.Days.DayTemplate
dayTemplate.Parent = nil
local crateTemplate = rewardSelectionCrate.Frame.Items.CrateTemplate
crateTemplate.Parent = nil
local day7sByLayoutOrder = {}
local clonesByChildName = {}
local v7 = nil
local v8 = v.new()
local Login = {}

function Login.Start(_)
	v5 = v3.Client:WaitReplion("Data")
	v6 = getSelectionCrateRewards(localPlayer)
	v5:OnChange("WelcomeBackEvent.ClaimedSelectionCrate", UpdateFinalRewardFrame)
	v5:OnChange("WelcomeBackEvent.ClaimedSelectionCrate", UpdateAllSelectionTiles)
	v5:OnChange("WelcomeBackEvent.DailyLoginStreak", UpdateAllSelectionTiles)
	UpdateAllSelectionTiles()
	v8:Connect(UpdateFinalRewardFrame)
	v8:Connect(UpdateSelectionFrame)
	v8:Connect(UpdateSelectionCount)
	v8:Connect(UpdateAllSelectionTiles)
	UpdateSelectionCount()
	v5:OnChange("WelcomeBackEvent.DailyLoginStreak", UpdateSelectionFrame)
	UpdateSelectionFrame()
	rewardSelectionCrate.Frame.Close.MouseButton1Click:Connect(function()
		Login:ChangeSelectionCrateItem(nil)
		Login:ToggleSelectionCrate(false)
	end)
	rewardSelectionCrate.Frame.Collect.MouseButton1Click:Connect(function()
		Login:ToggleSelectionCrate(false)
	end)
	v5:OnChange("WelcomeBackEvent.DailyLoginStreak", UpdateAllShopTiles)
	v5:OnChange("WelcomeBackEvent.ClaimedDailyRewards", UpdateAllShopTiles)
	UpdateAllShopTiles()
	UpdateFinalRewardFrame()
end

function Login:ChangeSelectionCrateItem(p: string?)
	local v9 = v7
	v7 = p

	if v9 ~= p then
		v8:Fire()
	end
end

function Login:ToggleSelectionCrate(visible: boolean)
	changeFinalQuest.Visible = false
	frame.Visible = not visible
	rewardSelectionCrate.Visible = visible
end

function UpdateSelectionCount()
	local v9 = v7 and 1 or 0
	rewardSelectionCrate.Frame.Label2.Text = `Selected: {v9}/1`
end

function UpdateFinalRewardFrame()
	local v9 = day7sByLayoutOrder[#day7sByLayoutOrder]

	if v9 then
		local v10 = v5:Get("WelcomeBackEvent.ClaimedSelectionCrate")
		local v11 = v5:Get("WelcomeBackEvent.DailyLoginStreak") or 0
		local v12 = (v7 and true or false) and #welcomeBackDailyRewards <= v11
		v9.Options.Claim.Visible = v12 and not v10
		v9.Options.Spacer.Visible = not (v12 or v10)
		v9.Options.View.Visible = not v10

		if not v10 then
			local force

			if v7 then
				force = v6[v7]
			elseif v6.Force then
				force = v6.Force
			else
				force = v6["Continuity Zero"]
			end

			if force then
				v9.Vector.Image = force.Reward.Icon or ""
			end
		end
	end
end

function UpdateSelectionTile(childName: string)
	local v9 = v6[childName]
	local clone = clonesByChildName[childName]

	if not clone then
		clone = crateTemplate:Clone()
		clone.Vector.Image = v9.Reward.Icon or ""
		local itemName = clone.ItemName
		local text

		if string.find(childName, "Emote") then
			text = ReplicatedStorage2.Misc.Emotes:FindFirstChild(childName):GetAttribute("EmoteName")
		else
			text = childName
		end

		itemName.Text = text
		clone.MouseButton1Click:Connect(function()
			if v5:Get("WelcomeBackEvent.ClaimedSelectionCrate") then
				Login:ToggleSelectionCrate(false)
			else
				Login:ChangeSelectionCrateItem(childName)
			end
		end)
		clone.Parent = rewardSelectionCrate.Frame.Items
		clonesByChildName[childName] = clone
	end

	if clone then
		clone.Sel.Visible = childName == v7
	end
end

function UpdateSelectionFrame()
	local visible = v7 and true or false
	local v10 = v5:Get("WelcomeBackEvent.DailyLoginStreak") or 0
	local v11 = math.max(#welcomeBackDailyRewards - v10, 0)

	if v11 == 0 then
		local v12 = v5:Get("WelcomeBackEvent.ClaimedSelectionCrate") and "Claimed reward!" or "Claimable now!"
		rewardSelectionCrate.Frame.Label1.Text = `<stroke color="rgb(3, 31, 65)" joins="round" thickness="2.5">{v12}</stroke>`
	else
		rewardSelectionCrate.Frame.Label1.Text = `<stroke color="rgb(3, 31, 65)" joins="round" thickness="2.5">Claimable in <font color="rgb(255, 200, 33 )">{v11}</font> days</stroke>`
	end

	rewardSelectionCrate.Frame.CollectGrey.Visible = not visible
	rewardSelectionCrate.Frame.Collect.Visible = visible
end

function UpdateAllSelectionTiles()
	for k in v6 do
		UpdateSelectionTile(k)
	end
end

function UpdateShopTile(layoutOrder: number, p: number, p2)
	local welcomeBackDailyReward = welcomeBackDailyRewards[layoutOrder]
	local visible = p2[layoutOrder] and true or false
	local v10 = layoutOrder <= p and not visible
	local day7 = day7sByLayoutOrder[layoutOrder]

	if not day7 then
		if layoutOrder == #welcomeBackDailyRewards then
			day7 = login.Day7

			if not visible then
				day7.Options.View.MouseButton1Click:Connect(function()
					if not v5:Get("WelcomeBackEvent.ClaimedSelectionCrate") then
						Login:ToggleSelectionCrate(true)
					end
				end)
				local mouseButton1ClickConnection = nil
				mouseButton1ClickConnection = day7.Options.Claim.MouseButton1Click:Connect(function()
					if remoteFunction2:InvokeServer(v7) then
						mouseButton1ClickConnection:Disconnect()
					end
				end)
			end
		else
			day7 = dayTemplate:Clone()
			day7.LayoutOrder = layoutOrder
			day7.TextLabel.Text = `Day {layoutOrder}`

			if not visible then
				local mouseButton1ClickConnection = nil
				mouseButton1ClickConnection = day7.Claim.MouseButton1Click:Connect(function()
					if remoteFunction:InvokeServer(layoutOrder) then
						mouseButton1ClickConnection:Disconnect()
					end
				end)
			end

			day7.Parent = login.Days
		end

		day7sByLayoutOrder[layoutOrder] = day7
	end

	if day7 then
		local reward = welcomeBackDailyReward.Reward

		if reward == "SWORD_SELECTION_CRATE" then
			day7.Vector.Image = "rbxassetid://17302327393"
		elseif typeof(reward) == "table" then
			day7.Vector.Image = reward.Icon or ""
			day7.ItemName.Text = reward.DisplayName or ""
		end

		if layoutOrder < #welcomeBackDailyRewards then
			day7.Claim.Visible = not visible and v10
			day7.ItemName.Visible = not (visible or v10)
		end

		day7.Check.Visible = visible
		day7.Claimed.Visible = visible
	end
end

function UpdateAllShopTiles()
	local v9 = v5:Get("WelcomeBackEvent.DailyLoginStreak") or 0
	local v10 = v5:Get("WelcomeBackEvent.ClaimedDailyRewards") or {}

	for i in ipairs(welcomeBackDailyRewards) do
		UpdateShopTile(i, v9, v10)
	end
end

return Login