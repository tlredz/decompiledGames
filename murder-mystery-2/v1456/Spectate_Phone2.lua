local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectateService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SpectateService"))
local lobby = script.Parent.Parent:WaitForChild("Lobby")
local spectate = lobby:WaitForChild("Dock"):WaitForChild("Spectate")
local spectate2 = lobby:WaitForChild("Screens"):WaitForChild("Spectate")

local function onSpectateStarted()
	spectate2.Visible = true
end

local function onSpectateCancelled()
	spectate2.Visible = false
end

local function onSpectateTargetChanged(p)
	spectate2.PlayerName.Text = p.Name
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
_G.CancelSpectate = SpectateService.CancelSpectate