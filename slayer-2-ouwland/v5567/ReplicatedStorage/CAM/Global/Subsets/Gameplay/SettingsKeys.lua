local SettingsKeys = {
	Scope = "Account",
	RunToggle = {
		Path = "Settings/Gameplay/RunToggle",
		Default = false
	},
	StrictShiftLock = {
		Path = "Settings/Gameplay/StrictShiftLock",
		Default = false
	},
	AutoWaveSkip = {
		Path = "Settings/Gameplay/AutoWaveSkip",
		Default = false
	},
	Particles = {
		Path = "Settings/Performance/Particles",
		Default = 1
	},
	ParticlesMine = {
		Path = "Settings/Performance/ParticlesMine",
		Default = 1
	},
	ParticlesAllies = {
		Path = "Settings/Performance/ParticlesAllies",
		Default = 1
	},
	ParticlesOthers = {
		Path = "Settings/Performance/ParticlesOthers",
		Default = 1
	},
	ParticleSteps = {
		1,
		0.9,
		0.8,
		0.7,
		0.6,
		0.5,
		0.4,
		0.3,
		0.2,
		0.1,
		0
	}
}

function SettingsKeys.ParticleStep(value)
	if type(value) ~= "number" then
		return nil
	end

	for _, particleStep in SettingsKeys.ParticleSteps do
		if math.abs(particleStep - value) <= 0.01 then
			return particleStep
		end
	end

	return nil
end

SettingsKeys.Materials = {
	Path = "Settings/Performance/Materials",
	Default = true
}
SettingsKeys.Shadows = {
	Path = "Settings/Performance/Shadows",
	Default = true
}
SettingsKeys.ScreenShake = {
	Path = "Settings/Performance/ScreenShake",
	Default = 1
}
SettingsKeys.ThemeVolume = {
	Path = "Settings/Audio/Theme",
	Default = 0.5
}
SettingsKeys.AmbienceVolume = {
	Path = "Settings/Audio/Ambience",
	Default = 0.5
}
SettingsKeys.BossUI = {
	Path = "Settings/Interface/BossUI",
	Default = true
}
SettingsKeys.BossUIAttribute = "BossUIHidden"
SettingsKeys.HealthStats = {
	Path = "Settings/Interface/HealthStats",
	Default = true
}
SettingsKeys.KeybindHelper = {
	Path = "Settings/Hud/KeybindHelper",
	Default = true,
	Dense = true
}
SettingsKeys.PvpSwitch = {
	Path = "Settings/Interface/PvpSwitch",
	Default = true
}
SettingsKeys.Titles = {
	Path = "Settings/Interface/Titles",
	Default = true
}
SettingsKeys.TitleEffects = {
	Path = "Settings/Interface/TitleEffects",
	Default = true
}
SettingsKeys.ForcePlatform = {
	Path = "Settings/Misc/ForcePlatform",
	Default = ""
}
SettingsKeys.PlatformChoices = {
	{
		Value = "",
		Label = "Auto"
	},
	{
		Value = "PC",
		Label = "PC"
	},
	{
		Value = "Console",
		Label = "Console"
	},
	{
		Value = "Mobile",
		Label = "Mobile"
	}
}

function SettingsKeys.IsPlatformChoice(value)
	if type(value) ~= "string" then
		return false
	end

	for _, platformChoice in SettingsKeys.PlatformChoices do
		if platformChoice.Value == value then
			return true
		end
	end

	return false
end

SettingsKeys.MobileScaleRange = {
	Min = 0.7,
	Max = 4.5,
	Default = 1
}
SettingsKeys.MobileScale = {
	Path = "Settings/Mobile/Scale",
	Default = (SettingsKeys.MobileScaleRange.Default - SettingsKeys.MobileScaleRange.Min) / (SettingsKeys.MobileScaleRange.Max - SettingsKeys.MobileScaleRange.Min)
}
SettingsKeys.MobileDirectionalDash = {
	Path = "Settings/Mobile/DirectionalDash",
	Default = false
}
SettingsKeys.MobileSkillDragTurnsCamera = {
	Path = "Settings/Mobile/SkillDragTurnsCamera",
	Default = false
}
SettingsKeys.MobileToolbarDrag = {
	Path = "Settings/Mobile/ToolbarDrag",
	Default = true
}
SettingsKeys.PadDirectionalDash = {
	Path = "Settings/Pad/DirectionalDash",
	Default = false
}
SettingsKeys.GlobalQueue = {
	Path = "Settings/Queue/Global",
	Default = true
}
SettingsKeys.AimAssist = {
	Path = "Settings/AimAssist/Strength",
	Default = 0.25,
	Dense = true
}
SettingsKeys.AimAssistCombat = {
	Path = "Settings/AimAssist/Combat",
	Default = 0.5
}
SettingsKeys.KeybindRoot = "Settings/Keybinds"
SettingsKeys.Keybinds = {
	{
		Name = "Run",
		Label = "Run"
	},
	{
		Name = "Shiftlock",
		Label = "Shift lock",
		NoPad = true
	},
	{
		Name = "Emotes",
		Label = "Emotes",
		NoPad = true
	},
	{
		Name = "Toolbar_1st",
		Label = "Tool 1",
		NoPad = true
	},
	{
		Name = "Toolbar_2nd",
		Label = "Tool 2",
		NoPad = true
	},
	{
		Name = "Toolbar_3rd",
		Label = "Tool 3",
		NoPad = true
	},
	{
		Name = "Toolbar_4th",
		Label = "Tool 4",
		NoPad = true
	},
	{
		Name = "Toolbar_5th",
		Label = "Tool 5",
		NoPad = true
	},
	{
		Name = "Skills_1st",
		Label = "Skill 1"
	},
	{
		Name = "Skills_2nd",
		Label = "Skill 2"
	},
	{
		Name = "Skills_3rd",
		Label = "Skill 3"
	},
	{
		Name = "Skills_4th",
		Label = "Skill 4"
	},
	{
		Name = "Skills_5th",
		Label = "Skill 5"
	},
	{
		Name = "Skills_6th",
		Label = "Skill 6"
	},
	{
		Name = "Skills_7th",
		Label = "Skill 7"
	},
	{
		Name = "Skills_8th",
		Label = "Skill 8"
	},
	{
		Name = "Skills_9th",
		Label = "Skill 9"
	},
	{
		Name = "Skills_10th",
		Label = "Skill 10"
	}
}

