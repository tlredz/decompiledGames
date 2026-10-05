return {
	AssetIds = { "3036987884" },
	MaxLifetime = 2,
	VolumeModifier = 2,
	Offset = 0,
	Fadeout = 0.4,
	CustomFunction = function(p, _)
		return {
			asset = 1,
			timePosition = 0,
			pitch = 1.059463 ^ p
		}
	end
}