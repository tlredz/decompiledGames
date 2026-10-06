return {
	IsLimited = function(data)
		local collectiblesItemDetails = data.CollectiblesItemDetails or {}
		local itemRestrictions = data.ItemRestrictions or {}
		return data.IsLimited == true or data.IsLimitedUnique == true or collectiblesItemDetails.IsLimited == true or table.find(
			itemRestrictions,
			"Limited"
		) ~= nil or table.find(itemRestrictions, "LimitedUnique") ~= nil
	end
}