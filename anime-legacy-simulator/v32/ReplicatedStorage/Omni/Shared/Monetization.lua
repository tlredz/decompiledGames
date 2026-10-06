local values = {}
local values2 = {}
local v = {}

local function IsName(value)
	return typeof(value) == "string" and string.find(value, "%S") ~= nil
end

local function IsAmount(value)
	return typeof(value) == "number" and value > 0 and value <= 9007199254740991 and value % 1 == 0
end

local function IsDefinition(p)
	return typeof(p) == "table" and getmetatable(p) == nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsKind(p)
	return p == "Fixed" or p == "Random" or p == "Modifier"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsOrigin(p)
	return p == "Free" or p == "Paid" or p == "Mixed" or p == "Unknown"
end

local function CopyUses(uses)
	if uses == nil then
		return table.freeze({})
	end

	local v3

	if typeof(uses) == "table" then
		v3 = getmetatable(uses) == nil
	else
		v3 = false
	end

	if not v3 then
		return nil, "Uses must be a system-to-kind table."
	end

	local v4 = {}

	for k, item in uses do
		local v5

		if typeof(k) == "string" then
			v5 = string.find(k, "%S") ~= nil
		else
			v5 = false
		end

		if not v5 or item ~= "Fixed" and item ~= "Random" and item ~= "Modifier" then
			return nil, "Each use requires a system name and a valid kind."
		end

		v4[k] = item
	end

	return table.freeze(v4)
end

local function CopyPrerequisites(prerequisites)
	if prerequisites == nil then
		return table.freeze({})
	end

	local v3

	if typeof(prerequisites) == "table" then
		v3 = getmetatable(prerequisites) == nil
	else
		v3 = false
	end

	if not v3 then
		return nil, "Prerequisites must be a set of requirement names."
	end

	local v4 = {}

	for k, item in prerequisites do
		local v5

		if typeof(k) == "string" then
			v5 = string.find(k, "%S") ~= nil
		else
			v5 = false
		end

		if not v5 or item ~= true then
			return nil, "Each prerequisite must have a name and the value true."
		end

		v4[k] = true
	end

	return table.freeze(v4)
end

local function AddUses(result, items)
	for k, item in items do
		result.Systems[k] = true
		result.HasRandomAccess = result.HasRandomAccess or item == "Random"
		result.HasChanceModifier = result.HasChanceModifier or item == "Modifier"
	end
end

local function GetExposure(items, p, p2)
	local result = {
		Systems = {},
		HasRandomAccess = p2 == "Random",
		HasChanceModifier = p2 == "Modifier"
	}
	AddUses(result, p)
	local v3 = {}
	local v4 = {}

	for k in items do
		table.insert(v3, k)
		v4[k] = true
	end

	local v5 = 1

	while v5 <= #v3 do
		local v6 = v3[v5]
		v5 += 1
		AddUses(result, values[v6].Uses)

		for _, v7 in values2 do
			if not (v7.Payment.Type == "Input" and v7.Payment.Input == v6) then
				continue
			end

			AddUses(result, v7.Uses)
			result.HasRandomAccess = result.HasRandomAccess or v7.Type == "Random"
			result.HasChanceModifier = result.HasChanceModifier or v7.Type == "Modifier"

			for k in v7.Content do
				if v4[k] then
					continue
				end

				v4[k] = true
				table.insert(v3, k)
			end
		end
	end

	return result
end

local function GetOrigin(p: string?, hasPaidSource: boolean)
	local result = {
		HasFreeSource = false,
		HasPaidSource = hasPaidSource,
		HasUnknownSource = false
	}
	local v3 = {}
	local v4 = {}

	if p then
		table.insert(v3, p)
		v4[p] = true
	end

	local v5 = 1

	while v5 <= #v3 do
		local v6 = v3[v5]
		local origin = values[v6].Origin
		v5 += 1
		result.HasFreeSource = result.HasFreeSource or origin == "Free" or origin == "Mixed"
		result.HasPaidSource = result.HasPaidSource or origin == "Paid" or origin == "Mixed"
		result.HasUnknownSource = result.HasUnknownSource or origin == "Unknown"

		for _, v7 in values2 do
			if not v7.Content[v6] then
				continue
			end

			if v7.Payment.Type == "Robux" then
				result.HasPaidSource = true
			elseif not v4[v7.Payment.Input] then
				v4[v7.Payment.Input] = true
				table.insert(v3, v7.Payment.Input)
			end
		end
	end

	if result.HasUnknownSource then
		result.Origin = "Unknown"
		return result
	end

	if result.HasFreeSource and result.HasPaidSource then
		result.Origin = "Mixed"
		return result
	end

	if result.HasPaidSource then
		result.Origin = "Paid"
		return result
	end

	result.Origin = "Free"
	return result
