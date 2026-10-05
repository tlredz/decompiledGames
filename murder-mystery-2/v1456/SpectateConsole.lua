local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpectateService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SpectateService"))
local parent = script.Parent.Parent
parent:WaitForChild("Dock"):WaitForChild("Frame"):WaitForChild("Spectate")
local spectate = parent:WaitForChild("Spectate")
local console = game.Players.LocalPlayer.PlayerGui:WaitForChild("InputContext"):WaitForChild("Console")
local dock = console:WaitForChild("Dock")
local spectate2 = console:WaitForChild("Spectate")

local function onSpectateStarted()
	spectate.Visible = true
end

local function onSpectateCancelled()
	spectate.Visible = false
end

local function onSpectateTargetChanged(p)
	spectate.Title.PlayerName.Text = p.Name
end

local function onSpectateButtonActivated()
	SpectateService:ToggleSpectate()
end

SpectateService.SpectateStarted.Event:Connect(onSpectateStarted)
SpectateService.SpectateCancelled.Event:Connect(onSpectateCancelled)
SpectateService.SpectateTargetChanged.Event:Connect(onSpectateTargetChanged)
spectate2.NavigateRight.Pressed:Connect(function()
	SpectateService:NavigateSpectate(1)
end)
spectate2.NavigateLeft.Pressed:Connect(function()
	SpectateService:NavigateSpectate(-1)
end)
dock:WaitForChild("Spectate").Pressed:Connect(function()
	if SpectateService:SetSpectating(true) then
		spectate2.Enabled = true
		parent.Core.Dock.CloseDock:Fire()
	end
end)
spectate2:WaitForChild("Back").Pressed:Connect(function()
	SpectateService:SetSpectating(false)
	spectate2.Enabled = false
end)