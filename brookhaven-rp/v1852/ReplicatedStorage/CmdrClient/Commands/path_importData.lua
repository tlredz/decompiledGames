return {
	Name = "path_importData",
	Description = "Writes path datastore entry from JSON produced by path_exportData (single-line JSON string).",
	Group = "GameSdkPathing",
	Args = {
		{
			Type = "string",
			Name = "pathName",
			Description = "The datastore key name to write (must match pathName inside JSON if present)."
		},
		{
			Type = "string",
			Name = "exportJson",
			Description = "Full JSON string from performance_pathGetData copy UI."
		}
	}
}