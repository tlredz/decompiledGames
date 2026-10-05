local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("StarterPlayer")
return {
	PRINT_NAME = "[Chests]",
	STREAM_TAG = "_ChestTagged",
	UPDATE_ATTRIBUTE = "IsDisabled",
	FOLDER_NAME = "ChestModels",
	FOLDER_LOCATION = Workspace,
	MODELS_LOCATION = ReplicatedStorage:WaitForChild("Assets"),
	SETTINGS_LOCATION = ReplicatedStorage,
	STREAM = {
		INTERVAL = 2,
		BATCH_SIZE = 12,
		DISTANCE = 1500
	}
}