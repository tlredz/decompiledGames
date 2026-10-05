local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
require(ReplicatedStorage.Modules.Server)
return {
	{
		SettingName = "HideGoldNametag",
		Display = "Hide Gold Nametag",
		Type = "Toggle"
	}
}