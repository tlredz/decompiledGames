require("@game/ReplicatedStorage/Omni/DataTemplate")
local module = require("@game/ReplicatedStorage/Omni/Shared/Fighters")
local module2 = require("@game/ReplicatedStorage/Omni/Shared/Weapons")
local module3 = require("@game/ReplicatedStorage/Omni/Shared/Mounts")
local MonetizationPolicy = require(script.Parent.MonetizationPolicy)
local Gems = require(script.Parent.Gems)
local v = {
	Fighters = module.List,
	Weapons = module2.List,
	Mounts = module3.List
}
local v2 = {
	TradeRequestDuration = 30,
	TradeAcceptDuration = 10,
	RAPWeight = 0.1,
	DefaultRAP = 100,
	UnfairThreshold = 0.3,
	FairnessReadyCooldown = 5,
	PaidGemRAP = 1,
	GetData = function(p, p2)
		if typeof(p) ~= "table" or p.Type ~= "Items" and not v[p.Type] or typeof(p.ID) ~= "string" then
			return nil, true
		end

		if p.Type == "Items" and p.ID == "Free Gems" then
			return nil, true
		end

		if typeof(p2) ~= "table" then
			return nil, false
		end

		local v3 = p2[p.Type]

		if typeof(v3) == "table" and typeof(v3.List) == "table" then
			return v3.List[p.ID], false
		end

		return nil, false
	end
}

function v2.GetOfferKey(p, p2)
	if not v[p.Type] then
		return nil
	end

	local data, v3 = v2.GetData(p, p2)

	if v3 or not data then
		return nil
	end

	return (`{p.Type}/{data.Name}`)
end

function v2.GetDefaultRAP(p, p2)
	local v3 = v[p.Type]

	if not v3 then
		return v2.DefaultRAP
	end

	local data, v4 = v2.GetData(p, p2)

	if v4 or not data then
		return v2.DefaultRAP
	end

	local v5 = v3[data.Name]

	if v5 then
		return v5.TradeValue or v2.DefaultRAP
	end

	return v2.DefaultRAP
end

function v2.GetGemsValue(data)
	if typeof(data) ~= "table" or data.Type ~= "Items" or data.ID ~= "Paid Gems" then
		return 0
	end

	if typeof(data.Amount) == "number" then
		return data.Amount * v2.PaidGemRAP
	end

	return 0
end

function v2.UpdateRAP(p: number, p2: number, p3: number?)
	return (math.floor(p * (1 - (p3 or v2.RAPWeight)) + p2 * (p3 or v2.RAPWeight)))
end

function v2.CanOfferWeapon(p, p2)
	local data, v3 = v2.GetData(p, p2)

	if v3 or p.Type ~= "Weapons" or typeof(data) ~= "table" then
		return false
	end

	local v4 = module2.List[data.Name]
	return v4 ~= nil and v4.Tradeable == true and data.Locked ~= true and p2.Weapons.Equipped ~= p.ID
end

function v2.IsPaidItem(p)
	if typeof(p) ~= "table" then
		return false
	end

	if p.PurchaseOrigin == "Paid" or p.PaidRandomItem == true then
		return true
	end

	for _, v3 in { "Trait", "Breathings", "Talents" } do
		local v4 = p[v3]

		if typeof(v4) == "table" and v4.PaidRandomItem == true then
			return true
		end
	end

	return false
end

function v2.CanOffer(data, p)
	if typeof(data) ~= "table" then
		return false, "Only tradeable fighters, weapons, mounts and Paid Gems can be offered."
	end

	if data.Type == "Items" then
		if data.ID ~= "Paid Gems" then
			return false, "Only tradeable fighters, weapons, mounts and Paid Gems can be offered."
		end

		local amount = data.Amount

		if typeof(amount) ~= "number" or amount < 1 or amount % 1 ~= 0 then
			return false, "Choose a valid amount of Paid Gems."
		end

		local v3 = Gems.Read(p)

		if v3 and not (v3.Paid < amount) then
			return true
		end

		return false, "You don't have enough Paid Gems for this offer."
	else
		local v3 = v[data.Type]

		if not v3 then
			return false, "Only tradeable fighters, weapons, mounts and Paid Gems can be offered."
		end

		local data2, v4 = v2.GetData(data, p)
		local v5 = data.Type == "Mounts" and "Name" or "ID"

		if v4 or typeof(data2) ~= "table" or data2[v5] ~= data.ID then
			return false, "This item is no longer available in the owner's inventory."
		end

		local v6 = v3[data2.Name]

		if not v6 or v6.Tradeable ~= true then
			return false, "This item cannot be traded."
		end

		if data2.Locked == true then
			return false, "Unlock this item before offering it."
		end

		local equipped = p[data.Type].Equipped

		if data.Type == "Weapons" and equipped == data.ID or data.Type == "Fighters" and typeof(equipped) == "table" and equipped[data.ID] or data.Type == "Mounts" and typeof(equipped) == "table" and equipped[v6.Type] == data.ID then
			return false, "Unequip this item before offering it."
		end

		return true
	end
