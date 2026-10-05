return {
	AssetIds = {
		"31173820",
		"31173799",
		"31173844",
		"31173863",
		"31173881",
		"31173898",
		"31173735",
		"31173771"
	},
	MaxLifetime = 2,
	VolumeModifier = 0.7,
	Offset = 0,
	Fadeout = 0.4,
	CustomFunction = function(asset, _)
		return {
			asset = asset,
			timePosition = 0,
			pitch = 1
		}
	end
}