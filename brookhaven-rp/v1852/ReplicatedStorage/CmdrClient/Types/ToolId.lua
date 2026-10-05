local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.TableUtil)
return function(registry)
	local function stringsGetter()
		local config = ToolsConfig.GetConfig()
		local names = {}

		for _, v in pairs(config) do
			table.insert(names, v.Name)
		end

		return names
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("toolId")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end