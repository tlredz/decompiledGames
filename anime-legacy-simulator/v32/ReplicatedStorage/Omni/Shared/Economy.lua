local MonetizationCatalog = require(script.Parent.MonetizationCatalog)
local MonetizationPolicy = require(script.Parent.MonetizationPolicy)
local Gems = require(script.Parent.Gems)
local v = {}

local function IsAmount(value)
	return typeof(value) == "number" and value >= 0 and value <= 9007199254740991 and value % 1 == 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsBalance(value)
	return typeof(value) == "number" and value >= 0 and value <= 9007199254740991
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetKind(type)
	if type == "Items" then
		return "Item"
	elseif type == "Currencies" then
		return "Currency"
	end

	return type
end

local function GetTotal(list, p: string, p2: string)
	if p == "Item" then
		list = list.Items and list.Items.List
	end

	if typeof(list) ~= "table" then
		return nil
	end

	local v2 = list[p2]
	local v3 = v2 == nil and 0 or v2
	local v4

	if typeof(v3) == "number" and v3 >= 0 then
		v4 = v3 <= 9007199254740991
	else
		v4 = false
	end

	if not v4 then
		v3 = nil
	end

	return v3, list
end

function v.Reconcile(p)
	local economy = p.Economy

	if typeof(economy) ~= "table" or economy.Version ~= 2 then
		return false, "InvalidEconomy"
	end

	local balances = economy.Balances

	if typeof(balances) ~= "table" or typeof(balances.Item) ~= "table" or typeof(balances.Currency) ~= "table" then
		return false, "InvalidEconomy"
	end

	for k, v2 in MonetizationCatalog.List() do
		for k2 in v2 do
			if Gems.GetName({
				Type = k,
				Name = k2
			}) then
				continue
			end

			local list

			if k == "Item" then
				list = p.Items and p.Items.List
			else
				list = p
			end

			local v3

			if typeof(list) == "table" then
				local v4 = list[k2]
				v3 = v4 == nil and 0 or v4
				local v5

				if typeof(v3) == "number" and v3 >= 0 then
					v5 = v3 <= 9007199254740991
				else
					v5 = false
				end

				if not v5 then
					v3 = nil
				end
			end

			if v3 == nil then
				continue
			end

			local v4 = balances[k][k2]
			local free

			if typeof(v4) == "table" then
				free = not IsBalance(v4.Free) and 0 or v4.Free
			else
				free = 0
			end

			local paid

			if typeof(v4) == "table" then
				paid = not IsBalance(v4.Paid) and 0 or v4.Paid
			else
				paid = 0
			end

			if not ((v4 ~= nil or v3 ~= 0) and (typeof(v4) ~= "table" or free ~= v4.Free or paid ~= v4.Paid or free + paid ~= v3)) then
				continue
			end

			local v7 = v3 - (free + paid)

			if v7 > 0 then
				paid += v7
			elseif v7 < 0 then
				local v8 = -v7
				local v9 = math.min(paid, v8)
				paid -= v9
				free = math.max(0, free - (v8 - v9))
			end

			balances[k][k2] = {
				Free = free,
				Paid = paid
			}
		end
	end

	return true
end

function v:Migrate()
	if typeof(self) ~= "table" then
		return false, "InvalidEconomy"
	end

	local economy = self.Economy

	if typeof(economy) ~= "table" then
		return false, "InvalidEconomy"
	end

	if economy.Version == 2 then
		return v.Reconcile(self)
	end

	if economy.Version ~= 0 and economy.Version ~= 1 then
		return false, "UnknownEconomyVersion"
	end

	local v2 = Gems.Read(self)

	if not v2 then
		return false, "InvalidGemBalance"
	end

	local balances = economy.Balances

	if economy.Version == 0 then
		balances = {
			Item = {},
			Currency = {}
		}

		for k, v3 in MonetizationCatalog.List() do
			for k2 in v3 do
				if Gems.GetName({
					Type = k,
					Name = k2
				}) then
					continue
				end

				local list

				if k == "Item" then
					list = self.Items and self.Items.List
				else
					list = self
				end

				local free

				if typeof(list) == "table" then
					local v5 = list[k2]
					free = v5 == nil and 0 or v5
					local v6

					if typeof(free) == "number" and free >= 0 then
						v6 = free <= 9007199254740991
					else
						v6 = false
					end

					if not v6 then
						free = nil
					end
				end

				if free == nil then
					return false, "InvalidBalance"
				else
					balances[k][k2] = {
						Free = free,
						Paid = 0
					}
				end
			end
		end
	end

	if typeof(balances) ~= "table" or typeof(balances.Item) ~= "table" or typeof(balances.Currency) ~= "table" then
		return false, "InvalidEconomy"
	end

	self.Items.List["Free Gems"] = v2.Free
	self.Items.List["Paid Gems"] = v2.Paid
	self.FreeGems = nil
	self.PaidGems = nil
	self.Index.Item = self.Index.Item or {}
	self.Index.Item["Free Gems"] = math.max(self.Index.Item["Free Gems"] or 0, v2.Free)
	self.Index.Item["Paid Gems"] = math.max(self.Index.Item["Paid Gems"] or 0, v2.Paid)
	self.Economy = {
		Version = 2,
		Balances = balances
	}
	return v.Reconcile(self)
