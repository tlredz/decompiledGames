return (table.freeze({
	warnings = {
		Ineligible = "[VideoAd Controller] User is entirely ineligible to see advertised content."
	},
	computedWarnings = {
		AdsResult = function(name)
			if typeof(name) == "EnumItem" then
				name = name.Name
			end

			return (`[VideoAd Controller] In attempting to check ads for user, Roblox API provided the following: {name}`)
		end
	}
}))