local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
require(ReplicatedStorage.Packages.Observers)

if not ServerInfo.isTestGame() or ServerInfo.isMedalServer() then
	return function() end
end

local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local inputBeganConnection = require(ReplicatedStorage3:WaitForChild("UserInputService")).InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and script:GetAttribute(input.KeyCode.Name) then
		GuiHandler:Open(script:GetAttribute(input.KeyCode.Name))
	end
end)
return function()
	inputBeganConnection:Disconnect()
	inputBeganConnection = nil
end