local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playWaveEvents = ReplicatedStorage:WaitForChild("PlayWaveEvents", 30)
local playWaveClientReady = playWaveEvents and playWaveEvents:WaitForChild("PlayWaveClientReady", 30)

if playWaveClientReady then
	playWaveClientReady:FireServer()
else
	warn("[PlayWave] PlayWaveClientReady event not found.")
end

local playWaveBenefit = playWaveEvents and playWaveEvents:WaitForChild("PlayWaveBenefit", 30)

if playWaveBenefit then
	playWaveBenefit.OnClientEvent:Connect(function(p) end)
end