function SettingsKeys.IsEditable(value)
	if type(value) ~= "string" then
		return false
	end

	for _, keybind in SettingsKeys.Keybinds do
		if keybind.Name == value then
			return true
		end
	end

	return false
end

SettingsKeys.PadKeybindRoot = "Settings/PadKeybinds"
SettingsKeys.PadChordSeparator = "+"
SettingsKeys.PadReserved = {
	[Enum.KeyCode.DPadUp] = true,
	[Enum.KeyCode.DPadDown] = true,
	[Enum.KeyCode.DPadLeft] = true,
	[Enum.KeyCode.ButtonL3] = true,
	[Enum.KeyCode.ButtonX] = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function padButton(p)
	if typeof(p) ~= "EnumItem" or p.EnumType ~= Enum.KeyCode then
		return false
	end

	local name = p.Name
	return string.match(name, "^Button") ~= nil or string.match(name, "^DPad") ~= nil
end

function SettingsKeys.IsPadBindable(p, p2)
	local v2 = padButton(p) -- equivalent call inferred; original call site unknown

	if not v2 or SettingsKeys.PadReserved[p] == true then
		return false
	end

	if p2 == nil then
		return true
	end

	if p2 == p then
		return false
	end

	local v3 = padButton(p2) -- equivalent call inferred; original call site unknown
	return v3 and SettingsKeys.PadReserved[p2] ~= true
end

SettingsKeys.Reserved = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
	[Enum.KeyCode.Space] = true,
	[Enum.KeyCode.Q] = true,
	[Enum.KeyCode.M] = true,
	[Enum.KeyCode.Escape] = true,
	[Enum.KeyCode.Tab] = true,
	[Enum.KeyCode.Backquote] = true,
	[Enum.KeyCode.Slash] = true,
	[Enum.KeyCode.T] = true
}
local v3 = {
	"Zero",
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine"
}
local v4 = {
	LeftShift = true,
	RightShift = true,
	LeftControl = true,
	RightControl = true,
	LeftAlt = true,
	RightAlt = true,
	Minus = true,
	Equals = true,
	LeftBracket = true,
	RightBracket = true,
	Semicolon = true,
	Quote = true,
	Comma = true,
	Period = true,
	Slash = true,
	BackSlash = true,
	Insert = true,
	Delete = true,
	Home = true,
	End = true,
	PageUp = true,
	PageDown = true,
	Up = true,
	Down = true,
	Left = true,
	Right = true
}

local function bindable(name: string)
	if #name == 1 and string.match(name, "^%a$") ~= nil or string.match(name, "^F%d+$") ~= nil then
		return true
	end

	if not (string.match(name, "^Keypad") == nil and v4[name] ~= true) then
		return true
	end

	for _, v5 in v3 do
		if name == v5 then
			return true
		end
	end

	return false
end

local v5 = {}

for _, v6 in Enum.KeyCode:GetEnumItems() do
	if bindable(v6.Name) then
		v5[v6] = true
	end
end

local function bindableKey(p)
	if typeof(p) ~= "EnumItem" or p.EnumType ~= Enum.KeyCode then
		return false
	end

	return SettingsKeys.Reserved[p] ~= true and v5[p] == true
end

function SettingsKeys.IsBindable(p, p2)
	local v6

	if typeof(p) == "EnumItem" and p.EnumType == Enum.KeyCode and SettingsKeys.Reserved[p] ~= true then
		v6 = v5[p] == true
	else
		v6 = false
	end

	if not v6 then
		return false
	end

	if p2 == nil then
		return true
	end

	if p2 == p or (typeof(p2) ~= "EnumItem" or p2.EnumType ~= Enum.KeyCode) then
		return false
	end

	return SettingsKeys.Reserved[p2] ~= true and v5[p2] == true
end

return SettingsKeys