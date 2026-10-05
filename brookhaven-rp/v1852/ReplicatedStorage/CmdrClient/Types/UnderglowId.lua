local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.TableUtil)
return function(registry)
	local function stringsGetter()
		local children = ReplicatedStorage.Underglow:GetChildren()
		local result = {}

		for _, v in children do
			table.insert(result, v.Name)
		end

		table.insert(result, "None")
		return result
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("underglowId")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end