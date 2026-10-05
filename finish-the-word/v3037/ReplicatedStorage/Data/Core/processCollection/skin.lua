local import = _G.import("itemModules")
return {
	purchaseSkin = function(p, object, object2, p2)
		if not object2:hasVip() then
			return "VIP is required"
		end

		if object:has("Inventory", "Skin", p2) or object:has("Equip", "Skin", p2) then
			return "Skin already owned"
		end

		local item = import:getItem("Skin", p2)

		if not item then
			return "Skin not found"
		end

		local currency = item.Currency

		if object.Statistics[currency] < item.DirectPrice then
			return "Not enough " .. currency
		end

		return true, p, object, object2, p2
	end
}