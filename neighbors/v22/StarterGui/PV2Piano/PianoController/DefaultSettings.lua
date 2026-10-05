local DefaultSettings = {
	MIN_TRANSPOSITION = -24,
	MAX_TRANSPOSITION = 24,
	MIN_VOLUME = 0.1,
	MAX_VOLUME = 2,
	MIN_VELOCITY = 0.1,
	MAX_VELOCITY = 2,
	DEFAULT_SOUNDFONT = 1,
	DEFAULT_VELOCITY_CURVES = {
		function(p)
			return (math.clamp(0.0254 + 0.095 * p - 0.00106 * (p * p), 0.1, 2))
		end,
		function(p)
			return (math.clamp(math.log(p) * 0.552 + 0.102, 0.1, 2))
		end,
		function(p)
			return (math.clamp(math.exp(0.091 * p) * 0.111, 0.1, 2))
		end,
		function(p)
			return (math.clamp(math.tanh(2 * (p / 16) - 2) + 1, 0.1, 2))
		end
	},
	DEFAULT_KEYBINDS = {
		Sustain = Enum.KeyCode.Space,
		ToggleSustain = Enum.KeyCode.Quote,
		ToggleShiftLock = Enum.KeyCode.Return,
		TranspositionUp = Enum.KeyCode.Up,
		TranspositionDown = Enum.KeyCode.Down,
		VolumeUp = Enum.KeyCode.Right,
		VolumeDown = Enum.KeyCode.Left,
		ChangeCamera = Enum.KeyCode.BackSlash,
		Exit = Enum.KeyCode.Backspace
	},
	DEFAULT_PIANO_SETTINGS = {
		MIDI88 = true,
		MIDIVelocity = true,
		MIDICurve = 1,
		EnableSustainHotkey = true,
		EnableShiftLockHotkey = true,
		ShowNoteLabels = true
	},
	DEFAULT_GAME_SETTINGS = {
		MaxSounds = 35,
		DelayNoteEvents = true,
		EventDelay = 500,
		PlayServerOrigin = true,
		OriginInverseMultiplier = 1,
		OriginSoundMultiplier = 8,
		PlayClientSounds = true,
		PlayServerSounds = true,
		PlayClientEffects = true,
		PlayServerEffects = true,
		HidePetsAtPiano = true,
		PreloadSoundFontsOnJoin = false,
		DisableCapturesHotkey = true
	},
	DEFAULT_MOBILE_PIANO_SETTINGS = {
		DoubleLayout = false,
		WhiteKeyWidth = false,
		WhiteKeyHeight = false,
		BlackKeyWidth = false,
		BlackKeyHeight = false
	},
	SETTINGS_CLAMP_VALUES = {
		MaxSounds = {
			Min = 1,
			Max = 100
		},
		MIDICurve = {
			Min = 1,
			Max = 4
		},
		EventDelay = {
			Min = 0,
			Max = 5000
		},
		OriginSoundMultiplier = {
			Min = 0.01,
			Max = 25
		},
		OriginInverseMultiplier = {
			Min = 0.01,
			Max = 25
		}
	}
}

for _, v in pairs(DefaultSettings) do
	if type(v) == "table" then
		table.freeze(v)
	end
end

table.freeze(DefaultSettings)
return DefaultSettings