local Gamepasses = require(script.Parent.Gamepasses)
local Fighters = require(script.Parent.Fighters)
local Weapons = require(script.Parent.Weapons)
local Mounts = require(script.Parent.Mounts)
local ProfileBanners = require(script.Parent.ProfileBanners)
local Items = require(script.Parent.Items)
local Potions = require(script.Parent.Potions)
local Economy = require(script.Parent.Economy)
local Gems = require(script.Parent.Gems)
local MonetizationCatalog = require(script.Parent.MonetizationCatalog)
local CommerceRewards = {}

local function IsAmount(value)
	return typeof(value) == "number" and value > 0 and value % 1 == 0 and value <= 9007199254740991
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AddIndex(data, type: string, name: string, p: number)
	data.Index[type] = data.Index[type] or {}
	data.Index[type][name] = (data.Index[type][name] or 0) + p
end

local function GetRewardAmount(p, reward)
	if reward.EnsureOwned == true and reward.Type == "Fighter" then
		local count = 0

		for _, v in p.Fighters.List do
			if v.Name == reward.Name then
				count += 1
			end
		end

		return (math.max(0, reward.Amount - count))
	elseif reward.Claim and p.Commerce.RewardClaims[reward.Claim] then
		return 0
	else
		return reward.Amount
	end
end

function CommerceRewards.IsRewardConfigured(data)
	if typeof(data) ~= "table" then
		return false
	end

	local amount = data.Amount
	local v

	if typeof(amount) == "number" and amount > 0 and amount % 1 == 0 then
		v = amount <= 9007199254740991
	else
		v = false
	end

	if not v then
		return false
	end

	if data.EnsureOwned ~= nil then
		if data.EnsureOwned ~= true or data.Type ~= "Fighter" or data.Amount ~= 1 then
			return false
		end

		local v2 = Fighters.List[data.Name]

		if not v2 or v2.Sellable ~= false or v2.Deconstructable ~= false or v2.Tradeable ~= false then
			return false
		end
	end

	if Gems.GetName(data) then
		return true
	end

	if data.Type == "Fighter" then
		return Fighters.List[data.Name] ~= nil
	end

	if data.Type == "Weapon" then
		return Weapons.IsConfigured(data.Name)
	end

	if data.Type == "Mount" then
		return Mounts.List[data.Name] ~= nil
	end

	if data.Type == "Banner" then
		return ProfileBanners.List[data.Name] ~= nil
	end

	if data.Type ~= "Item" then
		return false
	end

	local v2 = Items.List[data.Name]

	if v2 then
		return v2.Type ~= "Potions" or Potions.IsConfigured(Potions.List[data.Name])
	end

	return false
end

function CommerceRewards.Snapshot(data)
	if typeof(data) ~= "table" or data.RewardsConfigured == false or data.Kind ~= "Gamepass" and data.Kind ~= "Bundle" and data.Kind ~= "GemPack" then
		return nil
	end

	local v = data.Kind == "Gamepass" and {} or data.Rewards

	if typeof(v) ~= "table" then
		return nil
	end

	local v2 = {
		Name = data.Name,
		Passes = {},
		Rewards = {}
	}

	if data.Kind == "Gamepass" then
		table.insert(v2.Passes, data.Name)
	elseif data.AllGamepasses then
		for k, gamepass in Gamepasses do
			if typeof(gamepass) ~= "table" or gamepass.RewardsConfigured == false then
				return nil
			end

			table.insert(v2.Passes, k)
		end
	end

	for _, v3 in v do
		if not CommerceRewards.IsRewardConfigured(v3) then
			return nil
		end

		table.insert(v2.Rewards, table.clone(v3))
	end

	for _, pass in v2.Passes do
		local gamepass = Gamepasses[pass]

		if typeof(gamepass) ~= "table" or gamepass.RewardsConfigured == false then
			return nil
		end

		local v3 = gamepass.Rewards == nil and {} or gamepass.Rewards

		if typeof(v3) ~= "table" then
			return nil
		end

		for _, v4 in v3 do
			if not CommerceRewards.IsRewardConfigured(v4) then
				return nil
			end

			local clone = table.clone(v4)
			clone.Claim = pass
			table.insert(v2.Rewards, clone)
		end
	end

	if #v2.Passes > 0 or #v2.Rewards > 0 then
		return v2
	end

	return nil
