local Option = require(game.ReplicatedStorage.Packages.Option)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Display = require(game.ReplicatedStorage.Packages.Display)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("SkinDefinition"):tag("SkinVFX"):display(Display.JSON.new():setSortKeys(true):setOverride(function(p, p2, object, p3)
	if type(p) ~= "table" or p.Type == nil then
		return nil
	end

	if p.Type == "Palette" and type(p.ItemId) == "number" then
		local copy = TableUtil.deepCopy(p)
		copy.ItemId = ItemConfig.match(p.ItemId):unwrap().Index.DebugLabel
		return object:display(copy, p2, p3)
	elseif p.Type == "ColorSet" and type(p.ItemId) == "number" then
		local copy = TableUtil.deepCopy(p)
		copy.ItemId = ItemConfig.match(p.ItemId):unwrap().Index.DebugLabel
		return object:display(copy, p2, p3)
	end

	return nil
end):build()):traceback():build()
local v2 = {
	{
		Type = "ColorSet",
		Color3 = Color3.new(0.1, 0.1, 0.1),
		ItemId = IdMap.Skin.AURASKINdefault
	},
	{
		Type = "ColorSet",
		Color3 = Color3.fromHex("FFAA1D"),
		ItemId = IdMap.Skin["Bright Yellow"]
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Orange Soda"],
		Color3 = Color3.fromHex("FA5B3D")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Slimy Green"],
		Color3 = Color3.fromHex("299617")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Yellow Sunshine"],
		Color3 = Color3.fromHex("FFF700")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Green Lizard"],
		Color3 = Color3.fromHex("A7F432")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Blue Jeans"],
		Color3 = Color3.fromHex("5DADEC")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Plump Purple"],
		Color3 = Color3.fromHex("8046C0")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Fiery Rose"],
		Color3 = Color3.fromHex("FF5470")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Heat Wave"],
		Color3 = Color3.fromHex("FF7A00")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Absolute Zero"],
		Color3 = Color3.fromHex("0000FF")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Snow White"],
		Color3 = Color3.fromHex("BBBBBB")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Pure Red"],
		Color3 = Color3.fromHex("FF0000")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Winter Sky"],
		Color3 = Color3.fromHex("FF00BF")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Rainbow Saviour"],
		Color3 = Color3.fromHex("010101")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin.Aquamarine,
		Color3 = Color3.fromHex("7FFFD4")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Light Pink"],
		Color3 = Color3.fromHex("FF82B4")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin.Kitsune,
		Color3 = Color3.fromHex("3D54FF"),
		FadeColor3 = Color3.fromHex("C74FFF")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin.Dragon,
		Color3 = Color3.fromHex("FF3C00"),
		FadeColor3 = Color3.fromHex("FF007B")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Oni Aura"],
		Color3 = Color3.fromHex("FF1A1A"),
		FadeColor3 = Color3.fromHex("b8b8b8")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Celestial Aura"],
		Color3 = Color3.fromHex("AE00ff"),
		FadeColor3 = Color3.fromHex("b8b8b8")
	},
	{
		Type = "ColorSet",
		ItemId = IdMap.Skin["Hacker Aura"],
		Color3 = Color3.fromHex("39FF14"),
		FadeColor3 = Color3.fromHex("000000")
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.BOMBSKINdefault,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 105, 50),
			Default_Color2 = Color3.fromRGB(254, 59, 33),
			Default_Color3 = Color3.fromRGB(255, 144, 70),
			Shifted_Color1 = Color3.fromRGB(255, 105, 50),
			Shifted_Color2 = Color3.fromRGB(254, 59, 33),
			Shifted_Color3 = Color3.fromRGB(255, 144, 70),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.BOMBSKINazura,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 105, 50),
			Default_Color2 = Color3.fromRGB(254, 59, 33),
			Default_Color3 = Color3.fromRGB(255, 144, 70),
			Shifted_Color1 = Color3.fromRGB(0, 255, 255),
			Shifted_Color2 = Color3.fromRGB(0, 85, 255),
			Shifted_Color3 = Color3.fromRGB(0, 34, 255),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 85, 255))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.BOMBSKINnuclear,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 105, 50),
			Default_Color2 = Color3.fromRGB(254, 59, 33),
			Default_Color3 = Color3.fromRGB(255, 144, 70),
			Shifted_Color1 = Color3.fromRGB(221, 255, 0),
			Shifted_Color2 = Color3.fromRGB(255, 255, 0),
			Shifted_Color3 = Color3.fromRGB(85, 255, 0),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.BOMBSKINcelebration,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 105, 50),
			Default_Color2 = Color3.fromRGB(254, 59, 33),
			Default_Color3 = Color3.fromRGB(255, 144, 70),
			Default_Color4 = Color3.fromRGB(72, 133, 232),
			Default_Color5 = Color3.fromRGB(255, 0, 0),
			Shifted_Color1 = Color3.fromRGB(255, 0, 0),
			Shifted_Color2 = Color3.fromRGB(0, 26, 255),
			Shifted_Color3 = Color3.fromRGB(255, 73, 73),
			Shifted_Color4 = Color3.fromRGB(255, 0, 0),
			Shifted_Color5 = Color3.fromRGB(0, 13, 255),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.BOMBSKINthermite,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 105, 50),
			Default_Color2 = Color3.fromRGB(254, 59, 33),
			Default_Color3 = Color3.fromRGB(255, 144, 70),
			Shifted_Color1 = Color3.fromRGB(255, 0, 34),
			Shifted_Color2 = Color3.fromRGB(255, 85, 0),
			Shifted_Color3 = Color3.fromRGB(255, 85, 0),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 89)),
				ColorSequenceKeypoint.new(0.202, Color3.fromRGB(255, 84, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 0))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.DIAMONDSKINblue,
		Palette = {
			Default_Color1 = Color3.fromRGB(81, 128, 245),
			Default_Color2 = Color3.fromRGB(255, 239, 255),
			Default_Color3 = Color3.fromRGB(133, 189, 252),
			Shifted_Color1 = Color3.fromRGB(81, 128, 245),
			Shifted_Color2 = Color3.fromRGB(225, 239, 255),
			Shifted_Color3 = Color3.fromRGB(133, 189, 252),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.DIAMONDSKINred,
		Palette = {
			Default_Color1 = Color3.fromRGB(170, 207, 255),
			Default_Color2 = Color3.fromRGB(253, 254, 255),
			Default_Color3 = Color3.fromRGB(180, 220, 255),
			Shifted_Color1 = Color3.fromRGB(0, 0, 0),
			Shifted_Color2 = Color3.fromRGB(255, 0, 13),
			Shifted_Color3 = Color3.fromRGB(144, 0, 0),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.fromRGB(0, 0, 0))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.DIAMONDSKINgreen,
		Palette = {
			Default_Color1 = Color3.fromRGB(81, 128, 245),
			Default_Color2 = Color3.fromRGB(225, 239, 255),
			Default_Color3 = Color3.fromRGB(133, 189, 252),
			Shifted_Color1 = Color3.fromRGB(37, 118, 37),
			Shifted_Color2 = Color3.fromRGB(220, 255, 219),
			Shifted_Color3 = Color3.fromRGB(204, 252, 204),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.fromRGB(120, 222, 106))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.DIAMONDSKINtopaz,
		Palette = {
			Default_Color1 = Color3.fromRGB(81, 128, 245),
			Default_Color2 = Color3.fromRGB(225, 239, 255),
			Default_Color3 = Color3.fromRGB(133, 189, 252),
			Shifted_Color1 = Color3.fromRGB(255, 186, 140),
			Shifted_Color2 = Color3.fromRGB(255, 196, 167),
			Shifted_Color3 = Color3.fromRGB(255, 200, 124),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.fromRGB(255, 223, 158), Color3.fromRGB(127, 73, 29))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.DIAMONDSKINpoudretteite,
		Palette = {
			Default_Color1 = Color3.fromRGB(81, 128, 245),
			Default_Color2 = Color3.fromRGB(225, 239, 255),
			Default_Color3 = Color3.fromRGB(133, 189, 252),
			Shifted_Color1 = Color3.fromRGB(255, 133, 233),
			Shifted_Color2 = Color3.fromRGB(255, 255, 255),
			Shifted_Color3 = Color3.fromRGB(255, 234, 249),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 158, 244))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.KYUKONSKINcrimson,
		Palette = {
			Default_Color1 = Color3.fromRGB(39, 61, 255),
			Default_Color2 = Color3.fromRGB(61, 103, 255),
			Default_Color3 = Color3.fromRGB(64, 131, 255),
			Default_Color4 = Color3.fromRGB(38, 38, 255),
			Default_Color5 = Color3.fromRGB(214, 109, 39),
			Default_Color6 = Color3.fromRGB(84, 41, 255),
			Default_Color7 = Color3.fromRGB(94, 255, 250),
			Default_Color8 = Color3.fromRGB(255, 33, 37),
			Default_Color9 = Color3.fromRGB(118, 255, 49),
			Shifted_Color1 = Color3.fromRGB(255, 33, 33),
			Shifted_Color2 = Color3.fromRGB(255, 20, 20),
			Shifted_Color3 = Color3.fromRGB(255, 101, 101),
			Shifted_Color4 = Color3.fromRGB(255, 0, 0),
			Shifted_Color5 = Color3.fromRGB(255, 87, 75),
			Shifted_Color6 = Color3.fromRGB(255, 0, 0),
			Shifted_Color7 = Color3.fromRGB(255, 89, 89),
			Shifted_Color8 = Color3.fromRGB(255, 33, 37),
			Shifted_Color9 = Color3.fromRGB(255, 172, 99),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.KYUKONSKINgalaxy,
		Palette = {
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 85, 255))
			}),
			GrayscaleToColorStrength = 0,
			Default_Color1 = Color3.new(0.152941, 0.239216, 1),
			Default_Color2 = Color3.new(0.239216, 0.403922, 1),
			Default_Color3 = Color3.new(0.25098, 0.513726, 1),
			Default_Color4 = Color3.new(0.14902, 0.14902, 1),
			Default_Color5 = Color3.new(0.839216, 0.427451, 0.152941),
			Default_Color6 = Color3.new(0.329412, 0.160784, 1),
			Default_Color7 = Color3.new(0.368627, 1, 0.980392),
			Default_Color8 = Color3.new(1, 0.129412, 0.145098),
			Default_Color9 = Color3.new(0.462745, 1, 0.192157),
			Shifted_Color1 = Color3.new(0.333333, 0, 1),
			Shifted_Color2 = Color3.new(0.215686, 0.658824, 1),
			Shifted_Color3 = Color3.new(0, 0, 0.498039),
			Shifted_Color4 = Color3.new(1, 0.458824, 0.0745098),
			Shifted_Color5 = Color3.new(1, 0.333333, 1),
			Shifted_Color6 = Color3.new(0.235294, 0, 1),
			Shifted_Color7 = Color3.new(0, 0.666667, 1),
			Shifted_Color8 = Color3.new(1, 0.129412, 0.145098),
			Shifted_Color9 = Color3.new(1, 0.333333, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.YETISKINfiend,
		Palette = {
			Default_Color1 = Color3.new(0.321569, 0.592157, 1),
			Default_Color2 = Color3.new(0.498039, 0.823529, 1),
			Default_Color3 = Color3.new(0.380392, 0.701961, 1),
			Default_Color4 = Color3.new(0.172549, 0.364706, 1),
			Default_Color5 = Color3.new(0.619608, 0.92549, 1),
			Default_Color6 = Color3.new(0.956863, 0.305882, 0.109804),
			Default_Color7 = Color3.new(0.466667, 0.101961, 0.101961),
			Default_Color8 = Color3.fromRGB(130, 28, 255),
			Default_Color9 = Color3.fromRGB(255, 102, 204),
			Shifted_Color1 = Color3.new(0.317647, 0, 1),
			Shifted_Color2 = Color3.new(0, 0, 0),
			Shifted_Color3 = Color3.new(1, 0, 0.34902),
			Shifted_Color4 = Color3.new(0.482353, 0.109804, 1),
			Shifted_Color5 = Color3.new(0, 0, 0),
			Shifted_Color6 = Color3.new(0.956863, 0.305882, 0.109804),
			Shifted_Color7 = Color3.new(0.466667, 0.101961, 0.101961),
			Shifted_Color8 = Color3.fromRGB(130, 28, 255),
			Shifted_Color9 = Color3.fromRGB(255, 102, 204),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.FIENDSKINsealed,
		Palette = {
			Default_Color1 = Color3.new(0.321569, 0.592157, 1),
			Default_Color2 = Color3.new(0.498039, 0.823529, 1),
			Default_Color3 = Color3.new(0.380392, 0.701961, 1),
			Default_Color4 = Color3.new(0.172549, 0.364706, 1),
			Default_Color5 = Color3.new(0.619608, 0.92549, 1),
			Default_Color6 = Color3.new(0.956863, 0.305882, 0.109804),
			Default_Color7 = Color3.new(0.466667, 0.101961, 0.101961),
			Default_Color8 = Color3.fromRGB(130, 28, 255),
			Default_Color9 = Color3.fromRGB(255, 102, 204),
			Shifted_Color1 = Color3.fromRGB(222, 217, 235),
			Shifted_Color2 = Color3.fromRGB(250, 244, 255),
			Shifted_Color3 = Color3.fromRGB(240, 235, 250),
			Shifted_Color4 = Color3.fromRGB(10, 0, 20),
			Shifted_Color5 = Color3.fromRGB(250, 244, 255),
			Shifted_Color6 = Color3.fromRGB(215, 174, 246),
			Shifted_Color7 = Color3.fromRGB(165, 120, 226),
			Shifted_Color8 = Color3.fromRGB(10, 0, 20),
			Shifted_Color9 = Color3.fromRGB(235, 220, 255),
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(185, 139, 244)),
				ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			}),
			GrayscaleToColorStrength = 1
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.GRAVITYSKINdefault,
		Palette = {
			Default_Color1 = Color3.fromRGB(110, 73, 240),
			Default_Color2 = Color3.fromRGB(57, 49, 192),
			Default_Color3 = Color3.fromRGB(122, 62, 215),
			Default_Color4 = Color3.fromRGB(218, 43, 29),
			Default_Color5 = Color3.fromRGB(212, 95, 44),
			Default_Color6 = Color3.fromRGB(205, 144, 82),
			Default_Color7 = Color3.fromRGB(104, 209, 252),
			Default_Color8 = Color3.fromRGB(32, 150, 68),
			Default_Color9 = Color3.fromRGB(218, 90, 217),
			Shifted_Color1 = Color3.fromRGB(110, 73, 240),
			Shifted_Color2 = Color3.fromRGB(57, 49, 192),
			Shifted_Color3 = Color3.fromRGB(122, 62, 215),
			Shifted_Color4 = Color3.fromRGB(218, 43, 29),
			Shifted_Color5 = Color3.fromRGB(212, 95, 44),
			Shifted_Color6 = Color3.fromRGB(205, 144, 82),
			Shifted_Color7 = Color3.fromRGB(104, 209, 252),
			Shifted_Color8 = Color3.fromRGB(32, 150, 68),
			Shifted_Color9 = Color3.fromRGB(218, 90, 217),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.GRAVITYSKINheavenly,
		Palette = {
			Default_Color1 = Color3.fromRGB(120, 79, 255),
			Shifted_Color1 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.031, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.035, Color3.new(1, 0.86362, 0.52084)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0.86362, 0.52084))
			}),
			Shifted_Color1_StaticTime = 1,
			Default_Color2 = Color3.fromRGB(217, 75, 28),
			Shifted_Color2 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(0.362, Color3.new(0.013374, 0.011871, 0.0072353)),
				ColorSequenceKeypoint.new(0.365, Color3.new(0.85385, 0.75789, 0.46193)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0.88762, 0.54099))
			}),
			Shifted_Color2_StaticTime = 1,
			Default_Color3 = Color3.fromRGB(29, 113, 50),
			Shifted_Color3 = Color3.fromRGB(0, 0, 0),
			Default_Color4 = Color3.fromRGB(67, 63, 54),
			Shifted_Color4 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.98144, 1, 0.54487)),
				ColorSequenceKeypoint.new(0.298, Color3.new(1, 0.85241, 0.36224)),
				ColorSequenceKeypoint.new(0.302, Color3.new(0.045763, 0.039008, 0.016577)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
			}),
			Shifted_Color4_StaticTime = 0,
			Default_Color5 = Color3.fromRGB(103, 136, 255),
			Shifted_Color5 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0.93868, 0.51715))
			}),
			Shifted_Color5_StaticTime = 1,
			Default_Color6 = Color3.fromRGB(221, 135, 255),
			Shifted_Color6 = Color3.new(1, 0.86362, 0.52084),
			Default_Color7 = Color3.fromRGB(44, 101, 29),
			Shifted_Color7 = Color3.new(1, 0.88762, 0.54099),
			Default_Color8 = Color3.fromRGB(255, 0, 191),
			Shifted_Color8 = Color3.new(1, 0.86362, 0.52084),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0.88979, 0.6445))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.GHOSTSKINdefault,
		Palette = {
			Default_Color1 = Color3.fromRGB(81, 255, 0),
			Default_Color2 = Color3.fromRGB(0, 255, 64),
			Default_Color3 = Color3.fromRGB(0, 255, 115),
			Default_Color4 = Color3.fromRGB(35, 255, 174),
			Default_Color5 = Color3.fromRGB(1, 255, 200),
			Default_Color6 = Color3.fromRGB(19, 255, 239),
			Default_Color7 = Color3.fromRGB(0, 240, 255),
			Default_Color8 = Color3.fromRGB(0, 208, 255),
			Default_Color9 = Color3.fromRGB(0, 115, 255),
			Shifted_Color1 = Color3.fromRGB(81, 255, 0),
			Shifted_Color2 = Color3.fromRGB(0, 255, 64),
			Shifted_Color3 = Color3.fromRGB(0, 255, 115),
			Shifted_Color4 = Color3.fromRGB(35, 255, 174),
			Shifted_Color5 = Color3.fromRGB(1, 255, 200),
			Shifted_Color6 = Color3.fromRGB(19, 255, 239),
			Shifted_Color7 = Color3.fromRGB(0, 240, 255),
			Shifted_Color8 = Color3.fromRGB(0, 208, 255),
			Shifted_Color9 = Color3.fromRGB(0, 115, 255),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.GHOSTSKINred,
		Palette = {
			Default_Color1 = Color3.fromRGB(81, 255, 0),
			Default_Color2 = Color3.fromRGB(0, 255, 64),
			Default_Color3 = Color3.fromRGB(0, 255, 115),
			Default_Color4 = Color3.fromRGB(35, 255, 174),
			Default_Color5 = Color3.fromRGB(1, 255, 200),
			Default_Color6 = Color3.fromRGB(19, 255, 239),
			Default_Color7 = Color3.fromRGB(0, 240, 255),
			Default_Color8 = Color3.fromRGB(0, 208, 255),
			Default_Color9 = Color3.fromRGB(0, 115, 255),
			Shifted_Color1 = Color3.fromRGB(187, 0, 16),
			Shifted_Color2 = Color3.fromRGB(187, 0, 16),
			Shifted_Color3 = Color3.fromRGB(187, 0, 16),
			Shifted_Color4 = Color3.fromRGB(187, 0, 16),
			Shifted_Color5 = Color3.fromRGB(187, 0, 16),
			Shifted_Color6 = Color3.fromRGB(187, 0, 16),
			Shifted_Color7 = Color3.fromRGB(187, 0, 16),
			Shifted_Color8 = Color3.fromRGB(187, 0, 16),
			Shifted_Color9 = Color3.fromRGB(187, 0, 16),
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 5)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(150, 10, 30)),
				ColorSequenceKeypoint.new(0.75, Color3.fromRGB(238, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(252, 0, 9))
			}),
			GrayscaleToColorStrength = 1
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.MAGNETSKINdefault,
		Palette = {
			Default_Color1 = Color3.fromRGB(97, 160, 255),
			Default_Color2 = Color3.fromRGB(51, 65, 255),
			Default_Color3 = Color3.fromRGB(0, 0, 255),
			Default_Color4 = Color3.fromRGB(57, 18, 186),
			Default_Color5 = Color3.fromRGB(255, 41, 21),
			Default_Color6 = Color3.fromRGB(255, 95, 32),
			Default_Color7 = Color3.fromRGB(255, 68, 140),
			Default_Color8 = Color3.fromRGB(255, 45, 66),
			Default_Color9 = Color3.fromRGB(89, 255, 52),
			Shifted_Color1 = Color3.fromRGB(97, 160, 255),
			Shifted_Color2 = Color3.fromRGB(51, 65, 255),
			Shifted_Color3 = Color3.fromRGB(0, 0, 255),
			Shifted_Color4 = Color3.fromRGB(57, 18, 186),
			Shifted_Color5 = Color3.fromRGB(255, 41, 21),
			Shifted_Color6 = Color3.fromRGB(255, 95, 32),
			Shifted_Color7 = Color3.fromRGB(255, 68, 140),
			Shifted_Color8 = Color3.fromRGB(255, 45, 66),
			Shifted_Color9 = Color3.fromRGB(89, 255, 52),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.MAGNETSKINarksteel,
		Palette = {
			Default_Color1 = Color3.fromRGB(23, 46, 255),
			Shifted_Color1 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.694118, 1, 0.890196)),
				ColorSequenceKeypoint.new(0.186, Color3.new(0.615686, 1, 0.780392)),
				ColorSequenceKeypoint.new(0.508, Color3.new(0.356863, 1, 0.678431)),
				ColorSequenceKeypoint.new(1, Color3.new(0.552941, 1, 0.901961))
			}),
			Shifted_Color1_StaticTime = 1,
			Default_Color2 = Color3.fromRGB(214, 109, 39),
			Shifted_Color2 = Color3.fromRGB(214, 109, 39),
			Default_Color3 = Color3.fromRGB(255, 46, 130),
			Shifted_Color3 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0.95355, 0.47137)),
				ColorSequenceKeypoint.new(0.186, Color3.new(1, 0.88538, 0.45619)),
				ColorSequenceKeypoint.new(0.508, Color3.new(1, 0.40606, 0.35574)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 0.18941, 0.19946))
			}),
			Default_Color4 = Color3.fromRGB(105, 35, 255),
			Shifted_Color4 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.694118, 1, 0.890196)),
				ColorSequenceKeypoint.new(0.186, Color3.new(0.615686, 1, 0.780392)),
				ColorSequenceKeypoint.new(0.508, Color3.new(0.356863, 1, 0.678431)),
				ColorSequenceKeypoint.new(1, Color3.new(0.552941, 1, 0.901961))
			}),
			Default_Color5 = Color3.fromRGB(84, 255, 249),
			Shifted_Color5 = Color3.new(0.305882, 1, 0.745098),
			Default_Color6 = Color3.fromRGB(89, 255, 52),
			Shifted_Color6 = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(0.694118, 1, 0.890196)),
				ColorSequenceKeypoint.new(0.186, Color3.new(0.615686, 1, 0.780392)),
				ColorSequenceKeypoint.new(0.508, Color3.new(0.356863, 1, 0.678431)),
				ColorSequenceKeypoint.new(1, Color3.new(0.552941, 1, 0.901961))
			}),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.LIGHTNINGSKINblue,
		Palette = {
			Default_Color1 = Color3.fromRGB(0, 255, 255),
			Default_Color2 = Color3.fromRGB(15, 199, 255),
			Default_Color3 = Color3.fromRGB(2, 230, 255),
			Shifted_Color1 = Color3.fromRGB(0, 255, 255),
			Shifted_Color2 = Color3.fromRGB(15, 199, 255),
			Shifted_Color3 = Color3.fromRGB(2, 230, 255),
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1)),
			GrayscaleToColorStrength = 0
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.LIGHTNINGSKINgreen,
		Palette = {
			Default_Color1 = Color3.fromRGB(0, 255, 255),
			Default_Color2 = Color3.fromRGB(255, 204, 0),
			Default_Color3 = Color3.fromRGB(2, 230, 255),
			Shifted_Color1 = Color3.fromRGB(111, 255, 49),
			Shifted_Color2 = Color3.fromRGB(77, 255, 0),
			Shifted_Color3 = Color3.fromRGB(24, 255, 8),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.LIGHTNINGSKINyellow,
		Palette = {
			Default_Color1 = Color3.fromRGB(0, 255, 255),
			Default_Color2 = Color3.fromRGB(255, 204, 0),
			Default_Color3 = Color3.fromRGB(2, 230, 255),
			Shifted_Color1 = Color3.fromRGB(255, 239, 66),
			Shifted_Color2 = Color3.fromRGB(255, 204, 0),
			Shifted_Color3 = Color3.fromRGB(255, 222, 57),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.LIGHTNINGSKINred,
		Palette = {
			Default_Color1 = Color3.fromRGB(0, 255, 255),
			Default_Color2 = Color3.fromRGB(255, 204, 0),
			Default_Color3 = Color3.fromRGB(2, 230, 255),
			Default_Color4 = Color3.fromRGB(153, 241, 255),
			Default_Color5 = Color3.fromRGB(38, 186, 255),
			Default_Color6 = Color3.fromRGB(87, 252, 255),
			Default_Color7 = Color3.fromRGB(57, 219, 255),
			Shifted_Color1 = Color3.fromRGB(255, 0, 0),
			Shifted_Color2 = Color3.fromRGB(255, 84, 84),
			Shifted_Color3 = Color3.fromRGB(206, 10, 13),
			Shifted_Color4 = Color3.fromRGB(255, 146, 146),
			Shifted_Color5 = Color3.fromRGB(172, 0, 0),
			Shifted_Color6 = Color3.fromRGB(255, 78, 78),
			Shifted_Color7 = Color3.fromRGB(202, 24, 24),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.LIGHTNINGSKINpurple,
		Palette = {
			Default_Color1 = Color3.fromRGB(0, 255, 255),
			Default_Color2 = Color3.fromRGB(255, 204, 0),
			Default_Color3 = Color3.fromRGB(2, 230, 255),
			Shifted_Color1 = Color3.fromRGB(0, 0, 0),
			Shifted_Color2 = Color3.fromRGB(8, 0, 255),
			Shifted_Color3 = Color3.fromRGB(30, 0, 255),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(0, 0, 0))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PAINSKINdeepblue,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 55, 58),
			Default_Color2 = Color3.fromRGB(95, 14, 14),
			Default_Color3 = Color3.fromRGB(255, 114, 112),
			Shifted_Color1 = Color3.fromRGB(55, 58, 255),
			Shifted_Color2 = Color3.fromRGB(14, 14, 95),
			Shifted_Color3 = Color3.fromRGB(112, 138, 255),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PAINSKINdefault,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 55, 58),
			Default_Color2 = Color3.fromRGB(95, 14, 14),
			Default_Color3 = Color3.fromRGB(255, 114, 112),
			Shifted_Color1 = Color3.fromRGB(255, 55, 58),
			Shifted_Color2 = Color3.fromRGB(95, 14, 14),
			Shifted_Color3 = Color3.fromRGB(255, 114, 112),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(0, 0, 0))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PAINSKINred,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 55, 58),
			Default_Color2 = Color3.fromRGB(95, 14, 14),
			Default_Color3 = Color3.fromRGB(255, 114, 112),
			Shifted_Color1 = Color3.fromRGB(84, 0, 0),
			Shifted_Color2 = Color3.fromRGB(43, 0, 0),
			Shifted_Color3 = Color3.fromRGB(0, 0, 0),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(0, 0, 0))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PAINSKINorange,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 55, 58),
			Default_Color2 = Color3.fromRGB(95, 14, 14),
			Default_Color3 = Color3.fromRGB(255, 114, 112),
			Shifted_Color1 = Color3.fromRGB(255, 95, 55),
			Shifted_Color2 = Color3.fromRGB(95, 41, 14),
			Shifted_Color3 = Color3.fromRGB(255, 131, 112),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PAINSKINcelestial,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 55, 58),
			Default_Color2 = Color3.fromRGB(95, 14, 14),
			Default_Color3 = Color3.fromRGB(255, 114, 112),
			Shifted_Color1 = Color3.fromRGB(82, 55, 255),
			Shifted_Color2 = Color3.fromRGB(28, 14, 95),
			Shifted_Color3 = Color3.fromRGB(112, 117, 255),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PAINSKINsuperspirit,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 55, 58),
			Default_Color2 = Color3.fromRGB(95, 14, 14),
			Default_Color3 = Color3.fromRGB(255, 114, 112),
			Shifted_Color1 = Color3.fromRGB(255, 252, 55),
			Shifted_Color2 = Color3.fromRGB(95, 95, 14),
			Shifted_Color3 = Color3.fromRGB(255, 255, 112),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.fromRGB(60, 128, 255))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PORTALSKINblue,
		Palette = {
			Default_Color1 = Color3.fromRGB(176, 255, 246),
			Default_Color2 = Color3.fromRGB(84, 189, 255),
			Default_Color3 = Color3.fromRGB(74, 131, 255),
			Default_Color4 = Color3.fromRGB(0, 60, 255),
			Default_Color5 = Color3.fromRGB(102, 118, 255),
			Default_Color6 = Color3.fromRGB(0, 0, 255),
			Default_Color7 = Color3.fromRGB(110, 63, 248),
			Shifted_Color1 = Color3.fromRGB(176, 255, 246),
			Shifted_Color2 = Color3.fromRGB(84, 189, 255),
			Shifted_Color3 = Color3.fromRGB(74, 131, 255),
			Shifted_Color4 = Color3.fromRGB(0, 60, 255),
			Shifted_Color5 = Color3.fromRGB(102, 118, 255),
			Shifted_Color6 = Color3.fromRGB(0, 0, 255),
			Shifted_Color7 = Color3.fromRGB(110, 63, 248),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.PORTALSKINdivine,
		Palette = {
			Default_Color1 = Color3.fromRGB(176, 255, 246),
			Default_Color2 = Color3.fromRGB(84, 189, 255),
			Default_Color3 = Color3.fromRGB(74, 131, 255),
			Default_Color4 = Color3.fromRGB(0, 60, 255),
			Default_Color5 = Color3.fromRGB(102, 118, 255),
			Default_Color6 = Color3.fromRGB(0, 0, 255),
			Default_Color7 = Color3.fromRGB(110, 63, 248),
			Shifted_Color1 = Color3.fromRGB(255, 229, 97),
			Shifted_Color2 = Color3.fromRGB(255, 225, 30),
			Shifted_Color3 = Color3.fromRGB(255, 199, 16),
			Shifted_Color4 = Color3.fromRGB(255, 158, 21),
			Shifted_Color5 = Color3.fromRGB(141, 118, 0),
			Shifted_Color6 = Color3.fromRGB(83, 69, 0),
			Shifted_Color7 = Color3.fromRGB(248, 158, 41),
			GrayscaleToColorStrength = 0.2,
			GrayscaleToColorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 255))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.TIGERSKINwerewolf,
		Palette = {
			Default_Color1 = Color3.new(0.996078, 0.243137, 0.105882),
			Default_Color2 = Color3.new(0.65098, 0.0196078, 0.776471),
			Default_Color3 = Color3.new(0.603922, 0.341176, 1),
			Default_Color4 = Color3.new(0.690196, 0.313726, 1),
			Default_Color5 = Color3.new(0.411765, 0.137255, 1),
			Default_Color6 = Color3.new(0.768627, 0.180392, 1),
			Default_Color7 = Color3.new(0.227451, 0.0196078, 0.298039),
			Default_Color8 = Color3.new(0.666667, 0, 1),
			Default_Color9 = Color3.new(0.223529, 0.0470588, 0.427451),
			Shifted_Color1 = Color3.new(0.345098, 0.14902, 0.996078),
			Shifted_Color2 = Color3.new(0.498039, 0.498039, 0.996078),
			Shifted_Color3 = Color3.new(0.235294, 0.160784, 0.486275),
			Shifted_Color4 = Color3.new(0.45098, 1, 0),
			Shifted_Color5 = Color3.new(0.427451, 0.839216, 0.0901961),
			Shifted_Color6 = Color3.new(0.533333, 1, 0),
			Shifted_Color7 = Color3.new(0, 0.356863, 0.14902),
			Shifted_Color8 = Color3.new(0.682353, 1, 0),
			Shifted_Color9 = Color3.new(0.168627, 0.427451, 0.0470588),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromRGB(123, 35, 255))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.FALCSKINeagle,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 102, 56),
			Default_Color2 = Color3.fromRGB(255, 109, 51),
			Default_Color3 = Color3.fromRGB(253, 115, 58),
			Shifted_Color1 = Color3.fromRGB(255, 102, 56),
			Shifted_Color2 = Color3.fromRGB(255, 109, 51),
			Shifted_Color3 = Color3.fromRGB(253, 115, 58),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.FALCSKINfalcon,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 102, 56),
			Default_Color2 = Color3.fromRGB(255, 109, 51),
			Default_Color3 = Color3.fromRGB(253, 115, 58),
			Shifted_Color1 = Color3.fromRGB(255, 102, 56),
			Shifted_Color2 = Color3.fromRGB(255, 109, 51),
			Shifted_Color3 = Color3.fromRGB(253, 115, 58),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new(Color3.new(1, 1, 1))
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.FALCSKINparrot,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 102, 56),
			Default_Color2 = Color3.fromRGB(255, 109, 51),
			Default_Color3 = Color3.fromRGB(253, 115, 58),
			Shifted_Color1 = Color3.fromRGB(0, 85, 255),
			Shifted_Color2 = Color3.fromRGB(255, 157, 0),
			Shifted_Color3 = Color3.fromRGB(255, 0, 0),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
				ColorSequenceKeypoint.new(0.7, Color3.new(1, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.new(0, 0.333333, 1))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.FALCSKINrequiem,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 102, 56),
			Default_Color2 = Color3.fromRGB(255, 109, 51),
			Default_Color3 = Color3.fromRGB(253, 115, 58),
			Shifted_Color1 = Color3.fromRGB(47, 0, 25),
			Shifted_Color2 = Color3.fromRGB(106, 0, 101),
			Shifted_Color3 = Color3.fromRGB(255, 0, 115),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(116, 39, 58)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.FALCSKINmatrix,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 102, 56),
			Default_Color2 = Color3.fromRGB(255, 109, 51),
			Default_Color3 = Color3.fromRGB(253, 115, 58),
			Shifted_Color1 = Color3.fromRGB(0, 255, 0),
			Shifted_Color2 = Color3.fromRGB(0, 255, 127),
			Shifted_Color3 = Color3.fromRGB(39, 116, 0),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 14, 9)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 50, 0))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.FALCSKINglacier,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 102, 56),
			Default_Color2 = Color3.fromRGB(255, 109, 51),
			Default_Color3 = Color3.fromRGB(253, 115, 58),
			Shifted_Color1 = Color3.fromRGB(0, 85, 255),
			Shifted_Color2 = Color3.fromRGB(0, 255, 255),
			Shifted_Color3 = Color3.fromRGB(160, 234, 255),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)),
				ColorSequenceKeypoint.new(0.592, Color3.fromRGB(0, 170, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 255, 255))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.WSTDSKINgreen,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.fromRGB(255, 85, 0),
			Default_Color3 = Color3.fromRGB(255, 85, 0),
			Shifted_Color1 = Color3.fromRGB(255, 85, 0),
			Shifted_Color2 = Color3.fromRGB(255, 85, 0),
			Shifted_Color3 = Color3.fromRGB(255, 85, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.WSTDSKINbloodmoon,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Default_Color3 = Color3.fromRGB(255, 89, 0),
			Shifted_Color1 = Color3.fromRGB(255, 0, 0),
			Shifted_Color2 = Color3.fromRGB(0, 0, 0),
			Shifted_Color3 = Color3.fromRGB(0, 0, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.WSTDSKINvioletnight,
		Palette = {
			Shifted_Color1 = Color3.fromRGB(81, 0, 255),
			Shifted_Color2 = Color3.fromRGB(190, 164, 255),
			Default_Color1 = Color3.new(1, 0.333333, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Shifted_Color3 = Color3.fromRGB(81, 0, 255),
			Default_Color3 = Color3.new(1, 0.333333, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.WSTDSKINeclipse,
		Palette = {
			Shifted_Color1 = Color3.fromRGB(0, 85, 255),
			Shifted_Color2 = Color3.fromRGB(0, 255, 140),
			Default_Color1 = Color3.new(1, 0.333333, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Shifted_Color3 = Color3.fromRGB(0, 85, 255),
			Default_Color3 = Color3.new(1, 0.333333, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.WSTDSKINphoenixsky,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Default_Color3 = Color3.fromRGB(255, 89, 0),
			Shifted_Color1 = Color3.fromRGB(255, 0, 0),
			Shifted_Color2 = Color3.fromRGB(0, 85, 255),
			Shifted_Color3 = Color3.fromRGB(0, 85, 255)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.WSTDSKINember,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Default_Color3 = Color3.fromRGB(255, 89, 0),
			Shifted_Color1 = Color3.fromRGB(0, 0, 0),
			Shifted_Color2 = Color3.fromRGB(255, 30, 0),
			Shifted_Color3 = Color3.fromRGB(255, 30, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.ESTDSKINgreen,
		Palette = {
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.fromRGB(255, 85, 0),
			Default_Color3 = Color3.fromRGB(255, 85, 0),
			Shifted_Color1 = Color3.fromRGB(255, 85, 0),
			Shifted_Color2 = Color3.fromRGB(255, 85, 0),
			Shifted_Color3 = Color3.fromRGB(255, 85, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.ESTDSKINbloodmoon,
		Palette = {
			Ring_Color = Color3.fromRGB(255, 0, 0),
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Default_Color3 = Color3.fromRGB(255, 89, 0),
			Shifted_Color1 = Color3.fromRGB(255, 0, 0),
			Shifted_Color2 = Color3.fromRGB(0, 0, 0),
			Shifted_Color3 = Color3.fromRGB(0, 0, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.ESTDSKINvioletnight,
		Palette = {
			Ring_Color = Color3.fromRGB(38, 0, 255),
			Shifted_Color1 = Color3.fromRGB(81, 0, 255),
			Shifted_Color2 = Color3.fromRGB(190, 164, 255),
			Default_Color1 = Color3.new(1, 0.333333, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Shifted_Color3 = Color3.fromRGB(81, 0, 255),
			Default_Color3 = Color3.new(1, 0.333333, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.ESTDSKINeclipse,
		Palette = {
			Ring_Color = Color3.fromRGB(0, 170, 255),
			Shifted_Color1 = Color3.fromRGB(0, 85, 255),
			Shifted_Color2 = Color3.fromRGB(0, 255, 140),
			Default_Color1 = Color3.new(1, 0.333333, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Shifted_Color3 = Color3.fromRGB(0, 85, 255),
			Default_Color3 = Color3.new(1, 0.333333, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.ESTDSKINphoenixsky,
		Palette = {
			Ring_Color = Color3.new(1, 0, 0),
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Default_Color3 = Color3.fromRGB(255, 89, 0),
			Shifted_Color1 = Color3.fromRGB(255, 0, 0),
			Shifted_Color2 = Color3.fromRGB(0, 85, 255),
			Shifted_Color3 = Color3.fromRGB(0, 85, 255)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.ESTDSKINember,
		Palette = {
			Ring_Color = Color3.fromRGB(255, 85, 0),
			Default_Color1 = Color3.fromRGB(255, 85, 0),
			Default_Color2 = Color3.new(0, 0, 1),
			Default_Color3 = Color3.fromRGB(255, 89, 0),
			Shifted_Color1 = Color3.fromRGB(0, 0, 0),
			Shifted_Color2 = Color3.fromRGB(255, 30, 0),
			Shifted_Color3 = Color3.fromRGB(255, 30, 0)
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.BLADESKINdefault,
		Palette = {
			Default_Color1 = Color3.fromRGB(187, 181, 255),
			Default_Color2 = Color3.fromRGB(96, 56, 255),
			Default_Color3 = Color3.fromRGB(92, 42, 255),
			Default_Color4 = Color3.fromRGB(104, 58, 255),
			Default_Color5 = Color3.fromRGB(126, 87, 255),
			Default_Color6 = Color3.fromRGB(92, 42, 255),
			Default_Color7 = Color3.fromRGB(120, 66, 255),
			Default_Color8 = Color3.fromRGB(255, 166, 76),
			Default_Color9 = Color3.fromRGB(120, 66, 255),
			Shifted_Color1 = Color3.fromRGB(187, 181, 255),
			Shifted_Color2 = Color3.fromRGB(96, 56, 255),
			Shifted_Color3 = Color3.fromRGB(92, 42, 255),
			Shifted_Color4 = Color3.fromRGB(104, 58, 255),
			Shifted_Color5 = Color3.fromRGB(126, 87, 255),
			Shifted_Color6 = Color3.fromRGB(92, 42, 255),
			Shifted_Color7 = Color3.fromRGB(120, 66, 255),
			Shifted_Color8 = Color3.fromRGB(255, 166, 76),
			Shifted_Color9 = Color3.fromRGB(120, 66, 255),
			GrayscaleToColorStrength = 0,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
			})
		}
	},
	{
		Type = "Palette",
		ItemId = IdMap.Skin.BLADESKINlime,
		Palette = {
			Default_Color1 = Color3.fromRGB(187, 181, 255),
			Default_Color2 = Color3.fromRGB(96, 56, 255),
			Default_Color3 = Color3.fromRGB(92, 42, 255),
			Default_Color4 = Color3.fromRGB(104, 58, 255),
			Default_Color5 = Color3.fromRGB(126, 87, 255),
			Default_Color6 = Color3.fromRGB(92, 42, 255),
			Default_Color7 = Color3.fromRGB(120, 66, 255),
			Default_Color8 = Color3.fromRGB(255, 166, 76),
			Default_Color9 = Color3.fromRGB(120, 66, 255),
			Shifted_Color1 = Color3.fromRGB(50, 255, 50),
			Shifted_Color2 = Color3.fromRGB(50, 255, 50),
			Shifted_Color3 = Color3.fromRGB(50, 255, 50),
			Shifted_Color4 = Color3.fromRGB(50, 255, 50),
			Shifted_Color5 = Color3.fromRGB(50, 255, 50),
			Shifted_Color6 = Color3.fromRGB(50, 255, 50),
			Shifted_Color7 = Color3.fromRGB(50, 255, 50),
			Shifted_Color8 = Color3.fromRGB(255, 166, 76),
			Shifted_Color9 = Color3.fromRGB(50, 255, 50),
			GrayscaleToColorStrength = 1,
			GrayscaleToColorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
			})
		}
	}
}
TableUtil.deepFreeze(v2)
local Appearance = {
	applyPaletteToInstance = function(instance, grayscaleToColorSequence, p: string, p2: string)
		local extended = v.extend("applyPaletteToInstance", true)
		extended.info(function()
			local fullName = instance:GetFullName()
			local v4

			if grayscaleToColorSequence then
				v4 = ItemConfig.match(grayscaleToColorSequence.ItemId):unwrap().Index.DebugLabel
			end

			return (`called fn: (inst={fullName}, appearanceDefinition={v4}, focus={p}, mode={p2})`)
		end)
		extended.trace(function()
			return "appearance-definition", grayscaleToColorSequence
		end)

		local function applyAttribute(attributeName: string, p3)
			if p2 == "Overwrite" then
				instance:SetAttribute(attributeName, p3)
				extended.trace((`overwriting key "{attributeName}" to "{p3}"`))
			else
				if p2 ~= "FillBlanks" or instance:GetAttribute(attributeName) ~= nil or p3 == nil then
					extended.trace((`skipping key "{attributeName}"`))
					return
				end

				instance:SetAttribute(attributeName, p3)
				extended.trace((`filling empty value for key "{attributeName}" with "{p3}"`))
			end
		end

		if p == "Default" then
			local default_Color1

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color1 = grayscaleToColorSequence.Palette.Default_Color1
				else
					default_Color1 = false
				end
			else
				default_Color1 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color1", default_Color1)
			local default_Color2

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color2 = grayscaleToColorSequence.Palette.Default_Color2
				else
					default_Color2 = false
				end
			else
				default_Color2 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color2", default_Color2)
			local default_Color3

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color3 = grayscaleToColorSequence.Palette.Default_Color3
				else
					default_Color3 = false
				end
			else
				default_Color3 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color3", default_Color3)
			local default_Color4

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color4 = grayscaleToColorSequence.Palette.Default_Color4
				else
					default_Color4 = false
				end
			else
				default_Color4 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color4", default_Color4)
			local default_Color5

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color5 = grayscaleToColorSequence.Palette.Default_Color5
				else
					default_Color5 = false
				end
			else
				default_Color5 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color5", default_Color5)
			local default_Color6

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color6 = grayscaleToColorSequence.Palette.Default_Color6
				else
					default_Color6 = false
				end
			else
				default_Color6 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color6", default_Color6)
			local default_Color7

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color7 = grayscaleToColorSequence.Palette.Default_Color7
				else
					default_Color7 = false
				end
			else
				default_Color7 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color7", default_Color7)
			local default_Color8

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color8 = grayscaleToColorSequence.Palette.Default_Color8
				else
					default_Color8 = false
				end
			else
				default_Color8 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color8", default_Color8)
			local default_Color9

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					default_Color9 = grayscaleToColorSequence.Palette.Default_Color9
				else
					default_Color9 = false
				end
			else
				default_Color9 = grayscaleToColorSequence
			end

			applyAttribute("Default_Color9", default_Color9)

			if grayscaleToColorSequence and grayscaleToColorSequence.Type == "Palette" and grayscaleToColorSequence.Palette.Default_Color10 then
				error("update applyPaletteToInstance to support larger default numbers")
			end
		end

		if p == "Shifted" then
			local shifted_Color1

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color1 = grayscaleToColorSequence.Palette.Shifted_Color1
				else
					shifted_Color1 = false
				end
			else
				shifted_Color1 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color1", shifted_Color1)
			local shifted_Color2

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color2 = grayscaleToColorSequence.Palette.Shifted_Color2
				else
					shifted_Color2 = false
				end
			else
				shifted_Color2 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color2", shifted_Color2)
			local shifted_Color3

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color3 = grayscaleToColorSequence.Palette.Shifted_Color3
				else
					shifted_Color3 = false
				end
			else
				shifted_Color3 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color3", shifted_Color3)
			local shifted_Color4

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color4 = grayscaleToColorSequence.Palette.Shifted_Color4
				else
					shifted_Color4 = false
				end
			else
				shifted_Color4 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color4", shifted_Color4)
			local shifted_Color5

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color5 = grayscaleToColorSequence.Palette.Shifted_Color5
				else
					shifted_Color5 = false
				end
			else
				shifted_Color5 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color5", shifted_Color5)
			local shifted_Color6

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color6 = grayscaleToColorSequence.Palette.Shifted_Color6
				else
					shifted_Color6 = false
				end
			else
				shifted_Color6 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color6", shifted_Color6)
			local shifted_Color7

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color7 = grayscaleToColorSequence.Palette.Shifted_Color7
				else
					shifted_Color7 = false
				end
			else
				shifted_Color7 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color7", shifted_Color7)
			local shifted_Color8

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color8 = grayscaleToColorSequence.Palette.Shifted_Color8
				else
					shifted_Color8 = false
				end
			else
				shifted_Color8 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color8", shifted_Color8)
			local shifted_Color9

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					shifted_Color9 = grayscaleToColorSequence.Palette.Shifted_Color9
				else
					shifted_Color9 = false
				end
			else
				shifted_Color9 = grayscaleToColorSequence
			end

			applyAttribute("Shifted_Color9", shifted_Color9)

			if grayscaleToColorSequence and grayscaleToColorSequence.Type == "Palette" and grayscaleToColorSequence.Palette.Shifted_Color10 then
				error("update applyPaletteToInstance to support larger shifted numbers")
			end

			for i = 1, 9 do
				local formatted = `Shifted_Color{i}_StaticTime`
				local v12

				if grayscaleToColorSequence then
					if grayscaleToColorSequence.Type == "Palette" then
						v12 = grayscaleToColorSequence.Palette[formatted]
					else
						v12 = false
					end
				else
					v12 = grayscaleToColorSequence
				end

				applyAttribute(formatted, v12)
			end

			local grayscaleToColorStrength

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					grayscaleToColorStrength = grayscaleToColorSequence.Palette.GrayscaleToColorStrength
				else
					grayscaleToColorStrength = false
				end
			else
				grayscaleToColorStrength = grayscaleToColorSequence
			end

			applyAttribute("GrayscaleToColorStrength", grayscaleToColorStrength)

			if grayscaleToColorSequence then
				if grayscaleToColorSequence.Type == "Palette" then
					grayscaleToColorSequence = grayscaleToColorSequence.Palette.GrayscaleToColorSequence
				else
					grayscaleToColorSequence = false
				end
			end

			applyAttribute("GrayscaleToColorSequence", grayscaleToColorSequence)
		end

		extended.trace("completed applying palette")
	end
}
local v3 = FunctionCache.new(function(p, p2)
	local unwrapped = ItemConfig.match(p, p2):unwrap()

	for _, v4 in v2 do
		if v4.ItemId == unwrapped.Index.ItemId then
			return Option.some(v4)
		end
	end

	return Option.none()
end, function(p, p2)
	return (`{p}_{p2}`)
end)

function Appearance.match(value, p)
	local extended = v.extend("match", true)
	extended.info(function()
		if type(value) == "number" then
			return (`called fn: (itemId={ItemConfig.match(value):unwrap().Index.ItemId})`)
		end

		return (`called fn: (storageKey={value}, idType={p})`)
	end)
	local v4 = v3:call(value, p)
	extended.trace(function()
		return "appearance", v4:asNullable()
	end)
	return v4
end

local v4 = FunctionCache.new(function(data, data2)
	if not (data and data.R) then
		return nil
	end

	local color = Color3.new(data.R, data.G, data.B)
	local color2 = data2 and Color3.new(data2.R, data2.G, data2.B) or nil

	for _, v5 in pairs(v2) do
		if not (v5.Type == "ColorSet" and v5.Color3:ToHex() == color:ToHex()) then
			continue
		end

		if color2 and v5.FadeColor3 and v5.FadeColor3:ToHex() == color2:ToHex() or v5.FadeColor3 == nil and color2 == nil then
			return ItemConfig.match(v5.ItemId):unwrap()
		end
	end

	return nil
end, function(data, data2)
	local v6

	if type(data) == "table" then
		v6 = Color3.new(data.R, data.G, data.B):ToHex()
	else
		v6 = tostring(data)
	end

	local v7

	if type(data2) == "table" then
		v7 = Color3.new(data2.R, data2.G, data2.B):ToHex()
	else
		v7 = tostring(data2)
	end

	return (`{v6}_{v7}}`)
end)

function Appearance.getIdFromColorSetValues(p, p2)
	return v4:call(p, p2)
end

return Appearance