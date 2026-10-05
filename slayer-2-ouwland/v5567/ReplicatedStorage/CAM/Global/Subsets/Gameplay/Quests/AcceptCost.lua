local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shop = require(ReplicatedStorage.CAM.Global.Shop)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local AcceptCost = {
	Normalize = function(value)
		if type(value) == "string" then
			return {
				[value] = 1
			}
		end

		if type(value) == "table" then
			return value
		end

		return {}
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function held(p, k: string)
	local heldItem = Utility.HeldItem(p, k)

	if heldItem == nil then
		return 0
	end

	local amount = heldItem:FindFirstChild("Amount")
	return amount ~= nil and amount.Value or 1
end

function AcceptCost.Check(p, p2)
	if p == nil then
		return false
	end

	for k, v in AcceptCost.Normalize(p2) do
		local cashier = Shop.cashiers[k]
		local v2

		if cashier == nil then
			local v3 = held(p, k) -- equivalent call inferred; original call site unknown
			v2 = v <= v3
		else
			v2 = cashier.CanBuy(p, v)
		end

		if not v2 then
			return false, k, v
		end
	end

	return true
end

function AcceptCost.Charge(p, p2, p3, p4: string?)
	if not RunService:IsServer() then
		return
	end

	local ServerStorage = game:GetService("ServerStorage")
	local Item = require(ServerStorage.SAM.Services.Removers.Item)

	for k, v in AcceptCost.Normalize(p3) do
		local cashier = Shop.cashiers[k]

		if cashier == nil then
			Item(p, k, v, nil, "QuestFee")
		else
			cashier.Buy(p2, v, p, p4)
		end
	end
end

function AcceptCost.FormatText(p)
	local v = {}

	for k, v2 in AcceptCost.Normalize(p) do
		local cashier = Shop.cashiers[k]
		local v3

		if cashier == nil then
			v3 = `{Utility.addCommasToNumber(v2)} {k}`
		else
			v3 = cashier.FormulateTextPlusText(v2)
		end

		table.insert(v, v3)
	end

	return table.concat(v, ", ")
end

return AcceptCost