end

function v.GetBalance(p, p2)
	if typeof(p) ~= "table" or typeof(p2) ~= "table" or typeof(p2.Name) ~= "string" then
		return nil
	end

	local kind = GetKind(p2.Type) -- equivalent call inferred; original call site unknown

	if kind ~= "Item" and kind ~= "Currency" then
		return nil
	end

	local name = Gems.GetName(p2)

	if name then
		local v3 = Gems.Read(p)

		if not v3 then
			return nil
		end

		if name == "Free Gems" then
			return {
				Free = v3.Free,
				Paid = 0,
				Total = v3.Free
			}
		elseif name == "Paid Gems" then
			return {
				Free = 0,
				Paid = v3.Paid,
				Total = v3.Paid
			}
		end

		return v3
	else
		if not MonetizationCatalog.Get(kind, p2.Name) then
			return nil
		end

		local name2 = p2.Name
		local list

		if kind == "Item" then
			list = p.Items and p.Items.List
		else
			list = p
		end

		local total

		if typeof(list) == "table" then
			local v4 = list[name2]
			total = v4 == nil and 0 or v4
			local v5

			if typeof(total) == "number" and total >= 0 then
				v5 = total <= 9007199254740991
			else
				v5 = false
			end

			if not v5 then
				total = nil
			end
		end

		local economy = p.Economy

		if total == nil or typeof(economy) ~= "table" or economy.Version ~= 2 then
			return nil
		end

		if typeof(economy.Balances) ~= "table" or typeof(economy.Balances[kind]) ~= "table" then
			return nil
		end

		local v4 = economy.Balances[kind][p2.Name]

		if v4 == nil and total == 0 then
			return {
				Free = 0,
				Paid = 0,
				Total = 0
			}
		end

		if typeof(v4) ~= "table" then
			return nil
		end

		local free = v4.Free
		local v5

		if typeof(free) == "number" and free >= 0 then
			v5 = free <= 9007199254740991
		else
			v5 = false
		end

		if not v5 then
			return nil
		end

		local paid = v4.Paid
		local v6

		if typeof(paid) == "number" and paid >= 0 then
			v6 = paid <= 9007199254740991
		else
			v6 = false
		end

		if v6 then
			if v4.Free + v4.Paid == total then
				return {
					Free = v4.Free,
					Paid = v4.Paid,
					Total = total
				}
			end

			return nil
		end

		return nil
	end
end

function v.GetSpendable(p, p2, flag: boolean)
	local balance = v.GetBalance(p, p2)

	if balance then
		return math.floor(balance.Free) + (flag ~= true and 0 or math.floor(balance.Paid))
	end

	return 0
end

function v.PreparePayment(p, data, flag: boolean)
	if typeof(data) ~= "table" then
		return nil, "InvalidPrice"
	end

	local amount = data.Amount
	local v2

	if typeof(amount) == "number" and amount >= 0 and amount <= 9007199254740991 then
		v2 = amount % 1 == 0
	else
		v2 = false
	end

	if not (v2 and data.Amount ~= 0) then
		return nil, "InvalidPrice"
	end

	local balance = v.GetBalance(p, data)

	if not balance then
		return nil, "InvalidBalanceOrigin"
	end

	if math.floor(balance.Free) + math.floor(balance.Paid) < data.Amount then
		return nil, "InsufficientBalance"
	end

	local free = math.min(math.floor(balance.Free), data.Amount)
	local paid = data.Amount - free

	if paid > 0 and flag ~= true then
		return nil, "PaidBalanceRestricted"
	end

	return {
		Type = GetKind(data.Type),
		Name = data.Name,
		Free = free,
		Paid = paid,
		Amount = data.Amount,
		Origin = paid > 0 and "Paid" or "Free"
	}
end

function v.PrepareCommercePayment(p, value: number, flag: boolean, flag2: boolean)
	local v2 = {
		Type = "Currency",
		Name = "Gems",
		Amount = value
	}

	if not flag then
		return v.PreparePayment(p, v2, flag2)
	end

	local v3

	if typeof(value) == "number" and value >= 0 and value <= 9007199254740991 then
		v3 = value % 1 == 0
	else
		v3 = false
	end

	if not v3 or value == 0 then
		return nil, "InvalidPrice"
	end

	local balance = v.GetBalance(p, v2)

	if not balance then
		return nil, "InvalidBalanceOrigin"
	end

	if math.floor(balance.Paid) < value then
		return nil, "InsufficientPaidGems"
	end

	if flag2 then
		return {
			Type = "Currency",
			Name = "Gems",
			Free = 0,
			Paid = value,
			Amount = value,
			Origin = "Paid"
		}
	end

	return nil, "PaidBalanceRestricted"
end

