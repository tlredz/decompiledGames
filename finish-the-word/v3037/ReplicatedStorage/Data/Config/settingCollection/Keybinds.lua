local value = Enum.PreferredInput.KeyboardAndMouse.Value
local value2 = Enum.PreferredInput.Gamepad.Value
local _ = game.Players.LocalPlayer
return {
	PanMenuLeft = {
		DisplayName = "Pan Menu Left",
		Type = "InputCapture",
		Default = {
			[value] = "N",
			[value2] = "ButtonL2"
		},
		Action = {
			Id = "panMenu",
			Args = { -1 }
		},
		LayoutOrder = 1
	}
}