local BuildInfo = require(game.ReplicatedStorage.BuildInfo)

if BuildInfo.IS_PUBLISHED then
	return {}
end

local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
screenGui.ResetOnSpawn = false
local frame = Instance.new("Frame", screenGui)
frame.Visible = false
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.P then
		frame.Visible = true

		while input.UserInputState ~= Enum.UserInputState.End do
			task.wait()
		end

		frame.Visible = false
	end
end)
return {}