local BattlePass = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local GridCreator = require(game.ReplicatedStorage.Modules.GridCreator)
local christmasEvents2018 = game.ReplicatedStorage.ChristmasEvents2018
BattlePass.GUI = nil
BattlePass.BattlePassFrame = nil
BattlePass.YourTier = nil
BattlePass.CurrentPassPage = 0
BattlePass.CurrentTierBuy = 1
BattlePass.BuyTiersFrame = nil
BattlePass.NewPassTierRewardObject = nil
BattlePass.NewPassPageObject = nil
BattlePass.PassTierRewardObjectFunction = nil

function BattlePass.GenerateTiers(newPassTierRewardObject, newPassPageObject, passTierRewardObjectFunction, p)
	local christmasPass2018 = Sync.ChristmasPass2018
	GridCreator.CreatePass(
		passTierRewardObjectFunction,
		newPassTierRewardObject,
		christmasPass2018,
		BattlePass.BattlePassFrame,
		newPassPageObject
	)
	BattlePass.YourTier.Text = "Your Tier: " .. ProfileData.Christmas2018.CurrentTier
	local currentTier = ProfileData.Christmas2018.CurrentTier

	if christmasPass2018.TotalTiers <= currentTier then
		currentTier -= 1
	end

	local currentPassPage = math.floor(currentTier / 5)

	if not p then
		for _, child in pairs(BattlePass.BattlePassFrame:GetChildren()) do
			child.Visible = child.Name == "Page" .. currentPassPage
		end

		BattlePass.CurrentPassPage = currentPassPage
	end

	BattlePass.CurrentTierBuy = 1
	BattlePass.ChangeBuyTiers(0)
	BattlePass.NewPassTierRewardObject = newPassTierRewardObject
	BattlePass.NewPassPageObject = newPassPageObject
	BattlePass.PassTierRewardObjectFunction = passTierRewardObjectFunction
end

local connections = {}

function BattlePass.GenerateTierRewardPC(data, p, text)
	local v = tostring(text)
	local claimedReward = ProfileData.Christmas2018.ClaimedRewards[v]
	local v2 = Sync.ChristmasPass2018.Rewards[v] ~= nil

	if p.ItemID then
		GridCreator.MakeItemFrame(data, p, false)

		if not connections[data] then
			connections[data] = data.Claim.MouseButton1Click:connect(function()
				data.Claim.Visible = false

				if ProfileData.Christmas2018.ClaimedRewards[v] ~= true then
					BattlePass.ClaimReward(v)
				end
			end)
		end
	end

	data.Locked.Visible = ProfileData.Christmas2018.CurrentTier < text
	data.Next.Visible = ProfileData.Christmas2018.CurrentTier + 1 == text
	local claim = data.Claim
	claim.Visible = text <= ProfileData.Christmas2018.CurrentTier and not claimedReward and v2
	data.Title.TierNumber.Text = text
end

function BattlePass.ChangePage(p)
	BattlePass.CurrentPassPage += p

	for _, child in pairs(BattlePass.BattlePassFrame:GetChildren()) do
		child.Visible = child.Name == "Page" .. BattlePass.CurrentPassPage
	end
end

function BattlePass.ChangeBuyTiers(p)
	local currentTier = ProfileData.Christmas2018.CurrentTier
	local totalTiers = Sync.ChristmasPass2018.TotalTiers
	local tierCost = Sync.ChristmasPass2018.TierCost
	BattlePass.CurrentTierBuy += p

	if BattlePass.CurrentTierBuy < 1 then
		BattlePass.CurrentTierBuy = 1
	end

	if totalTiers < BattlePass.CurrentTierBuy + currentTier then
		BattlePass.CurrentTierBuy = totalTiers - currentTier
	end

	local v = tostring(BattlePass.CurrentTierBuy > 1 and "s" or "")
	BattlePass.BuyTiersFrame.Buy.Text = "Buy " .. BattlePass.CurrentTierBuy .. " Tier" .. v
	BattlePass.BuyTiersFrame.CandyDisplay.Amount.Text = BattlePass.CurrentTierBuy * tierCost

	if totalTiers <= currentTier then
		BattlePass.BuyTiersFrame.Parent.Visible = false
		BattlePass.BattlePassFrame.Parent.PassComplete.Visible = true
	end
end

function BattlePass.BuyTiers()
	local currentTierBuy = BattlePass.CurrentTierBuy
	local logs2018 = ProfileData.Materials.Owned.Logs2018 or 0
	local v = Sync.ChristmasPass2018.TierCost * currentTierBuy
	local v2 = v <= logs2018
	print("Tiers To Buy: " .. currentTierBuy)
	print("Current Tier: " .. ProfileData.Christmas2018.CurrentTier)

	if not v2 then
		return false, v - logs2018
	end

	christmasEvents2018.BuyTiers:FireServer(currentTierBuy)
	ProfileData.Materials.Owned.Logs2018 = ProfileData.Materials.Owned.Logs2018 - v
	ProfileData.Christmas2018.CurrentTier = ProfileData.Christmas2018.CurrentTier + currentTierBuy
	BattlePass.CurrentTierBuy = 1
	BattlePass.ChangeBuyTiers(0)
	print(" -- ")
	print("Tiers To Buy: " .. BattlePass.CurrentTierBuy)
	print("Current Tier: " .. ProfileData.Christmas2018.CurrentTier)
	BattlePass.UpdateCandies()
	BattlePass.GenerateTiers(
		BattlePass.NewPassTierRewardObject,
		BattlePass.NewPassPageObject,
		BattlePass.PassTierRewardObjectFunction
	)
	return true
end

function BattlePass.ClaimReward(p)
	local v = tostring(p)
	local reward = Sync.ChristmasPass2018.Rewards[v]

	if reward then
		local itemID = reward.ItemID
		print(itemID)

		if ProfileData.Christmas2018.CurrentTier >= tonumber(v) and ProfileData.Christmas2018.ClaimedRewards[v] ~= true then
			ProfileData.Christmas2018.ClaimedRewards[v] = true

			if reward.ItemType == "Weapons" or reward.ItemType == "Pets" or reward.ItemType == "Materials" then
				local v2 = ProfileData[reward.ItemType].Owned[itemID]
				ProfileData[reward.ItemType].Owned[itemID] = v2 and v2 + reward.Amount or reward.Amount
			else
				table.insert(ProfileData[reward.ItemType].Owned, itemID)
			end

			BattlePass.GenerateTiers(
				BattlePass.NewPassTierRewardObject,
				BattlePass.NewPassPageObject,
				BattlePass.PassTierRewardObjectFunction,
				true
			)
			christmasEvents2018.ClaimReward:FireServer(v)
		end
	end
end

function BattlePass.UpdateCandies()
	BattlePass.GUI.CandyDisplay.Amount.Text = GridCreator.Commafy(ProfileData.Materials.Owned.Logs2018 or 0)
end

return BattlePass