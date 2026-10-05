return {
	Name = "createpromocode",
	Description = "Creates a promo code",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "string",
			Name = "Promocode",
			Description = "The promocode players will enter for the reward"
		},
		{
			Type = "duration",
			Name = "Expiration Time",
			Description = "The amount of time before the code expires"
		},
		{
			Type = "rewardtype",
			Name = "Type",
			Description = "The type of reward"
		},
		function(object)
			local argument = object:GetArgument(3)

			if (argument and argument:GetValue()) == "Tool" then
				return {
					Type = "tools",
					Name = "Value",
					Description = "The list of tools to reward"
				}
			end

			return {
				Type = "integer",
				Name = "Value",
				Description = "The numerical reward value"
			}
		end
	}
}