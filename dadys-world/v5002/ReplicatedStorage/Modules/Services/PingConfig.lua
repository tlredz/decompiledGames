return {
	COOLDOWN = 5,
	DEV_COOLDOWN = 1,
	DURATION = 8,
	FADE_TIME = 1.5,
	CAST_RADIUS = 3,
	CAST_DISTANCE = 500,
	MARKER_HEIGHT_OFFSET = 4,
	PULSE_SPEED = 2,
	MAX_PINGS_PER_PLAYER = 3,
	Types = {
		Location = {
			label = "HERE",
			color = Color3.fromRGB(255, 255, 255),
			icon = "rbxassetid://6031091004",
			priority = 1
		},
		Generator = {
			label = "GENERATOR",
			color = Color3.fromRGB(255, 215, 0),
			icon = "rbxassetid://6031302931",
			priority = 3
		},
		Item = {
			label = "ITEM",
			color = Color3.fromRGB(144, 238, 144),
			icon = "rbxassetid://6031280882",
			priority = 2
		},
		Tape = {
			label = "TAPE",
			color = Color3.fromRGB(255, 215, 0),
			icon = "rbxassetid://6031280882",
			priority = 3
		},
		Twisted = {
			label = "DANGER!",
			color = Color3.fromRGB(255, 50, 50),
			icon = "rbxassetid://6031094667",
			priority = 5
		},
		NeedHealing = {
			label = "NEED HEALING!",
			color = Color3.fromRGB(255, 100, 150),
			icon = "rbxassetid://6031280882",
			priority = 4
		},
		Teammate = {
			label = "",
			color = Color3.fromRGB(100, 180, 255),
			icon = "rbxassetid://6031260882",
			priority = 2
		},
		Exit = {
			label = "EXIT",
			color = Color3.fromRGB(180, 100, 255),
			icon = "rbxassetid://6031225809",
			priority = 4
		}
	},
	Keybinds = {
		Mouse = Enum.UserInputType.MouseButton3,
		Gamepad = Enum.KeyCode.ButtonX
	},
	Sounds = {
		PingCreate = "rbxassetid://9119713951",
		PingReceive = "rbxassetid://9119713951"
	}
}