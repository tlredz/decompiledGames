local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrUtil)
return {
	Name = "housing_overrideTheme",
	Description = "Overrides the global house theme.",
	Group = "Housing",
	Args = {
		{
			Type = "houseLayer",
			Name = "layer",
			Description = "The house layer to override the theme for"
		},
		function(object)
			local value = object:GetArgument(1):GetValue()

			if value then
				return {
					Type = CmdrUtil.cleanTypeName(("houseTheme%s"):format(value)),
					Name = "theme",
					Description = ("theme for layer (%s)"):format(value)
				}
			end

			return nil
		end
	}
}