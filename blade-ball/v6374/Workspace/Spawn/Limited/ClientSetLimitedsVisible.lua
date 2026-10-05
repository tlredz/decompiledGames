local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not ReplicatedStorage.FeaturesToggle.LimitedSwords.Value then
	return
end

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local ClientSetLimitedsVisible = require(ReplicatedStorage.Shared.LobbyLimitedSwords.ClientSetLimitedsVisible)
ClientSetLimitedsVisible(script.Parent)