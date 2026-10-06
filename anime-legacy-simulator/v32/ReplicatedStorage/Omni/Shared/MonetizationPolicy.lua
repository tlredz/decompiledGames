local Settings = require(script.Parent.Parent.Settings)
local v = {
	Unavailable = function(p: string)
		return table.freeze({
			Status = p == "Loading" and "Loading" or "Failed",
			ArePaidRandomItemsRestricted = true,
			IsPaidItemTradingAllowed = false
		})
	end,
	Normalize = function(p)
		if not (typeof(p) == "table" and typeof(p.ArePaidRandomItemsRestricted) == "boolean") then
			return nil
		end

		if typeof(p.IsPaidItemTradingAllowed) == "boolean" then
			return table.freeze({
				Status = "Ready",
				ArePaidRandomItemsRestricted = p.ArePaidRandomItemsRestricted,
				IsPaidItemTradingAllowed = p.IsPaidItemTradingAllowed
			})
		end

		return nil
	end
}

function v.FromPlayer(instance)
	local monetizationPolicyStatus = instance:GetAttribute("MonetizationPolicyStatus")

	if monetizationPolicyStatus == "Ready" then
		return v.Normalize({
			ArePaidRandomItemsRestricted = instance:GetAttribute("ArePaidRandomItemsRestricted"),
			IsPaidItemTradingAllowed = instance:GetAttribute("IsPaidItemTradingAllowed")
		}) or v.Unavailable("Failed")
	end

	return v.Unavailable(monetizationPolicyStatus)
end

function v.CanUsePaidRandomItems(p)
	if Settings.EnforcePaidRandomRestrictions == false then
		return true
	end

	return typeof(p) == "table" and p.Status == "Ready" and p.ArePaidRandomItemsRestricted == false
end

function v.CanTradePaidItems(p)
	return typeof(p) == "table" and p.Status == "Ready" and p.IsPaidItemTradingAllowed == true
end

function v.GetUnavailableMessage(p)
	if typeof(p) ~= "table" or p.Status == "Loading" then
		return "Paid features are loading. Please try again shortly!"
	end

	if p.Status == "Ready" then
		return "This feature is not available for your account."
	end

	return "Paid features are temporarily unavailable. Please try again later!"
end

function v.GetPaymentMessage(p, p2)
	if p ~= "PaidBalanceRestricted" then
		return "This balance is temporarily unavailable. Please try again later!"
	end

	if p2.Status == "Ready" then
		return "Use tokens earned by playing for this action. Purchased tokens are unavailable for your account."
	end

	return (v.GetUnavailableMessage(p2))
end

return table.freeze(v)