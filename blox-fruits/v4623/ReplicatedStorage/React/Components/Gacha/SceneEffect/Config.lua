local IdMap = require(game.ReplicatedStorage.IdMap)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)

local function makeTitleColor(color: Color3, value: number?)
	local lerped = color:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, value or 0.5)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, lerped),
		ColorSequenceKeypoint.new(1, color)
	})
end

local function makeHeaderColor(color: Color3, color2: Color3)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.252159, color2),
		ColorSequenceKeypoint.new(0.497409, color),
		ColorSequenceKeypoint.new(0.701209, color2),
		ColorSequenceKeypoint.new(1, color)
	})
end

local function makeBannerColor(color: Color3, color2: Color3)
	return ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2) })
end

return {
	[IdMap.PhysicalMoveset["Sealed Fiend"]] = {
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Fiend (Yeti)-Fiend (Yeti)"],
		SkinItemId = IdMap.Skin.FIENDSKINsealed,
		TitleColor = makeTitleColor(Color3.new(0.764706, 0, 1)),
		HeaderColor = makeHeaderColor(Color3.fromRGB(188, 130, 255), Color3.fromRGB(131, 49, 254)),
		BannerColor = makeBannerColor(Color3.fromRGB(136, 50, 207), Color3.fromRGB(45, 17, 88))
	},
	[IdMap.PhysicalMoveset["Heavenly Gravity"]] = {
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Gravity-Gravity"],
		SkinItemId = IdMap.Skin.GRAVITYSKINheavenly,
		TitleColor = makeTitleColor(Color3.new(1, 0.74902, 0)),
		HeaderColor = makeHeaderColor(Color3.fromRGB(252, 254, 240), Color3.fromRGB(250, 227, 169)),
		BannerColor = makeBannerColor(Color3.fromRGB(251, 251, 232), Color3.fromRGB(249, 232, 183))
	},
	[IdMap.PhysicalMoveset["Red Ghost"]] = {
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Ghost-Ghost"],
		SkinItemId = IdMap.Skin.GHOSTSKINred,
		TitleColor = makeTitleColor(Color3.new(0.854902, 0.007843, 0.164706)),
		HeaderColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(181, 26, 26)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(181, 26, 26))
		})
	},
	[IdMap.PhysicalMoveset["Yellow Lightning"]] = {
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Lightning-Lightning"],
		SkinItemId = IdMap.Skin.LIGHTNINGSKINyellow,
		TitleColor = makeTitleColor(Color3.new(1, 0.815686, 0)),
		HeaderColor = makeBannerColor(Color3.fromRGB(255, 245, 132), Color3.fromRGB(251, 189, 20))
	},
	[IdMap.PhysicalMoveset["Magnet-Magnet"]] = {
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Magnet-Magnet"],
		SkinItemId = IdMap.Skin.MAGNETSKINdefault,
		TitleColor = makeTitleColor(Color3.new(0.533333, 0.52549, 0.521569))
	},
	[IdMap.PhysicalMoveset["Arcsteel Magnet"]] = {
		ShortName = "Arcsteel",
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Magnet-Magnet"],
		SkinItemId = IdMap.Skin.MAGNETSKINarksteel,
		TitleColor = makeTitleColor(Color3.new(1, 0.768627, 0)),
		HeaderColor = makeHeaderColor(Color3.fromRGB(244, 198, 32), Color3.fromRGB(223, 40, 41)),
		BannerColor = makeBannerColor(Color3.fromRGB(244, 198, 32), Color3.fromRGB(223, 40, 41))
	},
	[IdMap.PhysicalMoveset["Topaz Diamond"]] = {
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Diamond-Diamond"],
		SkinItemId = IdMap.Skin.DIAMONDSKINtopaz,
		TitleColor = makeTitleColor(Color3.new(1, 0.533333, 0)),
		HeaderColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 184, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 184, 50))
		})
	},
	[IdMap.PhysicalMoveset["Lime Blade"]] = {
		PhysicalMovesetItemId = IdMap.PhysicalMoveset["Blade-Blade"],
		SkinItemId = IdMap.Skin.BLADESKINlime,
		TitleColor = makeTitleColor(Color3.new(0, 1, 0.14902)),
		HeaderColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(98, 217, 4)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(98, 217, 4))
		})
	}
}