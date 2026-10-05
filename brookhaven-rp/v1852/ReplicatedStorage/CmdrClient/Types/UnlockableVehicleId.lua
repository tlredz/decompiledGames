local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local FreeItem = require(ReplicatedStorage.Modules.Shared.Item.Items.FreeItem)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
return function(registry)
	local function stringsGetter()
		local registry2 = ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY)
		local names = {}

		for _, v in pairs(registry2) do
			if not Object.InstanceOf(v, FreeItem) then
				table.insert(names, v:GetName())
			end
		end

		return names
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("unlockableVehicleId")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end