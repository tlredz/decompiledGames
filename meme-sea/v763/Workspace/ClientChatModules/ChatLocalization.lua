return {
	Get = function(_, p, p2)
		local string = p2
		pcall(function()
			local LocalizationService = game:GetService("LocalizationService")
			string = LocalizationService:GetCorescriptLocalizations()[1]:GetString(
				LocalizationService.SystemLocaleId,
				p
			)
		end)
		return string
	end
}