end

function CommerceRewards.CanUsePaidPayment(p)
	return CommerceRewards.Snapshot(p) ~= nil
end

function CommerceRewards.HasPendingRewards(p, p2)
	if typeof(p2) ~= "table" then
		return false
	end

	for _, pass in p2.Passes do
		if not p.Commerce.RewardClaims[pass] then
			return true
		end
	end

	for _, reward in p2.Rewards do
		if CommerceRewards.IsRewardConfigured(reward) and GetRewardAmount(p, reward) > 0 then
			return true
		end
	end

	return false
end

function CommerceRewards.Apply(data, data2, p: string)
	if typeof(data2) ~= "table" then
		return false
	end

	local purchaseOrigin = data2.Origin == "Free" and "Free" or "Paid"
	local total = 0
	local total2 = 0

	for _, reward in data2.Rewards do
		if not (reward.EnsureOwned == true or not (reward.Claim and data.Commerce.RewardClaims[reward.Claim])) then
			continue
		end

		if not CommerceRewards.IsRewardConfigured(reward) then
			return false
		end

		local rewardAmount = GetRewardAmount(data, reward)

		if rewardAmount <= 0 then
			continue
		end

		if reward.Type == "Fighter" then
			total2 += rewardAmount
		elseif reward.Type == "Weapon" then
			total += rewardAmount
		end
	end

	local clone = table.clone(data)
	clone.Gamepasses = table.clone(data.Gamepasses)

	for _, pass in data2.Passes do
		clone.Gamepasses[pass] = true
	end

	local module = require("@game/ReplicatedStorage/Omni/Utils/PlayerStats")
	local _, _, v2 = module.FightersInventory(clone, nil)
	local _, _, v3 = module.WeaponsInventory(clone, nil)

	if total2 > 0 and v2 < total2 or total > 0 and v3 < total then
		return false
	end

	data.Commerce.PassOrigins = data.Commerce.PassOrigins or {}

	for _, pass in data2.Passes do
		if not data.Gamepasses[pass] then
			data.Commerce.PassOrigins[pass] = purchaseOrigin
		end

		data.Gamepasses[pass] = true
	end

	for k, reward in data2.Rewards do
		local rewardAmount = GetRewardAmount(data, reward)

		if rewardAmount <= 0 then
			continue
		end

		if Gems.GetName(reward) then
			if not Economy.Credit(data, reward, purchaseOrigin) then
				return false
			end
		elseif reward.Type == "Item" and MonetizationCatalog.Get("Item", reward.Name) then
			if not Economy.Credit(data, reward, purchaseOrigin) then
				return false
			end

			AddIndex(data, "Item", reward.Name, reward.Amount) -- equivalent call inferred; original call site unknown
		elseif reward.Type == "Item" then
			data.Items.List[reward.Name] = (data.Items.List[reward.Name] or 0) + reward.Amount

			if purchaseOrigin == "Paid" then
				data.Commerce.PotionOrigins[reward.Name] = (data.Commerce.PotionOrigins[reward.Name] or 0) + reward.Amount
			end

			AddIndex(data, "Item", reward.Name, reward.Amount) -- equivalent call inferred; original call site unknown
		elseif reward.Type == "Banner" then
			data.Profile.Banners[reward.Name] = {
				Name = reward.Name
			}
		elseif reward.Type == "Mount" then
			data.Mounts.List[reward.Name] = data.Mounts.List[reward.Name] or {
				ID = p .. ":" .. k,
				Name = reward.Name
			}
		else
			local list

			if reward.Type == "Fighter" then
				list = data.Fighters.List
			else
				list = data.Weapons.List
			end

			for i = 1, rewardAmount do
				local ID = p .. ":" .. k .. ":" .. i
				local v6 = {
					ID = ID,
					Name = reward.Name,
					PurchaseOrigin = purchaseOrigin,
					Locked = true
				}

				if reward.Type == "Fighter" then
					v6.Level = 1
					v6.Exp = 0
					v6.Shiny = false
				end

				list[ID] = v6
			end

			AddIndex(data, reward.Type, reward.Name, rewardAmount) -- equivalent call inferred; original call site unknown
		end
	end

	for _, pass in data2.Passes do
		data.Commerce.RewardClaims[pass] = true
	end

	return true
end

return CommerceRewards