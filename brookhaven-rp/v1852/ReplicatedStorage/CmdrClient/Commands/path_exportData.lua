return {
	Name = "path_exportData",
	Description = "Shows a copy-paste JSON export of path data for use with path_importData.",
	Group = "GameSdkPathing",
	Args = {
		{
			Type = "pathName",
			Name = "pathName",
			Description = "The datastore key name of the path."
		}
	}
}