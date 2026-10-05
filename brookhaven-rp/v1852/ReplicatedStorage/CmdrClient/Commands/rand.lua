return {
	Name = "rand",
	Aliases = {},
	Description = "Returns a random number between min and max",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "integer",
			Name = "First number",
			Description = "If second number is nil, random number is between 1 and this value. If second number is provided, number is between this number and the second number."
		},
		{
			Type = "integer",
			Name = "Second number",
			Description = "The upper bound.",
			Optional = true
		}
	},
	Run = function(_, p, p2)
		return (tostring(p2 and math.random(p, p2) or math.random(p)))
	end
}