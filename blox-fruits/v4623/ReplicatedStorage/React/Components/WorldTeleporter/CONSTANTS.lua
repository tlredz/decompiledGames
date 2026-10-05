local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = {
	MID_RING_LIMIT = 9,
	INNER_RING_RATIO = 0.4,
	RING_FRAME_SCALE = 0.85,
	BACKGROUND_SCALE = 0.95,
	DEFAULT_THEME = {
		Background = Color3.fromHex("#003FC8"),
		Primary = Color3.fromHex("#69AFFF"),
		Secondary = Color3.fromHex("#B269FF"),
		Text = CONSTANTS.COLOR.PALETTE.WHITE
	},
	GOLDEN_THEME = {
		Background = Color3.fromHex("#3D2400"),
		Primary = CONSTANTS.COLOR.PALETTE.GOLD_500,
		Secondary = Color3.fromHex("#FFA62B"),
		Text = CONSTANTS.COLOR.PALETTE.WHITE
	},
	PUZZLE = {
		RETURN_DURATION = 1.25,
		BACKGROUND_VALUE = 0.47,
		BACKGROUND_SATURATION_BOOST = 0.5,
		SECONDARY_HUE_SHIFT = 0.25,
		SECONDARY_MIN_SATURATION = 0,
		SECONDARY_MIN_VALUE = 0.85
	},
	TRANSITION = {
		DURATION = 0.5,
		EASING_STYLE = Enum.EasingStyle.Quad,
		EASING_DIRECTION = Enum.EasingDirection.InOut
	},
	THEME_TRANSITION = {
		DURATION = 0.5,
		EASING_STYLE = Enum.EasingStyle.Quad,
		EASING_DIRECTION = Enum.EasingDirection.InOut
	},
	FLOOD = {
		DURATION = 1.5,
		EASING_STYLE = Enum.EasingStyle.Cubic,
		EASING_DIRECTION = Enum.EasingDirection.InOut,
		MARGIN = 8
	},
	COLLAPSE = {
		DURATION = 0.7,
		EASING_STYLE = Enum.EasingStyle.Back,
		EASING_DIRECTION = Enum.EasingDirection.In,
		SPIN = 30
	},
	CELEBRATION = {
		TITLE = "FIRST SEA",
		SUBTITLE = "COMPLETED",
		HOLD_DURATION = 5,
		PULSE = {
			CIRCLE_SCALE = 0.1,
			CIRCLE_THICKNESS = 2.5,
			TITLE_SCALE = 0.06,
			SPARK_RATE = 80
		}
	},
	RING_ORDER = { "Inner", "Outer" },
	RINGS = {
		Solo = {
			Outer = {
				Id = "Outer",
				Direction = -1,
				Period = 60,
				Radius = {
					Min = 0.405,
					Max = 0.435
				},
				Diameter = {
					Min = 0.675,
					Max = 0.75
				},
				BorderOffset = UDim.new(0.02, 0),
				IslandSize = {
					Min = UDim2.fromScale(0.225, 0.225),
					Default = UDim2.fromScale(0.3, 0.3),
					Max = UDim2.fromScale(0.4, 0.4)
				}
			}
		},
		Double = {
			Inner = {
				Id = "Inner",
				Direction = 1,
				Period = 60,
				Radius = {
					Min = 0.2,
					Max = 0.35
				},
				Diameter = {
					Min = 0.325,
					Max = 0.6
				},
				BorderOffset = UDim.new(0.02, 0),
				IslandSize = {
					Min = UDim2.fromScale(0.15, 0.15),
					Default = UDim2.fromScale(0.225, 0.225),
					Max = UDim2.fromScale(0.265, 0.265)
				}
			},
			Outer = {
				Id = "Outer",
				Direction = -1,
				Period = 60,
				Radius = {
					Min = 0.435,
					Max = 0.5
				},
				Diameter = {
					Min = 0.735,
					Max = 0.85
				},
				BorderOffset = UDim.new(0.01, 0),
				IslandSize = {
					Min = UDim2.fromScale(0.15, 0.15),
					Default = UDim2.fromScale(0.25, 0.25),
					Max = UDim2.fromScale(0.265, 0.265)
				}
			}
		}
	}
}
TableUtil.deepFreeze(CONSTANTS2)
return CONSTANTS2