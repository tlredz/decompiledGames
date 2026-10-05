local PALETTE = {
	GOLD_500 = Color3.fromHex("#FFD631"),
	GOLD_400 = Color3.fromHex("#FFF157"),
	GOLD_600 = Color3.fromHex("#FFC71D"),
	GOLD_450 = Color3.fromHex("#FFEF3C"),
	GOLD_700 = Color3.fromHex("#FFEF3C"),
	GOLD_DEEP = Color3.fromHex("#883D00"),
	GOLD_MUTED = Color3.fromHex("#E8D12F"),
	AMBER_500 = Color3.fromHex("#FFD900"),
	BLUE_500 = Color3.fromHex("#3E8CD0"),
	BLUE_400 = Color3.fromHex("#54ADE8"),
	BLUE_800 = Color3.fromHex("#1D4178"),
	GREEN_500 = Color3.fromHex("#30C741"),
	GREEN_400 = Color3.fromHex("#39EB4B"),
	GREEN_800 = Color3.fromHex("#1B7024"),
	RED_500 = Color3.fromHex("#FF4F4F"),
	RED_400 = Color3.fromHex("#FF7070"),
	RED_800 = Color3.fromHex("#832828"),
	GREY_TEXT = Color3.fromHex("#7A7A7A"),
	WHITE = Color3.fromHex("#FFFFFF"),
	BLACK = Color3.fromHex("#000000"),
	INK_900 = Color3.fromHex("#121415"),
	INK_850 = Color3.fromHex("#171717"),
	GREY_800 = Color3.fromHex("#303030"),
	GREY_600 = Color3.fromHex("#4F4F4F"),
	GREY_500 = Color3.fromHex("#7A7A7A"),
	GREY_400 = Color3.fromHex("#B3B3B3"),
	GREY_450 = Color3.fromHex("#999999")
}
local FAMILY = {
	HIGHWAY_GOTHIC = "rbxasset://fonts/families/HighwayGothic.json",
	SOURCE_SANS_PRO = "rbxasset://fonts/families/SourceSansPro.json"
}
return {
	COLOR = {
		PALETTE = PALETTE,
		PRIMARY = {
			BACKGROUND = PALETTE.GOLD_500,
			HIGHLIGHT = PALETTE.GOLD_400,
			BORDER = PALETTE.GOLD_DEEP,
			TINT = PALETTE.AMBER_500,
			MUTED = PALETTE.GOLD_MUTED,
			TEXT = PALETTE.WHITE,
			STROKE = PALETTE.BLACK
		},
		SECONDARY = {
			BACKGROUND = PALETTE.BLUE_500,
			HIGHLIGHT = PALETTE.BLUE_400,
			BORDER = PALETTE.BLUE_800,
			TEXT = PALETTE.WHITE,
			STROKE = PALETTE.BLACK
		},
		PURCHASE = {
			BACKGROUND = PALETTE.GREEN_500,
			HIGHLIGHT = PALETTE.GREEN_400,
			BORDER = PALETTE.GREEN_800,
			TEXT = PALETTE.WHITE,
			STROKE = PALETTE.BLACK
		},
		DANGER = {
			BACKGROUND = PALETTE.RED_500,
			HIGHLIGHT = PALETTE.RED_400,
			BORDER = PALETTE.RED_800,
			TEXT = PALETTE.WHITE,
			STROKE = PALETTE.BLACK
		},
		HEADER = {
			BACKGROUND = PALETTE.GOLD_600,
			HIGHLIGHT = PALETTE.GOLD_450,
			BORDER = PALETTE.GOLD_700,
			TEXT = PALETTE.WHITE,
			STROKE = PALETTE.BLACK
		},
		DISABLED = {
			BORDER = PALETTE.GREY_800,
			TINT = PALETTE.GREY_450,
			MUTED = PALETTE.GREY_500,
			TEXT = PALETTE.GREY_TEXT,
			STROKE = PALETTE.BLACK
		},
		PANEL = {
			BACKGROUND = PALETTE.INK_850
		},
		DIVIDER = {
			BORDER = PALETTE.GREY_600
		}
	},
	SPACING = {
		PADDING = {
			OFFSET = {
				XXS = UDim.new(0, 1),
				XS = UDim.new(0, 2),
				SM = UDim.new(0, 4),
				MD = UDim.new(0, 8),
				LG = UDim.new(0, 12),
				XL = UDim.new(0, 16),
				XXL = UDim.new(0, 24)
			},
			SCALE = {
				XXS = UDim.new(0.005, 0),
				XS = UDim.new(0.01, 0),
				SM = UDim.new(0.02, 0),
				MD = UDim.new(0.03, 0),
				LG = UDim.new(0.05, 0),
				XL = UDim.new(0.1, 0),
				XXL = UDim.new(0.15, 0)
			},
			NONE = UDim.new(0, 0)
		},
		CORNER_RADIUS = {
			SCALE = {
				XXS = UDim.new(0.01, 0),
				XS = UDim.new(0.03, 0),
				SM = UDim.new(0.05, 0),
				MD = UDim.new(0.1, 0),
				LG = UDim.new(0.2, 0),
				CIRCLE = UDim.new(0.5, 0)
			},
			NONE = UDim.new(0, 0)
		}
	},
	THICKNESS = {
		OUTLINE = {
			NONE = 0,
			HAIRLINE = 1,
			THIN = 1.5,
			REGULAR = 2,
			THICK = 3
		},
		SCROLLBAR = {
			NONE = 0,
			THIN = 4,
			REGULAR = 6,
			THICK = 8
		}
	},
	FONT = {
		FAMILY = FAMILY,
		FACE = {
			DISPLAY = Font.new(FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			DISPLAY_LIGHT = Font.new(FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Light, Enum.FontStyle.Normal),
			TITLE = Font.new(FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			BODY = Font.new(FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			BODY_BOLD = Font.new(FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			BODY_LIGHT = Font.new(FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Light, Enum.FontStyle.Normal),
			BODY_ITALIC = Font.new(FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.SemiBold, Enum.FontStyle.Italic)
		}
	},
	ALPHA = {
		OPAQUE = 0,
		SUBTLE = 0.1,
		LIGHT = 0.25,
		HALF = 0.5,
		MID = 0.6,
		HEAVY = 0.75,
		FAINT = 0.8,
		INVISIBLE = 1
	},
	LAYER = {
		TOOL_TIP = 1000,
		MODAL = 100,
		POPOVER = 23,
		OVERLAY = 5,
		RAISED_HIGH = 3,
		RAISED = 2,
		CONTENT = 1,
		BASE = 0,
		BEHIND = -1
	},
	MOTION = {
		SPRING = {
			SNAPPY = {
				DAMP = 1,
				FREQ = 15
			},
			BOUNCY = {
				DAMP = 0.75,
				FREQ = 1.25
			},
			GENTLE = {
				DAMP = 0.8,
				FREQ = 1.5
			},
			SETTLE = {
				DAMP = 1.5,
				FREQ = 1.2
			},
			DRIFT = {
				DAMP = 0.8,
				FREQ = 0.2
			}
		},
		TWEEN = {
			STANDARD = {
				STYLE = Enum.EasingStyle.Quad,
				DIRECTION = Enum.EasingDirection.Out,
				DURATION = 0.3
			},
			EMPHASIZED = {
				STYLE = Enum.EasingStyle.Quad,
				DIRECTION = Enum.EasingDirection.Out,
				DURATION = 0.3
			},
			SMOOTH = {
				STYLE = Enum.EasingStyle.Sine,
				DIRECTION = Enum.EasingDirection.InOut,
				DURATION = 0.3
			},
			LINEAR = {
				STYLE = Enum.EasingStyle.Linear,
				DIRECTION = Enum.EasingDirection.In,
				DURATION = 0.3
			}
		}
	}
}