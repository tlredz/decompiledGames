local v = {
	startsWith = function(value, list)
		if value:sub(1, #list) == list then
			return value:sub(#list + 1)
		end
	end
}
return {
	Name = "runif",
	Aliases = {},
	Description = "Runs a given command string if a certain condition is met.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "conditionFunction",
			Name = "Condition",
			Description = "The condition function"
		},
		{
			Type = "string",
			Name = "Argument",
			Description = "The argument to the condition function"
		},
		{
			Type = "string",
			Name = "Test against",
			Description = "The text to test against."
		},
		{
			Type = "string",
			Name = "Command",
			Description = "The command string to run if requirements are met. If omitted, return value from condition function is used.",
			Optional = true
		}
	},
	Run = function(p, p2, p3, p4, p5)
		local v2 = v[p2]

		if not v2 then
			return ("Condition %q is not valid."):format(p2)
		end

		local v3 = v2(p4, p3)

		if v3 then
			return p.Dispatcher:EvaluateAndRun(p.Cmdr.Util.RunEmbeddedCommands(p.Dispatcher, p5 or v3))
		end

		return ""
	end
}