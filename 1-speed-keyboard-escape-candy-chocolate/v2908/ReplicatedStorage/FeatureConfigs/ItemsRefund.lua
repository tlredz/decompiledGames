local ItemsRefund = {
	INDIVIDUAL_REFUNDS = {},
	RARITY_REFUNDS = {
		Common = 47000,
		Uncommon = 975000,
		Rare = 49750000,
		Epic = 496500000,
		Legendary = 960000000,
		Mythic = 2650000000
	},
	REFUNDS_NAME_PRODUCT = {
		["Common Item (Shop)"] = 47000,
		["Uncommon Item (Shop)"] = 975000,
		["Rare Item (Shop)"] = 49750000,
		["Epic Item (Shop)"] = 496500000,
		["Legendary Item (Shop)"] = 960000000,
		["Mythic Item (Shop)"] = 2650000000
	}
}

function ItemsRefund.GetRefundAmount(p: string, p2: string)
	if ItemsRefund.INDIVIDUAL_REFUNDS[p] then
		return ItemsRefund.INDIVIDUAL_REFUNDS[p]
	end

	return ItemsRefund.RARITY_REFUNDS[p2] or 0
end

return ItemsRefund