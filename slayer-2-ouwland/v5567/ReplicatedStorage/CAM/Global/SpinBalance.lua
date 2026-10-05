local SpinBalance = {
	ACCOUNT_VALUE = "AccountSpins",
	CLAN_POOL = "FreeClanSpins",
	OTHER_POOL = "FreeOtherSpins",
	SLOT_VALUE = "Spins"
}

local function numberValue(instance, childName: string)
	if instance == nil then
		return nil
	end

	local valueBase = instance:FindFirstChild(childName)

	if valueBase == nil or not valueBase:IsA("ValueBase") or typeof(valueBase.Value) ~= "number" then
		return nil
	end

	return valueBase
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spinningOf(instance)
	if instance == nil then
		return nil
	end

	return instance:FindFirstChild("Spinning")
end

function SpinBalance.Root(p)
	if p == nil then
		return nil
	end

	local parent = p.Parent

	if parent == nil or parent.Name ~= "slots" then
		return nil
	end

	return parent.Parent
end

function SpinBalance.Account(p)
	local root = SpinBalance.Root(p)
	local ACCOUNT_VALUE = SpinBalance.ACCOUNT_VALUE

	if root == nil then
		return nil
	end

	local valueBase = root:FindFirstChild(ACCOUNT_VALUE)

	if valueBase == nil or not valueBase:IsA("ValueBase") or typeof(valueBase.Value) ~= "number" then
		return nil
	end

	return valueBase
end

function SpinBalance.Free(instance, flag: boolean?)
	local v = spinningOf(instance) -- equivalent call inferred; original call site unknown
	local CLAN_POOL

	if flag then
		CLAN_POOL = SpinBalance.CLAN_POOL
	else
		CLAN_POOL = SpinBalance.OTHER_POOL
	end

	if v == nil then
		return nil
	end

	local valueBase = v:FindFirstChild(CLAN_POOL)

	if valueBase == nil or not valueBase:IsA("ValueBase") or typeof(valueBase.Value) ~= "number" then
		return nil
	end

	return valueBase
end

function SpinBalance.Slot(instance)
	local v = spinningOf(instance) -- equivalent call inferred; original call site unknown
	local SLOT_VALUE = SpinBalance.SLOT_VALUE

	if v == nil then
		return nil
	end

	local valueBase = v:FindFirstChild(SLOT_VALUE)

	if valueBase == nil or not valueBase:IsA("ValueBase") or typeof(valueBase.Value) ~= "number" then
		return nil
	end

	return valueBase
end

function SpinBalance.Values(p, flag: boolean?)
	local result = {}

	for _, v in { SpinBalance.Free(p, flag), SpinBalance.Slot(p), SpinBalance.Account(p) } do
		table.insert(result, v)
	end

	return result
end

function SpinBalance.Total(p, flag: boolean?)
	local total = 0

	for _, v in SpinBalance.Values(p, flag) do
		total += v.Value
	end

	return total
end

function SpinBalance.Charge(p, flag: boolean?, value: number)
	local v = math.floor(value or 0)

	if v <= 0 then
		return true
	end

	local values = SpinBalance.Values(p, flag)
	local total = 0

	for _, value2 in values do
		total += value2.Value
	end

	if total < v then
		return false
	end

	for _, value2 in values do
		if v <= 0 then
			break
		end

		local v2 = math.min(value2.Value, v)

		if not (v2 > 0) then
			continue
		end

		value2.Value -= v2
		v -= v2
	end

	return true
end

return SpinBalance