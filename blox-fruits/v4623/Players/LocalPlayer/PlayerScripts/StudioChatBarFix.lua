local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

if RunService:IsStudio() then
	local chatScript = localPlayer:WaitForChild("PlayerScripts"):WaitForChild("ChatScript", 300)
	local chatMain = chatScript and chatScript:WaitForChild("ChatMain", 300)

	if chatMain then
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or UserInputService:GetFocusedTextBox() ~= nil then
				return
			end

			if input.KeyCode == Enum.KeyCode.Slash then
				pcall(function()
					local module = require(chatMain)
					module:SpecialKeyPressed(Enum.SpecialKey.ChatHotkey)
				end)
			end
		end)
	end
end