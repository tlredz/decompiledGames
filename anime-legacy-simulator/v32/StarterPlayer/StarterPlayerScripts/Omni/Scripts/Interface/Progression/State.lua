local module = require("@game/ReplicatedStorage/Omni")
local State = {}

local function IsAmount(p)
	local v = module.Utils.Validator:ValidateNumber(p)

	if v then
		if p >= 0 and p <= 9007199254740991 then
			return p % 1 == 0
		else
			return false
		end
	end

	return v
end

local function ReadAmount(p)
	if p == nil then
		return 0
	end

	local v = module.Utils.Validator:ValidateNumber(p)

	if v then
		if p >= 0 and p <= 9007199254740991 then
			v = p % 1 == 0
		else
			v = false
		end
	end

	if v then
		return p
	end

	return nil
end

function State.GetBalance(p)
	if typeof(p) ~= "table" or typeof(p.Name) ~= "string" then
		return nil
	end

	local data = module.Data

	if typeof(data) ~= "table" then
		return nil
	end

	if p.Type == "Item" or p.Type == "Items" then
		if not module.Shared.Items.List[p.Name] or (typeof(data.Items) ~= "table" or typeof(data.Items.List) ~= "table") then
			return nil
		end

		local v = data.Items.List[p.Name]

		if v == nil then
			v = 0
		else
			local v2 = module.Utils.Validator:ValidateNumber(v)

			if v2 then
				if v >= 0 and v <= 9007199254740991 then
					v2 = v % 1 == 0
				else
					v2 = false
				end
			end

			if not v2 then
				v = nil
			end
		end

		return v, "Item"
	else
		if p.Type ~= "Currency" and p.Type ~= "Currencies" or not module.Shared.Perks[p.Name] then
			return nil
		end

		if p.Name == "Gems" then
			local freeGems = data.Items and data.Items.List and data.Items.List["Free Gems"]

			if freeGems == nil then
				freeGems = 0
			else
				local v = module.Utils.Validator:ValidateNumber(freeGems)

				if v then
					if freeGems >= 0 and freeGems <= 9007199254740991 then
						v = freeGems % 1 == 0
					else
						v = false
					end
				end

				if not v then
					freeGems = nil
				end
			end

			local paidGems = data.Items and data.Items.List and data.Items.List["Paid Gems"]

			if paidGems == nil then
				paidGems = 0
			else
				local v = module.Utils.Validator:ValidateNumber(paidGems)

				if v then
					if paidGems >= 0 and paidGems <= 9007199254740991 then
						v = paidGems % 1 == 0
					else
						v = false
					end
				end

				if not v then
					paidGems = nil
				end
			end

			if freeGems == nil or paidGems == nil then
				return nil, "Currency"
			end

			local v = freeGems + paidGems
			local v2 = module.Utils.Validator:ValidateNumber(v)

			if v2 then
				if v >= 0 and v <= 9007199254740991 then
					v2 = v % 1 == 0
				else
					v2 = false
				end
			end

			if v2 then
				return freeGems + paidGems, "Currency"
			end

			return nil, "Currency"
		else
			local v = data[p.Name]

			if v == nil then
				v = 0
			else
				local v2 = module.Utils.Validator:ValidateNumber(v)

				if v2 then
					if v >= 0 and v <= 9007199254740991 then
						v2 = v % 1 == 0
					else
						v2 = false
					end
				end

				if not v2 then
					v = nil
				end
			end

			return v, "Currency"
		end
	end
end

function State.Get(p: string)
	local data = module.Data
	local v = module.Shared.Progression.List[p]
	local progression

	if typeof(data) == "table" then
		progression = data.Progression
	else
		progression = false
	end

	local list

	if typeof(progression) == "table" then
		list = progression.List
	else
		list = false
	end

	local auto

	if typeof(progression) == "table" then
		auto = progression.Auto
	else
		auto = false
	end

	local v2

	if typeof(list) == "table" then
		v2 = list[p]
	else
		v2 = false
	end

	local v3 = typeof(list) == "table" and v2 == nil and 0 or v2
	local preview = module.Shared.Progression.GetPreview(p, v3)
	local price = preview and preview.Price

	if not price and preview and preview.Completed and typeof(v) == "table" then
		local levelInformation = module.Shared.Progression.GetLevelInformation(p, preview.CurrentLevel)
		price = levelInformation and levelInformation.Price
	end

	local balance, priceType = State.GetBalance(price)

	if preview and not preview.Completed and priceType == nil then
		preview = nil
	end

	local maps

	if typeof(data) == "table" then
		maps = data.Maps
	else
		maps = false
	end

	local hasAccess

	if typeof(v) == "table" and typeof(maps) == "table" and typeof(maps.List) == "table" then
		hasAccess = module.Utils.PlayerStats.OwnsMap(v.MapName, data) == true
	else
		hasAccess = false
	end

	local completed

	if preview == nil then
		completed = false
	else
		completed = preview.Completed == true
	end

	local canStart

	if preview == nil then
		canStart = false
	else
		canStart = not completed and hasAccess and priceType ~= nil
	end

	local monetizationPolicy = module.Shared.MonetizationPolicy.FromPlayer(module.Instance)
	local canSpendRandom, paymentReason = module.Shared.Economy.CanSpendRandom(data, price, monetizationPolicy)
	return {
		Info = typeof(v) ~= "table" and {} or v,
		Preview = preview,
		Price = price,
		PriceType = priceType,
		Balance = balance,
		Completed = completed,
		HasAccess = hasAccess,
		Auto = typeof(auto) == "table" and auto[p] == true,
		CanStart = canStart,
		CanUpgrade = canStart and canSpendRandom,
		PaymentReason = paymentReason,
		Policy = monetizationPolicy
	}
end

return State