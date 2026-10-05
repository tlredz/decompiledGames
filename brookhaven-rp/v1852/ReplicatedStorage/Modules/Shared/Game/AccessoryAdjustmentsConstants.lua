return {
	ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME = "AccessoryColorSurfaceAppearance",
	EMISSIVE_STRENGTH_MIN = 0,
	EMISSIVE_STRENGTH_MAX = 12,
	SLIDER_NORMALIZED_MIN = -0.5,
	SLIDER_NORMALIZED_MAX = 0.5,
	createDefaultAdjustment = function()
		return {
			position = {
				X = 0,
				Y = 0,
				Z = 0
			},
			rotation = {
				X = 0,
				Y = 0,
				Z = 0
			},
			scale = {
				X = 1,
				Y = 1,
				Z = 1
			}
		}
	end
}