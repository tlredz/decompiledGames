local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.TableUtil)
return function(registry)
	local HousingLayersAndThemes = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Cmdr"):WaitForChild("TypeConstants"):WaitForChild("HousingLayersAndThemes"))

	local function stringToObject(p: string)
		return p
	end

	for k, layer in HousingLayersAndThemes.Layers do
		local v = layer

		local function stringsGetter()
			return v
		end

		local v2 = CmdrUtil.cleanTypeName(("houseTheme%s"):format(k))
		registry:RegisterType(v2, (CmdrUtil.createTypeDefinition(v2, stringsGetter, stringToObject)))
	end
end