local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
return function(registry)
	local function stringsGetter()
		local HousingLayersAndThemes = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Cmdr"):WaitForChild("TypeConstants"):WaitForChild("HousingLayersAndThemes"))
		local result = {}

		for k, _ in HousingLayersAndThemes.Layers do
			table.insert(result, k)
		end

		return result
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("houseLayer")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end