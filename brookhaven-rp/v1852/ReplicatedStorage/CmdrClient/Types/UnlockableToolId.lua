local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local ToolsConfig = require(ReplicatedStorage.Modules.Shared.DB.Tools.ToolsConfig)
return function(registry)
	local function stringsGetter()
		local config = ToolsConfig.GetConfig()
		local result = {}

		for k, v in pairs(config) do
			if v.RequirementBehaviorData then
				table.insert(result, k)
			elseif v.Item then
				table.insert(result, v.Item)
			end
		end

		return result
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("unlockableToolId")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end