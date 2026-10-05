local Textures = require(game.ReplicatedStorage.Textures)
return {
	["android-tv"] = {
		Image = Textures.debug.HUD["android-tv.jpg"],
		Offset = UDim2.fromScale(0.011, 0.075),
		Size = UDim2.fromScale(0.9804999999999999, 0.86),
		SafeZoneOffset = UDim2.fromScale(0.05, 0.105),
		SafeZoneSize = UDim2.fromScale(0.95, 0.9485),
		Resolution = Vector2.new(1920, 1080),
		InputType = "Touch"
	},
	["galaxy-s11-classic"] = {
		Image = Textures.debug.HUD["galaxy-s11-classic.jpg"],
		Offset = UDim2.fromScale(0.0725, 0.101),
		Size = UDim2.fromScale(0.84595, 0.8255),
		SafeZoneOffset = UDim2.fromScale(0, 0.0725),
		Resolution = Vector2.new(1280, 800),
		InputType = "Touch"
	},
	["galaxy-s11-modern"] = {
		Image = Textures.debug.HUD["galaxy-s11-modern.jpg"],
		Offset = UDim2.fromScale(0.0725, 0.101),
		Size = UDim2.fromScale(0.84595, 0.8255),
		SafeZoneOffset = UDim2.fromScale(0, 0.0725),
		Resolution = Vector2.new(1280, 800),
		InputType = "Touch"
	},
	["iphone-7-classic"] = {
		Image = Textures.debug.HUD["iphone-7-classic.jpg"],
		Offset = UDim2.fromScale(0.1325, 0.1825),
		Size = UDim2.fromScale(0.736, 0.645),
		SafeZoneOffset = UDim2.fromScale(0, 0.155),
		Resolution = Vector2.new(667, 375),
		InputType = "Touch"
	},
	["iphone-7-modern"] = {
		Image = Textures.debug.HUD["iphone-7-modern.jpg"],
		Offset = UDim2.fromScale(0.1325, 0.1825),
		Size = UDim2.fromScale(0.736, 0.645),
		SafeZoneOffset = UDim2.fromScale(0, 0.155),
		Resolution = Vector2.new(667, 375),
		InputType = "Touch"
	},
	console = {
		Image = Textures.debug.HUD["console.jpg"],
		Offset = UDim2.fromScale(0.011, 0.075),
		Size = UDim2.fromScale(0.98, 0.859),
		SafeZoneOffset = UDim2.fromScale(0, 0.08),
		Resolution = Vector2.new(1920, 1080),
		InputType = "Gamepad"
	},
	["hd-pc"] = {
		Image = Textures.debug.HUD["hd-pc.jpg"],
		Offset = UDim2.fromScale(0.011, 0.075),
		Size = UDim2.fromScale(0.979, 0.86),
		SafeZoneOffset = UDim2.fromScale(0, 0.0555),
		Resolution = Vector2.new(1920, 1080),
		InputType = "MouseKeyboard"
	},
	["ipad-10-classic"] = {
		Image = Textures.debug.HUD["ipad-10-classic.jpg"],
		Offset = UDim2.fromScale(0.115, 0.1025),
		Size = UDim2.fromScale(0.757, 0.8215),
		SafeZoneOffset = UDim2.fromScale(0, 0.0725),
		Resolution = Vector2.new(1180, 820),
		InputType = "Touch"
	},
	["ipad-10-modern"] = {
		Image = Textures.debug.HUD["ipad-10-modern.jpg"],
		Offset = UDim2.fromScale(0.115, 0.1025),
		Size = UDim2.fromScale(0.757, 0.8215),
		SafeZoneOffset = UDim2.fromScale(0, 0.0725),
		Resolution = Vector2.new(1180, 820),
		InputType = "Touch"
	},
	["iphone-14-classic"] = {
		Image = Textures.debug.HUD["iphone-14-classic.jpg"],
		Offset = UDim2.fromScale(0.037, 0.1725),
		Size = UDim2.fromScale(0.9265, 0.6649999999999999),
		SafeZoneOffset = UDim2.fromScale(0.055, 0.145),
		SafeZoneSize = UDim2.fromScale(0.945, 0.9450000000000001),
		Resolution = Vector2.new(844, 390),
		InputType = "Touch"
	},
	["iphone-14-modern"] = {
		Image = Textures.debug.HUD["iphone-14-modern.jpg"],
		Offset = UDim2.fromScale(0.037, 0.1725),
		Size = UDim2.fromScale(0.9265, 0.6649999999999999),
		SafeZoneOffset = UDim2.fromScale(0.055, 0.145),
		SafeZoneSize = UDim2.fromScale(0.945, 0.9450000000000001),
		Resolution = Vector2.new(844, 390),
		InputType = "Touch"
	},
	laptop = {
		Image = Textures.debug.HUD["laptop.jpg"],
		Offset = UDim2.fromScale(0.011, 0.0745),
		Size = UDim2.fromScale(0.9805, 0.86),
		SafeZoneOffset = UDim2.fromScale(0, 0.075),
		Resolution = Vector2.new(1366, 768),
		InputType = "MouseKeyboard"
	},
	vga = {
		Image = Textures.debug.HUD["vga.jpg"],
		Offset = UDim2.fromScale(0.092, 0.04),
		Size = UDim2.fromScale(0.806, 0.9460000000000001),
		SafeZoneOffset = UDim2.fromScale(0, 0.125),
		Resolution = Vector2.new(640, 480),
		InputType = "MouseKeyboard"
	}
}