end

local function GetClassification(p, p2, p3, p4, hasPaidSource)
	local result = GetExposure(p, p2, p3)
	local origin = GetOrigin(p4, hasPaidSource)

	for k, v4 in origin do
		result[k] = v4
	end

	return result
end

return table.freeze({
	RegisterInput = function(name: string, data)
		local v3

		if typeof(name) == "string" then
			v3 = string.find(name, "%S") ~= nil
		else
			v3 = false
		end

		if not v3 then
			return false, "An input requires a name and a definition."
		end

		local v4

		if typeof(data) == "table" then
			v4 = getmetatable(data) == nil
		else
			v4 = false
		end

		if not v4 then
			return false, "An input requires a name and a definition."
		end

		if values[name] then
			return false, "The input is already registered."
		end

		if data.Type ~= "Currency" and data.Type ~= "Item" then
			return false, "Input type must be Currency or Item."
		end

		local origin = data.Origin == nil and "Unknown" or data.Origin

		if not IsOrigin(origin) then
			return false, "The input origin is invalid."
		end

		local uses, v7 = CopyUses(data.Uses)

		if not uses then
			return false, v7
		end

		local prerequisites, v9 = CopyPrerequisites(data.Prerequisites)

		if not prerequisites then
			return false, v9
		end

		values[name] = table.freeze({
			Name = name,
			Type = data.Type,
			Origin = origin,
			Uses = uses,
			Prerequisites = prerequisites
		})
		return true
	end,
	Register = function(name: string, data)
		local v3

		if typeof(name) == "string" then
			v3 = string.find(name, "%S") ~= nil
		else
			v3 = false
		end

		if not v3 then
			return false, "An offer requires a name and a definition."
		end

		local v4

		if typeof(data) == "table" then
			v4 = getmetatable(data) == nil
		else
			v4 = false
		end

		if not v4 then
			return false, "An offer requires a name and a definition."
		end

		if values2[name] then
			return false, "The offer is already registered."
		end

		if not IsKind(data.Type) then
			return false, "An offer requires a valid kind and a positive integer version."
		end

		local version = data.Version
		local v5

		if typeof(version) == "number" and version > 0 and version <= 9007199254740991 then
			v5 = version % 1 == 0
		else
			v5 = false
		end

		if not v5 then
			return false, "An offer requires a valid kind and a positive integer version."
		end

		local payment = data.Payment
		local v6

		if typeof(payment) == "table" then
			v6 = getmetatable(payment) == nil
		else
			v6 = false
		end

		if not v6 then
			return false, "An offer requires a payment with a positive integer amount."
		end

		local amount = payment.Amount
		local v7

		if typeof(amount) == "number" and amount > 0 and amount <= 9007199254740991 then
			v7 = amount % 1 == 0
		else
			v7 = false
		end

		if not v7 then
			return false, "An offer requires a payment with a positive integer amount."
		end

		local content, v8, v9, v10, v11, uses, v13, v14, prerequisites, v16

		if payment.Type == "Robux" then
			if payment.Input ~= nil then
				return false, "A Robux offer requires an unused ProductId and no payment input."
			end

			local productId = data.ProductId
			local v17

			if typeof(productId) == "number" and productId > 0 and productId <= 9007199254740991 then
				v17 = productId % 1 == 0
			else
				v17 = false
			end

			if not (v17 and not v[data.ProductId]) then
				return false, "A Robux offer requires an unused ProductId and no payment input."
			end

			content = data.Content

			if typeof(content) == "table" then
				v8 = getmetatable(content) == nil
			else
				v8 = false
			end

			if not (v8 and next(data.Content)) then
				return false, "An offer requires nonempty content."
			end

			v9 = {}

			for k, v18 in data.Content do
				if typeof(k) == "string" then
					v10 = string.find(k, "%S") ~= nil
				else
					v10 = false
				end

				if v10 and values[k] then
					if typeof(v18) == "number" and v18 > 0 and v18 <= 9007199254740991 then
						v11 = v18 % 1 == 0
					else
						v11 = false
					end

					if v11 then
						v9[k] = v18
						continue
					end
				end

				return false, "Content must reference registered inputs with positive integer amounts."
			end

			uses, v13 = CopyUses(data.Uses)

			if not uses then
				return false, v13
			end

			if data.Type ~= "Fixed" then
				v14 = false

				for k, v18 in uses do
					v14 = v14 or v18 == data.Type
				end

				if not v14 then
					return false, "A random or modifier offer must identify its affected system."
				end
			end

			prerequisites, v16 = CopyPrerequisites(data.Prerequisites)

			if not prerequisites then
				return false, v16
			end

			values2[name] = table.freeze({
				Name = name,
				Version = data.Version,
				Type = data.Type,
				ProductId = data.ProductId,
				Payment = table.freeze({
					Type = payment.Type,
					Input = payment.Input,
					Amount = payment.Amount
				}),
				Content = table.freeze(v9),
				Uses = uses,
				Prerequisites = prerequisites
			})

			if data.ProductId then
				v[data.ProductId] = name
			end

			return true
		else
			if payment.Type ~= "Input" then
				return false, "Payment type must be Robux or Input."
			end

			local input = payment.Input
			local v17

			if typeof(input) == "string" then
				v17 = string.find(input, "%S") ~= nil
			else
				v17 = false
			end

			if not v17 or not values[payment.Input] or data.ProductId ~= nil then
				return false, "An input payment requires a registered input and no ProductId."
			end

			content = data.Content

			if typeof(content) == "table" then
				v8 = getmetatable(content) == nil
			else
				v8 = false
			end

			if not (v8 and next(data.Content)) then
				return false, "An offer requires nonempty content."
			end

			v9 = {}

			for k, v18 in data.Content do
				if typeof(k) == "string" then
					v10 = string.find(k, "%S") ~= nil
				else
					v10 = false
				end

				if v10 and values[k] then
					if typeof(v18) == "number" and v18 > 0 and v18 <= 9007199254740991 then
						v11 = v18 % 1 == 0
					else
						v11 = false
					end

					if v11 then
						v9[k] = v18
						continue
					end
				end

				return false, "Content must reference registered inputs with positive integer amounts."
			end

			uses, v13 = CopyUses(data.Uses)

			if not uses then
				return false, v13
			end

			if data.Type ~= "Fixed" then
				v14 = false

				for k, v18 in uses do
					v14 = v14 or v18 == data.Type
				end

				if not v14 then
					return false, "A random or modifier offer must identify its affected system."
				end
			end

			prerequisites, v16 = CopyPrerequisites(data.Prerequisites)

			if not prerequisites then
				return false, v16
			end

			values2[name] = table.freeze({
				Name = name,
				Version = data.Version,
				Type = data.Type,
				ProductId = data.ProductId,
				Payment = table.freeze({
					Type = payment.Type,
					Input = payment.Input,
					Amount = payment.Amount
				}),
				Content = table.freeze(v9),
				Uses = uses,
				Prerequisites = prerequisites
			})

			if data.ProductId then
				v[data.ProductId] = name
			end

			return true
		end

		return false, "An offer requires a payment with a positive integer amount."
	end,
	GetInput = function(p: string)
		return values[p]
	end,
	GetOffer = function(p: string)
		return values2[p]
	end,
	GetOfferByProductId = function(p: number)
		local v3 = v[p]

		if v3 then
			return values2[v3]
		end

		return nil
	end,
	List = function()
		return table.clone(values2)
	end,
	ListInputs = function()
		return table.clone(values)
	end,
	GetInputClassification = function(p: string)
		if not values[p] then
			return nil
		end

		local result = GetExposure({
			[p] = 1
		}, {}, "Fixed")
		local origin = GetOrigin(p, false)

		for k, v4 in origin do
			result[k] = v4
		end

		return result
	end,
	GetOfferClassification = function(p: string)
		local v3 = values2[p]

		if not v3 then
			return nil
		end

		local content = v3.Content
		local uses = v3.Uses
		local type = v3.Type
		local input = v3.Payment.Input
		local hasPaidSource = v3.Payment.Type == "Robux"
		local result = GetExposure(content, uses, type)
		local origin = GetOrigin(input, hasPaidSource)

		for k, v6 in origin do
			result[k] = v6
		end

		result.DeliveryType = v3.Type
		return result
	end
})