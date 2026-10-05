local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cardModifiers = workspace.Info.CardModifiers
local FrostShield = {}
FrostShield.Name = "Frost Shield"
FrostShield.Icon = "rbxassetid://115259748026175"
FrostShield.Description = "Decreases the chance of an Iced Over floor occurring."

function FrostShield.CanAppearInVote()
	local success, result = pcall(function()
		local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
		return HolidayEventConfig.ENABLED and (HolidayEventConfig.ContentFlag == "Christmas" or HolidayEventConfig.CURRENT_EVENT:match("Christmas"))
	end)
	return success and result
end

function FrostShield.ApplyCardEffects()
	if not cardModifiers:FindFirstChild(script.Name) then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = script.Name
		numberValue.Value = 0.9
		numberValue.Parent = cardModifiers
	end
end

return FrostShield