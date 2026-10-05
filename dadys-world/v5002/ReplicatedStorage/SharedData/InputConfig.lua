return {
	Contexts = {
		Gameplay = {
			Priority = 2050,
			Sink = false,
			Enabled = true
		},
		Menu = {
			Priority = 2100,
			Sink = true,
			Enabled = false
		},
		MenuNav = {
			Priority = 2120,
			Sink = true,
			Enabled = false,
			ConflictGroup = "Overlay"
		},
		Debug = {
			Priority = 1,
			Sink = false,
			Enabled = true
		},
		Floor0Shop = {
			Priority = 2060,
			Sink = false,
			Enabled = false
		},
		CardVote = {
			Priority = 2080,
			Sink = true,
			Enabled = false
		},
		Settings = {
			Priority = 2130,
			Sink = true,
			Enabled = false
		},
		StickerWheel = {
			Priority = 2090,
			Sink = true,
			Enabled = false,
			ConflictGroup = "Overlay"
		},
		PopupNav = {
			Priority = 2110,
			Sink = true,
			Enabled = false,
			ConflictGroup = "Overlay"
		},
		Capture = {
			Priority = 2200,
			Sink = true,
			Enabled = false
		}
	},
	Actions = {
		DebugPing = {
			Context = "Debug",
			Type = "Bool",
			DisplayName = "Debug Ping",
			Category = "Debug",
			Remappable = false,
			Bindings = {
				Keyboard = { Enum.KeyCode.P }
			}
		},
		Sprint = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Sprint",
			Category = "Movement",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.LeftShift },
				Gamepad = { Enum.KeyCode.ButtonR1 },
				TouchButton = "MobileRun"
			},
			FixedBindings = {
				Gamepad = { Enum.KeyCode.ButtonL3 }
			}
		},
		Interact = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Interact",
			Category = "Gameplay",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.E },
				Gamepad = { Enum.KeyCode.ButtonX }
			}
		},
		GeneratorStop = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Stop Extracting",
			Category = "Gameplay",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.E },
				Gamepad = { Enum.KeyCode.ButtonB }
			}
		},
		SkillCheckTap = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Skill Check",
			Category = "Gameplay",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.Space },
				Gamepad = { Enum.KeyCode.ButtonA }
			}
		},
		UseAbility = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Use Ability",
			Category = "Abilities",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.F },
				Gamepad = { Enum.KeyCode.ButtonL1 }
			}
		},
		OpenStats = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Stats Panel",
			Category = "UI",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.T },
				Gamepad = { Enum.KeyCode.ButtonY }
			}
		},
		ViewProfile = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "View Profile",
			Category = "UI",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.Space },
				Gamepad = { Enum.KeyCode.ButtonL1 }
			}
		},
		Item1 = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Use Item 1",
			Category = "Items",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.One },
				Gamepad = { Enum.KeyCode.DPadLeft }
			}
		},
		Item2 = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Use Item 2",
			Category = "Items",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.Two },
				Gamepad = { Enum.KeyCode.DPadUp }
			}
		},
		Item3 = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Use Item 3",
			Category = "Items",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.Three },
				Gamepad = { Enum.KeyCode.DPadRight }
			}
		},
		Item4 = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Use Item 4",
			Category = "Items",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.Four },
				Gamepad = { Enum.KeyCode.DPadDown }
			}
		},
		StickerMenu = {
			Context = "Gameplay",
			Type = "Bool",
			DisplayName = "Sticker Wheel",
			Category = "Stickers",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.Q },
				Gamepad = { Enum.KeyCode.ButtonL2 }
			}
		},
		StickerPageLeft = {
			Context = "StickerWheel",
			Type = "Bool",
			DisplayName = "Stickers: Page Left",
			Category = "Stickers",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.Z },
				Gamepad = { Enum.KeyCode.DPadLeft }
			}
		},
		StickerPageRight = {
			Context = "StickerWheel",
			Type = "Bool",
			DisplayName = "Stickers: Page Right",
			Category = "Stickers",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.X },
				Gamepad = { Enum.KeyCode.DPadRight }
			}
		},
		StickerInventory = {
			Context = "StickerWheel",
			Type = "Bool",
			DisplayName = "Sticker Inventory",
			Category = "Stickers",
			Remappable = true,
			Bindings = {
				Keyboard = { Enum.KeyCode.C },
				Gamepad = { Enum.KeyCode.ButtonY }
			}
		},
		MenuConfirm = {
			Context = "MenuNav",
			Type = "Bool",
			DisplayName = "Menu: Confirm",
			Category = "UI",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonA }
			}
		},
		MenuBack = {
			Context = "MenuNav",
			Type = "Bool",
			DisplayName = "Menu: Back / Close",
			Category = "UI",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonB }
			}
		},
		PopupClose = {
			Context = "PopupNav",
			Type = "Bool",
			DisplayName = "Close Popup",
			Category = "UI",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonB }
			}
		},
		SettingsTabLeft = {
			Context = "Settings",
			Type = "Bool",
			DisplayName = "Settings: Tab Left",
			Category = "UI",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonL1 }
			}
		},
		SettingsTabRight = {
			Context = "Settings",
			Type = "Bool",
			DisplayName = "Settings: Tab Right",
			Category = "UI",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonR1 }
			}
		},
		Vote1 = {
			Context = "CardVote",
			Type = "Bool",
			DisplayName = "Vote: Card 1",
			Category = "Minigame",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonX }
			}
		},
		Vote2 = {
			Context = "CardVote",
			Type = "Bool",
			DisplayName = "Vote: Card 2",
			Category = "Minigame",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonA }
			}
		},
		Vote3 = {
			Context = "CardVote",
			Type = "Bool",
			DisplayName = "Vote: Card 3",
			Category = "Minigame",
			Remappable = false,
			Bindings = {
				Gamepad = { Enum.KeyCode.ButtonB }
			}
		},
		ShopPurchase = {
			Context = "Floor0Shop",
			Type = "Bool",
			DisplayName = "Purchase (Shop)",
			Category = "Minigame",
			Remappable = false,
			Bindings = {
				Keyboard = { Enum.KeyCode.E },
				Gamepad = { Enum.KeyCode.ButtonX }
			}
		}
	},
	ExclusiveSets = {
		Stickers = {
			"StickerMenu",
			"StickerInventory",
			"StickerPageLeft",
			"StickerPageRight",
			"ViewProfile"
		}
	},
	ReservedKeys = {
		"W",
		"A",
		"S",
		"D",
		"Up",
		"Down",
		"Left",
		"Right",
		"Escape",
		"Tab",
		"Unknown",
		"Slash",
		"BackSlash",
		"I",
		"O",
		"F1",
		"F2",
		"F3",
		"F4",
		"F5",
		"F6",
		"F7",
		"F8",
		"F9",
		"F10",
		"F11",
		"F12",
		"Print",
		"LeftAlt",
		"RightAlt",
		"ButtonR2",
		"Thumbstick1",
		"Thumbstick2",
		"ButtonR3",
		"ButtonL3",
		"ButtonStart",
		"ButtonSelect"
	}
}