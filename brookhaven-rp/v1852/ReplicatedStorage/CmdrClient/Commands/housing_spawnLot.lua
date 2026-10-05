local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
local PropertyUtil = require(ReplicatedStorage.Modules.Shared.Housing.PropertyUtil)
return {
	Name = "housing_spawnLot",
	Aliases = { "spawnlot" },
	Description = "Spawns a compatible house on the given lot.",
	Group = "Housing",
	Args = {
		{
			Type = "lotId",
			Name = "lotId",
			Description = "The lot to spawn on"
		},
		function(object)
			local value = object:GetArgument(1):GetValue()

			if value == nil then
				return nil
			end

			return {
				Type = CmdrUtil.createTypeDefinition("houseOptions", function()
					return PropertyUtil.GetCompatibleIdsForLot(value)
				end, function(p: string)
					return p
				end),
				Name = "houseOptions",
				Description = "A property compatible with this lot"
			}
		end
	}
}