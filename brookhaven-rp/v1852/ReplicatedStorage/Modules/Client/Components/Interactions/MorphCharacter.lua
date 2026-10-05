local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "MorphCharacter"
})
local v2 = {
	[Enum.KeyCode.Five] = "Regular",
	[Enum.KeyCode.Six] = "Happy",
	[Enum.KeyCode.Seven] = "Sad",
	[Enum.KeyCode.Eight] = "Surprise",
	[Enum.KeyCode.Nine] = "Annoyed",
	[Enum.KeyCode.Zero] = "Angry"
}
local flag = false

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if flag then
		return
	end

	flag = true
	self._didConnectInput = true
	self._Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		local v3 = v2[input.KeyCode]

		if not v3 then
			return
		end

		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		local morphCharacter = character:FindFirstChild("MorphCharacter")

		if morphCharacter and morphCharacter:IsA("Model") then
			Remotes.fireServer("MorphCharacterSetEmotion", v3)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()

	if self._didConnectInput then
		flag = false
	end
end

return v