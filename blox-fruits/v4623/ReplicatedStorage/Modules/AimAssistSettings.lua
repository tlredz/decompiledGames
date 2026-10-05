local AimAssistSettings = {
	DefaultProfile = "PC",
	ReferenceViewportHeight = 1080,
	TargetTag = "AimAssistTarget",
	OwnerAttribute = "AimAssistOwner",
	Profiles = {
		PC = {
			Enabled = true,
			MaxDistance = 600,
			AssistRadiusPixels = 40,
			InnerRadiusPixels = 5
		}
	}
}
AimAssistSettings.Profiles.Mobile = AimAssistSettings.Profiles.PC
AimAssistSettings.Profiles.Console = AimAssistSettings.Profiles.PC
return AimAssistSettings