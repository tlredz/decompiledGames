return {
	Name = "run-lines",
	Aliases = {},
	Description = "Splits input by newlines and runs each line as its own command. This is used by the init-run command.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Script",
			Description = "The script to parse.",
			Default = ""
		}
	},
	ClientRun = function(object, value)
		if #value == 0 then
			return ""
		end

		local v = object.Dispatcher:Run("var", "INIT_PRINT_OUTPUT") ~= ""
		local parts = value:gsub("\n+", "\n"):split("\n")

		for _, part in ipairs(parts) do
			if part:sub(1, 1) == "#" then
				continue
			end

			local evaluateAndRun = object.Dispatcher:EvaluateAndRun(part)

			if v then
				object:Reply(evaluateAndRun)
			end
		end

		return ""
	end
}