local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsKeys = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("SettingsKeys"))
local visibility = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Components"):WaitForChild("Layout"):WaitForChild("Visibility")
local Sets = {
	[visibility.HUD] = {
		"MenuOpened",
		"MapOpened",
		"SummonCamera",
		"Cutscene",
		"Dialogue",
		"Training",
		"MinigameVictory",
		"FishingBite"
	},
	[visibility.Menu] = {
		"MenuClosed",
		"SummonCamera",
		"Cutscene",
		"Dialogue",
		"Training",
		"MinigameVictory",
		"FishingBite"
	},
	[visibility.Prompts] = {
		"SummonCamera",
		"Cutscene",
		"Dialogue",
		"Training",
		"MinigameVictory",
		"FishingBite"
	},
	[visibility.Markers.Default] = {
		"Training",
		"Dialogue",
		"Cutscene",
		"MenuOpened",
		"MapOpened",
		"MuzanLair",
		"MinigameVictory",
		"FishingBite"
	},
	[visibility.Overhead.All] = {
		"SummonCamera",
		"Cutscene",
		"CameralessCutscene",
		"Dialogue",
		"Training",
		"MinigameVictory",
		"FishingBite"
	},
	[Enum.CoreGuiType.Chat.Name] = {
		"MenuOpened",
		"MapOpened",
		"SummonCamera",
		"Cutscene",
		"Dialogue",
		"Training",
		"LoadingScreen",
		"FishingBite",
		"Guided"
	},
	[Enum.CoreGuiType.PlayerList.Name] = {
		"Skill Tree",
		"LoadingScreen",
		"FishingBite",
		"Cutscene",
		"Guided"
	},
	[visibility.BossUI] = {
		SettingsKeys.BossUIAttribute,
		"MenuOpened",
		"MapOpened",
		"SummonCamera",
		"Cutscene",
		"MinigameVictory",
		"TrialEnding"
	},
	[script.Billboards] = {
		"SummonCamera",
		"Cutscene",
		"Dialogue",
		"Training",
		"MinigameVictory",
		"FishingBite"
	}
}
local v = visibility:FindFirstChild("Minimap")

if v == nil then
	v = Instance.new("BoolValue")
	v.Name = "Minimap"
	v.Value = true
	v.Parent = visibility
end

Sets[v] = {
	"MenuOpened",
	"SummonCamera",
	"Cutscene",
	"Dialogue",
	"Training",
	"MuzanLair",
	"MinigameVictory",
	"FishingBite"
}
local v2 = visibility:FindFirstChild("Compass")

if v2 == nil then
	v2 = Instance.new("BoolValue")
	v2.Name = "Compass"
	v2.Value = true
	v2.Parent = visibility
end

Sets[v2] = { "MapOpened" }
local parkourMarkers = visibility.Markers:FindFirstChild("ParkourMarkers")

if parkourMarkers ~= nil then
	Sets[parkourMarkers] = { "MenuOpened", "Cutscene", "Dialogue" }
end

local v3 = visibility.Markers:FindFirstChild("AllMarkers")

if v3 == nil then
	v3 = Instance.new("BoolValue")
	v3.Name = "AllMarkers"
	v3.Value = true
	v3.Parent = visibility.Markers
end

Sets[v3] = { "MapOpened", "Guided" }
local v4 = visibility:FindFirstChild("Controls")

if v4 == nil then
	v4 = Instance.new("BoolValue")
	v4.Name = "Controls"
	v4.Value = true
	v4.Parent = visibility
end

Sets[v4] = {
	"MenuOpened",
	"MapOpened",
	"SummonCamera",
	"Cutscene",
	"Dialogue",
	"MinigameVictory",
	"FishingBite"
}
return Sets