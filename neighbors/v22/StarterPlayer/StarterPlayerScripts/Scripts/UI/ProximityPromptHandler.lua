game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local Prompt = require(script.Prompt)
ProximityPromptService.PromptShown:Connect(function(instance, p)
	if instance.Style == Enum.ProximityPromptStyle.Default then
		return
	end

	if instance:GetAttribute("OnlyVisibleByUser") and instance:GetAttribute("OnlyVisibleByUser") ~= Players.LocalPlayer.UserId then
		instance.Enabled = false
		return
	end

	local v = Prompt.new(instance, p)
	instance.PromptHidden:Wait()
	v:Destroy()
end)