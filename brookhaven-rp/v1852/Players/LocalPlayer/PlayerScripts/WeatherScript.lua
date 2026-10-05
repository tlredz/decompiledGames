local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera;
(localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
local game8Settings = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Player8Handler"):WaitForChild("Game8Settings")
local module = require(game8Settings)
local weatherClients = module.WeatherClients
local Rain = require(script.Rain)
local rainOnOff = script:WaitForChild("RainOnOff")
local thunderclap1600 = script:WaitForChild("thunderclap1600")
weatherClients.OnClientEvent:connect(function(p)
	if p == "TurnOffRain" then
		if rainOnOff.Value == true then
			rainOnOff.Value = false
			Rain:Disable()
		end
	elseif p == "TurnOnRain" then
		if rainOnOff.Value == false then
			rainOnOff.Value = true

			if currentCamera:FindFirstChild("__RainEmitter") then
				local rainStraight = currentCamera.__RainEmitter:FindFirstChild("RainStraight")
				rainStraight.Transparency = NumberSequence.new(0.7)
				rainStraight.Speed = NumberRange.new(20)
			end

			Rain:Enable()
		end
	elseif p == "TurnOnSnow" then
		if rainOnOff.Value == false then
			rainOnOff.Value = true

			if currentCamera:FindFirstChild("__RainEmitter") then
				local snowStraight = currentCamera.__RainEmitter:FindFirstChild("SnowStraight")
				snowStraight.Enabled = true
			end

			Rain:EnableSnow()
		end
	elseif p == "TurnOffSnow" then
		if rainOnOff.Value == true then
			rainOnOff.Value = false
			Rain:Disable()
		end
	elseif p == "Thunder" then
		thunderclap1600:Play()
	end
end)