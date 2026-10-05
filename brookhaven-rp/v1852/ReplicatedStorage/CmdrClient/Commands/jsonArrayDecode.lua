return {
	Name = "json-array-decode",
	Aliases = {},
	Description = "Decodes a JSON Array into a comma-separated list",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "json",
			Name = "JSON",
			Description = "The JSON array."
		}
	},
	ClientRun = function(_, p)
		local v = type(p) ~= "table" and { p } or p
		return table.concat(v, ",")
	end
}