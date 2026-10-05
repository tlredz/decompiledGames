local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local CategoryItem = require(ReplicatedStorage.Modules.Shared.Item.CategoryItem)
local VehicleMiddleware = require(ReplicatedStorage.Modules.Shared.Item.Middleware.VehicleMiddleware)
local Object = require(ReplicatedStorage.Modules.Shared.Item.Object)
return function(registry)
	local function stringsGetter()
		local registry2 = ItemRegistry.GetRegistry(ItemRegistry.VEHICLES_REGISTRY)
		local names = {}

		for _, v in registry2 do
			if Object.InstanceOf(v, CategoryItem) and v:IsCategory() or not Object.InstanceOf(
				v,
				VehicleMiddleware.VehicleItem
			) then
				continue
			end

			if not (v.VehicleImpl.Type == "car" or v.VehicleImpl.Type == "boat" or v.VehicleImpl.Type == "hybrid") then
				continue
			end

			table.insert(names, v:GetName())
		end

		return names
	end

	local function stringToObject(p: string)
		return p
	end

	local v = CmdrUtil.cleanTypeName("vehicleId")
	registry:RegisterType(v, (CmdrUtil.createTypeDefinition(v, stringsGetter, stringToObject)))
end