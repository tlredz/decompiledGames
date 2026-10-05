local services = game.ReplicatedStorage:WaitForChild("Services")
require(services:WaitForChild("Tweens"))
script:WaitForChild("GameMessage")
local parent = script.Parent
local gameMessage = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable"):WaitForChild("GameMessage")
local _ = parent.Parent
local SFX = game.SoundService:WaitForChild("SFX")
local Handler = require(parent:WaitForChild("Handler"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local hasFinishedTutorial = localPlayer:WaitForChild("SavedData"):WaitForChild("HasFinishedTutorial")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameSettings = require(ReplicatedStorage:WaitForChild("GameSettings"))
gameMessage.OnClientEvent:Connect(function(p, p2, p3, p4)
	if localPlayer:GetAttribute("GameLoaded") ~= true or hasFinishedTutorial.Value ~= true and not GameSettings.Enabled("SKIPTUTORIALONSTUDIO") then
		return
	end

	SFX.UI.Notification:Play()
	Handler:AddMessage(p, p2, p3, nil, p4)
end)