function v.Debit(p, data)
	if typeof(data) ~= "table" then
		return false
	end

	local balance = v.GetBalance(p, data)

	if not balance then
		return false
	end

	local free = data.Free
	local v2

	if typeof(free) == "number" and free >= 0 and free <= 9007199254740991 then
		v2 = free % 1 == 0
	else
		v2 = false
	end

	if not v2 then
		return false
	end

	local paid = data.Paid
	local v3

	if typeof(paid) == "number" and paid >= 0 and paid <= 9007199254740991 then
		v3 = paid % 1 == 0
	else
		v3 = false
	end

	if v3 then
		if data.Free + data.Paid ~= data.Amount or (data.Free > balance.Free or data.Paid > balance.Paid) then
			return false
		end

		local kind = GetKind(data.Type) -- equivalent call inferred; original call site unknown

		if Gems.GetName(data) then
			if not p.Economy or p.Economy.Version ~= 2 then
				return false
			end

			p.Items.List["Free Gems"] = (p.Items.List["Free Gems"] or 0) - data.Free
			p.Items.List["Paid Gems"] = (p.Items.List["Paid Gems"] or 0) - data.Paid
		else
			local name = data.Name
			local list

			if kind == "Item" then
				list = p.Items and p.Items.List
			else
				list = p
			end

			if typeof(list) == "table" then
				local v5 = list[name]
				local v6 = v5 == nil and 0 or v5
				local v7

				if typeof(v6) == "number" and v6 >= 0 then
					v7 = v6 <= 9007199254740991
				end
			else
				list = nil
			end

			list[data.Name] = balance.Free - data.Free + (balance.Paid - data.Paid)
			p.Economy.Balances[kind][data.Name] = {
				Free = balance.Free - data.Free,
				Paid = balance.Paid - data.Paid
			}
		end

		return true
	end

	return false
end

function v.Credit(data, data2, p: string)
	if typeof(data2) ~= "table" then
		return false
	end

	local amount = data2.Amount
	local v2

	if typeof(amount) == "number" and amount >= 0 and amount <= 9007199254740991 then
		v2 = amount % 1 == 0
	else
		v2 = false
	end

	if not v2 then
		return false
	end

	if p ~= "Free" and p ~= "Paid" then
		return false
	end

	local balance = v.GetBalance(data, data2)

	if not balance then
		return false
	end

	local v3 = balance.Total + data2.Amount
	local v4

	if typeof(v3) == "number" and v3 >= 0 then
		v4 = v3 <= 9007199254740991
	else
		v4 = false
	end

	if not v4 then
		return false
	end

	local kind = GetKind(data2.Type) -- equivalent call inferred; original call site unknown
	local name = Gems.GetName(data2)

	if name then
		if not data.Economy or data.Economy.Version ~= 2 then
			return false
		end

		local v6 = Gems.Read(data)

		if not v6 then
			return false
		end

		local v7 = v6.Total + data2.Amount
		local v8

		if typeof(v7) == "number" and v7 >= 0 then
			v8 = v7 <= 9007199254740991
		else
			v8 = false
		end

		if not v8 then
			return false
		end

		if name == "Gems" then
			name = p == "Free" and "Free Gems" or "Paid Gems"
		end

		data.Items.List[name] = (data.Items.List[name] or 0) + data2.Amount
		data.Index.Item = data.Index.Item or {}
		data.Index.Item[name] = (data.Index.Item[name] or 0) + data2.Amount
		return true
	else
		local name2 = data2.Name
		local list

		if kind == "Item" then
			list = data.Items and data.Items.List
		else
			list = data
		end

		if typeof(list) == "table" then
			local v6 = list[name2]
			local v7 = v6 == nil and 0 or v6
			local v8

			if typeof(v7) == "number" and v7 >= 0 then
				v8 = v7 <= 9007199254740991
			end
		else
			list = nil
		end

		balance[p] += data2.Amount
		list[data2.Name] = balance.Free + balance.Paid
		data.Economy.Balances[kind][data2.Name] = {
			Free = balance.Free,
			Paid = balance.Paid
		}
		return true
	end

	return false
end

function v.Convert(p, p2, p3, flag: boolean)
	local v2, v3 = v.PreparePayment(p, p2, flag)

	if not v2 then
		return false, v3
	end

	local balance = v.GetBalance(p, p3)

	if not balance then
		return false, "InvalidReward"
	end

	local amount = p3.Amount
	local v4

	if typeof(amount) == "number" and amount >= 0 and amount <= 9007199254740991 then
		v4 = amount % 1 == 0
	else
		v4 = false
	end

	if not (v4 and p3.Amount ~= 0) then
		return false, "InvalidReward"
	end

	local v5 = balance.Total + p3.Amount
	local v6

	if typeof(v5) == "number" and v5 >= 0 then
		v6 = v5 <= 9007199254740991
	else
		v6 = false
	end

	if not v6 then
		return false, "InvalidReward"
	end

	if not v.Debit(p, v2) then
		return false, "InvalidPayment"
	end

	if v.Credit(p, p3, v2.Origin) then
		return true, v2
	end

	return false, "InvalidReward"
end

function v.CanSpendRandom(p, p2, p3)
	local v2, v3 = v.PreparePayment(p, p2, MonetizationPolicy.CanUsePaidRandomItems(p3))
	return v2 ~= nil, v3
end

return table.freeze(v)