end

function v2.IsPaidOffer(p, p2)
	if typeof(p) ~= "table" then
		return false
	end

	if p.Type == "Items" then
		return true
	end

	local data = v2.GetData(p, p2)
	return v2.IsPaidItem(data)
end

function v2.ValidateOffer(p, p2, options, options2)
	local canOffer, v3 = v2.CanOffer(p, p2)

	if not canOffer then
		return false, v3
	end

	if not v2.IsPaidOffer(p, p2) then
		return true
	end

	for _, v4 in { options or {}, options2 or {} } do
		if v4.Status ~= "Ready" then
			return false, "Paid item trading permissions are unavailable. Please try again shortly."
		end

		if not MonetizationPolicy.CanTradePaidItems(v4) then
			return false, "Both players must be eligible to trade paid items for this offer."
		end
	end

	return true
end

function v2.ValidateTransfer(offers, target, p3, offers2, target2, p6)
	local module4 = require("@game/ReplicatedStorage/Omni/Utils/PlayerStats")
	local v3 = {
		{
			Offers = offers,
			Data = target,
			Target = target2,
			Policy = p3,
			OtherPolicy = p6,
			Outgoing = {
				Fighters = 0,
				Weapons = 0,
				Mounts = 0
			},
			Gems = 0
		},
		{
			Offers = offers2,
			Data = target2,
			Target = target,
			Policy = p6,
			OtherPolicy = p3,
			Outgoing = {
				Fighters = 0,
				Weapons = 0,
				Mounts = 0
			},
			Gems = 0
		}
	}
	local count = 0

	for _, v4 in v3 do
		local v5 = {}

		for _, offer in v4.Offers do
			local v6, v7 = v2.ValidateOffer(offer, v4.Data, v4.Policy, v4.OtherPolicy)

			if not v6 then
				return false, v7
			end

			local v8 = offer.Type .. ":" .. offer.ID

			if v5[v8] then
				return false, "A duplicate item was found in this trade."
			end

			v5[v8] = true
			count += 1

			if offer.Type == "Items" then
				v4.Gems += offer.Amount
			else
				if v4.Target[offer.Type].List[offer.ID] then
					return false, "A duplicate item was found in this trade."
				end

				local outgoing = v4.Outgoing
				local type = offer.Type
				outgoing[type] += 1
			end
		end
	end

	if count == 0 then
		return false, "Add at least one item before accepting the trade."
	end

	for k, v4 in v3 do
		local gems = v3[3 - k].Gems

		if gems > 0 or v4.Gems > 0 then
			local v5 = Gems.Read(v4.Data)

			if not v5 or typeof(v4.Data.Economy) ~= "table" or v4.Data.Economy.Version ~= 2 or v5.Paid < v4.Gems or v5.Total - v4.Gems + gems > 9007199254740991 then
				return false, "One player cannot trade this amount of Paid Gems."
			end
		end

		for k2, v5 in {
			Fighters = module4.FightersInventory,
			Weapons = module4.WeaponsInventory
		} do
			local v6 = v3[3 - k].Outgoing[k2]

			if v6 == 0 then
				continue
			end

			local v7, v8 = v5(v4.Data)

			if v7 < v8 - v4.Outgoing[k2] + v6 then
				return false, "One player does not have enough inventory space for this trade."
			end
		end
	end

	return true
end

function v2.TransferOffers(offers, target, p3, offers2, target2, p6)
	local v3, v4 = v2.ValidateTransfer(offers, target, p3, offers2, target2, p6)

	if not v3 then
		return false, v4
	end

	local Economy = require(script.Parent.Economy)

	for _, v5 in {
		{
			Offers = offers,
			Data = target,
			Target = target2
		},
		{
			Offers = offers2,
			Data = target2,
			Target = target
		}
	} do
		for _, offer in v5.Offers do
			if offer.Type == "Items" then
				if not (Economy.Debit(v5.Data, {
					Type = "Item",
					Name = offer.ID,
					Free = 0,
					Paid = offer.Amount,
					Amount = offer.Amount
				}) and Economy.Credit(v5.Target, {
					Type = "Item",
					Name = offer.ID,
					Amount = offer.Amount
				}, "Paid")) then
					return false, "The Paid Gems could not be transferred."
				end
			else
				local v6 = v5.Data[offer.Type].List[offer.ID]
				v5.Target[offer.Type].List[offer.ID] = v6
				v5.Data[offer.Type].List[offer.ID] = nil

				if offer.Type ~= "Mounts" then
					local v7 = offer.Type == "Fighters" and "Fighter" or "Weapon"
					v5.Target.Index[v7] = v5.Target.Index[v7] or {}
					v5.Target.Index[v7][v6.Name] = (v5.Target.Index[v7][v6.Name] or 0) + 1
				end
			end
		end
	end

	return true
end

return table.freeze(v2)