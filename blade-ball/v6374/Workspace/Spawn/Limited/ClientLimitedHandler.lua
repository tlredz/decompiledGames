local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not ReplicatedStorage.FeaturesToggle.LimitedSwords.Value then
	return
end

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local ClientLimitedHandler = require(ReplicatedStorage.Shared.LobbyLimitedSwords.ClientLimitedHandler)
ClientLimitedHandler(script.Parent)