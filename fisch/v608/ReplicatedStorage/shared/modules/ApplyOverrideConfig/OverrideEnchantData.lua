local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
return {
	ConfigName = "OverrideEnchantData",
	ApplyEnvironment = "Both",
	Apply = function(p)
		if typeof(p) ~= "table" then
			return
		end

		local enchants = require(ReplicatedStorage.shared.modules:WaitForChild("library"):WaitForChild("rods"):WaitForChild("enchants"))
		enchants.Enchants = GeneralUtils.applyTable(enchants.Enchants, p, true)
		enchants:UpdateDescriptions()
	end
}