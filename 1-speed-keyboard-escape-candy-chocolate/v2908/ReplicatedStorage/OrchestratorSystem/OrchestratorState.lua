local options = { "Constant" }
local OrchestratorState = {
	ActiveSequence = nil,
	RuntimeActors = {},
	DuplicateRootTagsWarned = {},
	StripDefinitions = {},
	TimePosition = 0,
	PreviousTimePosition = 0,
	LastUpdateTime = 0,
	UsesConcertClock = false,
	IsPlaying = false
}

for _, v2 in Enum.EasingStyle:GetEnumItems() do
	table.insert(options, v2)
end

OrchestratorState.DefaultKeyframeEditableProperties = {
	{
		Path = { "EasingStyle" },
		DisplayName = "Easing Style",
		ValueType = "enum",
		Default = Enum.EasingStyle.Linear,
		Options = options
	},
	{
		Path = { "EasingDirection" },
		DisplayName = "Easing Direction",
		ValueType = "enum",
		Default = Enum.EasingDirection.InOut,
		Options = Enum.EasingDirection:GetEnumItems()
	}
}
return OrchestratorState