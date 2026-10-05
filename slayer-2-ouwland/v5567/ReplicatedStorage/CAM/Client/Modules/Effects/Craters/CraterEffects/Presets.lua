return {
	OFA = function(options)
		local v = options or {}
		return "Path", {
			AnimationSpeed = 0.2,
			Width = { 5.5, 0.8 },
			stepSize = 1,
			Distance = v.Distance or 50,
			BlockSize = v.BlockSize or { 2, 0.5 },
			HoldTime = v.HoldTime or 3,
			Range = v.Range or 5
		}
	end
}