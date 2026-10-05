local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectateService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SpectateService"))
local game2 = script.Parent.Parent:WaitForChild("Game")
local spectate = game2:WaitForChild("Dock"):WaitForChild("Spectate")
local spectate2 = game2:WaitForChild("Spectate")

local function onSpectateStarted()
	spectate2.Visible = true
end

local function onSpectateCancelled()
	spectate2.Visible = false
end

local function onSpectateTargetChanged(p)
	spectate2.CodeImage.PlayerName.Text = p.Name
end

local function onSpectateButtonActivated()
	SpectateService:ToggleSpectate()
end

SpectateService.SpectateStarted.Event:Connect(onSpectateStarted)
SpectateService.SpectateCancelled.Event:Connect(onSpectateCancelled)
SpectateService.SpectateTargetChanged.Event:Connect(onSpectateTargetChanged)
spectate2.Right.Activated:Connect(function()
	SpectateService:NavigateSpectate(1)
end)
spectate2.Left.Activated:Connect(function()
	SpectateService:NavigateSpectate(-1)
end)
spectate.Activated:Connect(onSpectateButtonActivated)